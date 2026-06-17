import AVFoundation
import Foundation

/// Owns the AVAudioEngine: captures mic audio as 16 kHz mono PCM-S16LE for STT
/// and plays back 24 kHz PCM-S16LE TTS audio. Half-duplex (tap-to-talk) for the prototype.
final class AudioSessionController {
  enum AudioError: Error { case converterUnavailable, formatUnavailable }

  private let engine = AVAudioEngine()
  private let playerNode = AVAudioPlayerNode()

  /// 16 kHz mono Int16 interleaved — the STT input format.
  private let captureFormat = AVAudioFormat(
    commonFormat: .pcmFormatInt16,
    sampleRate: CartesiaConfig.inputSampleRate,
    channels: 1,
    interleaved: true
  )!

  /// 24 kHz mono Float32 — the playback rendering format.
  private let playbackFormat = AVAudioFormat(
    commonFormat: .pcmFormatFloat32,
    sampleRate: CartesiaConfig.outputSampleRate,
    channels: 1,
    interleaved: false
  )!

  private var captureConverter: AVAudioConverter?
  private var isEngineRunning = false

  /// Called with each captured 16 kHz Int16 chunk while listening.
  var onCapture: ((Data) -> Void)?
  /// Approximate input level (0...1) for UI feedback.
  var onInputLevel: ((Float) -> Void)?

  // MARK: - Session

  func requestPermission() async -> Bool {
    await withCheckedContinuation { continuation in
      AVAudioApplication.requestRecordPermission { granted in
        continuation.resume(returning: granted)
      }
    }
  }

  private func configureSession() throws {
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(
      .playAndRecord,
      mode: .voiceChat,
      options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP]
    )
    try session.setActive(true, options: [])
  }

  private func startEngineIfNeeded() throws {
    guard isEngineRunning == false else { return }
    try configureSession()

    if engine.attachedNodes.contains(playerNode) == false {
      engine.attach(playerNode)
      engine.connect(playerNode, to: engine.mainMixerNode, format: playbackFormat)
    }

    engine.prepare()
    try engine.start()
    isEngineRunning = true
  }

  // MARK: - Capture (mic -> STT)

  func startCapturing() throws {
    try startEngineIfNeeded()

    let input = engine.inputNode
    let hardwareFormat = input.outputFormat(forBus: 0)

    // Guard against an invalid input format (e.g. Simulator with no microphone),
    // which would make installTap(onBus:) raise an Obj-C exception and crash.
    guard hardwareFormat.sampleRate > 0, hardwareFormat.channelCount > 0 else {
      throw AudioError.formatUnavailable
    }

    guard let converter = AVAudioConverter(from: hardwareFormat, to: captureFormat) else {
      throw AudioError.converterUnavailable
    }
    captureConverter = converter

    input.removeTap(onBus: 0)
    input.installTap(onBus: 0, bufferSize: 4_096, format: hardwareFormat) { [weak self] buffer, _ in
      self?.handleCaptured(buffer: buffer, hardwareFormat: hardwareFormat)
    }
  }

  func stopCapturing() {
    engine.inputNode.removeTap(onBus: 0)
    captureConverter = nil
  }

  private func handleCaptured(buffer: AVAudioPCMBuffer, hardwareFormat: AVAudioFormat) {
    guard let converter = captureConverter else { return }

    let ratio = captureFormat.sampleRate / hardwareFormat.sampleRate
    let capacity = AVAudioFrameCount(Double(buffer.frameLength) * ratio + 1_024)
    guard let outBuffer = AVAudioPCMBuffer(pcmFormat: captureFormat, frameCapacity: capacity) else {
      return
    }

    var consumed = false
    let status = converter.convert(to: outBuffer, error: nil) { _, outStatus in
      if consumed {
        outStatus.pointee = .noDataNow
        return nil
      }
      consumed = true
      outStatus.pointee = .haveData
      return buffer
    }

    guard status == .haveData || status == .inputRanDry else { return }
    guard let channelData = outBuffer.int16ChannelData, outBuffer.frameLength > 0 else { return }

    let frameCount = Int(outBuffer.frameLength)
    let data = Data(bytes: channelData[0], count: frameCount * MemoryLayout<Int16>.size)
    onCapture?(data)
    onInputLevel?(Self.rmsLevel(channelData[0], frameCount: frameCount))
  }

  private static func rmsLevel(_ samples: UnsafeMutablePointer<Int16>, frameCount: Int) -> Float {
    guard frameCount > 0 else { return 0 }
    var sum: Float = 0
    for i in 0..<frameCount {
      let normalized = Float(samples[i]) / Float(Int16.max)
      sum += normalized * normalized
    }
    let rms = (sum / Float(frameCount)).squareRoot()
    return min(1, rms * 6)
  }

  // MARK: - Playback (TTS -> speaker)

  func startPlayback() throws {
    try startEngineIfNeeded()
    if playerNode.isPlaying == false {
      playerNode.play()
    }
  }

  /// Schedules one chunk of 24 kHz Int16 PCM TTS audio for playback.
  func enqueueTTS(pcmS16LE data: Data) {
    guard data.isEmpty == false else { return }
    let sampleCount = data.count / MemoryLayout<Int16>.size
    guard sampleCount > 0,
          let buffer = AVAudioPCMBuffer(pcmFormat: playbackFormat, frameCapacity: AVAudioFrameCount(sampleCount)),
          let floatChannel = buffer.floatChannelData
    else { return }

    buffer.frameLength = AVAudioFrameCount(sampleCount)
    data.withUnsafeBytes { rawBuffer in
      let int16Pointer = rawBuffer.bindMemory(to: Int16.self)
      for i in 0..<sampleCount {
        floatChannel[0][i] = Float(int16Pointer[i]) / Float(Int16.max)
      }
    }

    playerNode.scheduleBuffer(buffer, completionHandler: nil)
  }

  func stopPlayback() {
    playerNode.stop()
  }

  // MARK: - Teardown

  func teardown() {
    stopCapturing()
    playerNode.stop()
    engine.stop()
    isEngineRunning = false
    try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
  }
}

import AVFoundation
import Foundation

/// Owns one persistent full-duplex audio graph for a voice session.
///
/// Why persistent + single-category: the previous design started the engine under
/// `.playback` (output-only) for the greeting, then switched the session to
/// `.playAndRecord` for listening WITHOUT rebuilding the engine. That leaves
/// `inputNode` wired to the old output-only route, so the mic tap silently captures
/// nothing — Sonia is heard, but the user can't be. Apple's guidance: configure
/// `.playAndRecord` once, start the engine once, and keep it up for the whole call.
///
/// Voice-Processing I/O (`setVoiceProcessingEnabled`) adds hardware echo cancellation
/// and AGC, so the mic ignores the TTS coming out of the speaker — what lets the user
/// talk naturally during/right after Sonia without feedback.
final class AudioSessionController {
  enum AudioError: Error { case engineUnavailable, formatUnavailable, converterUnavailable }

  private let engine = AVAudioEngine()
  private let playerNode = AVAudioPlayerNode()

  /// 16 kHz mono Int16 — the STT input format Cartesia expects.
  private let captureFormat = AVAudioFormat(
    commonFormat: .pcmFormatInt16,
    sampleRate: CartesiaConfig.inputSampleRate,
    channels: 1,
    interleaved: true
  )!

  /// 24 kHz mono Float32 — the TTS playback rendering format.
  private let playbackFormat = AVAudioFormat(
    commonFormat: .pcmFormatFloat32,
    sampleRate: CartesiaConfig.outputSampleRate,
    channels: 1,
    interleaved: false
  )!

  private var captureConverter: AVAudioConverter?
  private var isStarted = false
  private var isCapturing = false

  /// Total audio (seconds) scheduled for playback since the last `resetPlaybackClock()`.
  /// The TTS WebSocket delivers audio faster than realtime, so the session uses this to
  /// stay in "speaking" until playback actually finishes (keeps captions in sync).
  private(set) var scheduledPlaybackSeconds: Double = 0

  /// Called with each captured 16 kHz Int16 chunk while listening.
  var onCapture: ((Data) -> Void)?
  /// Approximate input level (0...1) for UI feedback + silence detection.
  var onInputLevel: ((Float) -> Void)?

  // MARK: - Permission

  func requestPermission() async -> Bool {
    await withCheckedContinuation { continuation in
      AVAudioApplication.requestRecordPermission { granted in
        continuation.resume(returning: granted)
      }
    }
  }

  // MARK: - Lifecycle

  /// Brings up the persistent full-duplex graph once for the whole call. Safe to call
  /// repeatedly — it no-ops once started.
  ///
  /// `defaultToSpeaker` (true) routes to the loudspeaker — the companion "speakerphone"
  /// session. Pass `false` for an earpiece/receiver call (the guided-journal "to your ear"
  /// flow); without `.defaultToSpeaker` in the category, `overrideOutputAudioPort(.none)`
  /// resolves to the receiver.
  func start(defaultToSpeaker: Bool = true) throws {
    guard isStarted == false else { return }

    let session = AVAudioSession.sharedInstance()
    // `.allowBluetooth` was renamed to `.allowBluetoothHFP` in iOS 26; reference only the
    // new name (gated) so there's no deprecation warning and BT headset mic still works.
    var options: AVAudioSession.CategoryOptions = [.allowBluetoothA2DP]
    if defaultToSpeaker { options.insert(.defaultToSpeaker) }
    if #available(iOS 26.0, *) {
      options.insert(.allowBluetoothHFP)
    }
    try session.setCategory(.playAndRecord, mode: .voiceChat, options: options)
    try session.setActive(true, options: [])

    // Voice-Processing I/O: echo cancellation + AGC. Enabling it on the input node also
    // enables it on the output node. Best-effort — plain duplex still works without it.
    do {
      try engine.inputNode.setVoiceProcessingEnabled(true)
    } catch {
      print("[Audio] voice processing unavailable: \(error)")
    }

    engine.attach(playerNode)
    engine.connect(playerNode, to: engine.mainMixerNode, format: playbackFormat)
    _ = engine.inputNode  // instantiate the input so the graph wires the mic in

    engine.prepare()
    try engine.start()
    isStarted = true

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleConfigurationChange),
      name: .AVAudioEngineConfigurationChange,
      object: engine
    )
  }

  /// Route/format changes (and enabling voice processing) can stop the engine; bring it
  /// back and re-arm the mic tap so capture survives.
  @objc private func handleConfigurationChange() {
    guard isStarted else { return }
    let wasCapturing = isCapturing
    if engine.isRunning == false { try? engine.start() }
    if wasCapturing { try? installInputTap() }
  }

  // MARK: - Capture (mic -> STT)

  func startCapturing() throws {
    if isStarted == false { try start() }
    guard engine.isRunning else { throw AudioError.engineUnavailable }
    try installInputTap()
    isCapturing = true
  }

  private func installInputTap() throws {
    let input = engine.inputNode
    let hardwareFormat = input.outputFormat(forBus: 0)

    // Invalid input format (no usable mic route) — surface instead of crashing in the tap.
    guard hardwareFormat.sampleRate > 0, hardwareFormat.channelCount > 0 else {
      throw AudioError.formatUnavailable
    }
    guard let converter = AVAudioConverter(from: hardwareFormat, to: captureFormat) else {
      throw AudioError.converterUnavailable
    }
    captureConverter = converter

    input.removeTap(onBus: 0)
    input.installTap(onBus: 0, bufferSize: 4_096, format: hardwareFormat) { [weak self] buffer, _ in
      self?.handleCaptured(buffer: buffer)
    }
  }

  func stopCapturing() {
    guard isCapturing else { return }
    engine.inputNode.removeTap(onBus: 0)
    captureConverter = nil
    isCapturing = false
  }

  private func handleCaptured(buffer: AVAudioPCMBuffer) {
    guard let converter = captureConverter else { return }
    let hardwareFormat = buffer.format

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

  /// Starts the player node. The engine is already running (see `start()`), so this just
  /// kicks playback off when the first TTS chunk is enqueued.
  func startPlayback() {
    guard isStarted else { return }
    if playerNode.isPlaying == false { playerNode.play() }
  }

  /// Resets the scheduled-playback duration at the start of each spoken utterance.
  func resetPlaybackClock() {
    scheduledPlaybackSeconds = 0
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

    scheduledPlaybackSeconds += Double(sampleCount) / CartesiaConfig.outputSampleRate
    playerNode.scheduleBuffer(buffer, completionHandler: nil)
  }

  func stopPlayback() {
    playerNode.stop()
  }

  /// Routes call audio to the loudspeaker (true) or the earpiece/receiver (false).
  func setSpeaker(_ on: Bool) {
    try? AVAudioSession.sharedInstance().overrideOutputAudioPort(on ? .speaker : .none)
  }

  // MARK: - Teardown

  func teardown() {
    NotificationCenter.default.removeObserver(
      self, name: .AVAudioEngineConfigurationChange, object: engine
    )
    stopCapturing()
    playerNode.stop()
    engine.stop()
    isStarted = false
    try? engine.inputNode.setVoiceProcessingEnabled(false)
    try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
  }
}

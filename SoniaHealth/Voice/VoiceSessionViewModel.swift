import Foundation
import SwiftUI

/// Orchestrates one voice therapy session:
/// mic → Cartesia STT → Claude → Cartesia TTS → speaker.
@MainActor
final class VoiceSessionViewModel: ObservableObject {
  enum State: Equatable {
    case connecting
    case idle        // ready, waiting for the user to tap and speak
    case listening   // capturing the user's turn
    case thinking    // transcribing + asking Claude
    case speaking    // playing Sonia's reply
    case error(String)
  }

  struct Line: Identifiable, Equatable {
    enum Speaker { case sonia, you }
    let id = UUID()
    let speaker: Speaker
    var text: String
  }

  @Published private(set) var state: State = .connecting
  @Published private(set) var statusText = "Connecting…"
  @Published private(set) var transcript: [Line] = []
  @Published private(set) var inputLevel: Float = 0
  @Published var permissionDenied = false

  private let audio = AudioSessionController()
  private let claude = ClaudeClient()
  private var currentSTT: CartesiaSTTClient?
  private var currentTTS: CartesiaTTSClient?
  private var history: [ClaudeClient.Turn] = []

  // MARK: - Lifecycle

  func begin() async {
    audio.onCapture = { [weak self] data in
      self?.currentSTT?.sendAudio(data)
    }
    audio.onInputLevel = { [weak self] level in
      DispatchQueue.main.async { self?.inputLevel = level }
    }

    let granted = await audio.requestPermission()
    guard granted else {
      permissionDenied = true
      state = .error("Microphone access is needed for a voice session.")
      statusText = "Microphone access denied"
      return
    }

    await speak(SoniaSystemPrompt.introduction, asSonia: true)
    setIdle()
  }

  func end() {
    currentSTT?.close()
    currentTTS?.cancel()
    audio.teardown()
  }

  // MARK: - Turn control

  func toggleMic() {
    switch state {
    case .idle:
      startListening()
    case .listening:
      Task { await finishTurn() }
    default:
      break
    }
  }

  private func startListening() {
    let stt = CartesiaSTTClient()
    currentSTT = stt
    stt.connect()

    do {
      try audio.startCapturing()
      state = .listening
      statusText = "Listening… tap when you're done"
    } catch {
      state = .error("Couldn't start the microphone.")
      statusText = "Audio error"
    }
  }

  private func finishTurn() async {
    audio.stopCapturing()
    inputLevel = 0
    state = .thinking
    statusText = "Thinking…"

    let userText = await currentSTT?.finishAndGetTranscript() ?? ""
    currentSTT?.close()
    currentSTT = nil

    guard userText.isEmpty == false else {
      setIdle()
      return
    }

    transcript.append(Line(speaker: .you, text: userText))
    history.append(.init(role: .user, text: userText))

    do {
      let reply = try await claude.reply(system: SoniaSystemPrompt.text, history: history)
      history.append(.init(role: .assistant, text: reply))
      await speak(reply, asSonia: true)
    } catch {
      state = .error("Sonia couldn't respond just now. Tap to try again.")
      statusText = "Connection issue"
      return
    }

    setIdle()
  }

  // MARK: - Speaking

  private func speak(_ text: String, asSonia: Bool) async {
    if asSonia {
      transcript.append(Line(speaker: .sonia, text: text))
    }
    state = .speaking
    statusText = "Sonia is speaking…"

    do {
      try audio.startPlayback()
    } catch {
      print("[Session] playback start failed: \(error)")
    }

    let tts = CartesiaTTSClient()
    currentTTS = tts
    await tts.speak(text) { [weak self] chunk in
      self?.audio.enqueueTTS(pcmS16LE: chunk)
    }
    currentTTS = nil
  }

  private func setIdle() {
    state = .idle
    statusText = "Tap to speak"
  }
}

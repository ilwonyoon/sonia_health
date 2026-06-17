import Foundation
import SwiftUI
import UIKit

/// Drives the hands-free guided-journal "call": Sonia speaks each question (TTS to the
/// earpiece), the user just talks back (STT with silence endpointing — no buttons), and
/// the next question is generated from their answer. Adapts the companion session's
/// turn-taking (`VoiceSessionViewModel`) to a fixed 3-question journal arc, routed to the
/// receiver with proximity screen-off so it feels like a phone call held to the ear.
@MainActor
final class GuidedJournalCallViewModel: ObservableObject {
  enum Phase: Equatable { case connecting, speaking, listening, thinking, ended, failed }

  let kind: JournalCheckinKind
  let total = GuidedJournalQuestionGenerator.questionCount

  @Published private(set) var phase: Phase = .connecting
  @Published private(set) var currentQuestion = ""   // what Sonia just asked
  @Published private(set) var liveCaption = ""       // the user's words while speaking
  @Published private(set) var index = 0
  @Published private(set) var inputLevel: Float = 0
  @Published private(set) var isSpeakerOn = false
  /// Time-boxed: a short 3-minute check-in. Counts down from 3:00 and gently wraps up at 0.
  @Published private(set) var secondsRemaining = 180
  @Published var micDenied = false

  private let sessionLimit = 180
  private var countdownTask: Task<Void, Never>?

  private let audio = AudioSessionController()
  private let generator: GuidedJournalQuestionGenerator
  private var stt: CartesiaSTTClient?
  private var tts: CartesiaTTSClient?

  private var memory: SoniaMemoryContext?
  private var today = ""
  private var journal = MemoryJournal.empty
  private var carryOver: [GuidedJournalQuestionGenerator.QA] = []

  private var questions: [String] = []
  private var answers: [String] = []

  // Silence-based endpointing (phone-call feel): once speech starts, a trailing silence
  // ends the turn. A touch longer than the companion session to respect reflective pauses.
  private var speechStarted = false
  private var lastVoiceAt: Date?
  private let speechThreshold: Float = 0.12
  private let endpointSilence: TimeInterval = 1.6

  private var playbackAnchor: Date?
  private var ended = false

  init(kind: JournalCheckinKind, claude: ClaudeClient = ClaudeClient()) {
    self.kind = kind
    self.generator = GuidedJournalQuestionGenerator(claude: claude)
  }

  // MARK: Lifecycle

  func start() async {
    audio.onCapture = { [weak self] data in self?.stt?.sendAudio(data) }
    audio.onInputLevel = { [weak self] level in
      Task { @MainActor in self?.handleLevel(level) }
    }

    loadContext()

    let granted = await audio.requestPermission()
    guard granted else { micDenied = true; phase = .failed; return }

    do {
      try audio.start(defaultToSpeaker: false)   // earpiece, like a call
    } catch {
      print("[JournalCall] audio start failed: \(error)")
      phase = .failed
      return
    }
    audio.setSpeaker(false)
    UIDevice.current.isProximityMonitoringEnabled = true   // screen off when held to ear

    // Strong "connected" haptic — like a call being answered the moment it's at your ear.
    let connect = UIImpactFeedbackGenerator(style: .heavy)
    connect.prepare()
    connect.impactOccurred(intensity: 1.0)

    startCountdown()

    let q1 = await GuidedJournalPrefetcher.shared.firstQuestion(
      kind: kind, memory: memory, carryOver: carryOver, today: today
    )
    await ask(q1)
  }

  func end() {
    guard ended == false else { return }
    ended = true
    countdownTask?.cancel(); countdownTask = nil
    stt?.close(); stt = nil
    tts?.cancel(); tts = nil
    audio.teardown()
    UIDevice.current.isProximityMonitoringEnabled = false
  }

  // MARK: Countdown (3-minute time box)

  private func startCountdown() {
    countdownTask = Task { @MainActor [weak self] in
      while true {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        guard let self, self.ended == false, Task.isCancelled == false else { return }
        if self.secondsRemaining > 0 { self.secondsRemaining -= 1 }
        if self.secondsRemaining <= 0 {
          await self.wrapUpForTime()
          return
        }
      }
    }
  }

  /// Time's up — stop listening, save what was shared, and close warmly.
  private func wrapUpForTime() async {
    guard ended == false, phase != .ended else { return }
    audio.stopCapturing()
    stt?.close(); stt = nil
    persist()
    currentQuestion = ""
    await speak("That's our few minutes for today. I've got what you shared — carry it gently with you.")
    UIDevice.current.isProximityMonitoringEnabled = false
    phase = .ended
  }

  // MARK: In-call controls

  func toggleSpeaker() {
    isSpeakerOn.toggle()
    audio.setSpeaker(isSpeakerOn)
    // On speaker you're looking at the screen; at the ear you're not.
    UIDevice.current.isProximityMonitoringEnabled = !isSpeakerOn
  }

  // MARK: Turn loop

  private func ask(_ question: String) async {
    questions.append(question)
    answers.append("")
    index = questions.count - 1
    currentQuestion = question
    await speak(question)
    guard ended == false else { return }
    await listen()
  }

  private func speak(_ text: String) async {
    phase = .speaking
    playbackAnchor = nil
    audio.startPlayback()
    audio.resetPlaybackClock()

    let client = CartesiaTTSClient()
    tts = client
    await client.speak(text) { [weak self] chunk in
      Task { @MainActor in if self?.playbackAnchor == nil { self?.playbackAnchor = Date() } }
      self?.audio.enqueueTTS(pcmS16LE: chunk)
    }
    tts = nil
    await waitForPlayback()
  }

  private func listen() async {
    let client = CartesiaSTTClient()
    stt = client
    liveCaption = ""
    speechStarted = false
    lastVoiceAt = nil
    client.onLiveTranscript = { [weak self] live in
      Task { @MainActor in
        guard let self, self.phase == .listening else { return }
        self.liveCaption = live
      }
    }
    client.connect()
    do {
      try audio.startCapturing()
      phase = .listening
    } catch {
      print("[JournalCall] capture failed: \(error)")
      phase = .failed
    }
  }

  private func handleLevel(_ level: Float) {
    inputLevel = level
    guard phase == .listening else { return }
    let now = Date()
    if level >= speechThreshold {
      speechStarted = true
      lastVoiceAt = now
    } else if speechStarted, let last = lastVoiceAt, now.timeIntervalSince(last) >= endpointSilence {
      speechStarted = false
      lastVoiceAt = nil
      Task { await finishTurn() }
    }
  }

  private func finishTurn() async {
    audio.stopCapturing()
    inputLevel = 0
    phase = .thinking

    let spoken = await stt?.finishAndGetTranscript() ?? ""
    stt?.close(); stt = nil

    // Dead air / false trigger — keep listening.
    guard spoken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
      await listen()
      return
    }

    let existing = answers[index]
    answers[index] = existing.isEmpty ? spoken : existing + " " + spoken

    if index < total - 1 {
      let priorQA = zip(questions, answers).map {
        GuidedJournalQuestionGenerator.QA(question: $0, answer: $1)
      }
      let next = await generator.nextQuestion(
        kind: kind, memory: memory, priorQA: priorQA, carryOver: carryOver, step: index + 1
      )
      guard ended == false else { return }
      await ask(next)
    } else {
      await close()
    }
  }

  private func close() async {
    countdownTask?.cancel(); countdownTask = nil
    persist()
    currentQuestion = ""
    let closing = kind == .morningIntention
      ? "I've got that. I'll hold it with you through the day — we'll talk tonight."
      : "Thank you for closing the day with me. Rest easy."
    await speak(closing)
    UIDevice.current.isProximityMonitoringEnabled = false
    phase = .ended
  }

  // MARK: Persistence + context

  private func persist() {
    let qa = zip(questions, answers).map {
      MemoryJournal.GuidedEntry.QA(question: $0, answer: $1)
    }
    let stamp = ISO8601DateFormatter().string(from: Date())
    var updated = journal
    updated.guidedEntries.append(
      .init(date: today, kind: kind.rawValue, qa: qa, completedAt: stamp)
    )
    updated.updatedAt = stamp
    MemoryStore.save(updated)
    journal = updated
  }

  private func loadContext() {
    guard let seed = try? SeedStore.load() else { return }
    today = seed.meta.today
    journal = MemoryStore.load()
    memory = SoniaMemoryContext.build(from: seed, journal: journal)
    if kind == .eveningReflection,
       let morning = journal.guidedEntry(date: today, kind: .morningIntention) {
      carryOver = morning.qa.map {
        GuidedJournalQuestionGenerator.QA(question: $0.question, answer: $0.answer)
      }
    }
  }

  private func waitForPlayback() async {
    guard let anchor = playbackAnchor else { return }
    let remaining = audio.scheduledPlaybackSeconds - Date().timeIntervalSince(anchor)
    guard remaining > 0 else { return }
    try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
  }
}

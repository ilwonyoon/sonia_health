import Foundation
import SwiftUI

/// Drives one guided-journal run (morning or evening) as an adaptive, growing sequence
/// rather than a fixed form. Q1 is fetched on `start()`; Q2/Q3 are generated on the fly
/// after each answer. On completion the answers are persisted to the live memory journal
/// so the morning flows into the evening (and into tomorrow's session memory).
@MainActor
final class GuidedJournalSession: ObservableObject {
  enum Phase: Equatable { case loading, answering, generating, complete }

  let kind: JournalCheckinKind
  let total = GuidedJournalQuestionGenerator.questionCount

  @Published private(set) var questions: [String] = []   // grows as the user advances
  @Published private(set) var answers: [String] = []
  @Published private(set) var index = 0
  @Published private(set) var phase: Phase = .loading

  private let generator: GuidedJournalQuestionGenerator
  private var memory: SoniaMemoryContext?
  private var today = ""                                  // ISO day from the seed
  private var journal = MemoryJournal.empty
  private var carryOver: [GuidedJournalQuestionGenerator.QA] = []   // today's morning, for evening

  init(kind: JournalCheckinKind, claude: ClaudeClient = ClaudeClient()) {
    self.kind = kind
    self.generator = GuidedJournalQuestionGenerator(claude: claude)
  }

  // MARK: Derived

  var currentQuestion: String { questions.indices.contains(index) ? questions[index] : "" }
  var isLast: Bool { index >= total - 1 }
  var canGoPrevious: Bool { index > 0 }

  /// Read-write access to the current answer, for the response field.
  var currentAnswer: String {
    answers.indices.contains(index) ? answers[index] : ""
  }
  func setCurrentAnswer(_ value: String) {
    guard answers.indices.contains(index) else { return }
    answers[index] = value
  }

  // MARK: Lifecycle

  /// Loads memory context and produces Q1 (prefetched if warm, else live, else fallback).
  func start() async {
    guard questions.isEmpty else { return }   // idempotent across re-appears
    loadContext()
    phase = .loading
    let q1 = await GuidedJournalPrefetcher.shared.firstQuestion(
      kind: kind, memory: memory, carryOver: carryOver, today: today
    )
    questions = [q1]
    answers = [""]
    index = 0
    phase = .answering
  }

  /// Advance from the current (answered) question. Generates the next one if needed.
  func advance() async {
    if isLast {
      await complete()
      return
    }
    let next = index + 1
    if questions.indices.contains(next) {
      index = next                            // already generated (user navigated back)
      return
    }
    phase = .generating
    let priorQA = zip(questions, answers).map {
      GuidedJournalQuestionGenerator.QA(question: $0, answer: $1)
    }
    let question = await generator.nextQuestion(
      kind: kind, memory: memory, priorQA: priorQA, carryOver: carryOver, step: next
    )
    questions.append(question)
    answers.append("")
    index = next
    phase = .answering
  }

  func goPrevious() {
    index = max(0, index - 1)
  }

  // MARK: Persistence

  private func complete() async {
    let qa = zip(questions, answers).map {
      MemoryJournal.GuidedEntry.QA(question: $0, answer: $1)
    }
    let entry = MemoryJournal.GuidedEntry(
      date: today,
      kind: kind.rawValue,
      qa: qa,
      completedAt: ISO8601DateFormatter().string(from: Date())
    )
    var updated = journal
    updated.guidedEntries.append(entry)
    updated.updatedAt = entry.completedAt
    MemoryStore.save(updated)
    journal = updated
    phase = .complete
  }

  // MARK: Context

  private func loadContext() {
    guard let seed = try? SeedStore.load() else { return }
    today = seed.meta.today
    journal = MemoryStore.load()
    memory = SoniaMemoryContext.build(from: seed, journal: journal)

    // Evening builds on this morning's intention, if it was completed today.
    if kind == .eveningReflection,
       let morning = journal.guidedEntry(date: today, kind: .morningIntention) {
      carryOver = morning.qa.map {
        GuidedJournalQuestionGenerator.QA(question: $0.question, answer: $0.answer)
      }
    }
  }
}

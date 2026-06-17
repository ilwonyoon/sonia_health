import Foundation

/// Warms the first guided-journal question *before* the user opens the entry, so Q1 feels
/// instant (brief requirement #1). The Today screen calls `warm(...)` on appear; the flow
/// calls `firstQuestion(...)` — which returns the cached value, awaits an in-flight warm,
/// or generates on demand. Keyed by day + kind so morning and evening cache separately.
@MainActor
final class GuidedJournalPrefetcher {
  static let shared = GuidedJournalPrefetcher()

  private let generator = GuidedJournalQuestionGenerator(claude: ClaudeClient())
  private var cache: [String: String] = [:]
  private var inFlight: [String: Task<String, Never>] = [:]

  private func key(_ kind: JournalCheckinKind, _ today: String) -> String {
    "\(today)|\(kind.rawValue)"
  }

  /// Kick off Q1 generation in the background if not already cached/in-flight.
  func warm(
    kind: JournalCheckinKind,
    memory: SoniaMemoryContext?,
    carryOver: [GuidedJournalQuestionGenerator.QA] = [],
    today: String
  ) {
    let k = key(kind, today)
    guard cache[k] == nil, inFlight[k] == nil else { return }
    inFlight[k] = Task { [generator] in
      await generator.firstQuestion(kind: kind, memory: memory, carryOver: carryOver)
    }
  }

  /// Return Q1: cached, then any in-flight warm, then a fresh generation.
  func firstQuestion(
    kind: JournalCheckinKind,
    memory: SoniaMemoryContext?,
    carryOver: [GuidedJournalQuestionGenerator.QA] = [],
    today: String
  ) async -> String {
    let k = key(kind, today)
    if let cached = cache[k] { return cached }
    if let task = inFlight[k] {
      let value = await task.value
      cache[k] = value
      inFlight[k] = nil
      return value
    }
    let value = await generator.firstQuestion(kind: kind, memory: memory, carryOver: carryOver)
    cache[k] = value
    return value
  }
}

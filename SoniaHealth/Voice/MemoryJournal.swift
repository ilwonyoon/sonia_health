import Foundation

/// Live, accumulating memory written after each real session (Phase 2 — write path).
///
/// The static seed (`sonia_seed.json`) is the persona's fixed backstory + demo history;
/// the journal is what Sonia *learns going forward*. It's persisted in the app's
/// Documents directory and merged with the seed when building conversation context, so
/// today's conversation shows up in tomorrow's memory.
struct MemoryJournal: Codable, Equatable {
  /// One consolidated session, distilled from a real conversation transcript.
  struct Entry: Codable, Equatable {
    let date: String              // ISO day, e.g. "2026-06-16"
    let summary: String
    let primaryTheme: String
    let moodAfterLabel: String?
    let moodAfterScore: Int?
    let homework: String?
  }

  /// A newly noticed long-term pattern ("memory card").
  struct LearnedInsight: Codable, Equatable {
    let title: String
    let body: String
  }

  var entries: [Entry] = []
  var learnedInsights: [LearnedInsight] = []
  /// What to open the next session on (last mood, open thread, upcoming event).
  var continuity: String?
  var updatedAt: String?

  static let empty = MemoryJournal()
}

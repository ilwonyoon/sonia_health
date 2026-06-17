import Foundation

/// After a session ends, asks Claude to distill the transcript into durable memory:
/// a session summary, any new long-term insight, and a continuity note for next time
/// (Phase 2 — write path). The result is appended to the `MemoryJournal`.
///
/// Runs best-effort: if the model call fails (e.g. missing key) the journal is returned
/// unchanged, so a session never breaks because consolidation didn't run.
struct MemoryConsolidator {
  let claude: ClaudeClient

  func consolidate(
    history: [ClaudeClient.Turn],
    into journal: MemoryJournal,
    today: String
  ) async -> MemoryJournal {
    // Nothing the user actually said → nothing worth remembering.
    guard history.contains(where: { $0.role == .user }) else { return journal }

    let transcript = history
      .map { "\($0.role == .user ? "Person" : "Sonia"): \($0.text)" }
      .joined(separator: "\n")

    do {
      let raw = try await claude.reply(
        system: Self.system,
        history: [ClaudeClient.Turn(
          role: .user,
          text: "Session transcript:\n\n\(transcript)\n\nReturn the JSON now."
        )],
        maxTokens: 700
      )
      guard let parsed = Self.parse(raw) else { return journal }

      var updated = journal
      updated.entries.append(.init(
        date: today,
        summary: parsed.summary,
        primaryTheme: parsed.primaryTheme,
        moodAfterLabel: parsed.moodAfterLabel,
        moodAfterScore: parsed.moodAfterScore,
        homework: parsed.homework
      ))
      updated.learnedInsights.append(
        contentsOf: parsed.newInsights.map { .init(title: $0.title, body: $0.body) }
      )
      updated.continuity = parsed.continuity
      updated.updatedAt = today
      return updated
    } catch {
      print("[Consolidator] consolidation failed: \(error)")
      return journal
    }
  }

  /// Today's date as an ISO day string (used when the seed has no `meta.today`).
  static func todayISO(timezoneIdentifier: String? = nil) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    if let id = timezoneIdentifier, let tz = TimeZone(identifier: id) {
      formatter.timeZone = tz
    }
    return formatter.string(from: Date())
  }

  // MARK: - Prompt

  private static let system = """
  You are the memory system of an AI wellness companion named Sonia. Read the session
  transcript and distill what's worth remembering for future sessions.

  Respond with ONLY a single JSON object — no markdown, no code fences, no commentary —
  with exactly these keys:
  {
    "summary": "one or two sentences recapping what the person worked through",
    "primaryTheme": "a short phrase naming the session's main theme",
    "moodAfterLabel": "one word for how they seemed to end (or null)",
    "moodAfterScore": integer 1-10 or null,
    "homework": "one concrete next step they agreed to, or null",
    "newInsights": [ { "title": "short pattern name", "body": "one sentence" } ],
    "continuity": "one sentence on what Sonia should gently open the next session on"
  }

  Only add a newInsight if a genuine recurring pattern is clear; otherwise use an empty
  array. Keep everything concise and grounded strictly in what was said.
  """

  // MARK: - Parsing

  private struct Parsed: Decodable {
    let summary: String
    let primaryTheme: String
    let moodAfterLabel: String?
    let moodAfterScore: Int?
    let homework: String?
    let newInsights: [Insight]
    let continuity: String?

    struct Insight: Decodable { let title: String; let body: String }
  }

  /// Extracts the JSON object from the model's reply (tolerates stray prose/fences).
  private static func parse(_ raw: String) -> Parsed? {
    guard
      let start = raw.firstIndex(of: "{"),
      let end = raw.lastIndex(of: "}"),
      start < end
    else { return nil }
    let json = String(raw[start...end])
    guard let data = json.data(using: .utf8) else { return nil }
    return try? JSONDecoder().decode(Parsed.self, from: data)
  }
}

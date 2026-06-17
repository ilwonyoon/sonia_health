import Foundation

/// Turns the generic Sonia prompt into a therapist who remembers THIS person across
/// daily sessions.
///
/// Merges two sources:
///   • the static seed (`SeedRoot`)   — fixed persona backstory + demo history
///   • the live journal (`MemoryJournal`) — what Sonia has learned in real sessions
///
/// and assembles a bounded context block so injection size stays roughly constant no
/// matter how many days the user has been active:
///   1. Profile (stable)              — always included
///   2. Insights / long-term patterns — seed + journal-learned, always included
///   3. Recent session summaries      — most recent `recentSessionCount` across both
///   4. Where-things-stand + continuity — last mood, latest GAD-7, open thread
///
/// `systemContext` is appended after `SoniaSystemPrompt.text`; `continuity` is the
/// compact "what to open on" summary handed to the greeting generator.
struct SoniaMemoryContext: Equatable {
  let systemContext: String
  let continuity: String

  /// Most-recent session summaries to inject. Older ones live on in the insights.
  static let recentSessionCount = 5

  /// One unified recent-session row drawn from either the seed or the live journal.
  private struct RecentItem {
    let date: String
    let label: String
    let gist: String
    let moodLabel: String?
    let moodScore: Int?
  }

  static func build(from seed: SeedRoot, journal: MemoryJournal = .empty) -> SoniaMemoryContext {
    let user = seed.user

    // Merge seed sessions + live journal entries into one recency-ranked list.
    let seedItems = seed.sessions.map { session in
      RecentItem(
        date: shortDate(session.startedAt),
        label: label(for: session.kind),
        gist: gist(of: session),
        moodLabel: session.moodAfter?.label,
        moodScore: session.moodAfter?.score
      )
    }
    let journalItems = journal.entries.map { entry in
      RecentItem(
        date: shortDate(entry.date),
        label: "check-in",
        gist: gist(of: entry),
        moodLabel: entry.moodAfterLabel,
        moodScore: entry.moodAfterScore
      )
    }
    let recent = (seedItems + journalItems)
      .sorted { $0.date > $1.date }
      .prefix(recentSessionCount)
    let lastItem = recent.first
    let latestGAD = seed.assessments(ofType: "GAD-7").last

    // Insights: seed-distilled + journal-learned.
    let insights: [(title: String, body: String)] =
      seed.insights.map { ($0.title, $0.body) } +
      journal.learnedInsights.map { ($0.title, $0.body) }

    // Open thread: prefer the freshest source.
    let openThread = journal.continuity ?? seedOpenThread(seed)

    // MARK: system context block
    var lines: [String] = []
    lines.append("## WHO YOU'RE TALKING WITH (your memory of them — recall it naturally, never read it back as a list)")
    lines.append("Name: \(user.firstName) (\(user.pronouns)), \(user.age), \(user.location).")
    if user.backstory.isEmpty == false {
      lines.append("Situation: \(user.backstory)")
    }
    if user.presentingConcerns.isEmpty == false {
      lines.append("What's been weighing on them: \(user.presentingConcerns.joined(separator: "; ")).")
    }
    if user.goals.isEmpty == false {
      lines.append("What they're working toward: \(user.goals.joined(separator: "; ")).")
    }

    if insights.isEmpty == false {
      lines.append("")
      lines.append("## PATTERNS YOU'VE NOTICED TOGETHER")
      for insight in insights {
        lines.append("- \(insight.title): \(insight.body)")
      }
    }

    if recent.isEmpty == false {
      lines.append("")
      lines.append("## RECENT SESSIONS (most recent first)")
      for item in recent {
        lines.append("- \(item.date) \(item.label): \(item.gist)")
      }
    }

    lines.append("")
    lines.append("## WHERE THINGS STAND NOW")
    if let last = lastItem, let moodLabel = last.moodLabel, let moodScore = last.moodScore {
      lines.append("- Last check-in was \(last.date); they ended around \(moodLabel.lowercased()) (\(moodScore) out of 10).")
    }
    if let gad = latestGAD {
      lines.append("- Most recent GAD-7 score: \(gad.score) (\(gad.severity)), on \(shortDate(gad.date)).")
    }
    if let open = openThread {
      lines.append("- An open thread to gently follow up on: \(open)")
    }
    lines.append("")
    lines.append("Open and respond as if you genuinely remember them. Lean on what's real above, but weave it in warmly — don't recite it.")

    let systemContext = lines.joined(separator: "\n")

    // MARK: continuity (for the opening line)
    var cont: [String] = ["First name: \(user.firstName)."]
    if let last = lastItem {
      cont.append("Last check-in: \(last.date), a \(last.label).")
      if let moodLabel = last.moodLabel, let moodScore = last.moodScore {
        cont.append("They ended that one feeling \(moodLabel.lowercased()) (\(moodScore) out of 10).")
      }
    }
    if let open = openThread {
      cont.append("What you suggested they carry forward: \(open)")
    }
    let continuity = cont.joined(separator: " ")

    return SoniaMemoryContext(systemContext: systemContext, continuity: continuity)
  }

  // MARK: - Helpers

  private static func gist(of session: Session) -> String {
    var parts: [String] = []
    if let summary = session.summary, summary.isEmpty == false {
      parts.append(summary)
    } else if session.userShared.isEmpty == false {
      parts.append(session.userShared)
    } else {
      parts.append(session.primaryTheme)
    }
    if let homework = session.homework, homework.isEmpty == false {
      parts.append("Homework: \(homework)")
    } else if let action = session.actionItem, action.isEmpty == false {
      parts.append("Next step: \(action)")
    }
    return parts.joined(separator: " ")
  }

  private static func gist(of entry: MemoryJournal.Entry) -> String {
    var parts = [entry.summary]
    if let homework = entry.homework, homework.isEmpty == false {
      parts.append("Homework: \(homework)")
    }
    return parts.joined(separator: " ")
  }

  private static func seedOpenThread(_ seed: SeedRoot) -> String? {
    guard let last = seed.sessions.sorted(by: { $0.startedAt > $1.startedAt }).first else { return nil }
    if let homework = last.homework, homework.isEmpty == false { return homework }
    if let action = last.actionItem, action.isEmpty == false { return action }
    return nil
  }

  private static func label(for kind: SessionKind) -> String {
    switch kind {
    case .morningCheckin: return "morning check-in"
    case .eveningCheckin: return "evening check-in"
    case .deepSession: return "deep session"
    }
  }

  /// Seed dates are ISO ("2026-06-15" or a full datetime) — keep just the day part.
  private static func shortDate(_ iso: String) -> String {
    String(iso.prefix(10))
  }
}

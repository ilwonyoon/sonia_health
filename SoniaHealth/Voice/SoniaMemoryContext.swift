import Foundation

/// Turns the generic Sonia prompt into a therapist who remembers THIS person across
/// daily sessions (Phase 1 — read path).
///
/// Assembles a bounded context block from the seed/memory so injection size stays
/// roughly constant no matter how many days the user has been active:
///   1. Profile (stable)              — always included
///   2. Insights / long-term patterns — always included (already distilled)
///   3. Recent session summaries      — only the most recent `recentSessionCount`
///   4. Where-things-stand + continuity — last mood, latest GAD-7, open thread
///
/// `systemContext` is appended after `SoniaSystemPrompt.text`; `continuity` is the
/// compact "what to open on" summary handed to the greeting generator.
struct SoniaMemoryContext: Equatable {
  let systemContext: String
  let continuity: String

  /// Most-recent session summaries to inject. Older ones live on in the insights.
  static let recentSessionCount = 5

  static func build(from seed: SeedRoot) -> SoniaMemoryContext {
    let user = seed.user

    let recent = seed.sessions
      .sorted { $0.startedAt > $1.startedAt }
      .prefix(recentSessionCount)
    let lastSession = recent.first
    let latestGAD = seed.assessments(ofType: "GAD-7").last

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

    if seed.insights.isEmpty == false {
      lines.append("")
      lines.append("## PATTERNS YOU'VE NOTICED TOGETHER")
      for insight in seed.insights {
        lines.append("- \(insight.title): \(insight.body)")
      }
    }

    if recent.isEmpty == false {
      lines.append("")
      lines.append("## RECENT SESSIONS (most recent first)")
      for session in recent {
        lines.append("- \(shortDate(session.date)) \(label(for: session.kind)): \(gist(of: session))")
      }
    }

    lines.append("")
    lines.append("## WHERE THINGS STAND NOW")
    if let last = lastSession, let mood = last.moodAfter {
      lines.append("- Last check-in was \(shortDate(last.date)); they ended around \(mood.label.lowercased()) (\(mood.score) out of 10).")
    }
    if let gad = latestGAD {
      lines.append("- Most recent GAD-7 score: \(gad.score) (\(gad.severity)), on \(shortDate(gad.date)).")
    }
    if let open = openThread(from: lastSession) {
      lines.append("- An open thread to gently follow up on: \(open)")
    }
    lines.append("")
    lines.append("Open and respond as if you genuinely remember them. Lean on what's real above, but weave it in warmly — don't recite it.")

    let systemContext = lines.joined(separator: "\n")

    // MARK: continuity (for the opening line)
    var cont: [String] = ["First name: \(user.firstName)."]
    if let last = lastSession {
      cont.append("Last check-in: \(shortDate(last.date)), a \(label(for: last.kind)).")
      if let mood = last.moodAfter {
        cont.append("They ended that one feeling \(mood.label.lowercased()) (\(mood.score) out of 10).")
      }
    }
    if let open = openThread(from: lastSession) {
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

  private static func openThread(from session: Session?) -> String? {
    guard let session else { return nil }
    if let homework = session.homework, homework.isEmpty == false { return homework }
    if let action = session.actionItem, action.isEmpty == false { return action }
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

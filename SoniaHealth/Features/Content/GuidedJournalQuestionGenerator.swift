import Foundation

/// Generates the guided-journal questions adaptively — mirrors `GreetingGenerator`.
///
/// Hybrid strategy (see `Prototype/GUIDED_JOURNAL_REDESIGN.md`):
///   • Q1 is generated from the user's memory context (and can be pre-fetched before
///     they enter — see `GuidedJournalPrefetcher`).
///   • Q2/Q3 are generated on the fly from memory + the prior question/answer pairs.
///   • Every call degrades gracefully to the hand-authored static questions
///     (`journal_today.json → checkinQuestions`) if the model can't be reached.
///
/// Morning and evening use deliberately different prompts: morning sets the day FORWARD
/// (intention); evening CLOSES it (reflection).
struct GuidedJournalQuestionGenerator {
  let claude: ClaudeClient

  struct QA: Equatable { let question: String; let answer: String }

  /// The whole arc is three questions.
  static let questionCount = 3

  /// Q1 — the opener.
  func firstQuestion(
    kind: JournalCheckinKind,
    memory: SoniaMemoryContext?,
    carryOver: [QA] = []
  ) async -> String {
    await generate(kind: kind, memory: memory, priorQA: [], carryOver: carryOver, step: 0)
  }

  /// Q2/Q3 — adaptive follow-up. `step` is 0-based (1 = second question).
  func nextQuestion(
    kind: JournalCheckinKind,
    memory: SoniaMemoryContext?,
    priorQA: [QA],
    carryOver: [QA] = [],
    step: Int
  ) async -> String {
    await generate(kind: kind, memory: memory, priorQA: priorQA, carryOver: carryOver, step: step)
  }

  // MARK: - Generation

  private func generate(
    kind: JournalCheckinKind,
    memory: SoniaMemoryContext?,
    priorQA: [QA],
    carryOver: [QA],
    step: Int
  ) async -> String {
    do {
      let system = Self.system(kind: kind, step: step, memory: memory, carryOver: carryOver)
      let reply = try await claude.reply(system: system, history: Self.history(priorQA: priorQA, kind: kind))
      let cleaned = Self.clean(reply)
      if cleaned.isEmpty == false { return cleaned }
    } catch {
      print("[GuidedJournal] question generation failed at step \(step), using fallback: \(error)")
    }
    return Self.fallback(kind: kind, step: step)
  }

  // MARK: - Prompt

  private static func system(
    kind: JournalCheckinKind,
    step: Int,
    memory: SoniaMemoryContext?,
    carryOver: [QA]
  ) -> String {
    let isMorning = kind == .morningIntention

    let arc = isMorning
      ? """
        This is a SHORT (~3 minute) SPOKEN MORNING check-in — a daily ritual, not a deep \
        session. Its single job: reinforce ONE concrete behavior change so the day starts well. \
        Three brief beats: (1) let them land and say how they are, (2) bring in the goal you set \
        together and take in how they feel about it, (3) remind them of the specific action they \
        committed to and ask them to carry it into today. Lean gentle and quietly energizing; \
        never ask them to recap a day that hasn't happened.
        """
      : """
        This is the EVENING. The arc CLOSES the day: let them look back honestly, find \
        something to give themselves credit for, and set something down before rest. \
        Lean calm, integrative, and releasing.
        """

    let followUpText = """

      It must follow naturally from what they just said — reflect the feeling underneath it \
      before you move on. Never repeat or merely rephrase a previous question.
      """

    let position: String
    let followUp: String
    if isMorning {
      if step == 0 {
        position = """
          BEAT 1 — Open. Warmly greet them and frame this as a quick moment together — just a \
          couple of minutes before the day picks up — then ask what's on their mind, or how they're \
          feeling as the day begins. Low-pressure; do NOT mention goals, tasks, or yesterday yet.
          """
        followUp = ""
      } else if step >= questionCount - 1 {
        position = """
          BEAT 3 — Acknowledge, then reinforce. FIRST, in one short warm sentence, reflect back \
          what they just shared so they feel heard. THEN name the SPECIFIC action they last \
          committed to (the open thread under 'WHERE THINGS STAND NOW' below — e.g. a phrase to \
          use, a breath to take), tie it to today, and ask them to keep it close — gently noting \
          you've only got this short moment now and you'll carry it with them. This one behavior \
          is the point of the check-in.
          """
        followUp = followUpText
      } else {
        position = """
          BEAT 2 — Acknowledge, then nudge. FIRST, in one short warm sentence, reflect back what \
          they just said so they feel genuinely heard. THEN gently connect it to the goal you've \
          been working on together (from your memory below). Curious and supportive, not \
          prescriptive.
          """
        followUp = followUpText
      }
    } else {
      position = step == 0
        ? "Write the FIRST of three questions — an inviting, low-pressure opener."
        : (step >= questionCount - 1
          ? "Write the THIRD and final question. It should help them land and carry one clear thing forward."
          : "Write the SECOND question.")
      followUp = step == 0 ? "" : followUpText
    }

    var blocks = [
      """
      You are Sonia, a warm AI wellness companion guiding someone you support daily through \
      a short SPOKEN \(isMorning ? "morning check-in" : "evening reflection"). They will SPEAK \
      their answer, so write the way you'd actually say it aloud — warm and brief.

      \(arc)

      \(position)\(followUp)

      Use your memory of them below to make this specific and genuinely relevant — never \
      presumptuous, never a generic worksheet prompt. Keep it to one or two short, speakable \
      sentences. Output ONLY what you would say — no preamble, numbering, quotation marks, \
      markdown, or emoji.
      """
    ]

    if carryOver.isEmpty == false {
      let lines = carryOver.map { "- Q: \($0.question)\n  A: \($0.answer)" }.joined(separator: "\n")
      blocks.append("## EARLIER TODAY (their morning intention — build the evening on it)\n\(lines)")
    }

    if let context = memory?.systemContext, context.isEmpty == false {
      blocks.append(context)
    }

    return blocks.joined(separator: "\n\n")
  }

  /// Replays the prior Q&A as conversation turns so the model can build on it.
  private static func history(priorQA: [QA], kind: JournalCheckinKind) -> [ClaudeClient.Turn] {
    guard priorQA.isEmpty == false else {
      let flavor = kind == .morningIntention ? "morning intention" : "evening reflection"
      return [.init(role: .user, text: "Begin the \(flavor). Ask the first question.")]
    }
    var turns: [ClaudeClient.Turn] = []
    for qa in priorQA {
      turns.append(.init(role: .assistant, text: qa.question))
      turns.append(.init(role: .user, text: qa.answer))
    }
    turns.append(.init(role: .user, text: "Ask the next question now."))
    return turns
  }

  // MARK: - Cleanup & fallback

  private static func clean(_ raw: String) -> String {
    var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    // Sonia's turn may be a short reflection + a question — keep both; just collapse any
    // line breaks into one spoken paragraph.
    text = text.replacingOccurrences(of: #"\s*\n+\s*"#, with: " ", options: .regularExpression)
    // Strip wrapping quotes and any leading "1." style numbering.
    text = text.trimmingCharacters(in: CharacterSet(charactersIn: "\"'“”"))
    if let range = text.range(of: #"^\s*\d+[\.\)]\s*"#, options: .regularExpression) {
      text.removeSubrange(range)
    }
    return text.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private static func fallback(kind: JournalCheckinKind, step: Int) -> String {
    let questions = JournalStore.loadOrFatal().questions(for: kind)
    if questions.indices.contains(step) { return questions[step] }
    return kind == .morningIntention
      ? "What do you most want to carry with you into today?"
      : "What's one thing from today you'd like to set down before bed?"
  }
}

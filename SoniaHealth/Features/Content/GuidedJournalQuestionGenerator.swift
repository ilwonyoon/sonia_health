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
    let arc = kind == .morningIntention
      ? """
        This is the MORNING. The arc sets the day FORWARD: ground them first, then help \
        them choose where to put their attention and how they want to meet what's ahead. \
        Lean gentle and quietly energizing. Never ask them to recap a day that hasn't happened.
        """
      : """
        This is the EVENING. The arc CLOSES the day: let them look back honestly, find \
        something to give themselves credit for, and set something down before rest. \
        Lean calm, integrative, and releasing.
        """

    let position = step == 0
      ? "Write the FIRST of three questions — an inviting, low-pressure opener."
      : (step >= questionCount - 1
        ? "Write the THIRD and final question. It should help them land and carry one clear thing forward."
        : "Write the SECOND question.")

    let followUp = step == 0
      ? ""
      : """

        It must follow naturally from what they just said — go one layer deeper, or in a \
        direction their answer opened. Never repeat or merely rephrase a previous question.
        """

    var blocks = [
      """
      You are Sonia, a warm AI wellness companion guiding someone you support daily through \
      a short spoken journal — a three-question \(kind == .morningIntention ? "morning intention" : "evening reflection").

      \(arc)

      \(position)\(followUp)

      Use your memory of them below to make the question specific and genuinely relevant — \
      never presumptuous, never a generic worksheet prompt. Keep it to one or two short \
      sentences, plain and speakable. Output ONLY the question itself — no preamble, \
      numbering, quotation marks, markdown, or emoji.
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
    // Take the first non-empty line; models occasionally add a trailing note.
    if let firstLine = text.split(separator: "\n").first.map(String.init) {
      text = firstLine.trimmingCharacters(in: .whitespacesAndNewlines)
    }
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

import Foundation

/// Produces Sonia's opening line — the "initial message" of a session.
///
/// Phase 1: generates it with Claude from the user-memory context so the greeting
/// reflects continuity ("yesterday you said you'd reuse box breathing — how did that
/// land?"). Degrades gracefully: a memory-aware template if the model call can't be
/// made (e.g. missing API key), then the plain static greeting if there's no memory.
struct GreetingGenerator {
  let claude: ClaudeClient

  func make(memory: SoniaMemoryContext?, firstName: String?, timeOfDay: TimeOfDay) async -> String {
    guard let memory else { return SoniaSystemPrompt.introduction }

    do {
      let system = Self.greetingSystem(timeOfDay: timeOfDay, memoryContext: memory.systemContext)
      let reply = try await claude.reply(
        system: system,
        history: [ClaudeClient.Turn(role: .user, text: "Generate the opening line now.")]
      )
      let cleaned = reply.trimmingCharacters(in: .whitespacesAndNewlines)
      if cleaned.isEmpty == false { return cleaned }
    } catch {
      print("[Greeting] LLM generation failed, using template: \(error)")
    }
    return Self.template(firstName: firstName, timeOfDay: timeOfDay)
  }

  // MARK: - Prompts

  private static func greetingSystem(timeOfDay: TimeOfDay, memoryContext: String) -> String {
    """
    You are Sonia, a warm AI wellness companion starting a new \(timeOfDay.phrase) check-in with
    someone you have been supporting daily. Speak ONE warm opening line — one or two short
    sentences — that:
    - greets them by first name and fits the \(timeOfDay.phrase),
    - gently references ONE specific, real thread from your memory below (their last mood, the
      small step you suggested, or what's coming up) so they feel remembered,
    - ends with a single, open, low-pressure question.
    Output only plain spoken words — no markdown, lists, emoji, quotation marks, or stage
    directions. Do not recite facts; weave them in naturally, the way someone who remembers would.

    \(memoryContext)
    """
  }

  private static func template(firstName: String?, timeOfDay: TimeOfDay) -> String {
    let name = firstName.map { " \($0)" } ?? ""
    return "Hi\(name), \(timeOfDay.greeting). It's good to have you back — how are you feeling right now?"
  }
}

/// Time-of-day used to shape the greeting, resolved in the user's own timezone.
enum TimeOfDay {
  case morning, afternoon, evening

  static func current(timezoneIdentifier: String?) -> TimeOfDay {
    var calendar = Calendar(identifier: .gregorian)
    if let identifier = timezoneIdentifier, let timezone = TimeZone(identifier: identifier) {
      calendar.timeZone = timezone
    }
    switch calendar.component(.hour, from: Date()) {
    case 5..<12: return .morning
    case 12..<17: return .afternoon
    default: return .evening
    }
  }

  var phrase: String {
    switch self {
    case .morning: return "morning"
    case .afternoon: return "afternoon"
    case .evening: return "evening"
    }
  }

  var greeting: String {
    switch self {
    case .morning: return "good morning"
    case .afternoon: return "good afternoon"
    case .evening: return "good evening"
    }
  }
}

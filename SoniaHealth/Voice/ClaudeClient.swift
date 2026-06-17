import Foundation

/// Minimal Anthropic Messages API client for the Sonia therapist turn.
///
/// NOTE: For a production app the LLM call belongs on a backend so the API key is
/// never shipped in the binary. This direct-call path is for the prototype only.
final class ClaudeClient {
  struct Turn {
    enum Role: String { case user, assistant }
    let role: Role
    let text: String
  }

  enum ClaudeError: Error { case badResponse, emptyContent }

  private let session = URLSession(configuration: .default)

  /// Sends the conversation and returns Sonia's reply text.
  /// `maxTokens` defaults to the short conversational cap; raise it for tasks that
  /// need longer output (e.g. memory consolidation JSON).
  func reply(system: String, history: [Turn], maxTokens: Int = AnthropicConfig.maxTokens) async throws -> String {
    var request = URLRequest(url: AnthropicConfig.endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(AppSecrets.anthropicAPIKey, forHTTPHeaderField: "x-api-key")
    request.setValue(AnthropicConfig.apiVersion, forHTTPHeaderField: "anthropic-version")

    let messages = history.map { ["role": $0.role.rawValue, "content": $0.text] }
    let body: [String: Any] = [
      "model": AnthropicConfig.model,
      "max_tokens": maxTokens,
      "system": system,
      "messages": messages
    ]
    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (data, response) = try await session.data(for: request)
    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
      let detail = String(data: data, encoding: .utf8) ?? ""
      print("[Claude] bad response: \(detail)")
      throw ClaudeError.badResponse
    }

    guard
      let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
      let content = json["content"] as? [[String: Any]]
    else {
      throw ClaudeError.badResponse
    }

    let text = content
      .compactMap { $0["text"] as? String }
      .joined()
      .trimmingCharacters(in: .whitespacesAndNewlines)

    guard text.isEmpty == false else { throw ClaudeError.emptyContent }
    return text
  }
}

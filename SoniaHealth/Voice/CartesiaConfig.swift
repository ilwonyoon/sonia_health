import Foundation

/// Central configuration for Cartesia + Anthropic integration.
///
/// Keys are injected from Config/Secrets.xcconfig into Info.plist and read here.
enum AppSecrets {
  static var cartesiaAPIKey: String {
    value(for: "CartesiaAPIKey")
  }

  static var anthropicAPIKey: String {
    value(for: "AnthropicAPIKey")
  }

  private static func value(for key: String) -> String {
    let raw = Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
    return raw.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

enum CartesiaConfig {
  /// Required version header/param for the Cartesia API.
  static let apiVersion = "2024-11-13"

  // MARK: Models
  static let ttsModel = "sonic-3"
  static let sttModel = "ink-whisper"
  static let language = "en"

  /// "Skylar" — warm, approachable American female. Recommended for therapy.
  static let defaultVoiceID = "e07c00bc-4134-4eae-9ea4-1a55fb45746b"

  // MARK: Audio formats
  /// Microphone capture / STT input.
  static let inputSampleRate: Double = 16_000
  /// TTS playback output.
  static let outputSampleRate: Double = 24_000

  // MARK: Endpoints
  static var ttsWebSocketURL: URL {
    var components = URLComponents(string: "wss://api.cartesia.ai/tts/websocket")!
    components.queryItems = [
      URLQueryItem(name: "api_key", value: AppSecrets.cartesiaAPIKey),
      URLQueryItem(name: "cartesia_version", value: apiVersion)
    ]
    return components.url!
  }

  static var sttWebSocketURL: URL {
    var components = URLComponents(string: "wss://api.cartesia.ai/stt/websocket")!
    components.queryItems = [
      URLQueryItem(name: "api_key", value: AppSecrets.cartesiaAPIKey),
      URLQueryItem(name: "cartesia_version", value: apiVersion),
      URLQueryItem(name: "model", value: sttModel),
      URLQueryItem(name: "language", value: language),
      URLQueryItem(name: "encoding", value: "pcm_s16le"),
      URLQueryItem(name: "sample_rate", value: String(Int(inputSampleRate)))
    ]
    return components.url!
  }
}

enum AnthropicConfig {
  static let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
  static let model = "claude-sonnet-4-5"
  static let apiVersion = "2023-06-01"
  static let maxTokens = 256
}

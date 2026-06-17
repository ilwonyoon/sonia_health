import Foundation

/// Streams TTS audio from Cartesia (sonic-3) over a WebSocket. Emits raw
/// 24 kHz PCM-S16LE chunks via `onChunk` as they arrive, then returns when done.
final class CartesiaTTSClient {
  private var task: URLSessionWebSocketTask?
  private let session = URLSession(configuration: .default)

  private var onChunk: ((Data) -> Void)?
  private var doneContinuation: CheckedContinuation<Void, Never>?
  private var isReceiving = false

  /// Speaks `text` with the given voice. Resolves when the stream completes (or errors).
  func speak(
    _ text: String,
    voiceID: String = CartesiaConfig.defaultVoiceID,
    onChunk: @escaping (Data) -> Void
  ) async {
    self.onChunk = onChunk

    let task = session.webSocketTask(with: CartesiaConfig.ttsWebSocketURL)
    self.task = task
    isReceiving = true
    task.resume()
    receiveLoop()

    sendRequest(text: text, voiceID: voiceID)

    await withCheckedContinuation { continuation in
      doneContinuation = continuation
    }
  }

  func cancel() {
    isReceiving = false
    task?.cancel(with: .normalClosure, reason: nil)
    task = nil
    resolveDone()
  }

  // MARK: - Private

  private func sendRequest(text: String, voiceID: String) {
    let payload: [String: Any] = [
      "context_id": UUID().uuidString,
      "model_id": CartesiaConfig.ttsModel,
      "transcript": text,
      "language": CartesiaConfig.language,
      "voice": ["mode": "id", "id": voiceID],
      "output_format": [
        "container": "raw",
        "encoding": "pcm_s16le",
        "sample_rate": Int(CartesiaConfig.outputSampleRate)
      ]
    ]

    guard let data = try? JSONSerialization.data(withJSONObject: payload),
          let string = String(data: data, encoding: .utf8)
    else {
      resolveDone()
      return
    }

    task?.send(.string(string)) { [weak self] error in
      if let error {
        print("[TTS] send request error: \(error)")
        self?.resolveDone()
      }
    }
  }

  private func receiveLoop() {
    task?.receive { [weak self] result in
      guard let self else { return }
      switch result {
      case let .success(message):
        let finished = self.handle(message: message)
        if finished {
          self.resolveDone()
        } else if self.isReceiving {
          self.receiveLoop()
        }
      case let .failure(error):
        print("[TTS] receive error: \(error)")
        self.resolveDone()
      }
    }
  }

  /// Returns true when the stream is complete.
  private func handle(message: URLSessionWebSocketTask.Message) -> Bool {
    let json: [String: Any]?
    switch message {
    case let .string(text):
      json = text.data(using: .utf8).flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
    case let .data(data):
      json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    @unknown default:
      json = nil
    }

    guard let json, let type = json["type"] as? String else { return false }
    switch type {
    case "chunk":
      if let base64 = json["data"] as? String, let pcm = Data(base64Encoded: base64) {
        onChunk?(pcm)
      }
      return false
    case "done":
      return true
    case "error":
      print("[TTS] error: \(json["error"] ?? "unknown")")
      return true
    default:
      return false
    }
  }

  private func resolveDone() {
    isReceiving = false
    doneContinuation?.resume()
    doneContinuation = nil
  }
}

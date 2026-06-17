import Foundation

/// Streams 16 kHz PCM-S16LE audio to Cartesia STT over a WebSocket and returns the
/// finalized transcript for a single speaking turn.
///
/// Protocol: send binary audio frames, send "finalize" to flush, await `flush_done`,
/// then send "done" and read the concatenated final transcript.
final class CartesiaSTTClient {
  private var task: URLSessionWebSocketTask?
  private let session = URLSession(configuration: .default)

  private var finalSegments: [String] = []
  private var flushContinuation: CheckedContinuation<Void, Never>?
  private var isReceiving = false

  func connect() {
    let task = session.webSocketTask(with: CartesiaConfig.sttWebSocketURL)
    self.task = task
    finalSegments = []
    task.resume()
    isReceiving = true
    receiveLoop()
  }

  func sendAudio(_ data: Data) {
    task?.send(.data(data)) { error in
      if let error { print("[STT] send audio error: \(error)") }
    }
  }

  /// Flushes buffered audio, waits for the transcript, and returns it.
  func finishAndGetTranscript() async -> String {
    task?.send(.string("finalize")) { error in
      if let error { print("[STT] finalize error: \(error)") }
    }

    // Wait for flush_done (bounded so a dropped message can't hang the session).
    await withTaskGroup(of: Void.self) { group in
      group.addTask { await self.waitForFlush() }
      group.addTask { try? await Task.sleep(nanoseconds: 4_000_000_000) }
      await group.next()
      group.cancelAll()
    }

    task?.send(.string("done")) { _ in }
    let transcript = finalSegments.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    return transcript
  }

  func close() {
    isReceiving = false
    task?.cancel(with: .normalClosure, reason: nil)
    task = nil
  }

  // MARK: - Private

  private func waitForFlush() async {
    await withCheckedContinuation { continuation in
      flushContinuation = continuation
    }
  }

  private func resolveFlush() {
    flushContinuation?.resume()
    flushContinuation = nil
  }

  private func receiveLoop() {
    task?.receive { [weak self] result in
      guard let self else { return }
      switch result {
      case let .success(message):
        self.handle(message: message)
        if self.isReceiving { self.receiveLoop() }
      case let .failure(error):
        print("[STT] receive error: \(error)")
        self.resolveFlush()
      }
    }
  }

  private func handle(message: URLSessionWebSocketTask.Message) {
    let json: [String: Any]?
    switch message {
    case let .string(text):
      json = text.data(using: .utf8).flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
    case let .data(data):
      json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    @unknown default:
      json = nil
    }

    guard let json, let type = json["type"] as? String else { return }
    switch type {
    case "transcript":
      let isFinal = (json["is_final"] as? Bool) ?? false
      if isFinal, let text = json["text"] as? String, text.isEmpty == false {
        finalSegments.append(text)
      }
    case "flush_done", "done":
      resolveFlush()
    case "error":
      print("[STT] error: \(json["message"] ?? json["error"] ?? "unknown")")
      resolveFlush()
    default:
      break
    }
  }
}

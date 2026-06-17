import Foundation

/// Loads and persists the live `MemoryJournal` in the app's Documents directory.
/// Pure file I/O — no seed knowledge (the seed stays read-only via `SeedStore`).
enum MemoryStore {
  static let fileName = "sonia_memory.json"

  private static var fileURL: URL? {
    FileManager.default
      .urls(for: .documentDirectory, in: .userDomainMask)
      .first?
      .appendingPathComponent(fileName)
  }

  static func load() -> MemoryJournal {
    guard
      let url = fileURL,
      let data = try? Data(contentsOf: url),
      let journal = try? JSONDecoder().decode(MemoryJournal.self, from: data)
    else { return .empty }
    return journal
  }

  static func save(_ journal: MemoryJournal) {
    guard let url = fileURL else { return }
    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      try encoder.encode(journal).write(to: url, options: [.atomic])
    } catch {
      print("[MemoryStore] save failed: \(error)")
    }
  }
}

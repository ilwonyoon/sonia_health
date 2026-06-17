//
//  JournalModels.swift
//  SoniaHealth
//
//  Models + loader for the Content ("Today") journal page.
//  Source of truth: Resources/SeedData/journal_today.json
//
//  Lifecycle a journal item moves through:
//    notification prompt  ->  OPEN card (question, no timeline stamp)
//                         ->  [user answers]  ->  COMPLETED timeline entry (stamp + answer + points)
//

import Foundation

// MARK: - Item

enum JournalItemType: String, Codable {
  case checkin
  case meditation
  case exercise
  case quote
}

enum JournalCheckinKind: String, Codable {
  case morningIntention
  case eveningReflection
}

enum JournalStatus: String, Codable {
  case open
  case completed
}

struct JournalItem: Codable, Equatable, Identifiable {
  let id: String
  let type: JournalItemType
  let kind: JournalCheckinKind?
  let status: JournalStatus
  let time: String          // "HH:mm"
  let points: Int
  let title: String
  let subtitle: String?
  /// OPEN check-in: the notification question shown on the card (no answer yet).
  let prompt: String?
  /// COMPLETED check-in: the user's saved answer + Sonia's reflection.
  let answer: String?
  let soniaResponse: String?
  /// Quote items.
  let author: String?
  let body: String?
}

// MARK: - Day

struct JournalStats: Codable, Equatable {
  let streakDays: Int
  let points: Int
  let linesJournaled: Int
}

struct CheckInProgress: Codable, Equatable {
  let sectionsLeft: Int
  let note: String
}

struct JournalToday: Codable, Equatable {
  let date: String
  let personaId: String
  let stats: JournalStats
  let checkInProgress: CheckInProgress?
  /// Guided question sets keyed by JournalCheckinKind.rawValue.
  let checkinQuestions: [String: [String]]
  let items: [JournalItem]

  var openItems: [JournalItem] { items.filter { $0.status == .open } }
  var completedItems: [JournalItem] { items.filter { $0.status == .completed } }

  func questions(for kind: JournalCheckinKind) -> [String] {
    checkinQuestions[kind.rawValue] ?? []
  }
}

// MARK: - Loader

enum JournalStore {
  static let resourceName = "journal_today"

  static func load(from bundle: Bundle = .main) throws -> JournalToday {
    guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
      throw SeedDataError.fileNotFound(resourceName)
    }
    do {
      let data = try Data(contentsOf: url)
      return try JSONDecoder().decode(JournalToday.self, from: data)
    } catch let error as SeedDataError {
      throw error
    } catch {
      throw SeedDataError.decodeFailed(underlying: error)
    }
  }

  static func loadOrFatal(from bundle: Bundle = .main) -> JournalToday {
    do { return try load(from: bundle) }
    catch { fatalError("JournalStore failed: \(error.localizedDescription)") }
  }
}

// MARK: - Presentation helpers

extension JournalItem {
  /// Display time like "7:42 AM" from the stored 24h "HH:mm".
  var displayTime: String {
    let parts = time.split(separator: ":")
    guard parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) else { return time }
    let period = h < 12 ? "AM" : "PM"
    let hour12 = h % 12 == 0 ? 12 : h % 12
    return String(format: "%d:%02d %@", hour12, m, period)
  }

  var sfSymbol: String {
    switch type {
    case .meditation: return "leaf.fill"
    case .exercise: return "wind"
    case .quote: return "quote.bubble.fill"
    case .checkin:
      switch kind {
      case .morningIntention: return "sun.max.fill"
      case .eveningReflection: return "moon.stars.fill"
      case .none: return "checkmark.circle.fill"
      }
    }
  }
}

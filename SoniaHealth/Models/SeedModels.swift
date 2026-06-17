//
//  SeedModels.swift
//  SoniaHealth
//
//  Codable models + loader for the prototype seed data.
//  Single source of truth: Resources/SeedData/sonia_seed.json
//  Schema doc: Prototype/DATA_MODEL.md
//
//  All keys are camelCase (matching the JSON), so no custom CodingKeys are needed.
//  Dates are kept as ISO-8601 strings; use `asDate` helpers when a `Date` is needed.
//

import Foundation

// MARK: - Root

struct SeedRoot: Codable, Equatable {
    let meta: SeedMeta
    let user: UserProfile
    let voices: [TherapistVoice]
    let assessments: [Assessment]
    let insights: [Insight]
    let engagement: Engagement
    let sessions: [Session]
}

// MARK: - Meta

struct SeedMeta: Codable, Equatable {
    let appName: String
    let schemaVersion: Int
    let today: String
    let timezone: String
    let notes: String
}

// MARK: - User

struct UserProfile: Codable, Equatable, Identifiable {
    let id: String
    let displayName: String
    let firstName: String
    let fullName: String
    let age: Int
    let pronouns: String
    let location: String
    let timezone: String
    let occupationStatus: String
    let joinedAt: String
    let backstory: String
    let presentingConcerns: [String]
    let goals: [String]
    let riskLevel: String
    let preferredVoiceId: String
    let preferences: UserPreferences
}

struct UserPreferences: Codable, Equatable {
    let morningTime: String
    let eveningTime: String
    let defaultMorningModality: Modality
    let defaultEveningModality: Modality
}

// MARK: - Voices

struct TherapistVoice: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let gender: String
    let ageRange: String
    let style: String
    let descriptor: String
    let sampleLine: String
    /// Placeholder — map to the real Cartesia voice UUID (see Documents/Cartesia).
    let cartesiaVoiceId: String?
}

// MARK: - Assessments

struct Assessment: Codable, Equatable, Identifiable {
    let id: String
    let type: String
    let date: String
    let score: Int
    let severity: String
    let administeredBy: String
}

// MARK: - Insights ("memory" / pattern cards)

struct Insight: Codable, Equatable, Identifiable {
    let id: String
    let createdAt: String
    let category: String
    let title: String
    let body: String
    let evidenceSessionIds: [String]
}

// MARK: - Engagement

struct Engagement: Codable, Equatable {
    let firstActiveDate: String
    let lastActiveDate: String
    let daysActive: Int
    let currentStreak: Int
    let longestStreak: Int
    let totalSessions: Int
    let morningCheckins: Int
    let eveningCheckins: Int
    let deepSessions: Int
    let completionRate: Double
}

// MARK: - Sessions

enum SessionKind: String, Codable, Equatable {
    case morningCheckin
    case eveningCheckin
    case deepSession
}

enum PartOfDay: String, Codable, Equatable {
    case morning
    case evening
}

enum Modality: String, Codable, Equatable {
    case text
    case voice
}

enum TranscriptKind: String, Codable, Equatable {
    case full
    case excerpt
    case none
}

enum Speaker: String, Codable, Equatable {
    case sonia
    case user
}

struct MoodPoint: Codable, Equatable {
    let score: Int   // 1...10
    let label: String
}

struct TranscriptTurn: Codable, Equatable, Identifiable {
    let role: Speaker
    let text: String
    /// Offset from session start in seconds — present on voice excerpts.
    let atOffsetSec: Int?

    // Stable id for SwiftUI lists (no id in JSON; derive from content + offset).
    var id: String { "\(role.rawValue)-\(atOffsetSec ?? -1)-\(text.hashValue)" }
}

struct Session: Codable, Equatable, Identifiable {
    let id: String
    let kind: SessionKind
    let dayIndex: Int
    let date: String
    let partOfDay: PartOfDay
    let startedAt: String
    let durationSec: Int
    let modality: Modality
    let voiceId: String?
    let moodBefore: MoodPoint?
    let moodAfter: MoodPoint?
    let primaryTheme: String
    let topics: [String]
    let steps: [String]
    let techniques: [String]
    let userShared: String
    let soniaReflection: String
    let intention: String?
    let reflection: String?
    let actionItem: String?
    let summary: String?
    let highlights: [String]
    let homework: String?
    let transcriptKind: TranscriptKind
    let transcript: [TranscriptTurn]
}

// MARK: - Loader

enum SeedDataError: Error, LocalizedError {
    case fileNotFound(String)
    case decodeFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "Seed data file '\(name).json' was not found in the app bundle."
        case .decodeFailed(let underlying):
            return "Failed to decode seed data: \(underlying)"
        }
    }
}

enum SeedStore {
    static let resourceName = "sonia_seed"

    /// Loads and decodes the bundled seed JSON. Throws on missing file / decode error.
    static func load(from bundle: Bundle = .main) throws -> SeedRoot {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw SeedDataError.fileNotFound(resourceName)
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(SeedRoot.self, from: data)
        } catch let error as SeedDataError {
            throw error
        } catch {
            throw SeedDataError.decodeFailed(underlying: error)
        }
    }

    /// Convenience for previews/prototyping: loads or crashes with a clear message.
    static func loadOrFatal(from bundle: Bundle = .main) -> SeedRoot {
        do {
            return try load(from: bundle)
        } catch {
            fatalError("SeedStore failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Derived helpers (read-only, immutable)

extension SeedRoot {
    /// The voice the user selected, if present in `voices`.
    var preferredVoice: TherapistVoice? {
        voices.first { $0.id == user.preferredVoiceId }
    }

    /// Sessions grouped by `date` (ISO day string), preserving order.
    var sessionsByDate: [(date: String, sessions: [Session])] {
        var order: [String] = []
        var map: [String: [Session]] = [:]
        for session in sessions {
            if map[session.date] == nil { order.append(session.date) }
            map[session.date, default: []].append(session)
        }
        return order.map { (date: $0, sessions: map[$0] ?? []) }
    }

    func sessions(on date: String) -> [Session] {
        sessions.filter { $0.date == date }
    }

    /// GAD-7 (or any) assessments sorted by date ascending.
    func assessments(ofType type: String) -> [Assessment] {
        assessments.filter { $0.type == type }.sorted { $0.date < $1.date }
    }

    func sessions(forInsight insight: Insight) -> [Session] {
        let ids = Set(insight.evidenceSessionIds)
        return sessions.filter { ids.contains($0.id) }
    }
}

extension Session {
    var moodDelta: Int? {
        guard let before = moodBefore?.score, let after = moodAfter?.score else { return nil }
        return after - before
    }

    var durationMinutes: Int { Int((Double(durationSec) / 60.0).rounded()) }
    var isVoice: Bool { modality == .voice }
    var isCheckin: Bool { kind == .morningCheckin || kind == .eveningCheckin }
}

private let iso8601Formatter: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime]
    return f
}()

extension Session {
    /// Parsed start date, if `startedAt` is a valid ISO-8601 datetime.
    var startedAtDate: Date? { iso8601Formatter.date(from: startedAt) }
}

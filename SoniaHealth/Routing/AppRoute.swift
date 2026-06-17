import Foundation

/// Top-level destinations for the Sonia Health prototype.
enum AppRoute: Equatable {
  case splash
  case onboarding
  case home
  case companion   // Companion "Phone" tab (IMG_3383): photo + quote + slide-to-start
  case content     // Content "Today" tab (IMG_3388): journal — open cards + completed timeline
  case checkin(JournalCheckinKind)  // Guided answer flow (IMG_3369–3373) for an unanswered check-in
  case session
  case history
  case settings
}

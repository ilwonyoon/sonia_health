import SwiftUI

/// One structural design system rendered through four contextual themes.
/// The accent color, icon, and surface treatment swap by context (time of day /
/// flow type); layout and components stay constant. Inject a theme into
/// accent-agnostic components rather than hard-coding a brand color.
///
/// See docs/design-system/themes.md.
enum SRFlowTheme: String, CaseIterable, Equatable {
  case morning      // Morning Intention — gold
  case evening      // Evening Reflection — lilac
  case assessment   // Wellbeing survey — white/cream
  case companion    // Phone & Chat — white-on-photo + glass

  enum SurfaceStyle: Equatable {
    case darkCard            // charcoal cards
    case modalAssessment     // dark, larger type, modal
    case photoScrim          // full-bleed photography + gradient scrim
  }

  enum ProgressStyle: Equatable {
    case segmented           // N segments = N questions
    case continuous          // thin continuous bar
  }

  /// The context accent (gold / lilac / cream-white) injected into CTAs, progress, icons.
  var accent: Color {
    switch self {
    case .morning: return SRColor.accentMorning
    case .evening: return SRColor.accentEvening
    case .assessment: return SRColor.accentAssessment
    case .companion: return SRColor.textOnPhoto
    }
  }

  /// Text/icon color that sits on top of an accent-filled CTA.
  var accentOnText: Color {
    switch self {
    case .companion: return SRColor.textPrimary
    default: return SRColor.textOnAccent
    }
  }

  /// SF Symbol motif for the theme.
  var iconName: String {
    switch self {
    case .morning: return "sun.max"
    case .evening: return "moon.stars"
    case .assessment: return "heart"
    case .companion: return "sparkles"
    }
  }

  var surfaceStyle: SurfaceStyle {
    switch self {
    case .morning, .evening: return .darkCard
    case .assessment: return .modalAssessment
    case .companion: return .photoScrim
    }
  }

  var progressStyle: ProgressStyle {
    switch self {
    case .assessment: return .continuous
    default: return .segmented
    }
  }

  /// Serif display style for the theme's titles.
  var titleStyle: SRTextStyle { .display }

  // MARK: - Context mapping

  /// Pick a theme from a part of day (used for Morning ↔ Evening flows).
  static func forPartOfDay(hour: Int) -> SRFlowTheme {
    (5..<17).contains(hour) ? .morning : .evening
  }
}

import SwiftUI

/// Shared visual primitives for Content journal cards (open + completed):
/// the per-item accent palette, the icon badge, and the points pill.

enum JournalPalette {
  static func accent(for item: JournalItem) -> Color {
    switch item.type {
    case .quote: return SRColor.accentEvening
    case .meditation, .exercise: return SRColor.accentReward
    case .checkin:
      switch item.kind {
      case .morningIntention: return SRColor.accentMorning
      case .eveningReflection: return SRColor.accentEvening
      case .none: return SRColor.brandAccent
      }
    }
  }
}

/// Rounded-square glyph badge. `solid` fills with the full accent (featured open
/// cards); otherwise a soft tint behind an accent-tinted glyph.
struct JournalIconBadge: View {
  let item: JournalItem
  var solid: Bool = false

  var body: some View {
    let accent = JournalPalette.accent(for: item)
    ZStack {
      RoundedRectangle(cornerRadius: SRRadius.md)
        .fill(solid ? accent : accent.opacity(0.18))
        .frame(width: solid ? 34 : 30, height: solid ? 34 : 30)
      Image(systemName: item.sfSymbol)
        .font(.system(size: solid ? 15 : 14, weight: .medium))
        .foregroundStyle(solid ? SRColor.textPrimary : accent)
    }
  }
}

/// "+N" leaf pill. `.reward` is the green earned-points tone (completed entries);
/// `.muted` is the grey to-be-earned tone (open cards).
struct JournalPointsPill: View {
  enum Tone { case reward, muted }

  let points: Int
  var tone: Tone = .reward

  var body: some View {
    HStack(spacing: SRSpacing.s2) {
      Image(systemName: "leaf.fill").font(.system(size: 10))
      Text("+\(points)").font(.system(size: 12, weight: .semibold))
    }
    .foregroundStyle(tone == .reward ? SRColor.accentReward : SRColor.textTertiary)
  }
}

import SwiftUI

/// A COMPLETED journal item: a left-rail timeline entry (time + dot + connector)
/// beside an accent-barred card holding the saved answer + Sonia's reflection.
struct JournalCompletedCard: View {
  let item: JournalItem

  private var accent: Color { JournalPalette.accent(for: item) }

  var body: some View {
    HStack(alignment: .top, spacing: SRSpacing.s12) {
      timeline
      card
    }
  }

  private var timeline: some View {
    VStack(spacing: SRSpacing.s4) {
      Text(item.displayTime)
        .font(.system(size: 11)).foregroundStyle(SRColor.textTertiary)
        .fixedSize()
      Circle().fill(accent).frame(width: 8, height: 8)
      Rectangle().fill(SRColor.borderMuted).frame(width: 1).frame(maxHeight: .infinity)
    }
    .frame(width: 64)
  }

  private var card: some View {
    SRCard {
      VStack(alignment: .leading, spacing: SRSpacing.s8) {
        HStack(spacing: SRSpacing.s8) {
          JournalIconBadge(item: item)
          SRText(item.title, style: .bodyEmphasis)
          Spacer()
          JournalPointsPill(points: item.points)
        }
        if let subtitle = item.subtitle {
          Text(subtitle).font(.system(size: 14)).foregroundStyle(SRColor.textSecondary)
        }
        if let answer = item.answer {
          Text(answer).font(.system(size: 15)).foregroundStyle(SRColor.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
        }
        if let response = item.soniaResponse {
          Text(response).font(.system(size: 13)).italic()
            .foregroundStyle(SRColor.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(SRSpacing.cardPadding)
      .overlay(alignment: .leading) {
        RoundedRectangle(cornerRadius: 2)
          .fill(accent)
          .frame(width: 3)
          .padding(.vertical, SRSpacing.s8)
      }
    }
  }
}

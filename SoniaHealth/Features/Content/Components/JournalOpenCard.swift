import SwiftUI

/// An OPEN journal item: a tappable prompt card whose background is tinted by the
/// item's accent. `.featured` (e.g. today's freshly-created check-in) gets a stronger
/// tint and a solid icon badge; `.standard` is the subtle grid card.
struct JournalOpenCard: View {
  enum Prominence { case standard, featured }

  let item: JournalItem
  var prominence: Prominence = .standard
  var onTap: () -> Void = {}

  private var accent: Color { JournalPalette.accent(for: item) }
  private var tintOpacity: Double { prominence == .featured ? 0.42 : 0.12 }
  private var minHeight: CGFloat { prominence == .featured ? 150 : 132 }
  private var detail: String? { item.prompt ?? item.subtitle ?? item.body }

  var body: some View {
    Button(action: onTap) {
      VStack(alignment: .leading, spacing: SRSpacing.s10) {
        HStack(alignment: .top) {
          JournalIconBadge(item: item, solid: prominence == .featured)
          Spacer()
          VStack(alignment: .trailing, spacing: SRSpacing.s2) {
            Text(item.displayTime)
              .font(.system(size: 12)).foregroundStyle(SRColor.textTertiary)
            JournalPointsPill(points: item.points, tone: .muted)
          }
        }
        SRText(item.title, style: .bodyEmphasis)
        if let detail, !detail.isEmpty {
          Text(detail)
            .font(.system(size: 13))
            .foregroundStyle(SRColor.textSecondary)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
        }
      }
      .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
      .padding(SRSpacing.cardPadding)
      .background(
        RoundedRectangle(cornerRadius: SRRadius.card)
          .fill(accent.opacity(tintOpacity))
      )
    }
    .buttonStyle(.plain)
  }
}

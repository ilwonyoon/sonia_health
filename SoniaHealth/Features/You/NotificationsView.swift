import SwiftUI

/// The "You" tab, reimagined as a Sonia notification feed (the demo's entry point).
/// Each item reads like a push notification *from Sonia* (single narrator); tapping one
/// drops the user straight into that guided-journal experience.
struct NotificationsView: View {
  @EnvironmentObject private var router: AppRouter

  private struct Notice: Identifiable {
    let id = UUID()
    let kind: JournalCheckinKind
    let time: String
    let title: String
    let body: String
  }

  // Sonia-voiced, context-anchored. Tapping routes into the guided journal.
  private let notices: [Notice] = [
    .init(kind: .morningIntention, time: "7:02 AM",
          title: "Good morning, Sarah",
          body: "Let's take a minute to set today's intention together before the day picks up."),
    .init(kind: .eveningReflection, time: "9:14 PM",
          title: "Winding down?",
          body: "When you're ready, let's look back on today — the callback week's a lot to hold.")
  ]

  var body: some View {
    ZStack {
      SRColor.backgroundCanvas.ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: SRSpacing.s16) {
          SRText("Notifications", style: .navigationLargeTitle)
            .padding(.top, SRSpacing.s12)

          VStack(spacing: SRSpacing.s12) {
            ForEach(notices) { notice in
              Button { router.navigate(to: .checkin(notice.kind)) } label: {
                noticeRow(notice)
              }
              .buttonStyle(.plain)
            }
          }
        }
        .padding(.horizontal, SRSpacing.s20)
      }
    }
  }

  private func noticeRow(_ notice: Notice) -> some View {
    SRCard(kind: .default) {
      HStack(alignment: .top, spacing: SRSpacing.s12) {
        appMark
        VStack(alignment: .leading, spacing: SRSpacing.s4) {
          HStack {
            SRText("SONIA", style: .eyebrow, tone: .tertiary)
            Spacer()
            Text(notice.time)
              .font(.system(size: 12))
              .foregroundStyle(SRColor.textTertiary)
          }
          SRText(notice.title, style: .bodyEmphasis)
          Text(notice.body)
            .font(.system(size: 14))
            .foregroundStyle(SRColor.textSecondary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(SRSpacing.cardPadding)
    }
  }

  /// Small "app icon" for the notification — Sonia's mark.
  private var appMark: some View {
    RoundedRectangle(cornerRadius: SRRadius.md, style: .continuous)
      .fill(SRColor.textPrimary)
      .frame(width: 34, height: 34)
      .overlay(
        Image(systemName: "waveform")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(SRColor.backgroundCanvas)
      )
  }
}

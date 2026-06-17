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
    let title: String     // verb-form, like "Claude responded" — what Sonia did
    let message: String
  }

  // Sonia-voiced, context-anchored. Tapping routes into the guided journal.
  private let notices: [Notice] = [
    .init(kind: .morningIntention, time: "7:02 AM",
          title: "Sonia checked in",
          message: "Good morning, Sarah. Let's take a minute to set today's intention together before the day picks up."),
    .init(kind: .eveningReflection, time: "9:14 PM",
          title: "Sonia reached out",
          message: "Winding down? When you're ready, let's look back on today — the callback week's a lot to hold.")
  ]

  var body: some View {
    ZStack {
      SRColor.backgroundCanvas.ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: SRSpacing.s12) {
          SRText("Notifications", style: .navigationLargeTitle)
            .padding(.top, SRSpacing.s12)
            .padding(.horizontal, SRSpacing.s4)

          ForEach(notices) { notice in
            Button { router.navigate(to: .checkin(notice.kind)) } label: {
              noticeRow(notice)
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.horizontal, SRSpacing.s16)
      }
    }
  }

  /// iOS-notification layout: app icon on the left; bold sender + time on the first row,
  /// the message below. ~16pt inset.
  private func noticeRow(_ notice: Notice) -> some View {
    HStack(alignment: .top, spacing: SRSpacing.s12) {
      appMark
      VStack(alignment: .leading, spacing: SRSpacing.s2) {
        HStack(alignment: .firstTextBaseline) {
          SRText(notice.title, style: .bodyEmphasis)
          Spacer()
          Text(notice.time)
            .font(.system(size: 12))
            .foregroundStyle(SRColor.textTertiary)
        }
        Text(notice.message)
          .font(.system(size: 14))
          .foregroundStyle(SRColor.textSecondary)
          .multilineTextAlignment(.leading)
          .lineLimit(4)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding(SRSpacing.s16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: SRRadius.lg, style: .continuous)
        .fill(SRColor.backgroundElevated)
    )
  }

  /// Small "app icon" for the notification — Sonia's mark.
  private var appMark: some View {
    RoundedRectangle(cornerRadius: SRRadius.md, style: .continuous)
      .fill(SRColor.textPrimary)
      .frame(width: 38, height: 38)
      .overlay(
        Image(systemName: "waveform")
          .font(.system(size: 17, weight: .semibold))
          .foregroundStyle(SRColor.backgroundCanvas)
      )
  }
}

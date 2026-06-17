import SwiftUI

/// Companion "Phone" tab — faithful recreation of IMG_3383.
/// Full-bleed moody backdrop + scrim, avatar + glass name chip, serif italic
/// pull-quote, slide-to-start control, and the 5-tab glass bar.
///
/// NOTE: the backdrop is a placeholder gradient (no stock photo wired yet);
/// drop a photo into Assets and swap `backdrop` to match the reference exactly.
struct CompanionPhoneView: View {
  @EnvironmentObject private var router: AppRouter

  var body: some View {
    ZStack {
      CompanionBackdrop()

      VStack(spacing: 0) {
        SRCompanionHeader(name: "Michelle")
          .padding(.top, SRSpacing.s24)

        Spacer(minLength: SRSpacing.s24)

        quote
          .padding(.horizontal, SRSpacing.s32)

        Spacer(minLength: SRSpacing.s24)

        SRSlideToStart(title: "Slide to start session") {
          router.navigate(to: .session)
        }
        .padding(.horizontal, SRSpacing.s16)
        .padding(.bottom, SRSpacing.s16)
      }
    }
  }

  // MARK: - Quote

  private var quote: some View {
    VStack(spacing: SRSpacing.s12) {
      SRText(
        "I want them to think of me as someone you can always trust.",
        style: .quote,
        tone: .primary
      )
      .multilineTextAlignment(.center)

      SRText("— You", style: .supporting, tone: .secondary)
    }
  }
}

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
      backdrop.ignoresSafeArea()
      scrim.ignoresSafeArea()

      VStack(spacing: 0) {
        header
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

        SRTabBarGlass(selected: .phone) { tab in
          if tab == .you || tab == .settings { router.present(sheet: .settings) }
        }
        .padding(.horizontal, SRSpacing.s16)
        .padding(.bottom, SRSpacing.s8)
      }
    }
  }

  // MARK: - Header (avatar + name chip)

  private var header: some View {
    VStack(spacing: SRSpacing.s12) {
      ZStack {
        Circle()
          .fill(
            LinearGradient(
              colors: [Color(red: 0.62, green: 0.66, blue: 0.74),
                       Color(red: 0.36, green: 0.40, blue: 0.48)],
              startPoint: .top, endPoint: .bottom
            )
          )
        SRIcon(systemName: "person.fill", color: .white.opacity(0.9), size: 30)
      }
      .frame(width: 64, height: 64)
      .overlay(Circle().stroke(.white.opacity(0.7), lineWidth: 2))
      .shadow(color: .black.opacity(0.3), radius: 10, y: 4)

      nameChip
    }
  }

  private var nameChip: some View {
    let shape = Capsule(style: .continuous)
    let label = SRText("Michelle", style: .controlLabel, tone: .inverse)
      .padding(.horizontal, SRSpacing.s16)
      .padding(.vertical, SRSpacing.s8)
    return Group {
      if #available(iOS 26.0, *) {
        label.glassEffect(.regular, in: shape)
      } else {
        label.background(.ultraThinMaterial, in: shape)
      }
    }
  }

  // MARK: - Quote

  private var quote: some View {
    VStack(spacing: SRSpacing.s12) {
      SRText(
        "I want them to think of me as someone you can always trust.",
        style: .quote,
        tone: .inverse
      )
      .multilineTextAlignment(.center)

      SRText("— You", style: .supporting, tone: .inverse)
        .opacity(0.6)
    }
  }

  // MARK: - Backdrop (placeholder for the reference photo)

  private var backdrop: some View {
    LinearGradient(
      colors: [
        Color(red: 0.38, green: 0.42, blue: 0.50),
        Color(red: 0.20, green: 0.23, blue: 0.30),
        Color(red: 0.08, green: 0.09, blue: 0.13)
      ],
      startPoint: .top, endPoint: .bottom
    )
  }

  private var scrim: some View {
    LinearGradient(
      colors: [.black.opacity(0.35), .clear, .clear, .black.opacity(0.55)],
      startPoint: .top, endPoint: .bottom
    )
  }
}

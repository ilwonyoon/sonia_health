import SwiftUI

struct HomeView: View {
  @EnvironmentObject private var router: AppRouter

  var body: some View {
    VStack(spacing: 0) {
      SRNavigationGlass(
        title: "Sonia",
        leading: {
          SRGlassIconButton(systemName: "sparkles", accessibilityLabel: "Sonia") {}
        },
        trailing: {
          SRGlassIconButton(systemName: "gearshape", accessibilityLabel: "Settings") {
            router.present(sheet: .settings)
          }
        }
      )
      .padding(.horizontal, SRSpacing.s16)
      .padding(.top, SRSpacing.s8)

      ScrollView {
        VStack(alignment: .leading, spacing: SRSpacing.sectionGap) {
          VStack(alignment: .leading, spacing: SRSpacing.s8) {
            SRText("Good to see you.", style: .homeMessage)
            SRText(
              "Take a moment for yourself. I'm here whenever you want to talk.",
              style: .body,
              tone: .secondary
            )
          }
          .padding(.top, SRSpacing.s24)

          sessionCard

          SRText("How it works", style: .sectionTitle, tone: .secondary)
          VStack(spacing: SRSpacing.s12) {
            stepRow(icon: "mic.fill", title: "Speak naturally", detail: "Tap to talk, tap again when you're done.")
            stepRow(icon: "waveform", title: "Sonia listens", detail: "Warm, judgment-free, evidence-based support.")
            stepRow(icon: "heart.text.square", title: "Feel a little lighter", detail: "Short reflections to ground your day.")
          }

          disclaimer
        }
        .padding(.horizontal, SRSpacing.s16)
        .padding(.bottom, 120)
      }
    }
    .overlay(alignment: .bottom) { bottomBar }
  }

  private var sessionCard: some View {
    SRCard(kind: .brand) {
      VStack(alignment: .leading, spacing: SRSpacing.s16) {
        HStack(spacing: SRSpacing.s16) {
          VoiceOrbView(level: 0.1, isActive: true)
            .frame(width: 64, height: 64)
          VStack(alignment: .leading, spacing: SRSpacing.s4) {
            SRText("Start a session", style: .sectionTitleMedium)
            SRText("A few minutes of calm, voice to voice.", style: .supporting, tone: .secondary)
          }
          Spacer(minLength: 0)
        }
        SRButton("Begin talking", kind: .primary, isFullWidth: true) {
          router.navigate(to: .session)
        }
      }
    }
  }

  private func stepRow(icon: String, title: String, detail: String) -> some View {
    SRCard(kind: .default) {
      HStack(spacing: SRSpacing.s16) {
        SRIcon(systemName: icon, color: SRColor.brandAction, size: 18)
          .frame(width: 28)
        VStack(alignment: .leading, spacing: SRSpacing.s2) {
          SRText(title, style: .bodyEmphasis)
          SRText(detail, style: .supporting, tone: .secondary)
        }
        Spacer(minLength: 0)
      }
    }
  }

  private var disclaimer: some View {
    SRText(
      "Sonia is an AI wellness companion, not a licensed therapist or a substitute for professional care. In a crisis, call or text 988 (US) or your local emergency number.",
      style: .caption,
      tone: .tertiary
    )
    .padding(.top, SRSpacing.s8)
  }

  private var bottomBar: some View {
    SRBottomBarGlass {
      SRGlassIconButton(systemName: "house.fill", accessibilityLabel: "Home") {
        router.navigate(to: .home)
      }
      Spacer(minLength: 0)
      SRButton("Talk to Sonia", kind: .primary) {
        router.navigate(to: .session)
      }
      Spacer(minLength: 0)
      SRGlassIconButton(systemName: "clock.arrow.circlepath", accessibilityLabel: "History") {}
    }
    .padding(.horizontal, SRSpacing.s16)
    .padding(.bottom, SRSpacing.s8)
  }
}

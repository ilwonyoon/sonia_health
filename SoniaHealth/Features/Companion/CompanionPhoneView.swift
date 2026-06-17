import SwiftUI

/// Companion "Phone" tab — redesigned per IMG_3468.
/// No big avatar: a calm canvas with three top chips (profile · agent name · Sonia mark)
/// and one clear call button at the bottom. Tapping the name chip opens the agent picker.
/// (Chat / "Send a text" is intentionally out of scope for now.)
struct CompanionPhoneView: View {
  @EnvironmentObject private var router: AppRouter
  @State private var showAgentSelector = false
  @State private var agentName = "Sonia"

  private var agents: [AgentSelectorSheet.Agent] {
    [.init(id: "sonia", name: "Sonia",
           blurb: "A warm, evidence-based companion for calmer days.")]
  }

  var body: some View {
    ZStack {
      CompanionBackdrop()

      VStack(spacing: 0) {
        topChips
          .padding(.horizontal, SRSpacing.s16)
          .padding(.top, SRSpacing.s8)

        Spacer(minLength: 0)

        callButton
          .padding(.bottom, SRSpacing.s32)
      }
    }
    .sheet(isPresented: $showAgentSelector) {
      AgentSelectorSheet(agents: agents) { agent in
        agentName = agent.name
      }
    }
  }

  // MARK: - Top chips

  private var topChips: some View {
    Button { showAgentSelector = true } label: {
      HStack(spacing: SRSpacing.s4) {
        SRText(agentName, style: .bodyEmphasis)
        Image(systemName: "chevron.down")
          .font(.system(size: 12, weight: .semibold))
          .foregroundStyle(SRColor.textSecondary)
      }
      .padding(.horizontal, SRSpacing.s16)
      .padding(.vertical, SRSpacing.s10)
      .glassCapsule()
    }
    .buttonStyle(.plain)
    .frame(maxWidth: .infinity)
  }

  // MARK: - Call button

  private var callButton: some View {
    VStack(spacing: SRSpacing.s12) {
      Button { router.navigate(to: .session) } label: {
        ZStack {
          Circle()
            .fill(SRColor.backgroundElevated)
            .shadow(color: .black.opacity(0.12), radius: 16, y: 6)
          Image(systemName: "phone.fill")
            .font(.system(size: 26, weight: .semibold))
            .foregroundStyle(SRColor.brandAccent)   // green icon = start a call (pairs with red end-call)
        }
        .frame(width: 76, height: 76)
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Start a call")

      SRText("Start a call", style: .supporting, tone: .secondary)
    }
  }
}

// MARK: - Glass capsule helper

private extension View {
  @ViewBuilder
  func glassCapsule() -> some View {
    if #available(iOS 26.0, *) {
      glassEffect(.regular.interactive(), in: Capsule(style: .continuous))
    } else {
      background(.ultraThinMaterial, in: Capsule(style: .continuous))
    }
  }
}

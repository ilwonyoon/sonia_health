import SwiftUI

/// The hands-free guided-journal "call" UI. Sonia speaks; the user just talks back. The orb
/// carries the state (speaking / listening / thinking) so a pause reads as "being heard,"
/// not a stall. Held to the ear the screen is off (proximity); on speaker this is what shows.
struct GuidedJournalCallView: View {
  @EnvironmentObject private var router: AppRouter
  let kind: JournalCheckinKind

  @StateObject private var vm: GuidedJournalCallViewModel

  init(kind: JournalCheckinKind) {
    self.kind = kind
    _vm = StateObject(wrappedValue: GuidedJournalCallViewModel(kind: kind))
  }

  private var accent: Color {
    kind == .morningIntention ? SRColor.accentMorning : SRColor.accentEvening
  }
  private var title: String {
    kind == .morningIntention ? "Morning Intention" : "Evening Reflection"
  }
  private var orbLevel: Float {
    switch vm.phase {
    case .listening: return max(0.18, vm.inputLevel)
    case .speaking:  return 0.4
    default:         return 0.2
    }
  }

  var body: some View {
    ZStack {
      SRColor.backgroundCanvas.ignoresSafeArea()

      VStack(spacing: SRSpacing.s24) {
        topBar
        Spacer()

        VoiceOrbView(level: orbLevel, isActive: vm.phase != .ended)
          .frame(width: 150, height: 150)

        caption

        Spacer()
        controls
      }
      .padding(.horizontal, SRSpacing.s20)
      .padding(.top, SRSpacing.s8)
      .padding(.bottom, SRSpacing.s20)
      .animation(.easeInOut(duration: 0.25), value: vm.phase)
    }
    .task { await vm.start() }
    .onDisappear { vm.end() }
    .onChange(of: vm.micDenied) { _, denied in
      // No mic → fall back to the typed flow cleanly.
      if denied { router.navigate(to: .checkin(kind)) }
    }
  }

  // MARK: Top bar

  private var topBar: some View {
    HStack {
      SRText(title, style: .controlLabel)
      Spacer()
      if vm.phase != .ended {
        Text("Question \(min(vm.index + 1, vm.total)) of \(vm.total)")
          .font(.system(size: 13)).foregroundStyle(SRColor.textTertiary)
      }
    }
  }

  // MARK: Caption

  @ViewBuilder
  private var caption: some View {
    switch vm.phase {
    case .connecting:
      status("Connecting…")
    case .speaking:
      VStack(spacing: SRSpacing.s8) {
        SRText(vm.currentQuestion, style: .questionTitle)
          .multilineTextAlignment(.center)
        status("Sonia")
      }
    case .listening:
      VStack(spacing: SRSpacing.s8) {
        Text(vm.liveCaption.isEmpty ? " " : vm.liveCaption)
          .font(.system(size: 18))
          .foregroundStyle(SRColor.textPrimary)
          .multilineTextAlignment(.center)
          .frame(minHeight: 60)
        status("Listening… just speak")
      }
    case .thinking:
      status("…")
    case .ended:
      VStack(spacing: SRSpacing.s8) {
        Image(systemName: "checkmark.circle.fill")
          .font(.system(size: 32)).foregroundStyle(accent)
        SRText("All set", style: .questionTitle)
      }
    case .failed:
      status("Couldn't start the call.")
    }
  }

  private func status(_ text: String) -> some View {
    Text(text)
      .font(.system(size: 14))
      .foregroundStyle(SRColor.textTertiary)
  }

  // MARK: Controls

  @ViewBuilder
  private var controls: some View {
    if vm.phase == .ended {
      Button { finish() } label: {
        Text("Done")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(SRColor.textOnAccent)
          .frame(maxWidth: .infinity)
          .padding(.vertical, SRSpacing.s16)
          .background(Capsule().fill(accent))
      }
      .buttonStyle(.plain)
      .padding(.horizontal, SRSpacing.s12)
    } else {
      HStack(spacing: SRSpacing.s32) {
        circleControl(
          icon: vm.isSpeakerOn ? "speaker.wave.2.fill" : "ear",
          tint: SRColor.textPrimary,
          bg: SRColor.backgroundElevated
        ) { vm.toggleSpeaker() }

        circleControl(icon: "phone.down.fill", tint: .white, bg: .red) { finish() }

        circleControl(
          icon: "keyboard",
          tint: SRColor.textPrimary,
          bg: SRColor.backgroundElevated
        ) {
          vm.end()
          router.navigate(to: .checkin(kind))
        }
      }
    }
  }

  private func circleControl(icon: String, tint: Color, bg: Color, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Image(systemName: icon)
        .font(.system(size: 20, weight: .semibold))
        .foregroundStyle(tint)
        .frame(width: 60, height: 60)
        .background(Circle().fill(bg))
    }
    .buttonStyle(.plain)
  }

  private func finish() {
    vm.end()
    router.navigate(to: .content)
  }
}

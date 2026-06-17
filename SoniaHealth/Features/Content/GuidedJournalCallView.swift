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

  var body: some View {
    ZStack {
      SRColor.backgroundCanvas.ignoresSafeArea()

      VStack(spacing: SRSpacing.s24) {
        topBar
        Spacer()

        caption

        Spacer()

        if vm.phase != .ended {
          Text(timeString(vm.secondsRemaining))
            .font(.system(size: 15, weight: .medium, design: .monospaced))
            .foregroundStyle(SRColor.textTertiary)
            .monospacedDigit()
        }
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
    SRText(title, style: .navigationTitle)
      .frame(maxWidth: .infinity, alignment: .center)
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

  private func timeString(_ seconds: Int) -> String {
    let s = max(0, seconds)
    return String(format: "%d:%02d", s / 60, s % 60)
  }
}

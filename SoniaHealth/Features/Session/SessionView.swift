import SwiftUI

struct SessionView: View {
  @EnvironmentObject private var router: AppRouter
  @StateObject private var model = VoiceSessionViewModel()

  var body: some View {
    VStack(spacing: 0) {
      SRNavigationGlass(
        title: "Session with Sonia",
        leading: {
          SRGlassIconButton(systemName: "chevron.left", accessibilityLabel: "Back") {
            model.end()
            router.navigate(to: .home)
          }
        },
        trailing: {
          SRGlassIconButton(systemName: "xmark", accessibilityLabel: "End session") {
            model.end()
            router.navigate(to: .home)
          }
        }
      )
      .padding(.horizontal, SRSpacing.s16)
      .padding(.top, SRSpacing.s8)

      Spacer(minLength: SRSpacing.s16)

      VoiceOrbView(level: model.inputLevel, isActive: isOrbActive)
        .frame(width: 180, height: 180)

      SRText(model.statusText, style: .bodyEmphasis, tone: .secondary)
        .padding(.top, SRSpacing.s24)

      transcriptView
        .padding(.top, SRSpacing.s16)

      Spacer(minLength: SRSpacing.s16)

      controls
        .padding(.horizontal, SRSpacing.s16)
        .padding(.bottom, SRSpacing.s24)
    }
    .task { await model.begin() }
    .alert("Microphone needed", isPresented: $model.permissionDenied) {
      Button("OK") { router.navigate(to: .home) }
    } message: {
      Text("Enable microphone access in Settings to talk with Sonia.")
    }
  }

  private var isOrbActive: Bool {
    switch model.state {
    case .listening, .speaking, .thinking, .connecting: return true
    default: return false
    }
  }

  private var transcriptView: some View {
    ScrollViewReader { proxy in
      ScrollView {
        VStack(spacing: SRSpacing.s12) {
          ForEach(model.transcript) { line in
            transcriptRow(line)
              .id(line.id)
          }
        }
        .padding(.horizontal, SRSpacing.s16)
      }
      .frame(maxHeight: 240)
      .onChange(of: model.transcript) { _, lines in
        if let last = lines.last {
          withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
        }
      }
    }
  }

  private func transcriptRow(_ line: VoiceSessionViewModel.Line) -> some View {
    HStack {
      if line.speaker == .you { Spacer(minLength: SRSpacing.s32) }
      SRCard(kind: line.speaker == .sonia ? .brand : .subtle) {
        SRText(line.text, style: .body, tone: .primary)
      }
      if line.speaker == .sonia { Spacer(minLength: SRSpacing.s32) }
    }
  }

  private var controls: some View {
    VStack(spacing: SRSpacing.s12) {
      Button(action: model.toggleMic) {
        ZStack {
          Circle()
            .fill(micButtonColor)
            .frame(width: 76, height: 76)
            .shadow(color: micButtonColor.opacity(0.4), radius: 16, x: 0, y: 8)
          SRIcon(systemName: micIcon, color: .white, size: 28)
        }
      }
      .buttonStyle(.plain)
      .disabled(isMicDisabled)
      .opacity(isMicDisabled ? 0.5 : 1)

      SRText(micHint, style: .caption, tone: .tertiary)
    }
  }

  private var micIcon: String {
    switch model.state {
    case .listening: return "stop.fill"
    case .speaking, .thinking: return "waveform"
    default: return "mic.fill"
    }
  }

  private var micButtonColor: Color {
    switch model.state {
    case .listening: return SRColor.feedbackDangerText
    default: return SRColor.brandAction
    }
  }

  private var isMicDisabled: Bool {
    switch model.state {
    case .idle, .listening: return false
    default: return true
    }
  }

  private var micHint: String {
    switch model.state {
    case .listening: return "Tap to send"
    case .idle: return "Tap and speak"
    default: return " "
    }
  }
}

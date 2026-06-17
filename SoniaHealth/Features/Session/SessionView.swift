import SwiftUI

/// Live voice session — faithful recreation of IMG_3384 (Companion call):
/// moody photo backdrop, companion header, top-right pause, right-side glass control
/// rail, and a bottom live caption. Tap anywhere (or the touch control) to speak.
struct SessionView: View {
  @EnvironmentObject private var router: AppRouter
  @StateObject private var model = VoiceSessionViewModel()

  var body: some View {
    ZStack {
      CompanionBackdrop(dim: 0.25)
        .contentShape(Rectangle())
        .onTapGesture { model.toggleMic() }

      VStack(spacing: 0) {
        SRCompanionHeader(name: "Sonia")
          .padding(.top, SRSpacing.s12)
          .frame(maxWidth: .infinity)
          .overlay(alignment: .topTrailing) {
            SRGlassIconButton(systemName: "pause.fill", accessibilityLabel: "End session",
                              foregroundColor: SRColor.textPrimary) {
              model.end()
              router.navigate(to: .companion)
            }
            .padding(.trailing, SRSpacing.s16)
          }

        Spacer(minLength: 0)

        caption
          .padding(.horizontal, SRSpacing.s20)
          .padding(.bottom, SRSpacing.s32)
      }

      controlRail
    }
    .task { await model.begin() }
    .alert("Microphone needed", isPresented: $model.permissionDenied) {
      Button("OK") { router.navigate(to: .companion) }
    } message: {
      Text("Enable microphone access in Settings to talk with Sonia. (The Simulator has no microphone — run on a device for live voice.)")
    }
  }

  // MARK: - Right-side glass control rail

  private var controlRail: some View {
    VStack(spacing: SRSpacing.s12) {
      SRGlassIconButton(systemName: micIcon, emphasis: .prominent,
                        accessibilityLabel: "Tap to speak",
                        foregroundColor: micTint) { model.toggleMic() }
      SRGlassIconButton(systemName: "text.bubble", accessibilityLabel: "Captions",
                        foregroundColor: SRColor.textPrimary) {}
      SRGlassIconButton(systemName: "square.and.arrow.up", accessibilityLabel: "Share",
                        foregroundColor: SRColor.textPrimary) {}
      SRGlassIconButton(systemName: "gearshape", accessibilityLabel: "Settings",
                        foregroundColor: SRColor.textPrimary) { router.present(sheet: .settings) }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
    .padding(.trailing, SRSpacing.s16)
  }

  // MARK: - Live caption

  @ViewBuilder
  private var caption: some View {
    if model.state == .speaking, model.captionWords.isEmpty == false {
      karaokeCaption
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(.easeOut(duration: 0.28), value: model.revealedWordCount)
    } else {
      SRText(captionText, style: .sectionTitleMedium, tone: .primary)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(.easeInOut(duration: 0.2), value: captionText)
    }
  }

  /// The whole sentence laid out once; spoken words sit at full strength, the rest stay
  /// dim. Because every word is present from the start, the layout never reflows — words
  /// just light up in place.
  private var karaokeCaption: Text {
    let words = model.captionWords
    let revealed = model.revealedWordCount
    return words.indices.reduce(Text("")) { line, i in
      let token = i == 0 ? words[i] : " " + words[i]
      let lit = i < revealed
      return line + Text(token)
        .foregroundColor(lit ? SRColor.textPrimary : SRColor.textPrimary.opacity(0.25))
    }
    .font(.system(size: 17, weight: .semibold))
  }

  private var captionText: String {
    switch model.state {
    case .connecting:
      return "Connecting…"
    case .listening:
      return model.liveCaption.isEmpty ? "Listening…" : model.liveCaption
    case .thinking:
      return model.liveCaption.isEmpty ? "…" : model.liveCaption
    case .speaking:
      return model.liveCaption.isEmpty
        ? (model.transcript.last?.text ?? "")
        : model.liveCaption
    default:
      return model.transcript.last?.text ?? SoniaSystemPrompt.introduction
    }
  }

  private var micIcon: String {
    switch model.state {
    case .listening: return "stop.fill"
    case .speaking, .thinking: return "waveform"
    default: return "hand.tap.fill"
    }
  }

  private var micTint: Color {
    model.state == .listening ? SRColor.brandAccent : SRColor.textPrimary
  }
}

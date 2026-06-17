import SwiftUI

/// Live voice session — redesigned per IMG_3471. Hands-free call: a name chip on top,
/// the live caption in the middle, and a clean bottom control row — a clear red
/// end-call button, plus mic-mute and speaker toggles (no "pause").
struct SessionView: View {
  @EnvironmentObject private var router: AppRouter
  @StateObject private var model = VoiceSessionViewModel()

  var body: some View {
    ZStack {
      CompanionBackdrop()

      VStack(spacing: 0) {
        nameChip
          .padding(.top, SRSpacing.s12)

        Spacer(minLength: 0)

        caption
          .padding(.horizontal, SRSpacing.s20)

        Spacer(minLength: 0)

        controlBar
          .padding(.horizontal, SRSpacing.s24)
          .padding(.bottom, SRSpacing.s16)
      }
    }
    .task { await model.begin() }
    .alert("Microphone needed", isPresented: $model.permissionDenied) {
      Button("OK") { endCall() }
    } message: {
      Text("Enable microphone access in Settings to talk with Sonia. (The Simulator has no microphone — run on a device for live voice.)")
    }
  }

  // MARK: - Top name chip

  private var nameChip: some View {
    SRText("Sonia", style: .controlLabel)
      .padding(.horizontal, SRSpacing.s16)
      .padding(.vertical, SRSpacing.s8)
      .glassCapsule()
  }

  // MARK: - Bottom controls

  private var controlBar: some View {
    HStack(spacing: 0) {
      glassControl(
        systemName: model.isMuted ? "mic.slash.fill" : "mic.fill",
        label: model.isMuted ? "Unmute" : "Mute",
        tint: model.isMuted ? Color.red : SRColor.textPrimary
      ) { model.toggleMute() }
        .frame(maxWidth: .infinity)

      endCallButton
        .frame(maxWidth: .infinity)

      glassControl(
        systemName: model.isSpeakerOn ? "speaker.wave.2.fill" : "speaker.slash.fill",
        label: "Speaker",
        tint: SRColor.textPrimary
      ) { model.toggleSpeaker() }
        .frame(maxWidth: .infinity)
    }
  }

  /// A 64pt glass circle control (mic / speaker), matching the end-call button's size.
  private func glassControl(systemName: String, label: String, tint: Color,
                            action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Image(systemName: systemName)
        .font(.system(size: 24, weight: .semibold))
        .foregroundStyle(tint)
        .frame(width: 64, height: 64)
        .contentShape(Circle())
    }
    .buttonStyle(.plain)
    .glassCircle()
    .accessibilityLabel(label)
  }

  private var endCallButton: some View {
    Button(action: endCall) {
      ZStack {
        Circle()
          .fill(Color.red)   // standard phone hang-up red (systemRed)
          .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
        Image(systemName: "phone.down.fill")
          .font(.system(size: 24, weight: .semibold))
          .foregroundStyle(.white)
      }
      .frame(width: 64, height: 64)
    }
    .buttonStyle(.plain)
    .accessibilityLabel("End call")
  }

  private func endCall() {
    model.end()
    router.navigate(to: .companion)
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

  /// The whole sentence laid out once; spoken words sit at full strength, the rest dim —
  /// so the layout never reflows, words just light up in place.
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
      if model.isMuted { return "Muted" }
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
}

// MARK: - Glass capsule helper

private extension View {
  @ViewBuilder
  func glassCapsule() -> some View {
    if #available(iOS 26.0, *) {
      glassEffect(.regular, in: Capsule(style: .continuous))
    } else {
      background(.ultraThinMaterial, in: Capsule(style: .continuous))
    }
  }

  @ViewBuilder
  func glassCircle() -> some View {
    if #available(iOS 26.0, *) {
      glassEffect(.regular.interactive(), in: Circle())
    } else {
      background(.ultraThinMaterial, in: Circle())
    }
  }
}

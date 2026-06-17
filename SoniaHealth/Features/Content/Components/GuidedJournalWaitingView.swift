import SwiftUI

/// The "waiting" moment while a guided-journal question is being prepared. Instead of a
/// spinner, a slow breathing pulse + a calm line — so the pause feels like the companion
/// is taking in what was said, not like loading. Copy shifts by kind and phase.
struct GuidedJournalWaitingView: View {
  let kind: JournalCheckinKind
  let phase: GuidedJournalSession.Phase
  let accent: Color

  @State private var breathing = false

  var body: some View {
    VStack(spacing: SRSpacing.s16) {
      ZStack {
        Circle()
          .fill(accent.opacity(0.18))
          .frame(width: 72, height: 72)
          .scaleEffect(breathing ? 1.0 : 0.72)
          .opacity(breathing ? 0.5 : 1.0)
        Circle()
          .fill(accent.opacity(0.9))
          .frame(width: 12, height: 12)
      }
      Text(message)
        .font(.system(size: 15))
        .foregroundStyle(SRColor.textSecondary)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .onAppear {
      withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
        breathing = true
      }
    }
  }

  private var message: String {
    switch (phase, kind) {
    case (.loading, .morningIntention):  return "Preparing your morning…"
    case (.loading, .eveningReflection): return "Preparing your evening…"
    case (.generating, .morningIntention):  return "Taking in what you said…"
    case (.generating, .eveningReflection): return "Sitting with that…"
    default: return ""
    }
  }
}

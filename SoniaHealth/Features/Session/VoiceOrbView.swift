import SwiftUI

/// Breathing gradient orb that reacts to audio level. The visual centerpiece of a session.
struct VoiceOrbView: View {
  let level: Float
  let isActive: Bool

  @State private var breathe = false

  private var scale: CGFloat {
    let base: CGFloat = breathe ? 1.04 : 0.96
    return base + CGFloat(min(level, 1)) * 0.28
  }

  var body: some View {
    ZStack {
      Circle()
        .fill(SRColor.brandAction.opacity(0.18))
        .scaleEffect(scale * 1.25)
        .blur(radius: 18)

      Circle()
        .fill(
          RadialGradient(
            colors: [SRColor.brandAccent, SRColor.brandAction],
            center: .center,
            startRadius: 4,
            endRadius: 90
          )
        )
        .overlay(
          Circle().stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
        .scaleEffect(scale)
        .shadow(color: SRColor.brandAction.opacity(0.35), radius: 24, x: 0, y: 10)
    }
    .animation(.easeInOut(duration: 0.18), value: level)
    .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: breathe)
    .onAppear { if isActive { breathe = true } }
  }
}

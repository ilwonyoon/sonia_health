import SwiftUI

/// Slide-to-start control (IMG_3383): a glass capsule track with a leading white
/// circular thumb the user drags to the end to trigger `onComplete`.
struct SRSlideToStart: View {
  let title: String
  let onComplete: () -> Void

  private let thumbSize: CGFloat = 52
  private let trackHeight: CGFloat = 64
  @State private var dragX: CGFloat = 0

  var body: some View {
    GeometryReader { geo in
      let maxX = max(0, geo.size.width - thumbSize - 6)
      ZStack(alignment: .leading) {
        track
        SRText(title, style: .bodyEmphasis, tone: .primary)
          .frame(maxWidth: .infinity)
          .opacity(1 - Double(dragX / max(maxX, 1)) * 1.2)

        thumb
          .offset(x: 3 + dragX)
          .gesture(
            DragGesture()
              .onChanged { value in
                dragX = min(max(0, value.translation.width), maxX)
              }
              .onEnded { _ in
                if dragX > maxX * 0.85 {
                  withAnimation(.spring(response: 0.3)) { dragX = maxX }
                  onComplete()
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.4)) { dragX = 0 }
                  }
                } else {
                  withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { dragX = 0 }
                }
              }
          )
      }
    }
    .frame(height: trackHeight)
  }

  private var track: some View {
    let shape = Capsule(style: .continuous)
    return Group {
      if #available(iOS 26.0, *) {
        Color.clear.glassEffect(.regular, in: shape)
      } else {
        shape.fill(.ultraThinMaterial).overlay(shape.stroke(.white.opacity(0.25), lineWidth: 1))
      }
    }
    .frame(height: trackHeight)
  }

  private var thumb: some View {
    ZStack {
      Circle().fill(SRColor.brandAccent)
      SRIcon(systemName: "arrow.right", color: SRColor.textOnAccent, size: 20)
    }
    .frame(width: thumbSize, height: thumbSize)
    .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
  }
}

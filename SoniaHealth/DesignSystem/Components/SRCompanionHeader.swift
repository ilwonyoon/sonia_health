import SwiftUI

/// Avatar + glass name chip used on the Companion screens (IMG_3383 / IMG_3384).
struct SRCompanionHeader: View {
  let name: String

  var body: some View {
    VStack(spacing: SRSpacing.s12) {
      ZStack {
        Circle()
          .fill(
            LinearGradient(
              colors: [Color(red: 0.62, green: 0.66, blue: 0.74),
                       Color(red: 0.36, green: 0.40, blue: 0.48)],
              startPoint: .top, endPoint: .bottom
            )
          )
        SRIcon(systemName: "person.fill", color: .white.opacity(0.9), size: 28)
      }
      .frame(width: 60, height: 60)
      .overlay(Circle().stroke(.white.opacity(0.7), lineWidth: 2))
      .shadow(color: .black.opacity(0.3), radius: 10, y: 4)

      nameChip
    }
  }

  private var nameChip: some View {
    let shape = Capsule(style: .continuous)
    let label = SRText(name, style: .controlLabel, tone: .inverse)
      .padding(.horizontal, SRSpacing.s16)
      .padding(.vertical, SRSpacing.s8)
    return Group {
      if #available(iOS 26.0, *) {
        label.glassEffect(.regular, in: shape)
      } else {
        label.background(.ultraThinMaterial, in: shape)
      }
    }
  }
}

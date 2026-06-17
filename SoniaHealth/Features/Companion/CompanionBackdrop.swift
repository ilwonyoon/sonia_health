import SwiftUI

/// Full-bleed soft backdrop for the Companion screens (light theme).
/// Gentle cream→cool-gray gradient on the app canvas; `dim` deepens it a touch
/// for the live call to focus attention on the caption.
struct CompanionBackdrop: View {
  var dim: Double = 0

  var body: some View {
    ZStack {
      SRColor.backgroundCanvas
      LinearGradient(
        colors: [
          Color(red: 0.98, green: 0.98, blue: 0.97),
          Color(red: 0.93, green: 0.94, blue: 0.95),
          Color(red: 0.87, green: 0.89, blue: 0.92)
        ],
        startPoint: .top, endPoint: .bottom
      )
      LinearGradient(
        colors: [.white.opacity(0.35), .clear, .clear, .black.opacity(0.04)],
        startPoint: .top, endPoint: .bottom
      )
      Color.black.opacity(dim * 0.4)
    }
    .ignoresSafeArea()
  }
}

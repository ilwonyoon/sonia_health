import SwiftUI

/// Full-bleed warm backdrop for the Companion / call screens.
/// A soft cream→sand vertical gradient with a gentle warm glow near the top for depth;
/// `dim` deepens it a touch during a live call to focus attention on the caption.
struct CompanionBackdrop: View {
  var dim: Double = 0

  var body: some View {
    ZStack {
      // Warm cream (top) settling into soft sand (bottom).
      LinearGradient(
        colors: [
          Color(red: 0.99, green: 0.97, blue: 0.93),
          Color(red: 0.97, green: 0.93, blue: 0.86),
          Color(red: 0.93, green: 0.87, blue: 0.77)
        ],
        startPoint: .top, endPoint: .bottom
      )
      // Soft warm glow up top so the screen feels lit, not flat.
      RadialGradient(
        colors: [Color(red: 1.0, green: 0.96, blue: 0.89).opacity(0.9), .clear],
        center: .init(x: 0.5, y: 0.22),
        startRadius: 0,
        endRadius: 460
      )
      Color.black.opacity(dim * 0.35)
    }
    .ignoresSafeArea()
  }
}

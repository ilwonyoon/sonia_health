import SwiftUI

/// Full-bleed warm backdrop for the Companion / call screens.
/// A soft cream→sand vertical gradient with a gentle warm glow near the top for depth;
/// `dim` deepens it a touch during a live call to focus attention on the caption.
struct CompanionBackdrop: View {
  var dim: Double = 0

  var body: some View {
    ZStack {
      // Bright, airy warm base — kept high-value so it reads fresh, not muddy.
      LinearGradient(
        colors: [
          Color(red: 1.00, green: 0.99, blue: 0.96),
          Color(red: 1.00, green: 0.95, blue: 0.90),
          Color(red: 0.99, green: 0.92, blue: 0.87)
        ],
        startPoint: .top, endPoint: .bottom
      )
      // Warm apricot glow up top gives the screen life and lift.
      RadialGradient(
        colors: [Color(red: 1.0, green: 0.86, blue: 0.72).opacity(0.45), .clear],
        center: .init(x: 0.5, y: 0.28),
        startRadius: 0,
        endRadius: 480
      )
      // A faint blush in the lower corner adds a subtle two-tone so it isn't flat beige.
      RadialGradient(
        colors: [Color(red: 1.0, green: 0.80, blue: 0.80).opacity(0.22), .clear],
        center: .init(x: 0.82, y: 0.86),
        startRadius: 0,
        endRadius: 420
      )
      Color.black.opacity(dim * 0.3)
    }
    .ignoresSafeArea()
  }
}

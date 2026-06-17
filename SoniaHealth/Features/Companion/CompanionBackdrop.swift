import SwiftUI

/// Full-bleed moody backdrop + legibility scrim for the Companion screens.
/// Placeholder gradient (no stock photo wired); `dim` darkens it for the live call.
struct CompanionBackdrop: View {
  var dim: Double = 0

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color(red: 0.38, green: 0.42, blue: 0.50),
          Color(red: 0.20, green: 0.23, blue: 0.30),
          Color(red: 0.08, green: 0.09, blue: 0.13)
        ],
        startPoint: .top, endPoint: .bottom
      )
      LinearGradient(
        colors: [.black.opacity(0.35), .clear, .clear, .black.opacity(0.55)],
        startPoint: .top, endPoint: .bottom
      )
      Color.black.opacity(dim)
    }
    .ignoresSafeArea()
  }
}

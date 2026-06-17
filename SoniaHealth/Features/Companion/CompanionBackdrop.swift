import SwiftUI

/// Full-bleed warm backdrop for the Companion / call screens.
/// A soft cream→sand vertical gradient with a gentle warm glow near the top for depth;
/// `dim` deepens it a touch during a live call to focus attention on the caption.
struct CompanionBackdrop: View {
  var dim: Double = 0

  var body: some View {
    ZStack {
      // Calm flat ivory (the app canvas, sampled from soniahealth.com). `dim` deepens
      // it a touch during a live call to focus attention on the caption.
      SRColor.backgroundCanvas
      Color.black.opacity(dim * 0.25)
    }
    .ignoresSafeArea()
  }
}

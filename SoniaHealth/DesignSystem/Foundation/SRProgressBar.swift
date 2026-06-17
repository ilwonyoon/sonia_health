import SwiftUI

struct SRProgressBar: View {
  let progress: Double
  let trackColor: Color
  let fillColor: Color

  init(
    progress: Double,
    trackColor: Color = SRColor.backgroundSubtle,
    fillColor: Color = SRColor.brandAction
  ) {
    self.progress = progress
    self.trackColor = trackColor
    self.fillColor = fillColor
  }

  private var clampedProgress: Double {
    min(max(progress, 0), 1)
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        Capsule()
          .fill(trackColor)
        Capsule()
          .fill(fillColor)
          .frame(width: geometry.size.width * clampedProgress)
      }
    }
    .frame(height: 8)
  }
}

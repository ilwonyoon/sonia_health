import SwiftUI

/// Segmented progress bar for a multi-step check-in flow. Segments up to and
/// including `current` (0-based) fill with `accent`; the rest stay muted.
struct CheckInProgressBar: View {
  let total: Int
  let current: Int
  let accent: Color

  var body: some View {
    HStack(spacing: SRSpacing.s8) {
      ForEach(0..<max(total, 1), id: \.self) { i in
        Capsule()
          .fill(i <= current ? accent : SRColor.borderMuted)
          .frame(height: 3)
      }
    }
  }
}

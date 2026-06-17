import SwiftUI

struct SRIcon: View {
  let systemName: String
  let color: Color
  let size: CGFloat

  init(systemName: String, color: Color = SRColor.textSecondary, size: CGFloat = 14) {
    self.systemName = systemName
    self.color = color
    self.size = size
  }

  var body: some View {
    Image(systemName: systemName)
      .font(.system(size: size, weight: .medium))
      .foregroundStyle(color)
  }
}

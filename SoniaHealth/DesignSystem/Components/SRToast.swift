import SwiftUI

struct SRToast: View {
  let text: String

  var body: some View {
    fallbackToast
  }

  private var fallbackToast: some View {
    HStack(spacing: SRSpacing.s8) {
      Image(systemName: "checkmark.circle.fill")
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(Color.white)
      SRText(text, style: .bodyEmphasis)
        .lineLimit(2)
    }
    .padding(.horizontal, SRSpacing.s16)
    .padding(.vertical, SRSpacing.s12)
    .background(SRColor.backgroundElevated.opacity(0.98))
    .clipShape(Capsule())
    .shadow(color: Color.black.opacity(0.18), radius: 18, y: 4)
  }
}

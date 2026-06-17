import SwiftUI

/// Typed-or-spoken response field for a check-in flow: a vertically-growing text
/// field on an elevated surface with a trailing mic affordance.
struct CheckInResponseField: View {
  @Binding var text: String
  var placeholder: String = "Type your response..."
  let accent: Color
  var focused: FocusState<Bool>.Binding

  var body: some View {
    HStack(alignment: .bottom, spacing: SRSpacing.s8) {
      TextField(placeholder, text: $text, axis: .vertical)
        .focused(focused)
        .font(.system(size: 15))
        .foregroundStyle(SRColor.textPrimary)
        .tint(accent)
        .lineLimit(1...5)

      Image(systemName: "mic.fill")
        .font(.system(size: 16))
        .foregroundStyle(SRColor.textSecondary)
    }
    .padding(SRSpacing.s16)
    .background(
      RoundedRectangle(cornerRadius: SRRadius.lg, style: .continuous)
        .fill(SRColor.backgroundElevated)
    )
  }
}

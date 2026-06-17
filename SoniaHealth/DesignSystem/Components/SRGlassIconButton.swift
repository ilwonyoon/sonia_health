import SwiftUI

struct SRGlassIconButton: View {
  enum Emphasis {
    case regular
    case prominent
  }

  private let systemName: String
  private let emphasis: Emphasis
  private let accessibilityLabel: String
  private let foregroundColor: Color?
  private let action: () -> Void

  init(
    systemName: String,
    emphasis: Emphasis = .regular,
    accessibilityLabel: String,
    foregroundColor: Color? = nil,
    action: @escaping () -> Void
  ) {
    self.systemName = systemName
    self.emphasis = emphasis
    self.accessibilityLabel = accessibilityLabel
    self.foregroundColor = foregroundColor
    self.action = action
  }

  var body: some View {
    fallbackButton
  }

  private var fallbackButton: some View {
    Button(action: action) {
      Image(systemName: systemName)
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(foregroundColor ?? SRColor.textPrimary)
        .frame(width: 44, height: 44)
        .background(SRColor.backgroundElevated.opacity(0.92))
        .overlay(
          Circle()
            .stroke(SRColor.borderDefault, lineWidth: 1)
        )
        .clipShape(Circle())
        .contentShape(Circle())
    }
    .buttonStyle(.plain)
    .accessibilityLabel(accessibilityLabel)
  }
}

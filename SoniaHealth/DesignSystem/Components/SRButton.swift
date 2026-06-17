import SwiftUI

struct SRButton: View {
  enum Kind {
    case primary
    case secondary
    case ghost
    case danger
  }

  enum Size {
    case small
    case medium
    case large

    var minHeight: CGFloat {
      switch self {
      case .small:
        return 36
      case .medium, .large:
        return 50
      }
    }

    var horizontalPadding: CGFloat {
      switch self {
      case .small:
        return SRSpacing.s16
      case .medium:
        return SRSpacing.s16
      case .large:
        return SRSpacing.s16
      }
    }

    var verticalPadding: CGFloat {
      switch self {
      case .small:
        return SRSpacing.s8
      case .medium:
        return SRSpacing.s12
      case .large:
        return SRSpacing.s16
      }
    }

    var textStyle: SRTextStyle {
      switch self {
      case .small:
        return .controlLabel
      case .medium, .large:
        return .navigationTitle
      }
    }
  }

  private let title: String
  private let kind: Kind
  private let size: Size
  private let isFullWidth: Bool
  private let cornerRadius: CGFloat
  private let action: () -> Void

  init(
    _ title: String,
    kind: Kind = .primary,
    size: Size = .medium,
    isFullWidth: Bool = false,
    cornerRadius: CGFloat = SRRadius.control,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.kind = kind
    self.size = size
    self.isFullWidth = isFullWidth
    self.cornerRadius = cornerRadius
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      SRText(title, style: size.textStyle, tone: foregroundTone)
        .lineLimit(1)
        .minimumScaleFactor(0.85)
        .padding(.horizontal, size.horizontalPadding)
        .frame(maxWidth: isFullWidth ? .infinity : nil, minHeight: size.minHeight)
        .background(backgroundColor)
        .overlay(
          RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .contentShape(Rectangle())
  }

  private var backgroundColor: Color {
    switch kind {
    case .primary:
      return Color.white
    case .secondary:
      return SRColor.backgroundSurface
    case .ghost:
      return .clear
    case .danger:
      return SRColor.feedbackDangerBackground
    }
  }

  private var borderColor: Color {
    switch kind {
    case .primary:
      return Color.white
    case .secondary:
      return SRColor.borderDefault
    case .ghost:
      return .clear
    case .danger:
      return SRColor.feedbackDangerBorder
    }
  }

  private var foregroundTone: SRText.Tone {
    switch kind {
    case .primary:
      return .dark
    case .secondary, .ghost:
      return .primary
    case .danger:
      return .danger
    }
  }
}

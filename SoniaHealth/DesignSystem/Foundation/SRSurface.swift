import SwiftUI

struct SRSurface<Content: View>: View {
  enum Kind {
    case canvas
    case surface
    case subtle
    case elevated
    case brand
    case success
    case warning
    case danger

    var fillColor: Color {
      switch self {
      case .canvas:
        return SRColor.backgroundCanvas
      case .surface:
        return SRColor.backgroundSurface
      case .subtle:
        return SRColor.backgroundSubtle
      case .elevated:
        return SRColor.backgroundElevated
      case .brand:
        return SRColor.brandSelectedBackground
      case .success:
        return SRColor.feedbackSuccessBackground
      case .warning:
        return SRColor.feedbackWarningBackground
      case .danger:
        return SRColor.feedbackDangerBackground
      }
    }

    var borderColor: Color {
      switch self {
      case .brand:
        return SRColor.borderStrong
      case .success:
        return SRColor.feedbackSuccessBorder
      case .warning:
        return SRColor.feedbackWarningBorder
      case .danger:
        return SRColor.feedbackDangerBorder
      default:
        return SRColor.borderDefault
      }
    }
  }

  private let kind: Kind
  private let cornerRadius: CGFloat
  private let content: Content

  init(
    kind: Kind = .surface,
    cornerRadius: CGFloat = SRRadius.card,
    @ViewBuilder content: () -> Content
  ) {
    self.kind = kind
    self.cornerRadius = cornerRadius
    self.content = content()
  }

  var body: some View {
    content
      .padding(SRSpacing.cardPadding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(kind.fillColor)
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .stroke(kind.borderColor, lineWidth: 1)
      )
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
  }
}

import SwiftUI

struct SRBadge: View {
  enum Kind {
    case `default`
    case brand
    case success
    case warning
    case danger
  }

  let text: String
  let kind: Kind

  init(_ text: String, kind: Kind = .default) {
    self.text = text
    self.kind = kind
  }

  var body: some View {
    SRText(text, style: .caption, tone: tone)
      .padding(.horizontal, SRSpacing.s8)
      .padding(.vertical, SRSpacing.s4)
      .background(backgroundColor)
      .overlay(
        Capsule()
          .stroke(borderColor, lineWidth: 1)
      )
      .clipShape(Capsule())
  }

  private var backgroundColor: Color {
    switch kind {
    case .default:
      return SRColor.backgroundSubtle
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

  private var borderColor: Color {
    switch kind {
    case .default:
      return SRColor.borderDefault
    case .brand:
      return SRColor.borderStrong
    case .success:
      return SRColor.feedbackSuccessBorder
    case .warning:
      return SRColor.feedbackWarningBorder
    case .danger:
      return SRColor.feedbackDangerBorder
    }
  }

  private var tone: SRText.Tone {
    switch kind {
    case .default:
      return .secondary
    case .brand:
      return .brand
    case .success:
      return .success
    case .warning:
      return .warning
    case .danger:
      return .danger
    }
  }
}

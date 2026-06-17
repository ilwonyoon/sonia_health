import SwiftUI

struct SRText: View {
  enum Tone {
    case primary
    case secondary
    case tertiary
    case inverse
    case brand
    case success
    case warning
    case danger
    case dark

    var color: Color {
      switch self {
      case .primary:
        return SRColor.textPrimary
      case .secondary:
        return SRColor.textSecondary
      case .tertiary:
        return SRColor.textTertiary
      case .inverse:
        return SRColor.textInverse
      case .brand:
        return SRColor.brandSelectedText
      case .success:
        return SRColor.feedbackSuccessText
      case .warning:
        return SRColor.feedbackWarningText
      case .danger:
        return SRColor.feedbackDangerText
      case .dark:
        return Color.black
      }
    }
  }

  private let content: String
  private let style: SRTextStyle
  private let tone: Tone

  init(_ content: String, style: SRTextStyle, tone: Tone = .primary) {
    self.content = content
    self.style = style
    self.tone = tone
  }

  var body: some View {
    Text(content)
      .font(style.font)
      .lineSpacing(style.lineSpacing)
      .tracking(style.tracking)
      .foregroundStyle(tone.color)
  }
}

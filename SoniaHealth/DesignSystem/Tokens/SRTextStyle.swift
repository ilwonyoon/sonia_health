import SwiftUI

enum SRTextStyle {
  case homeMessage
  case navigationLargeTitle
  case navigationTitle
  case screenTitle
  case sectionTitle
  case sectionTitleMedium
  case bodyEmphasis
  case body
  case supporting
  case controlLabel
  case caption

  @available(*, deprecated, renamed: "screenTitle")
  static var display: Self { .screenTitle }

  @available(*, deprecated, renamed: "sectionTitle")
  static var headline: Self { .sectionTitle }

  @available(*, deprecated, renamed: "sectionTitle")
  static var title: Self { .sectionTitle }

  @available(*, deprecated, renamed: "bodyEmphasis")
  static var bodyStrong: Self { .bodyEmphasis }

  @available(*, deprecated, renamed: "controlLabel")
  static var label: Self { .controlLabel }

  var font: Font {
    switch self {
    case .homeMessage:
      return .system(size: 28, weight: .medium, design: .default)
    case .navigationLargeTitle:
      return .system(size: 17, weight: .semibold, design: .default)
    case .navigationTitle:
      return .system(size: 17, weight: .semibold, design: .default)
    case .screenTitle:
      return .system(size: 17, weight: .semibold, design: .default)
    case .sectionTitle:
      return .system(size: 15, weight: .semibold, design: .default)
    case .sectionTitleMedium:
      return .system(size: 17, weight: .semibold, design: .default)
    case .bodyEmphasis:
      return .system(size: 15, weight: .semibold, design: .default)
    case .body:
      return .system(size: 15, weight: .regular, design: .default)
    case .supporting:
      return .system(size: 14, weight: .regular, design: .default)
    case .controlLabel:
      return .system(size: 13, weight: .medium, design: .default)
    case .caption:
      return .system(size: 12, weight: .regular, design: .default)
    }
  }

  var fontSize: CGFloat {
    switch self {
    case .homeMessage:
      return 28
    case .navigationLargeTitle, .navigationTitle, .screenTitle, .sectionTitleMedium:
      return 17
    case .sectionTitle, .bodyEmphasis, .body:
      return 15
    case .supporting:
      return 14
    case .controlLabel:
      return 13
    case .caption:
      return 12
    }
  }

  var lineHeight: CGFloat {
    switch self {
    case .body, .bodyEmphasis:
      return 19
    default:
      return fontSize
    }
  }

  var lineSpacing: CGFloat {
    max(lineHeight - fontSize, 0)
  }

  var tracking: CGFloat {
    switch self {
    case .caption:
      return 0
    default:
      return 0
    }
  }
}

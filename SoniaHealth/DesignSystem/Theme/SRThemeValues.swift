import SwiftUI

struct SRThemeValues {
  let backgroundCanvas: Color
  let backgroundSurface: Color
  let backgroundSubtle: Color
  let backgroundElevated: Color
  let textPrimary: Color
  let textSecondary: Color
  let textTertiary: Color
  let textInverse: Color
  let brandAction: Color
  let brandActionHover: Color
  let brandSelectedBackground: Color
  let brandSelectedText: Color
  let borderDefault: Color
  let borderMuted: Color
  let borderStrong: Color
  let feedbackSuccessBackground: Color
  let feedbackSuccessText: Color
  let feedbackSuccessBorder: Color
  let feedbackWarningBackground: Color
  let feedbackWarningText: Color
  let feedbackWarningBorder: Color
  let feedbackDangerBackground: Color
  let feedbackDangerText: Color
  let feedbackDangerBorder: Color

  static let current = SRThemeValues(
    backgroundCanvas: SRColor.backgroundCanvas,
    backgroundSurface: SRColor.backgroundSurface,
    backgroundSubtle: SRColor.backgroundSubtle,
    backgroundElevated: SRColor.backgroundElevated,
    textPrimary: SRColor.textPrimary,
    textSecondary: SRColor.textSecondary,
    textTertiary: SRColor.textTertiary,
    textInverse: SRColor.textInverse,
    brandAction: SRColor.brandAction,
    brandActionHover: SRColor.brandActionHover,
    brandSelectedBackground: SRColor.brandSelectedBackground,
    brandSelectedText: SRColor.brandSelectedText,
    borderDefault: SRColor.borderDefault,
    borderMuted: SRColor.borderMuted,
    borderStrong: SRColor.borderStrong,
    feedbackSuccessBackground: SRColor.feedbackSuccessBackground,
    feedbackSuccessText: SRColor.feedbackSuccessText,
    feedbackSuccessBorder: SRColor.feedbackSuccessBorder,
    feedbackWarningBackground: SRColor.feedbackWarningBackground,
    feedbackWarningText: SRColor.feedbackWarningText,
    feedbackWarningBorder: SRColor.feedbackWarningBorder,
    feedbackDangerBackground: SRColor.feedbackDangerBackground,
    feedbackDangerText: SRColor.feedbackDangerText,
    feedbackDangerBorder: SRColor.feedbackDangerBorder
  )
}

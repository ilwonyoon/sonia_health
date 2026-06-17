import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum SRRawColor {
  static let teal50 = Color(hex: 0xE1F5EE)
  static let teal100 = Color(hex: 0x9FE1CB)
  static let teal200 = Color(hex: 0x5DCAA5)
  static let teal400 = Color(hex: 0x1D9E75)
  static let teal600 = Color(hex: 0x0F6E56)
  static let teal800 = Color(hex: 0x085041)
  static let teal900 = Color(hex: 0x04342C)

  static let gray50 = Color(hex: 0xF4F4F2)
  static let gray100 = Color(hex: 0xE0E0DC)
  static let gray200 = Color(hex: 0xC4C4BE)
  static let gray400 = Color(hex: 0x888780)
  static let gray600 = Color(hex: 0x5F5E5A)
  static let gray800 = Color(hex: 0x2E2E2C)
  static let gray900 = Color(hex: 0x1A1A18)

  static let heroEvergreen = Color(hex: 0x21483E)
  static let heroRosewood = Color(hex: 0x543138)
  static let heroSteelBlue = Color(hex: 0x243B55)
  static let heroAmberOlive = Color(hex: 0x544625)
  static let heroAubergine = Color(hex: 0x3B304F)
  static let heroSpruce = Color(hex: 0x183438)
  static let heroClay = Color(hex: 0x58372C)
}

enum SRColor {
  static let backgroundCanvas = Color(light: Color(hex: 0xFAFAF9), dark: Color(hex: 0x0C0C0B))
  static let backgroundSurface = Color(light: .white, dark: Color(hex: 0x1A1A18))
  static let backgroundSubtle = Color(light: SRRawColor.gray50, dark: Color(hex: 0x242422))
  static let backgroundElevated = Color(light: .white, dark: Color(hex: 0x242422))

  static let textPrimary = Color(light: SRRawColor.gray900, dark: Color(hex: 0xEEEEE8))
  static let textSecondary = Color(light: SRRawColor.gray600, dark: Color(hex: 0xA0A09A))
  static let textTertiary = Color(light: SRRawColor.gray400, dark: Color(hex: 0x585856))
  static let textDisabled = Color(light: SRRawColor.gray400, dark: Color(hex: 0x585856))
  static let textInverse = Color(light: Color(hex: 0xFAFAF9), dark: Color(hex: 0xEEEEE8))

  static let brandAccent = Color(light: SRRawColor.teal200, dark: Color(hex: 0x4AE8C2))
  static let brandAction = Color(light: SRRawColor.teal400, dark: Color(hex: 0x2BC99A))
  static let brandActionHover = Color(light: SRRawColor.teal600, dark: Color(hex: 0x2BC99A))
  static let brandAccentLight = Color(light: SRRawColor.teal200, dark: Color(hex: 0x4AE8C2))
  static let brandSelectedBackground = Color(light: SRRawColor.teal50, dark: Color(hex: 0x4AE8C2, alpha: 0.15))
  static let brandSelectedText = Color(light: SRRawColor.teal800, dark: Color(hex: 0x4AE8C2))

  static let borderDefault = Color(light: .black.opacity(0.10), dark: .white.opacity(0.07))
  static let borderMuted = Color(light: .black.opacity(0.06), dark: .white.opacity(0.07))
  static let borderStrong = Color(light: .black.opacity(0.18), dark: .white.opacity(0.12))
  static let borderBrand = Color(light: SRRawColor.teal200.opacity(0.5), dark: Color(hex: 0x4AE8C2, alpha: 0.30))

  static let heroSurfaceEvergreen = SRRawColor.heroEvergreen
  static let heroSurfaceRosewood = SRRawColor.heroRosewood
  static let heroSurfaceSteelBlue = SRRawColor.heroSteelBlue
  static let heroSurfaceAmberOlive = SRRawColor.heroAmberOlive
  static let heroSurfaceAubergine = SRRawColor.heroAubergine
  static let heroSurfaceSpruce = SRRawColor.heroSpruce
  static let heroSurfaceClay = SRRawColor.heroClay

  static let heroContentPrimary = textInverse
  static let heroContentSecondary = textInverse.opacity(0.88)
  static let heroContentLabel = textInverse.opacity(0.58)
  static let heroProgressTrack = Color.white.opacity(0.14)
  static let heroGlassForeground = textInverse
  static let heroGlassDivider = Color.white.opacity(0.16)

  static let feedbackSuccessBackground = Color(light: SRRawColor.teal50, dark: SRRawColor.teal800)
  static let feedbackSuccessText = Color(light: SRRawColor.teal800, dark: SRRawColor.teal100)
  static let feedbackSuccessBorder = Color(light: SRRawColor.teal200, dark: SRRawColor.teal600)

  static let feedbackWarningBackground = Color(light: Color(hex: 0xFAEEDA), dark: Color(hex: 0x412402))
  static let feedbackWarningText = Color(light: Color(hex: 0x633806), dark: Color(hex: 0xFAC775))
  static let feedbackWarningBorder = Color(light: Color(hex: 0xEF9F27), dark: Color(hex: 0x854F0B))

  static let feedbackDangerBackground = Color(light: Color(hex: 0xFCEBEB), dark: Color(hex: 0x501313))
  static let feedbackDangerText = Color(light: Color(hex: 0x791F1F), dark: Color(hex: 0xF7C1C1))
  static let feedbackDangerBorder = Color(light: Color(hex: 0xF09595), dark: Color(hex: 0xA32D2D))

  // MARK: - Sonia accents (time-of-day / flow system)
  // Sampled from the real Sonia app screenshots. The accent is a *runtime* variable
  // keyed to context (morning / evening / assessment / companion), not a fixed brand
  // color. See docs/design-system/foundations.md and themes.md.
  static let accentMorning = Color(light: Color(hex: 0xC9A24B), dark: Color(hex: 0xD6B25E))
  static let accentEvening = Color(light: Color(hex: 0xB7A9D6), dark: Color(hex: 0xC6BAE2))
  static let accentAssessment = Color(light: Color(hex: 0xF4F2ED), dark: .white)
  static let accentAssessmentTrack = Color(hex: 0xE7E0CF)
  static let accentReward = Color(hex: 0x3E9C6B)
  static let accentRewardBackground = Color(hex: 0x3E9C6B, alpha: 0.18)

  /// Dark text used on a light accent CTA (gold / cream / white fills).
  static let textOnAccent = Color(hex: 0x1A1407)
  /// Foreground used over full-bleed companion photography.
  static let textOnPhoto = Color.white
}

enum SRRoutineHeroPalette: String, CaseIterable, Equatable, Codable {
  case evergreen
  case rosewood
  case steelBlue
  case amberOlive
  case aubergine
  case spruce
  case clay

  static let rotationOrder: [SRRoutineHeroPalette] = [
    .evergreen,
    .rosewood,
    .steelBlue,
    .amberOlive,
    .aubergine,
    .spruce,
    .clay
  ]

  static let mint: SRRoutineHeroPalette = .evergreen
  static let sky: SRRoutineHeroPalette = .steelBlue
  static let lavender: SRRoutineHeroPalette = .aubergine
  static let pink: SRRoutineHeroPalette = .clay
  static let rose: SRRoutineHeroPalette = .rosewood
  static let lemon: SRRoutineHeroPalette = .amberOlive
  static let sage: SRRoutineHeroPalette = .spruce
  static let iceBlue: SRRoutineHeroPalette = .steelBlue

  static func atRotationIndex(_ index: Int) -> SRRoutineHeroPalette {
    let order = rotationOrder
    guard order.isEmpty == false else {
      return .evergreen
    }
    return order[index % order.count]
  }

  static func assigned(to routineID: UUID) -> SRRoutineHeroPalette {
    let bytes = withUnsafeBytes(of: routineID.uuid) { Array($0) }
    let index = bytes.reduce(0) { partial, byte in
      ((partial * 31) + Int(byte)) % rotationOrder.count
    }
    return rotationOrder[index]
  }

  var backgroundColor: Color {
    switch self {
    case .evergreen:
      return SRColor.heroSurfaceEvergreen
    case .rosewood:
      return SRColor.heroSurfaceRosewood
    case .steelBlue:
      return SRColor.heroSurfaceSteelBlue
    case .amberOlive:
      return SRColor.heroSurfaceAmberOlive
    case .aubergine:
      return SRColor.heroSurfaceAubergine
    case .spruce:
      return SRColor.heroSurfaceSpruce
    case .clay:
      return SRColor.heroSurfaceClay
    }
  }

  var foregroundPrimary: Color {
    SRColor.heroContentPrimary
  }

  var foregroundSecondary: Color {
    SRColor.heroContentSecondary
  }

  var labelColor: Color {
    SRColor.heroContentLabel
  }

  var progressTrack: Color {
    SRColor.heroProgressTrack
  }

  var progressFill: Color {
    SRColor.brandAction
  }

  var glassForeground: Color {
    SRColor.heroGlassForeground
  }

  var glassDivider: Color {
    SRColor.heroGlassDivider
  }
}

private extension Color {
  init(hex: UInt32, alpha: Double = 1) {
    let red = Double((hex >> 16) & 0xFF) / 255
    let green = Double((hex >> 8) & 0xFF) / 255
    let blue = Double(hex & 0xFF) / 255
    self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
  }

  init(light: Color, dark: Color) {
    #if canImport(UIKit)
    self.init(UIColor { traitCollection in
      traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
    })
    #elseif canImport(AppKit)
    self.init(NSColor(name: nil) { appearance in
      let bestMatch = appearance.bestMatch(from: [.darkAqua, .aqua])
      return bestMatch == .darkAqua ? NSColor(dark) : NSColor(light)
    })
    #else
    self = light
    #endif
  }
}

import SwiftUI

// Fallback-first glass wrapper for structural UI.
// When the project baseline moves to an SDK with Liquid Glass APIs,
// replace the internal material treatment here rather than in feature code.
struct SRGlassContainer<Content: View>: View {
  enum Role {
    case navigation
    case bottomBar

    var horizontalPadding: CGFloat {
      switch self {
      case .navigation:
        return SRSpacing.s16
      case .bottomBar:
        return SRSpacing.s12
      }
    }

    var verticalPadding: CGFloat {
      switch self {
      case .navigation:
        return SRSpacing.s12
      case .bottomBar:
        return SRSpacing.s12
      }
    }

    var cornerRadius: CGFloat {
      switch self {
      case .navigation:
        return SRRadius.surface
      case .bottomBar:
        return SRRadius.surface
      }
    }
  }

  private let role: Role
  private let content: Content

  init(role: Role, @ViewBuilder content: () -> Content) {
    self.role = role
    self.content = content()
  }

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: role.cornerRadius, style: .continuous)
    if #available(iOS 26.0, *) {
      content
        .padding(.horizontal, role.horizontalPadding)
        .padding(.vertical, role.verticalPadding)
        .glassEffect(.regular, in: shape)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    } else {
      content
        .padding(.horizontal, role.horizontalPadding)
        .padding(.vertical, role.verticalPadding)
        .background(.ultraThinMaterial, in: shape)
        .overlay(shape.stroke(SRColor.borderDefault, lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
    }
  }
}

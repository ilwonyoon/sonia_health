import SwiftUI

struct SRCard<Content: View>: View {
  enum Kind {
    case `default`
    case subtle
    case brand
  }

  private let kind: Kind
  private let cornerRadius: CGFloat
  private let content: Content

  init(
    kind: Kind = .default,
    cornerRadius: CGFloat = SRRadius.card,
    @ViewBuilder content: () -> Content
  ) {
    self.kind = kind
    self.cornerRadius = cornerRadius
    self.content = content()
  }

  var body: some View {
    SRSurface(kind: surfaceKind, cornerRadius: cornerRadius) {
      content
    }
  }

  private var surfaceKind: SRSurface<Content>.Kind {
    switch kind {
    case .default:
      return .surface
    case .subtle:
      return .subtle
    case .brand:
      return .brand
    }
  }
}

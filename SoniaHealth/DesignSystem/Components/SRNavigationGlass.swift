import SwiftUI

struct SRNavigationGlass<Leading: View, Trailing: View>: View {
  private let title: String
  private let leading: Leading
  private let trailing: Trailing

  init(
    title: String,
    @ViewBuilder leading: () -> Leading,
    @ViewBuilder trailing: () -> Trailing
  ) {
    self.title = title
    self.leading = leading()
    self.trailing = trailing()
  }

  var body: some View {
    SRGlassContainer(role: .navigation) {
      HStack(spacing: SRSpacing.s12) {
        leading
        Spacer(minLength: SRSpacing.s12)
        SRText(title, style: .controlLabel)
        Spacer(minLength: SRSpacing.s12)
        trailing
      }
    }
  }
}

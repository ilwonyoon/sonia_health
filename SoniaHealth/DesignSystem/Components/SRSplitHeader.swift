import SwiftUI

struct SRInlineAccentHeader<Trailing: View>: View {
  private let leadingText: String
  private let accentText: String
  private let subtitle: String?
  private let trailing: Trailing

  init(
    leadingText: String,
    accentText: String,
    subtitle: String? = nil,
    @ViewBuilder trailing: () -> Trailing
  ) {
    self.leadingText = leadingText
    self.accentText = accentText
    self.subtitle = subtitle
    self.trailing = trailing()
  }

  var body: some View {
    HStack(alignment: .top, spacing: SRSpacing.s16) {
      VStack(alignment: .leading, spacing: SRSpacing.s4) {
        (
          Text(leadingText + " ")
            .foregroundStyle(SRColor.textPrimary)
          +
          Text(accentText)
            .foregroundStyle(SRColor.brandAccent)
        )
        .font(.system(size: 24, weight: .bold))
        .fixedSize(horizontal: false, vertical: true)

        if let subtitle, subtitle.isEmpty == false {
          SRText(subtitle, style: .caption, tone: .tertiary)
        }
      }

      Spacer(minLength: SRSpacing.s12)

      trailing
    }
    .padding(.horizontal, SRSpacing.s16)
  }
}

extension SRInlineAccentHeader where Trailing == EmptyView {
  init(
    leadingText: String,
    accentText: String,
    subtitle: String? = nil
  ) {
    self.init(leadingText: leadingText, accentText: accentText, subtitle: subtitle) {
      EmptyView()
    }
  }
}

struct SRSplitHeader<Trailing: View>: View {
  private let line1: String?
  private let line2: String
  private let subtitle: String?
  private let trailing: Trailing

  init(
    line1: String? = nil,
    line2: String,
    subtitle: String? = nil,
    @ViewBuilder trailing: () -> Trailing
  ) {
    self.line1 = line1
    self.line2 = line2
    self.subtitle = subtitle
    self.trailing = trailing()
  }

  var body: some View {
    SRHeader(layout: .split(line1: line1, line2: line2, subtitle: subtitle), trailing: {
      trailing
    })
  }
}

extension SRSplitHeader where Trailing == EmptyView {
  init(
    line1: String? = nil,
    line2: String,
    subtitle: String? = nil
  ) {
    self.init(line1: line1, line2: line2, subtitle: subtitle) {
      EmptyView()
    }
  }
}

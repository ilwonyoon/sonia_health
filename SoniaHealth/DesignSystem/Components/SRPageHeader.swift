import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct SRHeader: View {
  enum Layout {
    case centered(title: String, detail: String? = nil)
    case split(line1: String? = nil, line2: String, subtitle: String? = nil)
  }

  private let controlSide: CGFloat = 36
  private let sideSlotWidth: CGFloat = 80
  private let layout: Layout
  private let horizontalPadding: CGFloat
  private let leading: AnyView?
  private let trailing: AnyView?

  init(layout: Layout, horizontalPadding: CGFloat = SRSpacing.s16) {
    self.layout = layout
    self.horizontalPadding = horizontalPadding
    self.leading = nil
    self.trailing = nil
  }

  init<Leading: View>(
    layout: Layout,
    horizontalPadding: CGFloat = SRSpacing.s16,
    @ViewBuilder leading: () -> Leading
  ) {
    self.layout = layout
    self.horizontalPadding = horizontalPadding
    self.leading = AnyView(leading())
    self.trailing = nil
  }

  init<Trailing: View>(
    layout: Layout,
    horizontalPadding: CGFloat = SRSpacing.s16,
    @ViewBuilder trailing: () -> Trailing
  ) {
    self.layout = layout
    self.horizontalPadding = horizontalPadding
    self.leading = nil
    self.trailing = AnyView(trailing())
  }

  init<Leading: View, Trailing: View>(
    layout: Layout,
    horizontalPadding: CGFloat = SRSpacing.s16,
    @ViewBuilder leading: () -> Leading,
    @ViewBuilder trailing: () -> Trailing
  ) {
    self.layout = layout
    self.horizontalPadding = horizontalPadding
    self.leading = AnyView(leading())
    self.trailing = AnyView(trailing())
  }

  var body: some View {
    switch layout {
    case .centered(let title, let detail):
      centeredHeader(title: title, detail: detail)
    case .split(let line1, let line2, let subtitle):
      splitHeader(line1: line1, line2: line2, subtitle: subtitle)
    }
  }

  private func centeredHeader(title: String, detail: String?) -> some View {
    ZStack {
      HStack(alignment: .center, spacing: SRSpacing.s12) {
        leadingSlot
          .frame(width: sideSlotWidth, alignment: .leading)

        Spacer(minLength: 0)

        trailingSlot
          .frame(width: sideSlotWidth, alignment: .trailing)
      }

      VStack(spacing: 2) {
        SRText(title, style: .navigationTitle)
          .lineLimit(1)
          .truncationMode(.tail)
          .accessibilityIdentifier(title)
          .accessibilityAddTraits(.isHeader)

        if let detail, detail.isEmpty == false {
          SRText(detail, style: .caption, tone: .secondary)
        }
      }
      .multilineTextAlignment(.center)
      .padding(.horizontal, sideSlotWidth + SRSpacing.s12)
    }
    .frame(minHeight: controlSide, alignment: .center)
    .padding(.horizontal, horizontalPadding)
  }

  private func splitHeader(line1: String?, line2: String, subtitle: String?) -> some View {
    HStack(alignment: .top, spacing: SRSpacing.s16) {
      if let leading {
        leading
      }

      VStack(alignment: .leading, spacing: SRSpacing.s4) {
        VStack(alignment: .leading, spacing: 0) {
          if let line1, line1.isEmpty == false {
            Text(line1)
              .font(.system(size: 28, weight: .bold))
              .foregroundStyle(SRColor.textPrimary)
              .kerning(-1.5)
          }

          Text(line2)
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(SRColor.brandAccent)
            .kerning(-1.5)
        }
        .lineSpacing(-2)
        .fixedSize(horizontal: false, vertical: true)

        if let subtitle, subtitle.isEmpty == false {
          SRText(subtitle, style: .caption, tone: .tertiary)
        }
      }

      Spacer(minLength: SRSpacing.s12)

      if let trailing {
        trailing
      }
    }
    .padding(.horizontal, horizontalPadding)
  }

  @ViewBuilder
  private var leadingSlot: some View {
    if let leading {
      leading
    } else {
      Color.clear
        .frame(width: sideSlotWidth, height: controlSide)
    }
  }

  @ViewBuilder
  private var trailingSlot: some View {
    if let trailing {
      trailing
    } else {
      Color.clear
        .frame(width: sideSlotWidth, height: controlSide)
    }
  }
}

struct SRPageHeader<Trailing: View>: View {
  private let title: String
  private let detail: String?
  private let showsBackButton: Bool
  private let onBack: (() -> Void)?
  private let trailing: Trailing

  init(
    title: String,
    detail: String? = nil,
    showsBackButton: Bool = false,
    onBack: (() -> Void)? = nil,
    @ViewBuilder trailing: () -> Trailing
  ) {
    self.title = title
    self.detail = detail
    self.showsBackButton = showsBackButton
    self.onBack = onBack
    self.trailing = trailing()
  }

  var body: some View {
    SRHeader(
      layout: .centered(title: title, detail: detail),
      leading: {
        if showsBackButton, let onBack {
          SRGlassIconButton(systemName: "chevron.left", accessibilityLabel: "Back", action: onBack)
        } else {
          EmptyView()
        }
      },
      trailing: {
        trailing
      }
    )
  }
}

extension SRPageHeader where Trailing == EmptyView {
  init(
    title: String,
    detail: String? = nil,
    showsBackButton: Bool = false,
    onBack: (() -> Void)? = nil
  ) {
    self.init(title: title, detail: detail, showsBackButton: showsBackButton, onBack: onBack) {
      EmptyView()
    }
  }
}

struct SROverlayChrome<Center: View, Trailing: View>: View {
  private let controlSide: CGFloat = 36
  private let sideSlotWidth: CGFloat = 80

  let topInset: CGFloat
  let showsBackButton: Bool
  let onBack: (() -> Void)?
  let center: Center
  let trailing: Trailing

  init(
    topInset: CGFloat = 0,
    showsBackButton: Bool = false,
    onBack: (() -> Void)? = nil,
    @ViewBuilder center: () -> Center,
    @ViewBuilder trailing: () -> Trailing
  ) {
    self.topInset = topInset
    self.showsBackButton = showsBackButton
    self.onBack = onBack
    self.center = center()
    self.trailing = trailing()
  }

  var body: some View {
    ZStack {
      HStack(alignment: .center, spacing: SRSpacing.s12) {
        leadingSlot
          .frame(width: sideSlotWidth, alignment: .leading)

        Spacer(minLength: 0)

        trailing
          .frame(width: sideSlotWidth, alignment: .trailing)
      }

      center
        .padding(.horizontal, sideSlotWidth + SRSpacing.s12)
    }
    .frame(minHeight: controlSide, alignment: .center)
    .padding(.top, topInset)
    .padding(.horizontal, SRSpacing.s16)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .ignoresSafeArea(edges: .top)
  }

  @ViewBuilder
  private var leadingSlot: some View {
    if showsBackButton, let onBack {
      SRGlassIconButton(systemName: "chevron.left", accessibilityLabel: "Back", action: onBack)
    } else {
      Color.clear
        .frame(width: sideSlotWidth, height: controlSide)
    }
  }
}

extension SROverlayChrome where Trailing == EmptyView {
  init(
    topInset: CGFloat = 0,
    showsBackButton: Bool = false,
    onBack: (() -> Void)? = nil,
    @ViewBuilder center: () -> Center
  ) {
    self.init(topInset: topInset, showsBackButton: showsBackButton, onBack: onBack, center: center) {
      EmptyView()
    }
  }
}

struct SRScreenScaffold<TopChrome: View, Hero: View, Content: View, BottomInset: View>: View {
  enum TopChromePlacement {
    case stacked
    case overlay
  }

  enum TopChromeBackdropStyle {
    case none
    case band
  }

  @State private var measuredTopChromeHeight: CGFloat = 0

  private let usesScrollView: Bool
  private let disablesVerticalScrollBounce: Bool
  private let showsIndicators: Bool
  private let backgroundColor: Color
  private let topChromePlacement: TopChromePlacement
  private let topChromeBackdropStyle: TopChromeBackdropStyle
  private let reservesTopChromeSpace: Bool
  private let topChromeTopPadding: CGFloat
  private let topChromeBottomSpacing: CGFloat
  private let heroToContentSpacing: CGFloat
  private let heroTopOffset: CGFloat
  private let contentHorizontalPadding: CGFloat
  private let contentTopPadding: CGFloat
  private let contentTopAdjustment: CGFloat
  private let contentBottomPadding: CGFloat
  private let topChrome: TopChrome
  private let hero: Hero
  private let content: Content
  private let bottomInset: BottomInset

  init(
    usesScrollView: Bool = true,
    disablesVerticalScrollBounce: Bool = false,
    showsIndicators: Bool = false,
    backgroundColor: Color = SRColor.backgroundCanvas,
    topChromePlacement: TopChromePlacement = .stacked,
    topChromeBackdropStyle: TopChromeBackdropStyle = .none,
    reservesTopChromeSpace: Bool = false,
    topChromeTopPadding: CGFloat = SRSpacing.s8,
    topChromeBottomSpacing: CGFloat = SRSpacing.s8,
    heroToContentSpacing: CGFloat = 0,
    heroTopOffset: CGFloat = 0,
    contentHorizontalPadding: CGFloat = SRSpacing.s16,
    contentTopPadding: CGFloat = SRSpacing.s16,
    contentTopAdjustment: CGFloat = 0,
    contentBottomPadding: CGFloat = SRSpacing.s32,
    @ViewBuilder topChrome: () -> TopChrome,
    @ViewBuilder hero: () -> Hero,
    @ViewBuilder content: () -> Content,
    @ViewBuilder bottomInset: () -> BottomInset
  ) {
    self.usesScrollView = usesScrollView
    self.disablesVerticalScrollBounce = disablesVerticalScrollBounce
    self.showsIndicators = showsIndicators
    self.backgroundColor = backgroundColor
    self.topChromePlacement = topChromePlacement
    self.topChromeBackdropStyle = topChromeBackdropStyle
    self.reservesTopChromeSpace = reservesTopChromeSpace
    self.topChromeTopPadding = topChromeTopPadding
    self.topChromeBottomSpacing = topChromeBottomSpacing
    self.heroToContentSpacing = heroToContentSpacing
    self.heroTopOffset = heroTopOffset
    self.contentHorizontalPadding = contentHorizontalPadding
    self.contentTopPadding = contentTopPadding
    self.contentTopAdjustment = contentTopAdjustment
    self.contentBottomPadding = contentBottomPadding
    self.topChrome = topChrome()
    self.hero = hero()
    self.content = content()
    self.bottomInset = bottomInset()
  }

  var body: some View {
    ZStack {
      backgroundColor
        .ignoresSafeArea()

      switch topChromePlacement {
      case .stacked:
        VStack(spacing: 0) {
          topChrome
            .padding(.top, topChromeTopPadding)
            .padding(.bottom, topChromeBottomSpacing)

          bodyContent
        }
      case .overlay:
        ZStack(alignment: .top) {
          bodyContent

          overlayTopChrome
        }
      }
    }
    .safeAreaInset(edge: .bottom) {
      bottomInset
    }
  }

  private var overlayTopChrome: some View {
    topChrome
      .padding(.top, topChromeTopPadding)
      .padding(.bottom, topChromeBottomSpacing)
      .background(backgroundChromeBand)
      .background(
        GeometryReader { proxy in
          Color.clear
            .onAppear { measuredTopChromeHeight = proxy.size.height }
            .onChange(of: proxy.size.height) { _, newValue in
              measuredTopChromeHeight = newValue
            }
        }
      )
  }

  @ViewBuilder
  private var backgroundChromeBand: some View {
    switch topChromeBackdropStyle {
    case .none:
      EmptyView()
    case .band:
      ZStack(alignment: .bottom) {
        Rectangle()
          .fill(.ultraThinMaterial)
          .overlay(
            backgroundColor
              .opacity(0.78)
          )
          .overlay(
            LinearGradient(
              colors: [
                Color.black.opacity(0.20),
                Color.black.opacity(0.12),
                Color.black.opacity(0.05)
              ],
              startPoint: .top,
              endPoint: .bottom
            )
          )
          .mask(
            LinearGradient(
              stops: [
                .init(color: .white, location: 0),
                .init(color: .white, location: 0.58),
                .init(color: .white.opacity(0.82), location: 0.78),
                .init(color: .clear, location: 1)
              ],
              startPoint: .top,
              endPoint: .bottom
            )
          )

        LinearGradient(
          colors: [
            backgroundColor.opacity(0.20),
            Color.black.opacity(0.05),
            Color.clear
          ],
          startPoint: .top,
          endPoint: .bottom
        )
        .frame(height: 30)
        .offset(y: 22)
      }
      .ignoresSafeArea(edges: .top)
      .allowsHitTesting(false)
    }
  }

  private var scrollBody: some View {
    VStack(alignment: .leading, spacing: heroToContentSpacing) {
      hero
        .padding(.top, heroTopOffset)

      content
        .padding(.horizontal, contentHorizontalPadding)
        .padding(.top, contentTopPadding + contentTopAdjustment)
        .padding(.bottom, contentBottomPadding)
    }
    .padding(.top, overlayReservedSpace)
  }

  private var overlayReservedSpace: CGFloat {
    guard topChromePlacement == .overlay, reservesTopChromeSpace else {
      return 0
    }

    return max(0, measuredTopChromeHeight - 12)
  }

  @ViewBuilder
  private var bodyContent: some View {
    if usesScrollView {
      ScrollView(showsIndicators: showsIndicators) {
        scrollBody
      }
      .background(
        SRScrollBounceConfigurator(disablesVerticalBounce: disablesVerticalScrollBounce)
      )
    } else {
      scrollBody
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
  }
}

extension SRScreenScaffold where Hero == EmptyView {
  init(
    usesScrollView: Bool = true,
    disablesVerticalScrollBounce: Bool = false,
    showsIndicators: Bool = false,
    backgroundColor: Color = SRColor.backgroundCanvas,
    topChromePlacement: TopChromePlacement = .stacked,
    topChromeBackdropStyle: TopChromeBackdropStyle = .none,
    reservesTopChromeSpace: Bool = false,
    topChromeTopPadding: CGFloat = SRSpacing.s8,
    topChromeBottomSpacing: CGFloat = SRSpacing.s8,
    heroTopOffset: CGFloat = 0,
    contentHorizontalPadding: CGFloat = SRSpacing.s16,
    contentTopPadding: CGFloat = SRSpacing.s16,
    contentTopAdjustment: CGFloat = 0,
    contentBottomPadding: CGFloat = SRSpacing.s32,
    @ViewBuilder topChrome: () -> TopChrome,
    @ViewBuilder content: () -> Content,
    @ViewBuilder bottomInset: () -> BottomInset
  ) {
    self.init(
      usesScrollView: usesScrollView,
      disablesVerticalScrollBounce: disablesVerticalScrollBounce,
      showsIndicators: showsIndicators,
      backgroundColor: backgroundColor,
      topChromePlacement: topChromePlacement,
      topChromeBackdropStyle: topChromeBackdropStyle,
      reservesTopChromeSpace: reservesTopChromeSpace,
      topChromeTopPadding: topChromeTopPadding,
      topChromeBottomSpacing: topChromeBottomSpacing,
      heroToContentSpacing: 0,
      heroTopOffset: heroTopOffset,
      contentHorizontalPadding: contentHorizontalPadding,
      contentTopPadding: contentTopPadding,
      contentTopAdjustment: contentTopAdjustment,
      contentBottomPadding: contentBottomPadding,
      topChrome: topChrome,
      hero: { EmptyView() },
      content: content,
      bottomInset: bottomInset
    )
  }
}

extension SRScreenScaffold where BottomInset == EmptyView {
  init(
    usesScrollView: Bool = true,
    disablesVerticalScrollBounce: Bool = false,
    showsIndicators: Bool = false,
    backgroundColor: Color = SRColor.backgroundCanvas,
    topChromePlacement: TopChromePlacement = .stacked,
    topChromeBackdropStyle: TopChromeBackdropStyle = .none,
    reservesTopChromeSpace: Bool = false,
    topChromeTopPadding: CGFloat = SRSpacing.s8,
    topChromeBottomSpacing: CGFloat = SRSpacing.s8,
    heroToContentSpacing: CGFloat = 0,
    heroTopOffset: CGFloat = 0,
    contentHorizontalPadding: CGFloat = SRSpacing.s16,
    contentTopPadding: CGFloat = SRSpacing.s16,
    contentTopAdjustment: CGFloat = 0,
    contentBottomPadding: CGFloat = SRSpacing.s32,
    @ViewBuilder topChrome: () -> TopChrome,
    @ViewBuilder hero: () -> Hero,
    @ViewBuilder content: () -> Content
  ) {
    self.init(
      usesScrollView: usesScrollView,
      disablesVerticalScrollBounce: disablesVerticalScrollBounce,
      showsIndicators: showsIndicators,
      backgroundColor: backgroundColor,
      topChromePlacement: topChromePlacement,
      topChromeBackdropStyle: topChromeBackdropStyle,
      reservesTopChromeSpace: reservesTopChromeSpace,
      topChromeTopPadding: topChromeTopPadding,
      topChromeBottomSpacing: topChromeBottomSpacing,
      heroToContentSpacing: heroToContentSpacing,
      heroTopOffset: heroTopOffset,
      contentHorizontalPadding: contentHorizontalPadding,
      contentTopPadding: contentTopPadding,
      contentTopAdjustment: contentTopAdjustment,
      contentBottomPadding: contentBottomPadding,
      topChrome: topChrome,
      hero: hero,
      content: content,
      bottomInset: { EmptyView() }
    )
  }
}

extension SRScreenScaffold where Hero == EmptyView, BottomInset == EmptyView {
  init(
    usesScrollView: Bool = true,
    disablesVerticalScrollBounce: Bool = false,
    showsIndicators: Bool = false,
    backgroundColor: Color = SRColor.backgroundCanvas,
    topChromePlacement: TopChromePlacement = .stacked,
    topChromeBackdropStyle: TopChromeBackdropStyle = .none,
    reservesTopChromeSpace: Bool = false,
    topChromeTopPadding: CGFloat = SRSpacing.s8,
    topChromeBottomSpacing: CGFloat = SRSpacing.s8,
    heroTopOffset: CGFloat = 0,
    contentHorizontalPadding: CGFloat = SRSpacing.s16,
    contentTopPadding: CGFloat = SRSpacing.s16,
    contentTopAdjustment: CGFloat = 0,
    contentBottomPadding: CGFloat = SRSpacing.s32,
    @ViewBuilder topChrome: () -> TopChrome,
    @ViewBuilder content: () -> Content
  ) {
    self.init(
      usesScrollView: usesScrollView,
      disablesVerticalScrollBounce: disablesVerticalScrollBounce,
      showsIndicators: showsIndicators,
      backgroundColor: backgroundColor,
      topChromePlacement: topChromePlacement,
      topChromeBackdropStyle: topChromeBackdropStyle,
      reservesTopChromeSpace: reservesTopChromeSpace,
      topChromeTopPadding: topChromeTopPadding,
      topChromeBottomSpacing: topChromeBottomSpacing,
      heroToContentSpacing: 0,
      heroTopOffset: heroTopOffset,
      contentHorizontalPadding: contentHorizontalPadding,
      contentTopPadding: contentTopPadding,
      contentTopAdjustment: contentTopAdjustment,
      contentBottomPadding: contentBottomPadding,
      topChrome: topChrome,
      hero: { EmptyView() },
      content: content,
      bottomInset: { EmptyView() }
    )
  }
}

private struct SRScrollBounceConfigurator: UIViewRepresentable {
  let disablesVerticalBounce: Bool

  func makeUIView(context: Context) -> UIView {
    let view = UIView(frame: .zero)
    DispatchQueue.main.async {
      configure(from: view)
    }
    return view
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    DispatchQueue.main.async {
      configure(from: uiView)
    }
  }

  private func configure(from view: UIView) {
    var current: UIView? = view
    while let candidate = current {
      if let scrollView = candidate as? UIScrollView {
        scrollView.bounces = disablesVerticalBounce == false
        scrollView.alwaysBounceVertical = disablesVerticalBounce == false
        return
      }
      current = candidate.superview
    }
  }
}

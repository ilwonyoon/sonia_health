import SwiftUI

#if canImport(UIKit)
import UIKit

struct SRVerticalScrollHost<Content: View>: UIViewControllerRepresentable {
  let showsIndicators: Bool
  let bounces: Bool
  let content: Content

  init(
    showsIndicators: Bool = false,
    bounces: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self.showsIndicators = showsIndicators
    self.bounces = bounces
    self.content = content()
  }

  func makeUIViewController(context: Context) -> SRVerticalScrollHostController<Content> {
    SRVerticalScrollHostController(
      rootView: content,
      showsIndicators: showsIndicators,
      bounces: bounces
    )
  }

  func updateUIViewController(_ controller: SRVerticalScrollHostController<Content>, context: Context) {
    controller.update(
      rootView: content,
      showsIndicators: showsIndicators,
      bounces: bounces
    )
  }
}

final class SRVerticalScrollHostController<Content: View>: UIViewController {
  private let scrollView = UIScrollView()
  private let hostingController: UIHostingController<Content>

  init(rootView: Content, showsIndicators: Bool, bounces: Bool) {
    hostingController = UIHostingController(rootView: rootView)
    hostingController.safeAreaRegions = []
    super.init(nibName: nil, bundle: nil)
    configureScrollView(showsIndicators: showsIndicators, bounces: bounces)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .clear
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    hostingController.view.backgroundColor = .clear

    addChild(hostingController)
    view.addSubview(scrollView)
    scrollView.addSubview(hostingController.view)
    hostingController.didMove(toParent: self)

    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      hostingController.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
      hostingController.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
      hostingController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
    ])
  }

  func update(rootView: Content, showsIndicators: Bool, bounces: Bool) {
    hostingController.rootView = rootView
    configureScrollView(showsIndicators: showsIndicators, bounces: bounces)
  }

  private func configureScrollView(showsIndicators: Bool, bounces: Bool) {
    scrollView.backgroundColor = .clear
    scrollView.showsVerticalScrollIndicator = showsIndicators
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.bounces = bounces
    scrollView.alwaysBounceVertical = bounces
    scrollView.alwaysBounceHorizontal = false
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.clipsToBounds = true
  }
}
#endif

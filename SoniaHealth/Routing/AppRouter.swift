import Combine
import Foundation
import SwiftUI

/// Centralized, observable router. Feature views read `currentRoute` and call
/// `navigate(to:)` / `present(sheet:)`. No embedded NavigationStack in features.
@MainActor
final class AppRouter: ObservableObject {
  @Published private(set) var currentRoute: AppRoute = .splash
  @Published private(set) var presentedSheet: AppRoute?

  func setInitialRoute(_ route: AppRoute) {
    currentRoute = route
  }

  func navigate(to route: AppRoute) {
    withAnimation(.spring(response: 0.38, dampingFraction: 0.88)) {
      currentRoute = route
    }
  }

  func present(sheet route: AppRoute) {
    presentedSheet = route
  }

  func dismissSheet() {
    presentedSheet = nil
  }
}

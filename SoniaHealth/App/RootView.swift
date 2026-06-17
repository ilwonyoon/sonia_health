import SwiftUI

/// Hosts the current route. Navigation flows through the central `AppRouter`.
struct RootView: View {
  @EnvironmentObject private var router: AppRouter

  var body: some View {
    ZStack {
      SRColor.backgroundCanvas.ignoresSafeArea()

      switch router.currentRoute {
      case .splash:
        SplashView()
      case .checkin(let kind):
        CheckInFlowView(kind: kind)
      case .session:
        SessionView()
      default:
        // All tabbed routes (companion / chat / content / you / settings / home …)
        // live inside the native Liquid Glass tab shell.
        MainTabView()
      }
    }
    .sheet(item: Binding(
      get: { router.presentedSheet.map(SheetRoute.init) },
      set: { if $0 == nil { router.dismissSheet() } }
    )) { sheet in
      if sheet.route == .settings { SettingsSheet() }
    }
  }
}

/// Identifiable wrapper so an AppRoute can drive `.sheet(item:)`.
private struct SheetRoute: Identifiable {
  let route: AppRoute
  var id: String { String(describing: route) }
}

private struct SplashView: View {
  @EnvironmentObject private var router: AppRouter

  var body: some View {
    SRText("take a deep breath", style: .homeMessage, tone: .secondary)
      .multilineTextAlignment(.center)
      .task {
        // Deep-link for screenshots/QA: SIMCTL_CHILD_SONIA_ROUTE=companion
        if let raw = ProcessInfo.processInfo.environment["SONIA_ROUTE"],
           let route = Self.route(for: raw) {
          router.navigate(to: route)
          return
        }
        try? await Task.sleep(nanoseconds: 1_800_000_000)
        router.navigate(to: .companion)
      }
  }

  static func route(for raw: String) -> AppRoute? {
    switch raw {
    case "home": return .home
    case "companion": return .companion
    case "chat": return .chat
    case "content": return .content
    case "you": return .you
    case "morning": return .checkin(.morningIntention)
    case "evening": return .checkin(.eveningReflection)
    case "session": return .session
    default: return nil
    }
  }
}

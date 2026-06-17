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
      case .onboarding, .home:
        HomeView()
      case .session:
        SessionView()
      case .history:
        HomeView()
      case .settings:
        HomeView()
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
    VStack(spacing: SRSpacing.s16) {
      VoiceOrbView(level: 0.25, isActive: true)
        .frame(width: 120, height: 120)
      SRText("Sonia", style: .homeMessage)
      SRText("Your voice companion for calmer days", style: .supporting, tone: .secondary)
    }
    .task {
      try? await Task.sleep(nanoseconds: 1_200_000_000)
      router.navigate(to: .home)
    }
  }
}

import SwiftUI

/// The app's main 5-tab shell, built on the native `TabView` so iOS renders the real
/// Liquid Glass tab bar (selection highlight, morph, press feedback) instead of a
/// hand-rolled glass capsule. Tab selection is bridged to `AppRouter`, mirroring the
/// SaveReset pattern: the binding reads the current route and writes a `navigate(to:)`.
struct MainTabView: View {
  @EnvironmentObject private var router: AppRouter

  private enum Tab: Hashable {
    case phone, chat, content, you, settings

    init(route: AppRoute) {
      switch route {
      case .chat: self = .chat
      case .content: self = .content
      case .you: self = .you
      case .settings: self = .settings
      default: self = .phone   // companion / home / onboarding / history
      }
    }

    var route: AppRoute {
      switch self {
      case .phone: return .companion
      case .chat: return .chat
      case .content: return .content
      case .you: return .you
      case .settings: return .settings
      }
    }
  }

  var body: some View {
    TabView(selection: tabBinding) {
      CompanionPhoneView()
        .tag(Tab.phone)
        .tabItem { Label("Phone", systemImage: "phone.fill") }

      TabPlaceholderView(title: "Chat", systemImage: "bubble.left.fill",
                         message: "Text conversations with Sonia are coming soon.")
        .tag(Tab.chat)
        .tabItem { Label("Chat", systemImage: "bubble.left.fill") }

      ContentTodayView()
        .tag(Tab.content)
        .tabItem { Label("Content", systemImage: "book.fill") }

      TabPlaceholderView(title: "You", systemImage: "person.fill",
                         message: "Your profile and progress are coming soon.")
        .tag(Tab.you)
        .tabItem { Label("You", systemImage: "person.fill") }

      SettingsTabView()
        .tag(Tab.settings)
        .tabItem { Label("Settings", systemImage: "gearshape.fill") }
    }
    .tint(SRColor.textPrimary)
  }

  private var tabBinding: Binding<Tab> {
    Binding(
      get: { Tab(route: router.currentRoute) },
      set: { router.navigate(to: $0.route) }
    )
  }
}

/// Lightweight placeholder for tabs that don't have a screen yet.
private struct TabPlaceholderView: View {
  let title: String
  let systemImage: String
  let message: String

  var body: some View {
    ZStack {
      SRColor.backgroundCanvas.ignoresSafeArea()
      VStack(spacing: SRSpacing.s12) {
        Image(systemName: systemImage)
          .font(.system(size: 40, weight: .light))
          .foregroundStyle(SRColor.textTertiary)
        SRText(title, style: .navigationLargeTitle)
        SRText(message, style: .body, tone: .secondary)
          .multilineTextAlignment(.center)
      }
      .padding(SRSpacing.s32)
    }
  }
}

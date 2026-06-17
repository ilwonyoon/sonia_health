import SwiftUI

@main
struct SoniaHealthApp: App {
  @StateObject private var router = AppRouter()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(router)
        .tint(SRColor.brandAction)
    }
  }
}

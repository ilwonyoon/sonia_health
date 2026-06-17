import SwiftUI
import UIKit

/// The guided-journal "call" landing — the morning/evening routine start screen reached
/// from a Sonia notification. It frames the moment in Sonia's voice and waits for the user
/// to **lift the phone to their ear** (proximity) to begin, like answering a call. A Begin
/// button is the explicit fallback (and the only path on devices without a proximity
/// sensor, e.g. the simulator).
struct GuidedJournalStartView: View {
  @EnvironmentObject private var router: AppRouter
  let kind: JournalCheckinKind

  @State private var started = false

  private var firstName: String { (try? SeedStore.load())?.user.firstName ?? "" }
  private var greeting: String {
    let name = firstName.isEmpty ? "" : ", \(firstName)"
    return kind == .morningIntention ? "Good morning\(name)" : "Good evening\(name)"
  }
  private var subtitle: String {
    kind == .morningIntention
      ? "Let's set today's intention together — just the two of us."
      : "Let's look back on today together — no rush."
  }

  var body: some View {
    ZStack {
      SRColor.backgroundCanvas.ignoresSafeArea()

      VStack(spacing: SRSpacing.s24) {
        header
        Spacer()

        VStack(spacing: SRSpacing.s8) {
          SRText(greeting, style: .homeMessage)
          SRText(subtitle, style: .homeMessage, tone: .secondary)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, SRSpacing.s12)

        Spacer()

        // Hint doubles as the tap fallback (lift-to-ear is the primary trigger).
        Button { begin() } label: {
          HStack(spacing: SRSpacing.s8) {
            Image(systemName: "ear").font(.system(size: 14, weight: .medium))
            Text("Bring me to your ear to begin").font(.system(size: 14))
          }
          .foregroundStyle(SRColor.textTertiary)
        }
        .buttonStyle(.plain)
        .padding(.bottom, SRSpacing.s24)
      }
      .padding(.horizontal, SRSpacing.s20)
      .padding(.top, SRSpacing.s8)
    }
    .onAppear { UIDevice.current.isProximityMonitoringEnabled = true }
    .onDisappear { UIDevice.current.isProximityMonitoringEnabled = false }
    .onReceive(NotificationCenter.default.publisher(for: UIDevice.proximityStateDidChangeNotification)) { _ in
      // Phone lifted to the ear → answer the "call".
      if UIDevice.current.proximityState { begin() }
    }
  }

  private var header: some View {
    HStack {
      Button { router.navigate(to: .you) } label: {
        Image(systemName: "chevron.left")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(SRColor.textPrimary)
          .frame(width: 36, height: 36)
          .background(Circle().fill(SRColor.backgroundElevated))
      }
      .buttonStyle(.plain)
      Spacer()
    }
  }

  private func begin() {
    guard started == false else { return }
    started = true
    UIDevice.current.isProximityMonitoringEnabled = false
    router.navigate(to: .journalCall(kind))
  }
}

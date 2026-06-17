#if DEBUG
import SwiftUI

/// Demo-only controls (DEBUG builds only) for driving the guided-journal loop by hand
/// during a live demo — fire the morning check-in, then the evening, regardless of the
/// clock, and reset today's state to re-run the loop. Never shipped in release.
struct GuidedJournalDemoControls: View {
  @EnvironmentObject private var router: AppRouter
  @State private var expanded = false
  @State private var today = ""
  @State private var morningDone = false
  @State private var eveningDone = false

  var body: some View {
    VStack(alignment: .trailing, spacing: SRSpacing.s8) {
      if expanded { panel }
      toggle
    }
    .onAppear(perform: refreshStatus)
  }

  // MARK: Toggle pill

  private var toggle: some View {
    Button {
      refreshStatus()
      withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { expanded.toggle() }
    } label: {
      HStack(spacing: SRSpacing.s4) {
        Image(systemName: expanded ? "xmark" : "wrench.and.screwdriver.fill")
          .font(.system(size: 11, weight: .semibold))
        Text("DEMO").font(.system(size: 11, weight: .bold)).tracking(0.5)
      }
      .foregroundStyle(.white)
      .padding(.horizontal, SRSpacing.s12)
      .padding(.vertical, SRSpacing.s8)
      .background(Capsule().fill(SRColor.textPrimary.opacity(0.88)))
    }
    .buttonStyle(.plain)
  }

  // MARK: Panel

  private var panel: some View {
    VStack(alignment: .leading, spacing: SRSpacing.s10) {
      Text("GUIDED JOURNAL — DEMO")
        .font(.system(size: 11, weight: .bold)).tracking(0.5)
        .foregroundStyle(SRColor.textTertiary)

      status

      action(icon: "sun.max.fill", tint: SRColor.accentMorning, label: "Trigger morning") {
        expanded = false
        router.navigate(to: .checkin(.morningIntention))
      }
      action(icon: "moon.stars.fill", tint: SRColor.accentEvening, label: "Trigger evening") {
        expanded = false
        router.navigate(to: .checkin(.eveningReflection))
      }
      Divider()
      action(icon: "arrow.counterclockwise", tint: SRColor.textSecondary, label: "Reset today") {
        resetToday()
      }
    }
    .padding(SRSpacing.s12)
    .frame(width: 230, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: SRRadius.lg, style: .continuous)
        .fill(SRColor.backgroundElevated)
        .shadow(color: .black.opacity(0.14), radius: 14, y: 6)
    )
  }

  private var status: some View {
    HStack(spacing: SRSpacing.s12) {
      statusDot(label: "Morning", done: morningDone, tint: SRColor.accentMorning)
      statusDot(label: "Evening", done: eveningDone, tint: SRColor.accentEvening)
    }
  }

  private func statusDot(label: String, done: Bool, tint: Color) -> some View {
    HStack(spacing: SRSpacing.s4) {
      Circle().fill(done ? tint : SRColor.borderMuted).frame(width: 7, height: 7)
      Text("\(label): \(done ? "done" : "—")")
        .font(.system(size: 12)).foregroundStyle(SRColor.textSecondary)
    }
  }

  private func action(icon: String, tint: Color, label: String, run: @escaping () -> Void) -> some View {
    Button(action: run) {
      HStack(spacing: SRSpacing.s8) {
        Image(systemName: icon).font(.system(size: 13)).foregroundStyle(tint).frame(width: 18)
        Text(label).font(.system(size: 14, weight: .medium)).foregroundStyle(SRColor.textPrimary)
        Spacer()
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }

  // MARK: State

  private func refreshStatus() {
    today = (try? SeedStore.load())?.meta.today ?? ""
    let journal = MemoryStore.load()
    morningDone = journal.guidedEntry(date: today, kind: .morningIntention) != nil
    eveningDone = journal.guidedEntry(date: today, kind: .eveningReflection) != nil
  }

  private func resetToday() {
    var journal = MemoryStore.load()
    journal.guidedEntries.removeAll { $0.date == today }
    MemoryStore.save(journal)
    GuidedJournalPrefetcher.shared.reset()
    refreshStatus()
  }
}
#endif

import SwiftUI

/// Content tab — the "Today" journal (IMG_3388).
///
/// Two states per item: OPEN items show as cards (the notification's question,
/// no timeline stamp); COMPLETED items drop into a timestamped timeline with the
/// saved answer + Sonia's reflection. Driven by our persona seed (journal_today.json).
struct ContentTodayView: View {
  @EnvironmentObject private var router: AppRouter
  private let today = JournalStore.loadOrFatal()

  private let columns = [
    GridItem(.flexible(), spacing: SRSpacing.s12),
    GridItem(.flexible(), spacing: SRSpacing.s12),
  ]

  var body: some View {
    ZStack {
      SRColor.backgroundCanvas.ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: SRSpacing.sectionGap) {
          header
          if let progress = today.checkInProgress, progress.sectionsLeft > 0 {
            finishBanner(progress)
          }
          if !today.openItems.isEmpty { openSection }
          if !today.completedItems.isEmpty { completedSection }
        }
        .padding(.horizontal, SRSpacing.s20)
        .padding(.top, SRSpacing.s12)
      }
    }
    .task { await warmGuidedJournals() }
  }

  /// Brief req #1: have Q1 ready before the user opens an entry. When the Today page
  /// appears, warm the first question for each open check-in so tapping the card is instant.
  @MainActor
  private func warmGuidedJournals() async {
    guard let seed = try? SeedStore.load() else { return }
    let journal = MemoryStore.load()
    let memory = SoniaMemoryContext.build(from: seed, journal: journal)
    for item in today.openItems where item.type == .checkin {
      guard let kind = item.kind else { continue }
      var carryOver: [GuidedJournalQuestionGenerator.QA] = []
      if kind == .eveningReflection,
         let morning = journal.guidedEntry(date: seed.meta.today, kind: .morningIntention) {
        carryOver = morning.qa.map { .init(question: $0.question, answer: $0.answer) }
      }
      GuidedJournalPrefetcher.shared.warm(
        kind: kind, memory: memory, carryOver: carryOver, today: seed.meta.today
      )
    }
  }

  // MARK: Header

  private var header: some View {
    HStack(alignment: .firstTextBaseline) {
      SRText("Today", style: .navigationLargeTitle)
      Spacer()
      HStack(spacing: SRSpacing.s12) {
        stat(icon: "flame.fill", value: today.stats.streakDays, tint: SRColor.accentMorning)
        stat(icon: "leaf.fill", value: today.stats.points, tint: SRColor.accentReward)
        stat(icon: "text.alignleft", value: today.stats.linesJournaled, tint: SRColor.textSecondary)
      }
    }
  }

  private func stat(icon: String, value: Int, tint: Color) -> some View {
    HStack(spacing: SRSpacing.s4) {
      Image(systemName: icon).font(.system(size: 12, weight: .semibold)).foregroundStyle(tint)
      Text("\(value)").font(.system(size: 14, weight: .semibold)).foregroundStyle(SRColor.textPrimary)
    }
  }

  // MARK: Finish-check-in banner

  private func finishBanner(_ progress: CheckInProgress) -> some View {
    SRCard(kind: .subtle) {
      HStack(spacing: SRSpacing.s12) {
        ZStack {
          Circle().fill(SRColor.accentRewardBackground).frame(width: 40, height: 40)
          Image(systemName: "leaf.fill").foregroundStyle(SRColor.accentReward)
        }
        VStack(alignment: .leading, spacing: SRSpacing.s2) {
          SRText("Finish your check-in", style: .bodyEmphasis)
          Text("\(progress.note) · \(progress.sectionsLeft) sections left")
            .font(.system(size: 13)).foregroundStyle(SRColor.textSecondary)
        }
        Spacer()
        Button { router.navigate(to: .session) } label: {
          Text("Finish")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(SRColor.textOnAccent)
            .padding(.horizontal, SRSpacing.s16)
            .padding(.vertical, SRSpacing.s8)
            .background(Capsule().fill(SRColor.accentAssessment))
        }
        .buttonStyle(.plain)
      }
      .padding(SRSpacing.cardPadding)
    }
  }

  // MARK: Open section

  private var openSection: some View {
    VStack(alignment: .leading, spacing: SRSpacing.s12) {
      sectionLabel("OPEN", count: today.openItems.count)
      LazyVGrid(columns: columns, spacing: SRSpacing.s12) {
        ForEach(today.openItems) { item in
          JournalOpenCard(item: item, onTap: { open(item) })
        }
      }
    }
  }

  // MARK: Completed section

  private var completedSection: some View {
    VStack(alignment: .leading, spacing: SRSpacing.s12) {
      sectionLabel("COMPLETED", count: today.completedItems.count)
      VStack(spacing: SRSpacing.s12) {
        ForEach(today.completedItems) { JournalCompletedCard(item: $0) }
      }
    }
  }

  private func sectionLabel(_ text: String, count: Int) -> some View {
    SRText("\(text) (\(count))", style: .eyebrow, tone: .tertiary)
  }

  /// Open a tapped item: check-ins go to the guided answer flow, others to a session.
  private func open(_ item: JournalItem) {
    if item.type == .checkin, let kind = item.kind {
      router.navigate(to: .checkin(kind))
    } else {
      router.navigate(to: .session)
    }
  }
}

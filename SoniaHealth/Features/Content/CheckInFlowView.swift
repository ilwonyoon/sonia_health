import SwiftUI

/// Guided check-in answering flow — shown when a Morning Intention or Evening Reflection
/// hasn't been answered yet. An *adaptive* sequence: Q1 is fetched up front, Q2/Q3 are
/// generated on the fly from the user's memory + their previous answers (see
/// `GuidedJournalSession`). Completed answers persist so the morning flows into the evening.
struct CheckInFlowView: View {
  @EnvironmentObject private var router: AppRouter
  let kind: JournalCheckinKind

  @StateObject private var session: GuidedJournalSession
  @FocusState private var inputFocused: Bool

  init(kind: JournalCheckinKind) {
    self.kind = kind
    _session = StateObject(wrappedValue: GuidedJournalSession(kind: kind))
  }

  private var accent: Color {
    kind == .morningIntention ? SRColor.accentMorning : SRColor.accentEvening
  }
  private var title: String {
    kind == .morningIntention ? "Morning Intention" : "Evening Reflection"
  }
  private var symbol: String {
    kind == .morningIntention ? "sun.max.fill" : "moon.stars.fill"
  }

  var body: some View {
    ZStack {
      SRColor.backgroundCanvas.ignoresSafeArea()

      VStack(spacing: SRSpacing.s24) {
        header
        CheckInProgressBar(total: session.total, current: session.index, accent: accent)

        switch session.phase {
        case .loading, .generating:
          Spacer()
          GuidedJournalWaitingView(kind: kind, phase: session.phase, accent: accent)
          Spacer()
        case .answering, .complete:
          CheckInQuestionHeader(
            symbol: symbol,
            step: session.index + 1,
            total: session.total,
            question: session.currentQuestion,
            accent: accent
          )
          Spacer(minLength: SRSpacing.s24)
          CheckInResponseField(text: answerBinding, accent: accent, focused: $inputFocused)
          controls
        }
      }
      .padding(.horizontal, SRSpacing.s20)
      .padding(.top, SRSpacing.s8)
      .padding(.bottom, SRSpacing.s16)
      .animation(.easeInOut(duration: 0.25), value: session.phase)
      .animation(.easeInOut(duration: 0.25), value: session.index)
    }
    .task { await session.start() }
  }

  // MARK: Header

  private var header: some View {
    ZStack {
      SRText(title, style: .navigationTitle)
      HStack {
        Button { router.navigate(to: .content) } label: {
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
  }

  // MARK: Controls

  private var controls: some View {
    HStack {
      if session.canGoPrevious {
        Button { session.goPrevious() } label: {
          HStack(spacing: SRSpacing.s4) {
            Image(systemName: "chevron.left").font(.system(size: 12, weight: .semibold))
            Text("Previous").font(.system(size: 15, weight: .medium))
          }
          .foregroundStyle(SRColor.textSecondary)
        }
        .buttonStyle(.plain)
      }
      Spacer()
      Button { advance() } label: {
        HStack(spacing: SRSpacing.s4) {
          Text(session.isLast ? "Complete" : "Continue").font(.system(size: 15, weight: .semibold))
          Image(systemName: session.isLast ? "checkmark" : "chevron.right")
            .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(SRColor.textOnAccent)
        .padding(.horizontal, SRSpacing.s20)
        .padding(.vertical, SRSpacing.s12)
        .background(Capsule().fill(accent))
      }
      .buttonStyle(.plain)
    }
  }

  // MARK: Actions

  private var answerBinding: Binding<String> {
    Binding(
      get: { session.currentAnswer },
      set: { session.setCurrentAnswer($0) }
    )
  }

  private func advance() {
    inputFocused = false
    Task {
      await session.advance()
      if session.phase == .complete {
        // Reward / report screen comes in the next chunk; for now return to Today.
        router.navigate(to: .content)
      }
    }
  }
}

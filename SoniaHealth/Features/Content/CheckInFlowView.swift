import SwiftUI

/// Guided check-in answering flow (IMG_3369–3373) — shown when a Morning Intention
/// or Evening Reflection hasn't been answered yet. A short multi-question sequence
/// with a segmented progress bar, a typed/spoken response, and Continue / Complete.
///
/// Questions come from our persona seed (journal_today.json → checkinQuestions).
struct CheckInFlowView: View {
  @EnvironmentObject private var router: AppRouter
  let kind: JournalCheckinKind

  private let questions: [String]
  @State private var index = 0
  @State private var answers: [String]
  @FocusState private var inputFocused: Bool

  init(kind: JournalCheckinKind) {
    self.kind = kind
    let qs = JournalStore.loadOrFatal().questions(for: kind)
    self.questions = qs
    _answers = State(initialValue: Array(repeating: "", count: qs.count))
  }

  private var isLast: Bool { index >= questions.count - 1 }
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
        CheckInProgressBar(total: questions.count, current: index, accent: accent)
        CheckInQuestionHeader(
          symbol: symbol,
          step: index + 1,
          total: questions.count,
          question: questions.indices.contains(index) ? questions[index] : "",
          accent: accent
        )
        Spacer(minLength: SRSpacing.s24)
        CheckInResponseField(text: answerBinding, accent: accent, focused: $inputFocused)
        controls
      }
      .padding(.horizontal, SRSpacing.s20)
      .padding(.top, SRSpacing.s8)
      .padding(.bottom, SRSpacing.s16)
    }
  }

  // MARK: Header

  private var header: some View {
    ZStack {
      SRText(title, style: .navigationTitle)
      HStack {
        Button { back() } label: {
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
      if index > 0 {
        Button { previous() } label: {
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
          Text(isLast ? "Complete" : "Continue").font(.system(size: 15, weight: .semibold))
          Image(systemName: isLast ? "checkmark" : "chevron.right")
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
      get: { answers.indices.contains(index) ? answers[index] : "" },
      set: { if answers.indices.contains(index) { answers[index] = $0 } }
    )
  }

  private func advance() {
    if isLast {
      // Prototype: a real build would persist the answers + flip the item to completed.
      router.navigate(to: .content)
    } else {
      withAnimation(.easeInOut(duration: 0.2)) { index += 1 }
    }
  }

  private func previous() {
    withAnimation(.easeInOut(duration: 0.2)) { index = max(0, index - 1) }
  }

  private func back() {
    router.navigate(to: .content)
  }
}

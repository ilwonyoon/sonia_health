import SwiftUI

/// The question-step header for a check-in flow: an accent "Question N of M"
/// eyebrow above the centered serif question.
struct CheckInQuestionHeader: View {
  let symbol: String
  let step: Int          // 1-based
  let total: Int
  let question: String
  let accent: Color

  var body: some View {
    VStack(spacing: SRSpacing.s24) {
      eyebrow
      questionText
    }
  }

  private var eyebrow: some View {
    HStack(spacing: SRSpacing.s4) {
      Image(systemName: symbol).font(.system(size: 12)).foregroundStyle(accent)
      Text("Question \(step) of \(total)")
        .font(.system(size: 13)).foregroundStyle(SRColor.textTertiary)
    }
  }

  private var questionText: some View {
    SRText(question, style: .questionTitle)
      .multilineTextAlignment(.center)
      .frame(maxWidth: .infinity)
  }
}

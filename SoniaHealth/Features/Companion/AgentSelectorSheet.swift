import SwiftUI

/// "Select your agent" sheet (IMG_3469). Tapping the name chip on the Phone screen
/// opens this. For now there's a single agent (Sonia); the carousel dots are scaffolding
/// for when multiple counselors land, so the UI is ready without the data yet.
struct AgentSelectorSheet: View {
  let agents: [Agent]
  var onSelect: (Agent) -> Void = { _ in }
  @Environment(\.dismiss) private var dismiss
  @State private var index = 0

  struct Agent: Identifiable, Equatable {
    let id: String
    let name: String
    let blurb: String
  }

  var body: some View {
    let agent = agents[min(index, agents.count - 1)]
    return VStack(spacing: SRSpacing.s24) {
      SRText("Select your agent", style: .bodyEmphasis)
        .padding(.top, SRSpacing.s20)

      Spacer(minLength: 0)

      VStack(spacing: SRSpacing.s12) {
        SRText(agent.name, style: .navigationLargeTitle)
        SRText(agent.blurb, style: .body, tone: .secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, SRSpacing.s24)
      }

      if agents.count > 1 {
        HStack(spacing: SRSpacing.s8) {
          ForEach(agents.indices, id: \.self) { i in
            Circle()
              .fill(i == index ? SRColor.textPrimary : SRColor.textTertiary.opacity(0.4))
              .frame(width: 6, height: 6)
          }
        }
      }

      Spacer(minLength: 0)

      Button {
        onSelect(agent)
        dismiss()
      } label: {
        SRText("Select \(agent.name)", style: .bodyEmphasis, tone: .inverse)
          .frame(maxWidth: .infinity)
          .padding(.vertical, SRSpacing.s16)
          .background(Capsule(style: .continuous).fill(SRColor.textPrimary))
      }
      .buttonStyle(.plain)
      .padding(.horizontal, SRSpacing.s20)
      .padding(.bottom, SRSpacing.s24)
    }
    .frame(maxWidth: .infinity)
    .background(SRColor.backgroundElevated.ignoresSafeArea())
    .presentationDetents([.height(360)])
    .presentationDragIndicator(.visible)
    .presentationCornerRadius(28)
  }
}

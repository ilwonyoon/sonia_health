import SwiftUI

struct SettingsSheet: View {
  @EnvironmentObject private var router: AppRouter

  var body: some View {
    VStack(alignment: .leading, spacing: SRSpacing.sectionGap) {
      HStack {
        SRText("Settings", style: .navigationLargeTitle)
        Spacer()
        SRGlassIconButton(systemName: "xmark", accessibilityLabel: "Close") {
          router.dismissSheet()
        }
      }

      SRCard(kind: .default) {
        VStack(alignment: .leading, spacing: SRSpacing.s8) {
          SRText("Voice", style: .bodyEmphasis)
          SRText("Skylar — warm, American (default)", style: .supporting, tone: .secondary)
        }
      }

      SRCard(kind: .subtle) {
        VStack(alignment: .leading, spacing: SRSpacing.s8) {
          SRText("About Sonia", style: .bodyEmphasis)
          SRText(
            "Sonia is an AI wellness companion built on evidence-based techniques. She is not a licensed therapist and not a substitute for professional care.",
            style: .supporting,
            tone: .secondary
          )
        }
      }

      Spacer()
    }
    .padding(SRSpacing.s24)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(SRColor.backgroundCanvas.ignoresSafeArea())
    .presentationDetents([.medium])
  }
}

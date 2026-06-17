import SwiftUI

/// Settings as a first-class tab (the native TabView shell hosts it). Mirrors the
/// content of `SettingsSheet` without the sheet chrome (no close button / detents).
struct SettingsTabView: View {
  var body: some View {
    ZStack {
      SRColor.backgroundCanvas.ignoresSafeArea()

      VStack(alignment: .leading, spacing: SRSpacing.sectionGap) {
        SRText("Settings", style: .navigationLargeTitle)

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
              "Sonia is an AI wellness companion built on evidence-based techniques. She is not a licensed therapist and not a substitute for professional care. In a crisis, call or text 988 (US) or your local emergency number.",
              style: .supporting,
              tone: .secondary
            )
          }
        }

        Spacer()
      }
      .padding(.horizontal, SRSpacing.s20)
      .padding(.top, SRSpacing.s12)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
  }
}

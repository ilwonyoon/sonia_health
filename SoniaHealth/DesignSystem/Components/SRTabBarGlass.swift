import SwiftUI

/// The 5-tab shell from the real Sonia app (IMG_3383): Phone · Chat · Content · You · Settings.
/// Glass bar, white-on-photo labels, active item tinted + highlighted.
enum SRHomeTab: String, CaseIterable, Identifiable {
  case phone, chat, content, you, settings
  var id: String { rawValue }

  var title: String {
    switch self {
    case .phone: return "Phone"
    case .chat: return "Chat"
    case .content: return "Content"
    case .you: return "You"
    case .settings: return "Settings"
    }
  }

  var icon: String {
    switch self {
    case .phone: return "phone.fill"
    case .chat: return "bubble.left.fill"
    case .content: return "book.fill"
    case .you: return "person.fill"
    case .settings: return "gearshape.fill"
    }
  }
}

struct SRTabBarGlass: View {
  let selected: SRHomeTab
  var onSelect: (SRHomeTab) -> Void = { _ in }

  var body: some View {
    let bar = HStack(spacing: 0) {
      ForEach(SRHomeTab.allCases) { tab in
        Button { onSelect(tab) } label: { item(tab) }
          .buttonStyle(.plain)
          .frame(maxWidth: .infinity)
      }
    }
    .padding(.horizontal, SRSpacing.s8)
    .padding(.vertical, SRSpacing.s8)

    if #available(iOS 26.0, *) {
      bar.glassEffect(.regular, in: Capsule(style: .continuous))
    } else {
      bar.background(.ultraThinMaterial, in: Capsule(style: .continuous))
        .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
    }
  }

  private func item(_ tab: SRHomeTab) -> some View {
    let active = tab == selected
    return VStack(spacing: SRSpacing.s4) {
      Image(systemName: tab.icon)
        .font(.system(size: 18, weight: .medium))
      Text(tab.title)
        .font(.system(size: 11, weight: active ? .semibold : .regular))
    }
    .foregroundStyle(active ? SRColor.brandAccent : SRColor.textSecondary)
    .frame(maxWidth: .infinity)
    .padding(.vertical, SRSpacing.s4)
  }
}

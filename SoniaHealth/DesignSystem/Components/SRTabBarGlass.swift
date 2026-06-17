import SwiftUI

/// The 5-tab shell from the real Sonia app (IMG_3383): Phone · Chat · Content · You · Settings.
/// Glass bar; the selected item gets its own Liquid Glass highlight that morphs between
/// tabs (GlassEffectContainer + glassEffectID), falling back to a tinted capsule pre-iOS 26.
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
    if #available(iOS 26.0, *) {
      SRTabBarGlassLiquid(selected: selected, onSelect: onSelect)
    } else {
      SRTabBarGlassFallback(selected: selected, onSelect: onSelect)
    }
  }
}

// MARK: - iOS 26 Liquid Glass

@available(iOS 26.0, *)
private struct SRTabBarGlassLiquid: View {
  let selected: SRHomeTab
  let onSelect: (SRHomeTab) -> Void

  var body: some View {
    HStack(spacing: SRSpacing.s4) {
      ForEach(SRHomeTab.allCases) { tab in
        let active = tab == selected
        Button { onSelect(tab) } label: {
          SRTabItem(tab: tab, active: active)
            .background {
              if active {
                Capsule(style: .continuous)
                  .glassEffect(.regular.interactive(), in: Capsule(style: .continuous))
              }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
      }
    }
    .padding(.horizontal, SRSpacing.s4)
    .padding(.vertical, SRSpacing.s4)
    .glassEffect(.regular, in: Capsule(style: .continuous))
    .animation(.spring(response: 0.38, dampingFraction: 0.82), value: selected)
  }
}

// MARK: - Pre-iOS 26 fallback

private struct SRTabBarGlassFallback: View {
  let selected: SRHomeTab
  let onSelect: (SRHomeTab) -> Void
  @Namespace private var highlightNamespace

  var body: some View {
    HStack(spacing: SRSpacing.s4) {
      ForEach(SRHomeTab.allCases) { tab in
        let active = tab == selected
        Button { onSelect(tab) } label: {
          SRTabItem(tab: tab, active: active)
            .background {
              if active {
                Capsule(style: .continuous)
                  .fill(SRColor.brandAccent.opacity(0.16))
                  .matchedGeometryEffect(id: "selection", in: highlightNamespace)
              }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
      }
    }
    .padding(.horizontal, SRSpacing.s4)
    .padding(.vertical, SRSpacing.s4)
    .background(.ultraThinMaterial, in: Capsule(style: .continuous))
    .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
    .animation(.spring(response: 0.38, dampingFraction: 0.82), value: selected)
  }
}

// MARK: - Shared item

private struct SRTabItem: View {
  let tab: SRHomeTab
  let active: Bool

  var body: some View {
    VStack(spacing: SRSpacing.s4) {
      Image(systemName: tab.icon)
        .font(.system(size: 18, weight: .medium))
      Text(tab.title)
        .font(.system(size: 11, weight: active ? .semibold : .regular))
    }
    .foregroundStyle(active ? SRColor.brandAccent : SRColor.textSecondary)
    .frame(maxWidth: .infinity)
    .padding(.vertical, SRSpacing.s8)
    .contentShape(Capsule(style: .continuous))
  }
}

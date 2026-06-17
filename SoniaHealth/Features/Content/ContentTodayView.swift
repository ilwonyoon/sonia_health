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
    ZStack(alignment: .bottom) {
      SRColor.backgroundCanvas.ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: SRSpacing.sectionGap) {
          header
          if let progress = today.checkInProgress, progress.sectionsLeft > 0 {
            finishBanner(progress)
          }
          if !today.openItems.isEmpty { openSection }
          if !today.completedItems.isEmpty { completedSection }
          Color.clear.frame(height: 96) // clearance for the floating tab bar
        }
        .padding(.horizontal, SRSpacing.s20)
        .padding(.top, SRSpacing.s12)
      }

      SRTabBarGlass(selected: .content) { tab in
        switch tab {
        case .phone: router.navigate(to: .companion)
        case .you, .settings: router.present(sheet: .settings)
        case .content, .chat: break
        }
      }
      .padding(.horizontal, SRSpacing.s16)
      .padding(.bottom, SRSpacing.s8)
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
        ForEach(today.openItems) { OpenCard(item: $0, onTap: { router.navigate(to: .session) }) }
      }
    }
  }

  // MARK: Completed section

  private var completedSection: some View {
    VStack(alignment: .leading, spacing: SRSpacing.s12) {
      sectionLabel("COMPLETED", count: today.completedItems.count)
      VStack(spacing: SRSpacing.s12) {
        ForEach(today.completedItems) { CompletedRow(item: $0) }
      }
    }
  }

  private func sectionLabel(_ text: String, count: Int) -> some View {
    SRText("\(text) (\(count))", style: .eyebrow, tone: .tertiary)
  }
}

// MARK: - Open card

private struct OpenCard: View {
  let item: JournalItem
  var onTap: () -> Void = {}

  var body: some View {
    Button(action: onTap) {
      SRCard {
        VStack(alignment: .leading, spacing: SRSpacing.s10) {
          HStack(alignment: .top) {
            JournalIconBadge(item: item)
            Spacer()
            VStack(alignment: .trailing, spacing: SRSpacing.s2) {
              Text(item.displayTime)
                .font(.system(size: 12)).foregroundStyle(SRColor.textTertiary)
              PointsPill(points: item.points)
            }
          }
          SRText(item.title, style: .bodyEmphasis)
          Text(item.prompt ?? item.body ?? "")
            .font(.system(size: 13))
            .foregroundStyle(SRColor.textSecondary)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .padding(SRSpacing.cardPadding)
      }
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Completed timeline row

private struct CompletedRow: View {
  let item: JournalItem

  var body: some View {
    HStack(alignment: .top, spacing: SRSpacing.s12) {
      VStack(spacing: SRSpacing.s4) {
        Text(item.displayTime)
          .font(.system(size: 11)).foregroundStyle(SRColor.textTertiary)
          .fixedSize()
        Circle().fill(JournalPalette.accent(for: item)).frame(width: 8, height: 8)
        Rectangle().fill(SRColor.borderMuted).frame(width: 1).frame(maxHeight: .infinity)
      }
      .frame(width: 64)

      SRCard {
        VStack(alignment: .leading, spacing: SRSpacing.s8) {
          HStack(spacing: SRSpacing.s8) {
            JournalIconBadge(item: item)
            SRText(item.title, style: .bodyEmphasis)
            Spacer()
            PointsPill(points: item.points)
          }
          if let subtitle = item.subtitle {
            Text(subtitle).font(.system(size: 14)).foregroundStyle(SRColor.textSecondary)
          }
          if let answer = item.answer {
            Text(answer).font(.system(size: 15)).foregroundStyle(SRColor.textPrimary)
              .fixedSize(horizontal: false, vertical: true)
          }
          if let response = item.soniaResponse {
            Text(response).font(.system(size: 13)).italic()
              .foregroundStyle(SRColor.textSecondary)
              .fixedSize(horizontal: false, vertical: true)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SRSpacing.cardPadding)
        .overlay(alignment: .leading) {
          RoundedRectangle(cornerRadius: 2)
            .fill(JournalPalette.accent(for: item))
            .frame(width: 3)
            .padding(.vertical, SRSpacing.s8)
        }
      }
    }
  }
}

// MARK: - Shared bits

private struct JournalIconBadge: View {
  let item: JournalItem
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: SRRadius.md)
        .fill(JournalPalette.accent(for: item).opacity(0.18))
        .frame(width: 30, height: 30)
      Image(systemName: item.sfSymbol)
        .font(.system(size: 14, weight: .medium))
        .foregroundStyle(JournalPalette.accent(for: item))
    }
  }
}

private struct PointsPill: View {
  let points: Int
  var body: some View {
    HStack(spacing: SRSpacing.s2) {
      Image(systemName: "leaf.fill").font(.system(size: 10))
      Text("+\(points)").font(.system(size: 12, weight: .semibold))
    }
    .foregroundStyle(SRColor.accentReward)
  }
}

private enum JournalPalette {
  static func accent(for item: JournalItem) -> Color {
    switch item.type {
    case .quote: return SRColor.accentEvening
    case .meditation, .exercise: return SRColor.accentReward
    case .checkin:
      switch item.kind {
      case .morningIntention: return SRColor.accentMorning
      case .eveningReflection: return SRColor.accentEvening
      case .none: return SRColor.brandAccent
      }
    }
  }
}

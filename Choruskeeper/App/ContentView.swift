import SwiftUI

struct ContentView: View {
    enum Section: String, CaseIterable, Identifiable {
        case sanctuary
        case atlas
        case harmonise
        case collection
        case today

        var id: String { rawValue }

        var title: String {
            switch self {
            case .sanctuary: "Sanctuary"
            case .atlas: "Atlas"
            case .harmonise: "Harmonise"
            case .collection: "Cadents"
            case .today: "Today"
            }
        }

        var symbol: String {
            switch self {
            case .sanctuary: "sparkles"
            case .atlas: "map.fill"
            case .harmonise: "tuningfork"
            case .collection: "books.vertical.fill"
            case .today: "sun.max.fill"
            }
        }
    }

    @ObservedObject var store: GameStore
    @State private var section: Section = .sanctuary
    @State private var presentedLevel: LevelDefinition?

    var body: some View {
        ZStack(alignment: .bottom) {
            ChorusTheme.ink.ignoresSafeArea()

            Group {
                switch section {
                case .sanctuary:
                    SanctuaryView(store: store) { presentedLevel = $0 }
                case .atlas:
                    AtlasView(store: store) { presentedLevel = $0 }
                case .harmonise:
                    HarmoniseView(store: store)
                case .collection:
                    CollectionView(store: store)
                case .today:
                    TodayView(store: store) { presentedLevel = $0 }
                }
            }
            .safeAreaPadding(.bottom, 82)

            navigationBar
        }
        .fullScreenCover(item: $presentedLevel) { level in
            MelodyPuzzleView(
                level: level,
                isFirstClear: store.progress.bestStars[level.id] == nil
            ) { stars in
                store.complete(level, stars: stars)
            }
        }
    }

    private var navigationBar: some View {
        HStack(spacing: 3) {
            ForEach(Section.allCases) { item in
                Button {
                    withAnimation(.snappy) { section = item }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: item.symbol)
                            .font(.system(size: item == .harmonise ? 22 : 17, weight: .bold))
                        Text(item.title)
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .lineLimit(1)
                    }
                    .foregroundStyle(section == item ? ChorusTheme.brass : ChorusTheme.mist.opacity(0.62))
                    .padding(.vertical, item == .harmonise ? 12 : 9)
                    .background(
                        Circle()
                            .fill(section == item ? ChorusTheme.peacock.opacity(0.34) : .clear)
                            .frame(width: 50, height: 50)
                            .opacity(item == .harmonise ? 1 : 0)
                    )
                }
                .buttonStyle(.plain)
                .frame(width: 68)
                .accessibilityLabel(item.title)
                .accessibilityAddTraits(section == item ? .isSelected : [])
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { Divider().opacity(0.18) }
    }
}

import SwiftUI

struct AtlasView: View {
    @ObservedObject var store: GameStore
    let playLevel: (LevelDefinition) -> Void

    private var islands: [String] {
        LevelDefinition.campaign.reduce(into: []) { result, level in
            if !result.contains(level.island) { result.append(level.island) }
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                header
                ForEach(Array(islands.enumerated()), id: \.element) { index, island in
                    islandSection(island, index: index)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .padding(.bottom, 28)
        }
        .background(atlasBackground)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("SONG ATLAS")
                .font(.system(.caption, design: .rounded, weight: .black))
                .tracking(3)
                .foregroundStyle(ChorusTheme.coral)
            Text("The islands remember")
                .displayTitle()
            Text("Replay each lost melody. Better performances earn more stars, but every honest attempt moves the story forward.")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(ChorusTheme.mist.opacity(0.72))
        }
        .padding(.top, 8)
    }

    private func islandSection(_ island: String, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(format: "%02d", index + 1))
                    .font(.system(.title3, design: .serif, weight: .bold))
                    .foregroundStyle(ChorusTheme.brass)
                Text(island)
                    .font(.system(.title2, design: .serif, weight: .bold))
                Spacer()
                Text("\(islandStars(island))/9")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(.secondary)
            }

            ForEach(LevelDefinition.campaign.filter { $0.island == island }) { level in
                levelRow(level)
            }
        }
        .chorusCard()
    }

    private func levelRow(_ level: LevelDefinition) -> some View {
        let unlocked = store.isUnlocked(level)
        let stars = store.progress.bestStars[level.id, default: 0]

        return Button {
            if unlocked { playLevel(level) }
        } label: {
            HStack(spacing: 13) {
                ZStack {
                    Circle()
                        .fill(unlocked ? ChorusTheme.color(for: level.tone).opacity(0.25) : Color.white.opacity(0.05))
                    Image(systemName: unlocked ? level.tone.symbol : "lock.fill")
                        .foregroundStyle(unlocked ? ChorusTheme.color(for: level.tone) : .secondary)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text(level.title)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                    Text(unlocked ? level.subtitle : "Needs \(level.starsToUnlock) stars")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < stars ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundStyle(index < stars ? ChorusTheme.brass : Color.white.opacity(0.18))
                    }
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
        .accessibilityHint(unlocked ? "Opens the melody puzzle" : "Earn more stars to unlock")
    }

    private func islandStars(_ island: String) -> Int {
        LevelDefinition.campaign
            .filter { $0.island == island }
            .reduce(0) { $0 + store.progress.bestStars[$1.id, default: 0] }
    }

    private var atlasBackground: some View {
        ZStack {
            ChorusTheme.ink
            RadialGradient(colors: [ChorusTheme.peacock.opacity(0.23), .clear], center: .topTrailing, startRadius: 10, endRadius: 420)
            RadialGradient(colors: [ChorusTheme.coral.opacity(0.13), .clear], center: .bottomLeading, startRadius: 10, endRadius: 360)
        }
        .ignoresSafeArea()
    }
}

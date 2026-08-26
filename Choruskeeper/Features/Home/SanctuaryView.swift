import SwiftUI

struct SanctuaryView: View {
    @ObservedObject var store: GameStore
    let playLevel: (LevelDefinition) -> Void

    private var companion: CadentSpecies {
        let speciesID = store.progress.ownedCadents.first?.speciesID ?? "bramblebeat"
        return CadentSpecies.species(id: speciesID) ?? CadentSpecies.catalog[0]
    }

    var body: some View {
        ZStack {
            SkyArtworkBackground()
                .overlay {
                    LinearGradient(
                        colors: [ChorusTheme.ink.opacity(0.2), .clear, ChorusTheme.ink.opacity(0.76)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                    Spacer(minLength: 170)
                    companionCard
                    nextMelodyCard
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 28)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("CHORUSKEEPER")
                        .font(.system(.caption, design: .rounded, weight: .black))
                        .tracking(3.4)
                        .foregroundStyle(ChorusTheme.brass)
                    Text("The Quiet Sky")
                        .font(.system(.title, design: .serif, weight: .bold))
                }
                Spacer()
                ResourcePill(symbol: "sparkles", value: store.progress.sparks, tint: ChorusTheme.brass)
            }

            HStack(spacing: 8) {
                ResourcePill(symbol: "star.fill", value: store.progress.totalStars, tint: ChorusTheme.brass, label: "stars")
                ResourcePill(symbol: "pawprint.fill", value: store.progress.discoveredSpeciesIDs.count, tint: ChorusTheme.peacock, label: "voices")
            }
        }
    }

    private var companionCard: some View {
        HStack(spacing: 8) {
            CadentArtwork(species: companion)
                .frame(width: 118, height: 112)
                .offset(y: -8)

            VStack(alignment: .leading, spacing: 6) {
                Text("Your first voice")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(ChorusTheme.brass)
                    .textCase(.uppercase)
                Text(companion.name)
                    .font(.system(.title2, design: .serif, weight: .bold))
                Text(companion.epithet)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(ChorusTheme.mist.opacity(0.75))
            }
            Spacer(minLength: 0)
        }
        .chorusCard(padding: 12)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var nextMelodyCard: some View {
        if let level = store.nextLevel {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    ToneBadge(tone: level.tone)
                    Spacer()
                    Text("MELODY \(level.number) OF \(LevelDefinition.campaign.count)")
                        .font(.system(.caption2, design: .rounded, weight: .black))
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(level.island)
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(ChorusTheme.brass)
                    Text(level.title)
                        .font(.system(.title2, design: .serif, weight: .bold))
                    Text(level.subtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(ChorusTheme.mist.opacity(0.7))
                }
                Button {
                    playLevel(level)
                } label: {
                    Label("Restore this melody", systemImage: "play.fill")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(ChorusTheme.ink)
                        .background(ChorusTheme.brass.gradient, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .chorusCard()
            .frame(maxWidth: .infinity)
        }
    }
}

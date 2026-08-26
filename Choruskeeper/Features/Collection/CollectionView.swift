import SwiftUI

struct CollectionView: View {
    @ObservedObject var store: GameStore
    @State private var selectedSpecies: CadentSpecies?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header
                LazyVGrid(columns: columns, spacing: 13) {
                    ForEach(CadentSpecies.catalog) { species in
                        speciesCard(species)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .padding(.bottom, 30)
        }
        .background(collectionBackground)
        .sheet(item: $selectedSpecies) { species in
            SpeciesDetailView(species: species, store: store)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("THE LIVING SCORE")
                        .font(.system(.caption, design: .rounded, weight: .black))
                        .tracking(3)
                        .foregroundStyle(ChorusTheme.peacock)
                    Text("Cadents")
                        .displayTitle()
                }
                Spacer()
                ResourcePill(symbol: "pawprint.fill", value: store.progress.discoveredSpeciesIDs.count, tint: ChorusTheme.peacock, label: "of \(CadentSpecies.catalog.count)")
            }
            Text("Natural sounds made curious. Bond with each voice to reveal how it changes the islands.")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(ChorusTheme.mist.opacity(0.7))
        }
        .padding(.top, 8)
    }

    private func speciesCard(_ species: CadentSpecies) -> some View {
        let discovered = store.progress.discoveredSpeciesIDs.contains(species.id)
        let owned = store.progress.ownedCadents.filter { $0.speciesID == species.id }

        return Button {
            if discovered { selectedSpecies = species }
        } label: {
            VStack(spacing: 7) {
                CadentArtwork(species: species, isDiscovered: discovered)
                    .frame(height: 135)
                Text(discovered ? species.name : "Unknown voice")
                    .font(.system(.headline, design: .serif, weight: .bold))
                    .lineLimit(1)
                HStack(spacing: 5) {
                    Image(systemName: discovered ? species.affinity.symbol : "questionmark")
                    Text(discovered ? "\(species.rarity.title) · \(owned.count)" : "Keep listening")
                }
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundStyle(discovered ? ChorusTheme.color(for: species.affinity) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .chorusCard(padding: 11)
        }
        .buttonStyle(.plain)
        .disabled(!discovered)
    }

    private var collectionBackground: some View {
        LinearGradient(
            colors: [ChorusTheme.ink, ChorusTheme.deepBlue, ChorusTheme.ink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct SpeciesDetailView: View {
    let species: CadentSpecies
    @ObservedObject var store: GameStore
    @Environment(\.dismiss) private var dismiss

    private var owned: [OwnedCadent] {
        store.progress.ownedCadents.filter { $0.speciesID == species.id }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                HStack {
                    ToneBadge(tone: species.affinity)
                    Spacer()
                    Text(species.rarity.title.uppercased())
                        .font(.system(.caption2, design: .rounded, weight: .black))
                        .tracking(1.8)
                        .foregroundStyle(ChorusTheme.brass)
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
                CadentArtwork(species: species)
                    .frame(height: 290)
                VStack(spacing: 5) {
                    Text(species.name)
                        .displayTitle()
                    Text(species.epithet)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(ChorusTheme.mist.opacity(0.7))
                }
                Text(species.lore)
                    .font(.system(.title3, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(ChorusTheme.cream.opacity(0.86))
                    .padding(.horizontal, 10)

                ForEach(owned) { cadent in
                    bondCard(cadent)
                }
            }
            .padding(20)
        }
        .background(ChorusTheme.ink.ignoresSafeArea())
    }

    private func bondCard(_ cadent: OwnedCadent) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(cadent.nickname.isEmpty ? species.name : cadent.nickname)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                    Text("Bond level \(cadent.bondLevel) · \(cadent.bondNotes) notes shared")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "heart.fill")
                    .foregroundStyle(ChorusTheme.coral)
            }
            ProgressView(value: Double(cadent.bondNotes), total: 9)
                .tint(ChorusTheme.coral)
            Button {
                store.addBondNote(to: cadent.id)
            } label: {
                HStack {
                    Label("Share a bond note", systemImage: "music.note")
                    Spacer()
                    Text("\(GameEngine.bondSparkCost)")
                    Image(systemName: "sparkles")
                }
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(ChorusTheme.coral.opacity(0.18), in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(store.progress.sparks < GameEngine.bondSparkCost)
        }
        .chorusCard()
    }
}

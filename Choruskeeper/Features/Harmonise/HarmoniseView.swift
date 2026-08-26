import SwiftUI

struct HarmoniseView: View {
    @ObservedObject var store: GameStore
    @StateObject private var model = HarmoniseViewModel()

    var body: some View {
        ZStack {
            harmonyBackground

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    header
                    resonanceDais
                    toneGrid
                    actionButton
                    fairnessNote
                }
                .frame(maxWidth: .infinity)
                .padding(18)
                .padding(.bottom, 28)
            }
        }
        .overlay {
            if let revealedSpecies = model.revealedSpecies {
                discoveryOverlay(revealedSpecies)
            }
        }
        .animation(.easeOut(duration: 0.35), value: model.revealedSpecies)
        .alert("The harmony needs more", isPresented: Binding(
            get: { model.errorMessage != nil },
            set: { if !$0 { model.dismissError() } }
        )) {
            Button("Got it", role: .cancel) { model.dismissError() }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("THE RESONARIUM")
                        .font(.system(.caption, design: .rounded, weight: .black))
                        .tracking(3)
                        .foregroundStyle(ChorusTheme.brass)
                    Text("Harmonise a voice")
                        .displayTitle()
                }
                Spacer()
                ResourcePill(symbol: "sparkles", value: store.progress.sparks, tint: ChorusTheme.brass)
            }
            Text("Pair two tone fragments. The same pair always calls the same family, and every fifth harmony after 8 stars is guaranteed to be fabled.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(ChorusTheme.mist.opacity(0.72))
        }
        .padding(.top, 8)
    }

    private var resonanceDais: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .stroke(ChorusTheme.brass.opacity(0.12 + Double(index) * 0.05), lineWidth: 1)
                    .frame(width: CGFloat(90 + index * 36))
            }
                Circle()
                    .fill(ChorusTheme.peacock.opacity(0.18))
                    .frame(width: 108, height: 108)
                    .blur(radius: model.isResonating ? 4 : 12)
                    .scaleEffect(model.isResonating ? 1.25 : 1)

            HStack(spacing: 12) {
                ForEach(Array(model.selectedTones.enumerated()), id: \.offset) { _, tone in
                    Image(systemName: tone.symbol)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(ChorusTheme.color(for: tone))
                        .frame(width: 60, height: 60)
                        .background(.ultraThinMaterial, in: Circle())
                        .transition(.scale.combined(with: .opacity))
                }

                ForEach(model.selectedTones.count..<2, id: \.self) { _ in
                    Circle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(Color.white.opacity(0.24))
                        .frame(width: 60, height: 60)
                }
            }
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
        .chorusCard(padding: 8)
        .animation(.spring(response: 0.35), value: model.selectedTones)
    }

    private var toneGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 11) {
            ForEach(Tone.allCases) { tone in
                Button {
                    model.choose(tone, availableFragments: store.progress.fragments(for: tone))
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: tone.symbol)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(ChorusTheme.color(for: tone))
                            .frame(width: 38, height: 38)
                            .background(ChorusTheme.color(for: tone).opacity(0.14), in: Circle())
                        VStack(alignment: .leading, spacing: 1) {
                            Text(tone.title)
                                .font(.system(.headline, design: .rounded, weight: .bold))
                            Text("\(store.progress.fragments(for: tone)) fragments")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(ChorusTheme.color(for: tone).opacity(model.selectedTones.contains(tone) ? 0.8 : 0.12), lineWidth: 1.5)
                    }
                }
                .buttonStyle(.plain)
                .disabled(store.progress.fragments(for: tone) == 0 || model.selectedTones.count == 2)
                .opacity(store.progress.fragments(for: tone) == 0 ? 0.45 : 1)
            }
        }
    }

    private var actionButton: some View {
        Button {
            Task {
                await model.harmonise(using: store)
            }
        } label: {
            HStack {
                Label("Begin harmony", systemImage: "waveform.path")
                Spacer()
                Text("\(GameEngine.harmonySparkCost)")
                Image(systemName: "sparkles")
            }
            .font(.system(.headline, design: .rounded, weight: .bold))
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .foregroundStyle(ChorusTheme.ink)
            .background(ChorusTheme.brass.gradient, in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(model.selectedTones.count != 2 || model.isResonating)
        .opacity(model.selectedTones.count == 2 ? 1 : 0.45)
    }

    private var fairnessNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "heart.text.clipboard.fill")
                .foregroundStyle(ChorusTheme.coral)
            Text("No waiting room, premium currency, or paid rerolls. Restore melodies to earn every resource in the game.")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(ChorusTheme.mist.opacity(0.65))
        }
        .padding(.horizontal, 8)
    }

    private func discoveryOverlay(_ species: CadentSpecies) -> some View {
        ZStack {
            ChorusTheme.ink.opacity(0.96).ignoresSafeArea()
            RadialGradient(
                colors: [ChorusTheme.color(for: species.affinity).opacity(0.46), .clear],
                center: .center,
                startRadius: 20,
                endRadius: 320
            )
            VStack(spacing: 12) {
                Text("A NEW VOICE ANSWERS")
                    .font(.system(.caption, design: .rounded, weight: .black))
                    .tracking(3)
                    .foregroundStyle(ChorusTheme.brass)
                CadentArtwork(species: species)
                    .frame(height: 310)
                Text(species.name)
                    .displayTitle()
                Text(species.epithet)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(ChorusTheme.mist.opacity(0.75))
                ToneBadge(tone: species.affinity)
                Text(species.lore)
                    .font(.system(.body, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(ChorusTheme.cream.opacity(0.82))
                    .padding(.horizontal, 28)
                Button("Welcome, \(species.name)") {
                    withAnimation(.easeInOut) { model.dismissDiscovery() }
                }
                .font(.system(.headline, design: .rounded, weight: .bold))
                .padding(.horizontal, 26)
                .padding(.vertical, 14)
                .background(ChorusTheme.brass, in: Capsule())
                .foregroundStyle(ChorusTheme.ink)
                .padding(.top, 8)
            }
            .padding()
        }
        .transition(.opacity.combined(with: .scale(scale: 1.03)))
    }

    private var harmonyBackground: some View {
        ZStack {
            ChorusTheme.ink
            RadialGradient(colors: [ChorusTheme.peacock.opacity(0.32), .clear], center: .center, startRadius: 0, endRadius: 430)
        }
        .ignoresSafeArea()
    }

}

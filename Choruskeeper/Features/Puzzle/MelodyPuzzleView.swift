import SwiftUI

struct MelodyPuzzleView: View {
    let level: LevelDefinition
    let isFirstClear: Bool
    let onComplete: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var model: MelodyPuzzleViewModel

    init(level: LevelDefinition, isFirstClear: Bool, onComplete: @escaping (Int) -> Void) {
        self.level = level
        self.isFirstClear = isFirstClear
        self.onComplete = onComplete
        _model = StateObject(wrappedValue: MelodyPuzzleViewModel(melody: level.melody))
    }

    var body: some View {
        ZStack {
            puzzleBackground

            VStack(spacing: 20) {
                puzzleHeader
                Spacer(minLength: 4)
                if model.phase == .complete {
                    completionView
                } else {
                    scoreRibbon
                    toneGrid
                    instructionArea
                }
                Spacer(minLength: 4)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
        }
        .sensoryFeedback(.impact(weight: .light), trigger: model.feedbackTrigger)
    }

    private var puzzleHeader: some View {
        HStack(alignment: .top) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.headline.weight(.bold))
                    .frame(width: 42, height: 42)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityLabel("Close melody")

            Spacer()
            VStack(spacing: 3) {
                Text(level.island.uppercased())
                    .font(.system(.caption2, design: .rounded, weight: .black))
                    .tracking(2)
                    .foregroundStyle(ChorusTheme.brass)
                Text(level.title)
                    .font(.system(.title2, design: .serif, weight: .bold))
                Text("Melody \(level.number)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ToneBadge(tone: level.tone)
                .frame(width: 70)
        }
    }

    private var scoreRibbon: some View {
        HStack(spacing: 8) {
            ForEach(level.melody.indices, id: \.self) { index in
                Capsule()
                    .fill(ribbonColor(at: index))
                    .frame(maxWidth: 34)
                    .frame(height: 6)
            }
        }
        .padding(.horizontal, 22)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(model.session.cursor) of \(level.melody.count) notes complete")
    }

    private var toneGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(Tone.allCases) { tone in
                Button {
                    play(tone)
                } label: {
                    VStack(spacing: 10) {
                        Image(systemName: tone.symbol)
                            .font(.system(size: 32, weight: .bold))
                        Text(tone.title)
                            .font(.system(.headline, design: .rounded, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 118)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(ChorusTheme.color(for: tone).gradient.opacity(0.9))
                            .shadow(
                                color: ChorusTheme.color(for: tone).opacity(model.highlightedTone == tone ? 0.85 : 0.18),
                                radius: model.highlightedTone == tone ? 26 : 8
                            )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(model.highlightedTone == tone ? 0.88 : 0.14), lineWidth: model.highlightedTone == tone ? 4 : 1)
                    }
                    .scaleEffect(model.highlightedTone == tone ? 1.06 : 1)
                }
                .buttonStyle(.plain)
                .disabled(model.phase != .playing)
                .accessibilityHint(model.phase == .playing ? "Play this tone" : "Wait until the melody finishes")
            }
        }
        .animation(.spring(response: 0.24), value: model.highlightedTone)
    }

    private var instructionArea: some View {
        VStack(spacing: 13) {
            HStack(spacing: 8) {
                Image(systemName: model.session.mistakes == 0 ? "ear.fill" : "arrow.counterclockwise")
                    .foregroundStyle(model.session.mistakes == 0 ? ChorusTheme.brass : ChorusTheme.coral)
                Text(model.feedback)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
            }
            .multilineTextAlignment(.center)
            .frame(minHeight: 42)

            Button {
                Task { await model.previewMelody() }
            } label: {
                Label(model.buttonTitle, systemImage: model.phase == .ready ? "play.fill" : "ear.fill")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(ChorusTheme.ink)
                    .background(ChorusTheme.brass.gradient, in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(model.phase == .listening)
        }
        .chorusCard()
    }

    private var completionView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(ChorusTheme.brass.opacity(0.13))
                    .frame(width: 210, height: 210)
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 96, weight: .thin))
                    .foregroundStyle(ChorusTheme.brass)
            }
            Text("The island sings")
                .displayTitle()
            Text(level.subtitle)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(ChorusTheme.mist.opacity(0.72))

            HStack(spacing: 14) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < model.session.stars ? "star.fill" : "star")
                        .font(.system(size: 33, weight: .bold))
                        .foregroundStyle(index < model.session.stars ? ChorusTheme.brass : Color.white.opacity(0.18))
                        .scaleEffect(index < model.session.stars ? 1 : 0.84)
                }
            }

            HStack(spacing: 10) {
                ResourcePill(symbol: "sparkles", value: isFirstClear ? level.firstClearSparks : 5, tint: ChorusTheme.brass, label: "sparks")
                ResourcePill(symbol: level.tone.symbol, value: isFirstClear ? 2 : 1, tint: ChorusTheme.color(for: level.tone), label: "fragments")
            }

            Button {
                dismiss()
            } label: {
                Text("Return to the isles")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(ChorusTheme.brass, in: Capsule())
                    .foregroundStyle(ChorusTheme.ink)
            }
            .buttonStyle(.plain)
        }
        .transition(.scale.combined(with: .opacity))
        .chorusCard()
    }

    private var puzzleBackground: some View {
        ZStack {
            SkyArtworkBackground(artworkOpacity: 0.11, blurRadius: 3)
            RadialGradient(colors: [ChorusTheme.color(for: level.tone).opacity(0.32), .clear], center: .center, startRadius: 10, endRadius: 430)
        }
        .ignoresSafeArea()
    }

    private func ribbonColor(at index: Int) -> Color {
        if index < model.session.cursor {
            ChorusTheme.brass
        } else if model.phase == .listening && model.highlightedTone == level.melody[index] {
            ChorusTheme.color(for: level.melody[index])
        } else {
            Color.white.opacity(0.15)
        }
    }

    private func play(_ tone: Tone) {
        Task { @MainActor in
            if let stars = await model.play(tone) {
                onComplete(stars)
                withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                    model.showCompletion()
                }
            }
        }
    }
}

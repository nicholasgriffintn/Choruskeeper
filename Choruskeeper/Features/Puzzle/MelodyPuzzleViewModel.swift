import Combine
import Foundation

@MainActor
final class MelodyPuzzleViewModel: ObservableObject {
    enum Phase {
        case ready
        case listening
        case playing
        case complete
    }

    @Published private(set) var session: MelodySession
    @Published private(set) var phase: Phase = .ready
    @Published private(set) var highlightedTone: Tone?
    @Published private(set) var feedback = "Listen first, then return the melody."
    @Published private(set) var feedbackTrigger = 0

    private let melody: [Tone]
    private var hasEmittedCompletion = false

    init(melody: [Tone]) {
        self.melody = melody
        session = MelodySession(melody: melody)
    }

    var buttonTitle: String {
        switch phase {
        case .ready: "Hear the melody"
        case .listening: "Listening…"
        case .playing: "Hear it again"
        case .complete: "Complete"
        }
    }

    func previewMelody() async {
        guard phase != .listening else { return }
        if phase == .playing {
            session.restartAttempt()
        }
        phase = .listening
        feedback = "Watch the four tones…"

        for tone in melody {
            highlightedTone = tone
            feedbackTrigger += 1
            try? await Task.sleep(for: .milliseconds(480))
            highlightedTone = nil
            try? await Task.sleep(for: .milliseconds(130))
        }
        phase = .playing
        feedback = "Your turn. Begin with the first tone."
    }

    func play(_ tone: Tone) async -> Int? {
        guard phase == .playing else { return nil }
        highlightedTone = tone
        feedbackTrigger += 1
        try? await Task.sleep(for: .milliseconds(130))
        highlightedTone = nil

        switch session.play(tone) {
        case .correct(let remaining):
            feedback = remaining == 1 ? "One note remains…" : "Beautiful. \(remaining) notes remain."
        case .mistake:
            feedback = "That note wandered. Start the melody again."
        case .completed:
            feedback = "The whole island heard you."
            guard !hasEmittedCompletion else { return nil }
            hasEmittedCompletion = true
            return session.stars
        }
        return nil
    }

    func showCompletion() {
        phase = .complete
    }
}

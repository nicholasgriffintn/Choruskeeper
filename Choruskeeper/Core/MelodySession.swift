import Foundation

struct MelodySession: Equatable, Sendable {
    enum StepResult: Equatable, Sendable {
        case correct(remaining: Int)
        case mistake
        case completed(stars: Int)
    }

    let melody: [Tone]
    private(set) var cursor = 0
    private(set) var mistakes = 0
    private(set) var isComplete = false

    mutating func play(_ tone: Tone) -> StepResult {
        guard !isComplete, !melody.isEmpty else {
            return .completed(stars: stars)
        }

        guard melody[cursor] == tone else {
            mistakes += 1
            cursor = 0
            return .mistake
        }

        cursor += 1
        if cursor == melody.count {
            isComplete = true
            return .completed(stars: stars)
        }
        return .correct(remaining: melody.count - cursor)
    }

    mutating func restartAttempt() {
        guard !isComplete else { return }
        cursor = 0
    }

    var stars: Int {
        max(1, 3 - mistakes)
    }
}

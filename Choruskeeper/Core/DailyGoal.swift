import Foundation

struct DailyGoal: Identifiable, Equatable, Sendable {
    enum Metric: Sendable {
        case melodies
        case harmonies
        case bondNotes
    }

    let id: String
    let title: String
    let detail: String
    let metric: Metric
    let target: Int
    let reward: Int
    let symbol: String

    static let all: [DailyGoal] = [
        DailyGoal(id: "melodies", title: "Morning refrain", detail: "Restore 2 melodies", metric: .melodies, target: 2, reward: 16, symbol: "music.note.list"),
        DailyGoal(id: "harmony", title: "Meet a new voice", detail: "Harmonise 1 Cadent", metric: .harmonies, target: 1, reward: 20, symbol: "sparkles"),
        DailyGoal(id: "bond", title: "Kindred time", detail: "Share 2 bond notes", metric: .bondNotes, target: 2, reward: 14, symbol: "heart.fill")
    ]

    func progress(in daily: DailyProgress) -> Int {
        switch metric {
        case .melodies: daily.melodiesPlayed
        case .harmonies: daily.harmoniesMade
        case .bondNotes: daily.bondNotesGiven
        }
    }
}

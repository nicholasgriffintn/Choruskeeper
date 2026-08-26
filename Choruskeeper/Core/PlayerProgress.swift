import Foundation

struct OwnedCadent: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    let speciesID: String
    var nickname: String
    var bondLevel: Int
    var bondNotes: Int

    init(speciesID: String, nickname: String = "") {
        id = UUID()
        self.speciesID = speciesID
        self.nickname = nickname
        bondLevel = 1
        bondNotes = 0
    }
}

struct DailyProgress: Codable, Equatable, Sendable {
    var dayKey: String
    var melodiesPlayed = 0
    var harmoniesMade = 0
    var bondNotesGiven = 0
    var claimedGoalIDs: Set<String> = []
}

struct PlayerProgress: Codable, Equatable, Sendable {
    var sparks: Int
    var bestStars: [String: Int]
    var ownedCadents: [OwnedCadent]
    var fragments: [String: Int]
    var harmoniesCreated: Int
    var communityContribution: Int
    var daily: DailyProgress

    var totalStars: Int { bestStars.values.reduce(0, +) }

    var discoveredSpeciesIDs: Set<String> {
        Set(ownedCadents.map(\OwnedCadent.speciesID))
    }

    static func newGame(dayKey: String) -> PlayerProgress {
        PlayerProgress(
            sparks: 45,
            bestStars: [:],
            ownedCadents: [OwnedCadent(speciesID: "bramblebeat", nickname: "Pip")],
            fragments: Dictionary(uniqueKeysWithValues: Tone.allCases.map { ($0.rawValue, 3) }),
            harmoniesCreated: 0,
            communityContribution: 0,
            daily: DailyProgress(dayKey: dayKey)
        )
    }

    func fragments(for tone: Tone) -> Int {
        fragments[tone.rawValue, default: 0]
    }

    mutating func addFragments(_ amount: Int, for tone: Tone) {
        fragments[tone.rawValue, default: 0] += amount
    }
}

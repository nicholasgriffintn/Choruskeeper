import Foundation

enum HarmonyError: Error, Equatable, Sendable {
    case insufficientSparks
    case insufficientFragments(Tone)
}

enum GameEngine {
    static let harmonySparkCost = 15
    static let bondSparkCost = 8

    static func prepareForToday(_ progress: inout PlayerProgress, date: Date, calendar: Calendar = .current) {
        let currentDay = DayKey.make(for: date, calendar: calendar)
        guard progress.daily.dayKey != currentDay else { return }
        progress.daily = DailyProgress(dayKey: currentDay)
    }

    static func isUnlocked(_ level: LevelDefinition, in progress: PlayerProgress) -> Bool {
        progress.totalStars >= level.starsToUnlock
    }

    static func nextCampaignLevel(
        in progress: PlayerProgress,
        campaign: [LevelDefinition] = LevelDefinition.campaign
    ) -> LevelDefinition? {
        campaign.first {
            isUnlocked($0, in: progress) && progress.bestStars[$0.id] == nil
        } ?? campaign.reversed().first {
            isUnlocked($0, in: progress)
        }
    }

    static func complete(
        _ level: LevelDefinition,
        stars: Int,
        progress: inout PlayerProgress
    ) {
        let previousBest = progress.bestStars[level.id, default: 0]
        let earnedStars = min(3, max(1, stars))
        let isFirstClear = previousBest == 0

        progress.bestStars[level.id] = max(previousBest, earnedStars)
        progress.sparks += isFirstClear ? level.firstClearSparks : 5
        progress.addFragments(isFirstClear ? 2 : 1, for: level.tone)
        progress.daily.melodiesPlayed += 1
        progress.communityContribution += earnedStars * 10
    }

    static func harmonise(
        first: Tone,
        second: Tone,
        progress: inout PlayerProgress
    ) throws -> CadentSpecies {
        guard progress.sparks >= harmonySparkCost else {
            throw HarmonyError.insufficientSparks
        }

        var needed: [Tone: Int] = [first: 1]
        needed[second, default: 0] += 1
        for (tone, count) in needed where progress.fragments(for: tone) < count {
            throw HarmonyError.insufficientFragments(tone)
        }

        progress.sparks -= harmonySparkCost
        for (tone, count) in needed {
            progress.addFragments(-count, for: tone)
        }

        let species = harmonySpecies(first: first, second: second, progress: progress)
        progress.ownedCadents.append(OwnedCadent(speciesID: species.id))
        progress.harmoniesCreated += 1
        progress.daily.harmoniesMade += 1
        progress.communityContribution += species.rarity == .fabled ? 100 : 25
        return species
    }

    static func addBondNote(to cadentID: UUID, progress: inout PlayerProgress) -> Bool {
        guard progress.sparks >= bondSparkCost,
              let index = progress.ownedCadents.firstIndex(where: { $0.id == cadentID }) else {
            return false
        }

        progress.sparks -= bondSparkCost
        progress.ownedCadents[index].bondNotes += 1
        progress.ownedCadents[index].bondLevel = bondLevel(for: progress.ownedCadents[index].bondNotes)
        progress.daily.bondNotesGiven += 1
        return true
    }

    static func claim(_ goal: DailyGoal, progress: inout PlayerProgress) -> Bool {
        guard goal.progress(in: progress.daily) >= goal.target,
              !progress.daily.claimedGoalIDs.contains(goal.id) else {
            return false
        }

        progress.daily.claimedGoalIDs.insert(goal.id)
        progress.sparks += goal.reward
        return true
    }

    private static func harmonySpecies(
        first: Tone,
        second: Tone,
        progress: PlayerProgress
    ) -> CadentSpecies {
        let isFabledMoment = progress.totalStars >= 8
            && progress.harmoniesCreated % 5 == 4

        let speciesID: String
        if isFabledMoment {
            speciesID = "starhart"
        } else if first == second {
            switch first {
            case .grove: speciesID = "bramblebeat"
            case .tide: speciesID = "rillwhistle"
            case .ember: speciesID = "cinderpurr"
            case .gale: speciesID = "galegloam"
            }
        } else {
            let pair = Set([first, second])
            if pair.contains(.tide) && pair.contains(.gale) {
                speciesID = "rillwhistle"
            } else if pair.contains(.ember) {
                speciesID = "cinderpurr"
            } else if pair.contains(.gale) {
                speciesID = "galegloam"
            } else {
                speciesID = "bramblebeat"
            }
        }

        return CadentSpecies.species(id: speciesID) ?? CadentSpecies.catalog[0]
    }

    private static func bondLevel(for notes: Int) -> Int {
        switch notes {
        case 0...1: 1
        case 2...4: 2
        case 5...8: 3
        default: 4
        }
    }
}

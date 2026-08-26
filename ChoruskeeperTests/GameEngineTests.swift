import XCTest
@testable import ChoruskeeperCore

final class GameEngineTests: XCTestCase {
    func testMelodySessionResetsAfterAMistakeAndKeepsMeaningfulScore() {
        var session = MelodySession(melody: [.grove, .tide, .ember])

        XCTAssertEqual(session.play(.grove), .correct(remaining: 2))
        XCTAssertEqual(session.play(.gale), .mistake)
        XCTAssertEqual(session.cursor, 0)
        XCTAssertEqual(session.play(.grove), .correct(remaining: 2))
        XCTAssertEqual(session.play(.tide), .correct(remaining: 1))
        XCTAssertEqual(session.play(.ember), .completed(stars: 2))
        XCTAssertTrue(session.isComplete)
    }

    func testFirstClearAwardsFullRewardAndReplayAwardsSmallerReward() {
        let level = LevelDefinition.campaign[0]
        var progress = PlayerProgress.newGame(dayKey: "2026-8-26")
        let startingSparks = progress.sparks

        GameEngine.complete(level, stars: 2, progress: &progress)
        XCTAssertEqual(progress.sparks, startingSparks + level.firstClearSparks)
        XCTAssertEqual(progress.totalStars, 2)
        XCTAssertEqual(progress.fragments(for: level.tone), 5)

        GameEngine.complete(level, stars: 3, progress: &progress)
        XCTAssertEqual(progress.sparks, startingSparks + level.firstClearSparks + 5)
        XCTAssertEqual(progress.totalStars, 3)
        XCTAssertEqual(progress.fragments(for: level.tone), 6)
    }

    func testHarmonisingConsumesExactlyTheSelectedResources() throws {
        var progress = PlayerProgress.newGame(dayKey: "2026-8-26")
        let startingSparks = progress.sparks

        let species = try GameEngine.harmonise(first: .tide, second: .gale, progress: &progress)

        XCTAssertEqual(species.id, "rillwhistle")
        XCTAssertEqual(progress.sparks, startingSparks - GameEngine.harmonySparkCost)
        XCTAssertEqual(progress.fragments(for: .tide), 2)
        XCTAssertEqual(progress.fragments(for: .gale), 2)
        XCTAssertEqual(progress.daily.harmoniesMade, 1)
    }

    func testDuplicateToneRequiresTwoFragments() {
        var progress = PlayerProgress.newGame(dayKey: "2026-8-26")
        progress.fragments[Tone.ember.rawValue] = 1

        XCTAssertThrowsError(try GameEngine.harmonise(first: .ember, second: .ember, progress: &progress)) { error in
            XCTAssertEqual(error as? HarmonyError, .insufficientFragments(.ember))
        }
    }

    func testFifthHarmonyAfterEightStarsGuaranteesStarhart() throws {
        var progress = PlayerProgress.newGame(dayKey: "2026-8-26")
        progress.bestStars["one"] = 3
        progress.bestStars["two"] = 3
        progress.bestStars["three"] = 2
        progress.harmoniesCreated = 4
        progress.sparks = 100

        let species = try GameEngine.harmonise(first: .grove, second: .grove, progress: &progress)

        XCTAssertEqual(species.id, "starhart")
    }

    func testDailyGoalsCanOnlyBeClaimedOnce() {
        var progress = PlayerProgress.newGame(dayKey: "2026-8-26")
        let goal = DailyGoal.all[0]
        progress.daily.melodiesPlayed = 2
        let startingSparks = progress.sparks

        XCTAssertTrue(GameEngine.claim(goal, progress: &progress))
        XCTAssertEqual(progress.sparks, startingSparks + goal.reward)
        XCTAssertFalse(GameEngine.claim(goal, progress: &progress))
        XCTAssertEqual(progress.sparks, startingSparks + goal.reward)
    }

    func testPreparingANewDayResetsOnlyDailyProgress() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        var progress = PlayerProgress.newGame(dayKey: "2026-8-25")
        progress.daily.melodiesPlayed = 4
        progress.sparks = 99

        let date = Date(timeIntervalSince1970: 1_777_075_200)
        GameEngine.prepareForToday(&progress, date: date, calendar: calendar)

        XCTAssertEqual(progress.daily.melodiesPlayed, 0)
        XCTAssertEqual(progress.sparks, 99)
        XCTAssertNotEqual(progress.daily.dayKey, "2026-8-25")
    }

    func testNextCampaignLevelOffersAReplayWhenMoreStarsAreNeeded() {
        let firstLevel = LevelDefinition.campaign[0]
        var progress = PlayerProgress.newGame(dayKey: "2026-8-26")
        GameEngine.complete(firstLevel, stars: 1, progress: &progress)

        let nextLevel = GameEngine.nextCampaignLevel(in: progress)

        XCTAssertEqual(nextLevel?.id, firstLevel.id)
        XCTAssertTrue(GameEngine.isUnlocked(nextLevel!, in: progress))
    }
}

import Foundation

@MainActor
final class GameStore: ObservableObject {
    @Published private(set) var progress: PlayerProgress
    @Published private(set) var currentEvent: CommunityEvent?

    private let repository: ProgressRepository
    private let eventProvider: any EventProvider

    init(
        repository: ProgressRepository = UserDefaultsProgressRepository(),
        eventProvider: any EventProvider = PreviewEventProvider(),
        now: Date = .now
    ) {
        self.repository = repository
        self.eventProvider = eventProvider
        var saved = repository.load() ?? PlayerProgress.newGame(dayKey: DayKey.make(for: now))
        GameEngine.prepareForToday(&saved, date: now)
        progress = saved
        repository.save(saved)
    }

    var nextLevel: LevelDefinition? {
        GameEngine.nextCampaignLevel(in: progress)
    }

    func isUnlocked(_ level: LevelDefinition) -> Bool {
        GameEngine.isUnlocked(level, in: progress)
    }

    func complete(_ level: LevelDefinition, stars: Int) {
        GameEngine.complete(level, stars: stars, progress: &progress)
        persist()
    }

    func harmonise(first: Tone, second: Tone) throws -> CadentSpecies {
        let species = try GameEngine.harmonise(first: first, second: second, progress: &progress)
        persist()
        return species
    }

    @discardableResult
    func addBondNote(to cadentID: UUID) -> Bool {
        let didAdd = GameEngine.addBondNote(to: cadentID, progress: &progress)
        if didAdd { persist() }
        return didAdd
    }

    func claim(_ goal: DailyGoal) {
        if GameEngine.claim(goal, progress: &progress) {
            persist()
        }
    }

    func loadEvent() async {
        currentEvent = try? await eventProvider.currentEvent()
    }

    private func persist() {
        repository.save(progress)
    }
}

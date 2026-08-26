import Foundation

protocol ProgressRepository {
    func load() -> PlayerProgress?
    func save(_ progress: PlayerProgress)
}

struct UserDefaultsProgressRepository: ProgressRepository {
    private let defaults: UserDefaults
    private let key = "choruskeeper.player-progress.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> PlayerProgress? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(PlayerProgress.self, from: data)
    }

    func save(_ progress: PlayerProgress) {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        defaults.set(data, forKey: key)
    }
}

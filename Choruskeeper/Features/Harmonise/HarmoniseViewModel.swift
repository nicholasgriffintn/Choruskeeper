import Combine
import Foundation

@MainActor
final class HarmoniseViewModel: ObservableObject {
    @Published private(set) var selectedTones: [Tone] = []
    @Published private(set) var revealedSpecies: CadentSpecies?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isResonating = false

    func choose(_ tone: Tone, availableFragments: Int) {
        let alreadySelected = selectedTones.filter { $0 == tone }.count
        guard selectedTones.count < 2, availableFragments > alreadySelected else { return }
        selectedTones.append(tone)
    }

    func harmonise(using store: GameStore) async {
        guard selectedTones.count == 2, !isResonating else { return }
        isResonating = true
        try? await Task.sleep(for: .milliseconds(650))

        do {
            let species = try store.harmonise(first: selectedTones[0], second: selectedTones[1])
            selectedTones = []
            revealedSpecies = species
        } catch HarmonyError.insufficientSparks {
            errorMessage = "Restore a melody to earn more sparks. Nothing here asks for money."
        } catch HarmonyError.insufficientFragments(let tone) {
            errorMessage = "You need another \(tone.title) fragment. Levels marked \(tone.title) award them."
        } catch {
            errorMessage = "The tones slipped apart. Please try once more."
        }
        isResonating = false
    }

    func dismissDiscovery() {
        revealedSpecies = nil
    }

    func dismissError() {
        errorMessage = nil
    }
}

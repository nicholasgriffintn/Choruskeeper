import Foundation

struct CadentSpecies: Identifiable, Equatable, Sendable {
    enum Rarity: String, Sendable {
        case familiar
        case uncommon
        case fabled

        var title: String { rawValue.capitalized }
    }

    let id: String
    let name: String
    let epithet: String
    let lore: String
    let rarity: Rarity
    let affinity: Tone
    let assetName: String

    static let catalog: [CadentSpecies] = [
        CadentSpecies(
            id: "bramblebeat",
            name: "Bramblebeat",
            epithet: "The Moss Metronome",
            lore: "Each footfall wakes a seed. Old gardeners listen for its soft three-beat trot before planting anything precious.",
            rarity: .familiar,
            affinity: .grove,
            assetName: "Bramblebeat"
        ),
        CadentSpecies(
            id: "rillwhistle",
            name: "Rillwhistle",
            epithet: "The Laughing Current",
            lore: "Rillwhistles remember every stream they cross. Their pearl notes can guide a lost river back to the sea.",
            rarity: .uncommon,
            affinity: .tide,
            assetName: "Rillwhistle"
        ),
        CadentSpecies(
            id: "cinderpurr",
            name: "Cinderpurr",
            epithet: "The Hearth's Encore",
            lore: "It curls beside cold ovens and purrs until bread rises. A happy Cinderpurr smells faintly of cinnamon smoke.",
            rarity: .familiar,
            affinity: .ember,
            assetName: "Cinderpurr"
        ),
        CadentSpecies(
            id: "galegloam",
            name: "Galegloam",
            epithet: "The Moon's Bellwether",
            lore: "Its silver chimes ring one hour before the sky changes. Sailors once planned entire journeys around a single feather.",
            rarity: .uncommon,
            affinity: .gale,
            assetName: "Galegloam"
        ),
        CadentSpecies(
            id: "starhart",
            name: "Starhart",
            epithet: "Keeper of the Lost Refrain",
            lore: "A Starhart appears only when four island songs overlap. The note between its antlers is said to be the first sound dawn ever made.",
            rarity: .fabled,
            affinity: .gale,
            assetName: "Starhart"
        )
    ]

    static func species(id: String) -> CadentSpecies? {
        catalog.first { $0.id == id }
    }
}

import Foundation

struct LevelDefinition: Identifiable, Equatable, Sendable {
    let id: String
    let island: String
    let number: Int
    let title: String
    let subtitle: String
    let tone: Tone
    let melody: [Tone]
    let starsToUnlock: Int
    let firstClearSparks: Int

    static let campaign: [LevelDefinition] = [
        level("bellmeadow-1", "Bellmeadow", 1, "First Chime", "Wake the brass flowers", .grove, [.grove, .tide, .grove], 0),
        level("bellmeadow-2", "Bellmeadow", 2, "Fern Rhythm", "Follow the curled fronds", .grove, [.grove, .gale, .grove, .tide], 2),
        level("bellmeadow-3", "Bellmeadow", 3, "The Orchard Answers", "Return the keeper's refrain", .gale, [.tide, .grove, .gale, .grove, .tide], 4),
        level("glasswater-1", "Glasswater Keys", 4, "A River Remembers", "Find the current beneath the glass", .tide, [.tide, .tide, .gale, .grove], 6),
        level("glasswater-2", "Glasswater Keys", 5, "Pearl in the Rain", "Catch each falling note", .tide, [.gale, .tide, .grove, .tide, .gale], 8),
        level("glasswater-3", "Glasswater Keys", 6, "The Blue Chorus", "Join the three hidden streams", .tide, [.tide, .grove, .ember, .gale, .tide, .grove], 10),
        level("emberhush-1", "Emberhush Hollow", 7, "Warm the Quiet", "Coax a coal into song", .ember, [.ember, .grove, .ember, .gale], 12),
        level("emberhush-2", "Emberhush Hollow", 8, "Cinnamon Sparks", "Keep the hearthbeat steady", .ember, [.grove, .ember, .tide, .ember, .gale], 14),
        level("emberhush-3", "Emberhush Hollow", 9, "The Lantern Below", "Light what the Quiet buried", .ember, [.ember, .gale, .tide, .grove, .ember, .gale], 16),
        level("observatory-1", "Gale Observatory", 10, "Weatherwise", "Read tomorrow in the chimes", .gale, [.gale, .tide, .gale, .grove, .ember], 18),
        level("observatory-2", "Gale Observatory", 11, "Ribbonwind", "Tie the sky back together", .gale, [.grove, .gale, .ember, .tide, .gale, .grove], 20),
        level("observatory-3", "Gale Observatory", 12, "The Grand Refrain", "Let every island be heard", .gale, [.grove, .tide, .ember, .gale, .ember, .tide, .grove], 22)
    ]

    private static func level(
        _ id: String,
        _ island: String,
        _ number: Int,
        _ title: String,
        _ subtitle: String,
        _ tone: Tone,
        _ melody: [Tone],
        _ stars: Int
    ) -> LevelDefinition {
        LevelDefinition(
            id: id,
            island: island,
            number: number,
            title: title,
            subtitle: subtitle,
            tone: tone,
            melody: melody,
            starsToUnlock: stars,
            firstClearSparks: 18 + (number * 2)
        )
    }
}

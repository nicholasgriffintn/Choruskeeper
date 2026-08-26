import Foundation

enum Tone: String, Codable, CaseIterable, Identifiable, Sendable {
    case grove
    case tide
    case ember
    case gale

    var id: String { rawValue }

    var title: String {
        switch self {
        case .grove: "Grove"
        case .tide: "Tide"
        case .ember: "Ember"
        case .gale: "Gale"
        }
    }

    var symbol: String {
        switch self {
        case .grove: "leaf.fill"
        case .tide: "drop.fill"
        case .ember: "flame.fill"
        case .gale: "wind"
        }
    }
}

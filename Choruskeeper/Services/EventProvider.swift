import Foundation

struct CommunityEvent: Codable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let endsAt: Date
    let globalProgress: Int
    let goal: Int
    let rewardName: String
}

protocol EventProvider: Sendable {
    func currentEvent() async throws -> CommunityEvent
}

struct PreviewEventProvider: EventProvider {
    func currentEvent() async throws -> CommunityEvent {
        CommunityEvent(
            id: "sky-chorus",
            title: "The Sky Chorus",
            subtitle: "Every restored melody carries the Bellmeadow towards dawn.",
            endsAt: Calendar.current.date(byAdding: .day, value: 6, to: .now) ?? .now,
            globalProgress: 68_420,
            goal: 100_000,
            rewardName: "Aurora Chime Garden"
        )
    }
}

struct RemoteEventProvider: EventProvider {
    enum ProviderError: Error {
        case invalidResponse
    }

    let endpoint: URL
    let session: URLSession

    init(endpoint: URL, session: URLSession = .shared) {
        self.endpoint = endpoint
        self.session = session
    }

    func currentEvent() async throws -> CommunityEvent {
        let (data, response) = try await session.data(from: endpoint)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw ProviderError.invalidResponse
        }
        return try JSONDecoder().decode(CommunityEvent.self, from: data)
    }
}

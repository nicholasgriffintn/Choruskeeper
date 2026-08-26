import SwiftUI

@main
struct ChoruskeeperApp: App {
    @StateObject private var store = GameStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
                .preferredColorScheme(.dark)
                .task { await store.loadEvent() }
        }
    }
}

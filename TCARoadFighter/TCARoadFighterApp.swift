import SwiftUI
import ComposableArchitecture

@main
struct TCARoadFighterApp: App {
    var body: some Scene {
        WindowGroup {
            GameScreen(store: .init(initialState: .init()){
                GameScreenFeature()
            })
        }
    }
}

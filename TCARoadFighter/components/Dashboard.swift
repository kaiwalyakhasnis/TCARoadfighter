import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct DashboardFeature {
    @ObservableState
    public struct State : Equatable {
        public var level: Int = 1
        public var score: Int = 0
    }
    
    public enum Action : Equatable {
        case levelUp
        case scopeUp
        case reset
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .levelUp:
                state.level += 1
                return .none
            case .scopeUp:
                state.score += 1
                return .none
            case .reset:
                state.level = 1
                state.score = 0
                return .none
            }
        }
    } 
}

struct Dashboard: View {
    let store: StoreOf<DashboardFeature>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("  Level: \(store.level)")
                .font(.headline)
                .padding(.bottom, 2)
            
            Text("  Score: \(store.score)")
                .font(.headline)
        }
        .padding()
        .background(Color.black)
        .foregroundColor(.white)
        .cornerRadius(10)
        .frame(width: 150, height: 100) // Small square shape
    }
}

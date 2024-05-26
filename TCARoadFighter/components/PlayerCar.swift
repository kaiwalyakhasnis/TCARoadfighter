import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct PlayerCarFeature {
    @ObservableState
    public struct State : Equatable {
        @Shared(.inMemory("carXOffset")) var carXOffset: CGFloat = 0
        public var carRect: CGRect = CGRect.zero
    }
    
    public enum Action : Equatable {
        case savePlayerCarRect(carRect: CGRect)
        case setPlayerCarXOffset(xOffset: CGFloat)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .savePlayerCarRect(carRect):
                state.carRect = carRect
                return .none
            case let .setPlayerCarXOffset(xOffset):
                state.carXOffset = xOffset
                return .none
            }
        }
    }
}

struct PlayerCar : View {
    let maxWidth: CGFloat
    let maxHeight: CGFloat
    let store: StoreOf<PlayerCarFeature>
    
    var body: some View {
            GeometryReader { geo in
                Image("player_car")
                    .resizable()
                    .onChange(of: store.carXOffset){
                        store.send(.savePlayerCarRect(carRect: geo.self.frame(in: .global)))
                    }
            }
            .frame(width: 24, height: 32)
            .position(x: store.carXOffset, y: maxHeight - 200)
            .onAppear {
                store.send(.setPlayerCarXOffset(xOffset: maxWidth / 2))
            }
    }
    
}

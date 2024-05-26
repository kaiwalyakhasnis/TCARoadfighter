import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct ControlsFeature {
    @ObservableState
    public struct State : Equatable {
        @Shared(.inMemory("carXOffset")) var carXOffset: CGFloat = 0
    }
    
    public enum Action : Equatable {
        case leftControlClicked
        case rightControlClicked
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .leftControlClicked:
                state.carXOffset -= 10
                return .none
            case .rightControlClicked:
                state.carXOffset += 10
                return .none
            }
        }
    }
}

struct Controls : View {
    let maxWidth: CGFloat
    let maxHeight: CGFloat
    let store: StoreOf<ControlsFeature>
    
    var body: some View {
            HStack {
                RoundIconButton(
                    action: { store.send(.leftControlClicked) },
                    iconName: "arrow.left"
                )
                .position(x: 50, y: maxHeight - 100)
                
                RoundIconButton(
                    action: { store.send(.rightControlClicked) },
                    iconName: "arrow.right"
                )
                .position(x: maxWidth - 250, y: maxHeight - 100)
        }
    }
}

struct RoundIconButton: View {
    let action: () -> Void
    let iconName: String
    
    var body: some View {
            Button(action: action) {
                Image(systemName: iconName)
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().fill(Color.blue))
                    .frame(width: 50, height: 50)
            }
    }
}

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct RoadFeature {
    @ObservableState
    public struct State : Equatable {
        var offsetY: CGFloat = 0
        var speed: Double = 3
        var roadRects: [CGRect] = []
    }
    
    public enum Action : Equatable {
        case roadOffset(offsetY: CGFloat)
        case storeRoadRect(roadRect: CGRect)
        case increaseSpeed(speed: Double)
        case reset
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .roadOffset(offsetY):
                state.offsetY = offsetY
                return .none
            case let .storeRoadRect(roadRect):
                state.roadRects.append(roadRect)
                return .none
            case .increaseSpeed:
                state.speed += 1
                return .none
            case .reset:
                state.offsetY = 0
                state.speed = 3
                return .none
            }
        }
    }
}

struct Road : View {
    let maxWidth: CGFloat
    let maxHeight: CGFloat
    let store: StoreOf<RoadFeature>
    
    var body: some View {
        ZStack {
            RoadSectionView(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                store: store
            ).offset(y: store.offsetY)
            
            // stacking is required like this to allow animaiton without any white space in between
            RoadSectionView(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                store: store
            ).offset(y: store.offsetY - maxHeight + 2) // there is slight margin to original image, to compensate add couple extra points
        }
        .onAppear {
            let baseAnimation = Animation.linear(duration: store.speed).repeatForever(autoreverses: false)
            withAnimation(baseAnimation) {
                _ = store.send(.roadOffset(offsetY: maxHeight))
            }
        }
    }
}

struct RoadSectionView : View {
    let maxWidth: CGFloat
    let maxHeight: CGFloat
    let store: StoreOf<RoadFeature>
    
    var body: some View {
        HStack {
            GeometryReader { geo in
                Image("road_left")
                    .resizable()
                    .onAppear{
                        store.send(.storeRoadRect(roadRect: geo.self.frame(in: .global)))
                    }
            }
            .frame(width: maxWidth * 0.3, height: maxHeight)
            
            Image("road_center")
                .resizable()
                .frame(width: maxWidth * 0.5, height: maxHeight)
            
            GeometryReader { geo in
                Image("road_right")
                    .resizable()
                    .onAppear {
                        store.send(.storeRoadRect(roadRect: geo.self.frame(in: .global)))
                    }
            }
            .frame(width: maxWidth * 0.2, height: maxHeight)
        }
    }
}

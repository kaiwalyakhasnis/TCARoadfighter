import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct TrafficFeature {
    @ObservableState
    public struct State : Equatable {
        public var trafficBound: [String: CGRect] = [:]
        public var date: Date = Date()
    }
    
    public enum Action : Equatable {
        case storeTrafficBound(id: String, roadRect: CGRect)
        case reset
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .storeTrafficBound(id, carRect):
                state.trafficBound[id] = carRect
                return .none
            case .reset:
                state.trafficBound = [:]
                state.date = Date()
                return .none
            }
        }
    }
}

struct Traffic : View {
    let maxWidth: CGFloat
    let maxHeight: CGFloat
    let store: StoreOf<TrafficFeature>
    
    var body: some View {
        BlueCar(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            store: store,
            duration: 8.0,
            trafficOffset: maxWidth / 2 + 40,
            ID: "car1"
        )
        
        BlueCar(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            store: store,
            duration: 10.0,
            trafficOffset: maxWidth / 2 - 50,
            ID: "car2"
        )
        
        BlueCar(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            store: store,
            duration: 12.0,
            trafficOffset: maxWidth / 2 + 90,
            ID: "car3"
        )
        
        BlueCar(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            store: store,
            duration: 15.0,
            trafficOffset: maxWidth / 2 - 30,
            ID: "car4"
        )
        
        BlueCar(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            store: store,
            duration: 7.0,
            trafficOffset: maxWidth / 2,
            ID: "car5"
        )
    }
}

struct BlueCar : View {
    let maxWidth: CGFloat
    let maxHeight: CGFloat
    let store: StoreOf<TrafficFeature>
    let duration: TimeInterval
    let trafficOffset: CGFloat
    let ID: String

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                let elapsedTime = timeline.date.timeIntervalSince(store.date)
                let progress = (elapsedTime / duration).truncatingRemainder(dividingBy: 1.0)
                let yOffset = progress * maxHeight
                
                GeometryReader { geometry in
                    Image("blue_car")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onChange(of: yOffset) {
                            store.send(.storeTrafficBound(id:ID, roadRect: geometry.frame(in: .global)))
                        }
                }
                .offset(x: trafficOffset, y: yOffset)
                .frame(width: 24, height: 32)
            }
        }
    }
}

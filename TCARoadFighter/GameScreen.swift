import SwiftUI
import Combine
import ComposableArchitecture

@Reducer
public struct GameScreenFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.inMemory("carXOffset")) var carXOffset: CGFloat = 0
        var gameStatus: GameStatus = GameStatus.Running
        var gameCount: Int = 0
        var dashBoardState = DashboardFeature.State()
        var playerCarState = PlayerCarFeature.State()
        var controlsState = ControlsFeature.State()
        var trafficState = TrafficFeature.State()
        var roadState = RoadFeature.State()
    }
    
    public enum Action {
        case gameStart
        case gameOver
        case coliisionDetection
        case incrementGameCounter
        case dashBoardActions(action: DashboardFeature.Action)
        case playerCarActions(action: PlayerCarFeature.Action)
        case controlsActions(action: ControlsFeature.Action)
        case trafficActions(action: TrafficFeature.Action)
        case roadActions(action: RoadFeature.Action)
    }
    
    enum CancelID { case gameLoop }
    // lavel number : speed
    let speedByLevels = [1:3, 2:2.5, 3:2, 4:1.5, 5:1, 6:0.5]
    
    @Dependency(\.continuousClock) var clock
    public var body: some ReducerOf<Self> {
        Scope(state: \.dashBoardState, action: \.dashBoardActions) { DashboardFeature() }
        Scope(state: \.playerCarState, action: \.playerCarActions) { PlayerCarFeature()}
        Scope(state: \.controlsState, action: \.controlsActions) { ControlsFeature() }
        Scope(state: \.trafficState, action: \.trafficActions) { TrafficFeature() }
        Scope(state: \.roadState, action: \.roadActions) { RoadFeature() }
        
        Reduce { state, action in
            switch action {
            case .gameStart:
                state.gameStatus = GameStatus.Running
                return .run { send in
                    let timer = self.clock.timer(interval: .milliseconds(100))
                    for await _ in timer {
                        await send(.incrementGameCounter)
                        await send(.coliisionDetection)
                    }
                }.cancellable(id: CancelID.gameLoop)
                
            case .gameOver:
                state.gameCount = 0
                state.gameStatus = GameStatus.Over
                return .concatenate(
                    .cancel(id: CancelID.gameLoop),
                    .run { send in
                        await send(.dashBoardActions(action: .reset))
                        await send(.trafficActions(action: .reset))
                        await send(.roadActions(action: .reset))
                    }
                )
                
            case .coliisionDetection:
                return .run { [state] send in
                    if state.trafficState.trafficBound.contains(where: { $0.value.intersects(state.playerCarState.carRect)}) ||
                        state.roadState.roadRects.contains(where: { $0.intersects(state.playerCarState.carRect) }) {
                        await send(.gameOver)
                    }
                }
                
            case .incrementGameCounter:
                state.gameCount += 1
                return .run { [state] send in
                    if state.gameCount >= state.dashBoardState.level * 1000 {
                        await send(.dashBoardActions(action: .levelUp))
                    }
                    if state.gameCount >= state.dashBoardState.score * 50 {
                        await send(.dashBoardActions(action: .scopeUp))
                    }
                }
                
            case let .dashBoardActions(action):
                return .run { [state] send in
                    switch action {
                    case .levelUp:
                        await send(.roadActions(action: .increaseSpeed(speed: speedByLevels[state.dashBoardState.level] ?? 1)))
                        break
                    default:
                        break
                    }
                }
                
            case .playerCarActions(_):
                return .none
            case .controlsActions(_):
                return .none
            case .trafficActions(_):
                return .none
            case .roadActions(_):
                return .none
            }
        }
    }
}


struct GameScreen: View {
    let store: StoreOf<GameScreenFeature>
    var body: some View {
        gameView
    }
    
    @ViewBuilder
    private var gameView: some View {
        switch store.gameStatus {
        case .Running:
            runningView
        case .Over:
            gameOverView
        }
    }
    
    private var gameOverView: some View {
        GameOver(onRestart: {
            store.send(.gameStart)
        })
    }
    
    private var runningView: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height + 100
            let screenWidth = geometry.size.width
            
            ZStack {
                // moving road
                Road(
                    maxWidth: screenWidth,
                    maxHeight: screenHeight,
                    store: store.scope(
                        state: \.roadState,
                        action: \.roadActions
                    )
                )
                
                // traffic
                Traffic(
                    maxWidth: screenWidth,
                    maxHeight: screenHeight,
                    store: store.scope(
                        state: \.trafficState,
                        action: \.trafficActions
                    )
                )
                
                // player car
                PlayerCar(
                    maxWidth: screenWidth,
                    maxHeight: screenHeight,
                    store: store.scope(
                        state: \.playerCarState,
                        action: \.playerCarActions
                    )
                )
                
                // controls
                Controls(
                    maxWidth: screenWidth,
                    maxHeight: screenHeight,
                    store: store.scope(
                        state: \.controlsState,
                        action: \.controlsActions
                    )
                )
                
                // dashboard for scre and level
                Dashboard(
                    store: store.scope(
                        state: \.dashBoardState,
                        action: \.dashBoardActions
                    )
                )
                .position(x: 50.0, y:80.0)
            }
            .onAppear {
                store.send(.gameStart)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

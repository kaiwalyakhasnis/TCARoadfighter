import Foundation
import SwiftUI
import ComposableArchitecture

struct GameOver: View {
    var onRestart: () -> Void
    
    var body: some View {
            ZStack {
                // Black background
                Color.black
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        onRestart()
                    }
                
                // Centered "Game Over" text
                VStack {
                    Text("Game Over")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    
                    Text("Touch anywhere to restart")
                        .font(.body)
                        .foregroundColor(.white)
                }
            }
    }
}


struct GameOverView_Previews: PreviewProvider {
    static var previews: some View {
        GameOver(onRestart: {})
    }
}

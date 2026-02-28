import SwiftUI

struct AnimatedGradientView: View {
    @State private var startPoint = UnitPoint.topLeading
    @State private var endPoint = UnitPoint.bottomTrailing
    
    let colors: [Color]
    
    var body: some View {
        LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                    startPoint = UnitPoint.bottomLeading
                    endPoint = UnitPoint.topTrailing
                }
            }
    }
}

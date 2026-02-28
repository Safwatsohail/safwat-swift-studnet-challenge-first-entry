import SwiftUI

struct ContentView: View {
    @StateObject private var conversationStore = ConversationStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showSplash = true
    
    var body: some View {
        Group {
            if showSplash {
                SplashScreen {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            } else if !hasCompletedOnboarding {
                TutorialOnboardingView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        hasCompletedOnboarding = true
                    }
                }
            } else {
                RootTabView(store: conversationStore)
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
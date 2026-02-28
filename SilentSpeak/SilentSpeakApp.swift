import SwiftUI

@main
struct SilentSpeakApp: App {
    @StateObject private var conversationStore = ConversationStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreen {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
                .preferredColorScheme(.light)
            } else if !hasCompletedOnboarding {
                TutorialOnboardingView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        hasCompletedOnboarding = true
                    }
                }
                .preferredColorScheme(.light)
            } else {
                RootTabView(store: conversationStore)
                    .preferredColorScheme(.light)
            }
        }
    }
}

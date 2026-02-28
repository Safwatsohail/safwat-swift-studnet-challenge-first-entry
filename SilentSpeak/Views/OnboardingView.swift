import SwiftUI
import AVFoundation

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var animateContent = false
    let onComplete: () -> Void
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to SilentSpeak",
            subtitle: "Bridge the communication gap between deaf and hearing communities",
            icon: "hands.sparkles.fill",
            color: Color(red: 0.82, green: 0.53, blue: 0.43)
        ),
        OnboardingPage(
            title: "Sign Language Recognition",
            subtitle: "Use your camera to translate ASL gestures into spoken words",
            icon: "camera.fill",
            color: Color(red: 0.3, green: 0.7, blue: 0.45)
        ),
        OnboardingPage(
            title: "Speech to Sign",
            subtitle: "Speak into your device and see the corresponding ASL signs",
            icon: "mic.fill",
            color: Color(red: 0.3, green: 0.55, blue: 0.85)
        ),
        OnboardingPage(
            title: "Real-time Conversations",
            subtitle: "Enable seamless communication in both directions",
            icon: "bubble.left.and.bubble.right.fill",
            color: Color(red: 0.85, green: 0.3, blue: 0.3)
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.95, blue: 0.92),
                    Color(red: 0.96, green: 0.91, blue: 0.86)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Bottom controls
                VStack(spacing: 20) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? pages[currentPage].color : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    
                    // Next/Get Started button
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation(.spring()) {
                                currentPage += 1
                            }
                        } else {
                            onComplete()
                        }
                    }) {
                        Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(pages[currentPage].color)
                            )
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateContent = true
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 160, height: 160)
                    .scaleEffect(animate ? 1.0 : 0.8)
                
                Image(systemName: page.icon)
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(page.color)
                    .scaleEffect(animate ? 1.0 : 0.8)
            }
            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: animate)
            
            // Text
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.12))
                    .multilineTextAlignment(.center)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                
                Text(page.subtitle)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.45, green: 0.38, blue: 0.34))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
            }
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: animate)
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    OnboardingView {
        print("Onboarding completed")
    }
}
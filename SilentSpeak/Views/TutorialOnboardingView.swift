import SwiftUI
import AVFoundation

struct TutorialOnboardingView: View {
    let onComplete: () -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var currentStep = 0
    @State private var animateContent = false
    @State private var showingASLTutorial = false
    @State private var currentLetter = 0
    @State private var completedLetters: Set<String> = []
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    private let tutorialLetters = ["A", "S", "L"]
    
    private let steps = [
        TutorialStep(
            title: "Welcome to SilentSpeak",
            subtitle: "Let's learn how to communicate using sign language",
            icon: "hands.sparkles.fill",
            color: Color(red: 0.82, green: 0.53, blue: 0.43),
            description: "SilentSpeak helps bridge communication between deaf and hearing communities through real-time sign language recognition."
        ),
        TutorialStep(
            title: "Your First Signs",
            subtitle: "We'll start by learning to sign A-S-L",
            icon: "abc",
            color: Color(red: 0.3, green: 0.7, blue: 0.45),
            description: "Follow along as we teach you the three letters that spell ASL. Each letter has a unique hand shape."
        ),
        TutorialStep(
            title: "Practice Time",
            subtitle: "Let's practice signing A-S-L together",
            icon: "hand.raised.fill",
            color: Color(red: 0.3, green: 0.55, blue: 0.85),
            description: "Use your camera to practice each letter. We'll guide you through the correct hand positions."
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
            
            if showingASLTutorial {
                aslTutorialView
            } else {
                introductionView
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateContent = true
            }
        }
    }
    
    private var introductionView: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    // Progress indicator
                    HStack {
                        ForEach(0..<steps.count, id: \.self) { index in
                            Circle()
                                .fill(index <= currentStep ? steps[currentStep].color : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                                .scaleEffect(index == currentStep ? 1.2 : 1.0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
                            
                            if index < steps.count - 1 {
                                Rectangle()
                                    .fill(index < currentStep ? steps[currentStep].color : Color.gray.opacity(0.3))
                                    .frame(height: 2)
                                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    Spacer(minLength: 24)
                    
                    // Content
                    VStack(spacing: 30) {
                        // Icon
                        Image(systemName: steps[currentStep].icon)
                            .font(.system(size: 80, weight: .light))
                            .foregroundColor(steps[currentStep].color)
                            .scaleEffect(animateContent ? 1.0 : 0.8)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: animateContent)
                        
                        // Title and subtitle
                        VStack(spacing: 12) {
                            Text(steps[currentStep].title)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.12))
                                .multilineTextAlignment(.center)
                                .scaleEffect(animateContent ? 1.0 : 0.9)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3), value: animateContent)
                            
                            Text(steps[currentStep].subtitle)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0.45, green: 0.38, blue: 0.34))
                                .multilineTextAlignment(.center)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .animation(.easeInOut(duration: 0.6).delay(0.4), value: animateContent)
                        }
                        
                        // Description
                        Text(steps[currentStep].description)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0.6, green: 0.55, blue: 0.52))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .padding(.horizontal, 20)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.6).delay(0.5), value: animateContent)
                        
                        tutorialFeatureHighlights
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer(minLength: 24)
                    
                    if horizontalSizeClass != .regular {
                        introductionActionBar
                    }
                }
                .frame(minHeight: geometry.size.height)
            }
            .safeAreaInset(edge: .bottom) {
                if horizontalSizeClass == .regular {
                    introductionActionBar
                }
            }
        }
    }
    
    private var aslTutorialView: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    VStack(spacing: 12) {
                        Text("Learn to Sign: A-S-L")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.12))
                        
                        Text("Letter \(currentLetter + 1) of 3: \(tutorialLetters[currentLetter])")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.45, green: 0.38, blue: 0.34))
                        
                        HStack(spacing: 4) {
                            ForEach(0..<tutorialLetters.count, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(index <= currentLetter ? Color(red: 0.3, green: 0.7, blue: 0.45) : Color.gray.opacity(0.3))
                                    .frame(height: 4)
                                    .animation(.easeInOut(duration: 0.3), value: currentLetter)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 20)
                    
                    VStack(spacing: 30) {
                        VStack(spacing: 20) {
                            Text(tutorialLetters[currentLetter])
                                .font(.system(size: 120, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.45))
                                .scaleEffect(animateContent ? 1.0 : 0.8)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentLetter)
                            
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.92))
                                .frame(width: 220, height: 220)
                                .overlay(
                                    VStack(spacing: 12) {
                                        if let image = ASLImageLoader.loadImage(for: tutorialLetters[currentLetter]) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 170, height: 170)
                                        } else {
                                            Image(systemName: "hand.raised.fill")
                                                .font(.system(size: 60))
                                                .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.45))
                                        }
                                        
                                        Text("Letter \(tutorialLetters[currentLetter])")
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.12))
                                    }
                                    .padding(.vertical, 10)
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            
                            Text(ASLHandshapeDescriptions.descriptionFor(letter: tutorialLetters[currentLetter]))
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color(red: 0.45, green: 0.38, blue: 0.34))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                                .lineLimit(nil)
                            
                            tutorialControlGuide
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.45))
                                    
                                    Text("Timing Tips")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.45))
                                }
                                
                                VStack(spacing: 8) {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(Color(red: 0.3, green: 0.7, blue: 0.45))
                                            .frame(width: 6, height: 6)
                                        Text("Hold your hand steady for 1.5 seconds")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(Color(red: 0.45, green: 0.38, blue: 0.34))
                                        Spacer()
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(Color(red: 0.3, green: 0.7, blue: 0.45))
                                            .frame(width: 6, height: 6)
                                        Text("Lower your hand completely between signs")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(Color(red: 0.45, green: 0.38, blue: 0.34))
                                        Spacer()
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(Color(red: 0.3, green: 0.7, blue: 0.45))
                                            .frame(width: 6, height: 6)
                                        Text("Use the retry button if detection fails")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(Color(red: 0.45, green: 0.38, blue: 0.34))
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color(red: 0.3, green: 0.7, blue: 0.45).opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(Color(red: 0.3, green: 0.7, blue: 0.45).opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    
                    Spacer(minLength: 24)
                    
                    if horizontalSizeClass != .regular {
                        tutorialActionBar
                    }
                }
                .frame(minHeight: geometry.size.height)
            }
            .safeAreaInset(edge: .bottom) {
                if horizontalSizeClass == .regular {
                    tutorialActionBar
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateContent = true
            }
        }
    }
    
    private var introductionActionBar: some View {
        VStack(spacing: 16) {
            if currentStep == steps.count - 1 {
                Button(action: {
                    HapticManager.shared.mediumImpact()
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showingASLTutorial = true
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Start ASL Tutorial")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [steps[currentStep].color, steps[currentStep].color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: steps[currentStep].color.opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(BouncyPressStyle())
            } else {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        currentStep += 1
                        animateContent = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            animateContent = true
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [steps[currentStep].color, steps[currentStep].color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: steps[currentStep].color.opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(BouncyPressStyle())
            }
            
            if currentStep < steps.count - 1 {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showingASLTutorial = true
                    }
                }) {
                    Text("Skip to Tutorial")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.6, green: 0.55, blue: 0.52))
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(.ultraThinMaterial)
    }
    
    private var tutorialActionBar: some View {
        VStack(spacing: 16) {
            Button(action: {
                HapticManager.shared.mediumImpact()
                speakInstruction(for: tutorialLetters[currentLetter])
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Hear Instructions")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.3, green: 0.55, blue: 0.85), Color(red: 0.25, green: 0.45, blue: 0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color(red: 0.3, green: 0.55, blue: 0.85).opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(BouncyPressStyle())
            
            Button(action: {
                HapticManager.shared.mediumImpact()
                completedLetters.insert(tutorialLetters[currentLetter])
                
                if currentLetter < tutorialLetters.count - 1 {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        currentLetter += 1
                        animateContent = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            animateContent = true
                        }
                    }
                } else {
                    speakCompletion()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        onComplete()
                    }
                }
            }) {
                HStack(spacing: 12) {
                    Text(currentLetter < tutorialLetters.count - 1 ? "Next Letter" : "Start Using SilentSpeak")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    Image(systemName: currentLetter < tutorialLetters.count - 1 ? "arrow.right" : "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.3, green: 0.7, blue: 0.45), Color(red: 0.25, green: 0.6, blue: 0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.45).opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(BouncyPressStyle())
        }
        .padding(.horizontal, 30)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(.ultraThinMaterial)
    }
    
    private func speakInstruction(for letter: String) {
        let description = ASLHandshapeDescriptions.descriptionFor(letter: letter)
        let timingTips = "Remember: hold your hand steady for 1.5 seconds, then lower your hand completely before making the next sign. Use the retry button if the camera doesn't detect your sign properly."
        let instruction = "To sign the letter \(letter): \(description). \(timingTips)"
        
        let utterance = AVSpeechUtterance(string: instruction)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45  // Slightly slower for better comprehension
        utterance.pitchMultiplier = 1.0
        
        speechSynthesizer.speak(utterance)
    }
    
    private func speakCompletion() {
        let completion = "Congratulations! You've learned to sign A-S-L. You're now ready to start using SilentSpeak for full conversations."
        
        let utterance = AVSpeechUtterance(string: completion)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.1
        
        speechSynthesizer.speak(utterance)
    }
    
    private var tutorialFeatureHighlights: some View {
        VStack(spacing: 10) {
            highlightRow(icon: "camera.viewfinder", title: "Camera panel", detail: "Keep your hand inside the live frame and watch the confidence chip.")
            highlightRow(icon: "sparkles.rectangle.stack", title: "Prediction row", detail: "Tap any prediction, not just the first one, then use Retry if needed.")
            highlightRow(icon: "text.badge.plus", title: "Sentence builder", detail: "Use Add, suggestions, and Send & Speak to turn letters into a full message.")
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.65))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.45), lineWidth: 1)
                )
        )
    }
    
    private var tutorialControlGuide: some View {
        VStack(spacing: 10) {
            highlightRow(icon: "arrow.counterclockwise.circle.fill", title: "Retry button", detail: "Resets the hand detector so you can sign the same letter again.")
            highlightRow(icon: "speaker.wave.3.fill", title: "Speak Aloud", detail: "Reads the built sentence to the hearing person once you finish signing.")
            highlightRow(icon: "mic.circle.fill", title: "Speaker side", detail: "The microphone turns speech into text and matching ASL cards on the other panel.")
        }
        .padding(.horizontal, 20)
    }
    
    private func highlightRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.95))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(red: 0.82, green: 0.53, blue: 0.43))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.12))
                Text(detail)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.45, green: 0.38, blue: 0.34))
            }
            
            Spacer()
        }
    }
}

struct TutorialStep {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let description: String
}

// MARK: - Preview
struct TutorialOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialOnboardingView {
            print("Tutorial completed")
        }
    }
}

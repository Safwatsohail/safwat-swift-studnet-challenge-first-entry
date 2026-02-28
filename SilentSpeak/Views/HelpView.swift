import SwiftUI
import AVFoundation

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showingDictionary: Bool
    @Binding var showingTutorial: Bool
    
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var animateContent = false
    
    private let accentColor = Color(red: 0.82, green: 0.53, blue: 0.43)
    private let bgColor1 = Color(red: 0.98, green: 0.95, blue: 0.92)
    private let bgColor2 = Color(red: 0.96, green: 0.91, blue: 0.86)
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [bgColor1, bgColor2],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 60, weight: .light))
                                .foregroundColor(accentColor)
                                .scaleEffect(animateContent ? 1.0 : 0.8)
                                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1), value: animateContent)
                            
                            Text("SilentSpeak Help")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.12))
                            
                            Text("Learn how to use SilentSpeak effectively")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0.45, green: 0.38, blue: 0.34))
                                .multilineTextAlignment(.center)
                        }
                        .opacity(animateContent ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(0.2), value: animateContent)
                        
                        // Quick Actions
                        VStack(spacing: 16) {
                            helpActionCard(
                                title: "Take Tutorial",
                                subtitle: "Learn to sign A-S-L step by step",
                                icon: "hand.raised.fill",
                                color: Color(red: 0.3, green: 0.7, blue: 0.45)
                            ) {
                                dismiss()
                                showingTutorial = true
                            }
                            
                            helpActionCard(
                                title: "Browse Dictionary",
                                subtitle: "View all available ASL signs",
                                icon: "book.fill",
                                color: Color(red: 0.3, green: 0.55, blue: 0.85)
                            ) {
                                dismiss()
                                showingDictionary = true
                            }
                            
                            helpActionCard(
                                title: "Hear Instructions",
                                subtitle: "Listen to this help guide",
                                icon: "speaker.wave.2.fill",
                                color: Color(red: 0.85, green: 0.3, blue: 0.3)
                            ) {
                                speakHelpInstructions()
                            }
                        }
                        .opacity(animateContent ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(0.3), value: animateContent)
                        
                        // Instructions
                        VStack(spacing: 20) {
                            instructionSection(
                                title: "For Deaf Users",
                                icon: "hand.raised",
                                color: accentColor,
                                steps: [
                                    "1. Position your hand in front of the camera",
                                    "2. Make clear ASL letter signs (A-Z, 0-9)",
                                    "3. Tap predictions to select letters",
                                    "4. Build words letter by letter",
                                    "5. Tap 'Add' to add words to your sentence",
                                    "6. Tap 'Send & Speak' to communicate"
                                ]
                            )
                            
                            instructionSection(
                                title: "For Hearing Users",
                                icon: "waveform",
                                color: Color(red: 0.3, green: 0.55, blue: 0.85),
                                steps: [
                                    "1. Tap the microphone button to start listening",
                                    "2. Speak clearly into your device",
                                    "3. Your words will appear as text",
                                    "4. ASL signs will show below your speech",
                                    "5. The deaf person can see your message",
                                    "6. Switch modes using the bottom button"
                                ]
                            )
                            
                            instructionSection(
                                title: "Tips for Best Results",
                                icon: "lightbulb.fill",
                                color: Color(red: 0.85, green: 0.65, blue: 0.3),
                                steps: [
                                    "• Ensure good lighting for camera recognition",
                                    "• Keep your hand steady when signing",
                                    "• Practice the A-S-L tutorial first",
                                    "• Use the dictionary to learn new signs",
                                    "• Speak clearly for speech recognition",
                                    "• Use the help button anytime you need guidance"
                                ]
                            )
                        }
                        .opacity(animateContent ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(0.4), value: animateContent)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(accentColor)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateContent = true
            }
        }
    }
    
    private func helpActionCard(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            HapticManager.shared.mediumImpact()
            action()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 50, height: 50)
                        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.12))
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0.45, green: 0.38, blue: 0.34))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(BouncyPressStyle())
    }
    
    private func instructionSection(
        title: String,
        icon: String,
        color: Color,
        steps: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.12))
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(steps, id: \.self) { step in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        
                        Text(step)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.22))
                            .lineLimit(nil)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(color.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    private func speakHelpInstructions() {
        let instructions = """
        Welcome to SilentSpeak Help. Here's how to use the app:
        
        For deaf users: Position your hand in front of the camera and make clear ASL letter signs. 
        Tap predictions to select letters, build words letter by letter, then tap Send and Speak to communicate.
        
        For hearing users: Tap the microphone button and speak clearly. Your words will appear as text with ASL signs below.
        
        Use the mode switch button to change between deaf and hearing modes. 
        Access the dictionary to learn new signs, or take the tutorial to practice A-S-L.
        
        For best results, ensure good lighting and keep your hand steady when signing.
        """
        
        let utterance = AVSpeechUtterance(string: instructions)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        
        speechSynthesizer.speak(utterance)
    }
}

// MARK: - Preview
struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(
            showingDictionary: .constant(false),
            showingTutorial: .constant(false)
        )
    }
}
import SwiftUI
import AVFoundation

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("selectedVoice") private var selectedVoice = "com.apple.ttsbundle.Samantha-compact"
    @AppStorage("speechRate") private var speechRate: Double = 0.5
    @AppStorage("speechPitch") private var speechPitch: Double = 1.0
    @AppStorage("autoSave") private var autoSave = true
    @AppStorage("hapticFeedback") private var hapticFeedback = true
    @AppStorage("fontSize") private var fontSize: Double = 24
    @AppStorage("micSensitivity") private var micSensitivity: Double = 0.5
    @AppStorage("cameraPosition") private var useFrontCamera = true
    
    // Accessibility features
    @AppStorage("autoPlayAudio") private var autoPlayAudio = true
    @AppStorage("showSubtitles") private var showSubtitles = true
    @AppStorage("gestureSpeed") private var gestureSpeed: Double = 1.0
    
    @State private var animateContent = false
    @State private var showResetConfirm = false
    @State private var showVoicePicker = false
    
    let bgColor1 = Color(red: 0.98, green: 0.92, blue: 0.87)
    let bgColor2 = Color(red: 0.96, green: 0.82, blue: 0.73)
    let accentPeach = Color(red: 0.82, green: 0.53, blue: 0.43)
    let deepBrown = Color(red: 0.58, green: 0.35, blue: 0.28)
    let cardBg = Color.white.opacity(0.85)
    
    let colorBlindModes = [
        ("none", "None"),
        ("protanopia", "Protanopia (Red-Blind)"),
        ("deuteranopia", "Deuteranopia (Green-Blind)"),
        ("tritanopia", "Tritanopia (Blue-Blind)"),
        ("monochromacy", "Monochromacy (Total Color Blindness)")
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [bgColor1, bgColor2.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(deepBrown)
                    }
                    .buttonStyle(BouncyPressStyle())
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(deepBrown)
                    
                    Spacer()
                    
                    // Invisible spacer
                    HStack { Image(systemName: "chevron.left"); Text("Back") }.opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile
                        profileSection
                            .staggeredAppear(index: 0, isVisible: animateContent)
                        
                        // App Settings
                        settingsGroup(title: "App Settings", icon: "slider.horizontal.3", index: 1) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Font Size")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(deepBrown.opacity(0.6))
                                    Spacer()
                                    Text("\(Int(fontSize))pt")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(accentPeach)
                                        .animation(.spring(), value: fontSize)
                                }
                                Slider(value: $fontSize, in: 14...42, step: 2)
                                    .tint(accentPeach)
                                    .onChange(of: fontSize) { _ in
                                        if hapticFeedback {
                                            HapticManager.shared.selection()
                                        }
                                    }
                            }
                            .padding(.vertical, 4)
                            
                            Divider().opacity(0.3)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Mic Sensitivity")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(deepBrown.opacity(0.6))
                                    Spacer()
                                    Text("\(Int(micSensitivity * 100))%")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(accentPeach)
                                }
                                Slider(value: $micSensitivity, in: 0.1...1.0, step: 0.1)
                                    .tint(accentPeach)
                                    .onChange(of: micSensitivity) { _ in
                                        if hapticFeedback {
                                            HapticManager.shared.selection()
                                        }
                                    }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        // Voice & Speech
                        settingsGroup(title: "Voice & Speech", icon: "speaker.wave.3.fill", index: 2) {
                            Button(action: {
                                HapticManager.shared.lightImpact()
                                showVoicePicker = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Text-to-Speech Voice")
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                            .foregroundColor(deepBrown)
                                        Text(getVoiceName(selectedVoice))
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(deepBrown.opacity(0.5))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(deepBrown.opacity(0.3))
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(BouncyPressStyle())
                            
                            Divider().opacity(0.3)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Speech Rate")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(deepBrown.opacity(0.6))
                                    Spacer()
                                    Text(speechRate < 0.3 ? "Slow" : speechRate > 0.7 ? "Fast" : "Normal")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(accentPeach)
                                }
                                Slider(value: $speechRate, in: 0.1...1.0, step: 0.1)
                                    .tint(accentPeach)
                                    .onChange(of: speechRate) { _ in
                                        if hapticFeedback {
                                            HapticManager.shared.selection()
                                        }
                                    }
                            }
                            .padding(.vertical, 4)
                            
                            Divider().opacity(0.3)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Speech Pitch")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(deepBrown.opacity(0.6))
                                    Spacer()
                                    Text(speechPitch < 0.8 ? "Low" : speechPitch > 1.2 ? "High" : "Normal")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(accentPeach)
                                }
                                Slider(value: $speechPitch, in: 0.5...2.0, step: 0.1)
                                    .tint(accentPeach)
                                    .onChange(of: speechPitch) { _ in
                                        if hapticFeedback {
                                            HapticManager.shared.selection()
                                        }
                                    }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        // Accessibility Features
                        settingsGroup(title: "Accessibility", icon: "accessibility", index: 3) {
                            settingsToggle(title: "Auto-Play Audio", subtitle: "Automatically speak sentences", isOn: $autoPlayAudio)
                            Divider().opacity(0.3)
                            settingsToggle(title: "Show Subtitles", subtitle: "Display text captions", isOn: $showSubtitles)
                            Divider().opacity(0.3)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Gesture Recognition Speed")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(deepBrown.opacity(0.6))
                                    Spacer()
                                    Text(gestureSpeed < 0.7 ? "Slow" : gestureSpeed > 1.3 ? "Fast" : "Normal")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(accentPeach)
                                }
                                Slider(value: $gestureSpeed, in: 0.5...1.5, step: 0.1)
                                    .tint(accentPeach)
                                    .onChange(of: gestureSpeed) { _ in
                                        if hapticFeedback {
                                            HapticManager.shared.selection()
                                        }
                                    }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        // Camera
                        settingsGroup(title: "Camera", icon: "camera.fill", index: 4) {
                            settingsToggle(title: "Use Front Camera", subtitle: "Switch between front and rear camera", isOn: $useFrontCamera)
                        }
                        
                        // General
                        settingsGroup(title: "General", icon: "gearshape.fill", index: 5) {
                            settingsToggle(title: "Auto-Save Conversations", subtitle: "Automatically save all transcripts", isOn: $autoSave)
                            Divider().opacity(0.3)
                            settingsToggle(title: "Haptic Feedback", subtitle: "Vibration on button taps", isOn: $hapticFeedback)
                        }
                        
                        // About
                        settingsGroup(title: "About", icon: "info.circle.fill", index: 6) {
                            aboutRow(title: "Version", value: "1.0.0")
                            Divider().opacity(0.3)
                            aboutRow(title: "Build", value: "2026.1")
                            Divider().opacity(0.3)
                            aboutRow(title: "Developer", value: "SilentSpeak Team")
                        }
                        
                        // Reset
                        Button(action: {
                            HapticManager.shared.error()
                            showResetConfirm = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset to Defaults")
                            }
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.red.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.red.opacity(0.08))
                            )
                        }
                        .buttonStyle(AnimatedPressStyle(scaleAmount: 0.97, glowColor: .red))
                        .padding(.horizontal, 20)
                        .staggeredAppear(index: 7, isVisible: animateContent)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animateContent = true
            }
        }
        .alert("Reset Settings", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                withAnimation(.spring()) {
                    selectedVoice = "com.apple.ttsbundle.Samantha-compact"
                    speechRate = 0.5
                    speechPitch = 1.0
                    autoSave = true
                    hapticFeedback = true
                    fontSize = 24
                    micSensitivity = 0.5
                    useFrontCamera = true
                    autoPlayAudio = true
                    showSubtitles = true
                    gestureSpeed = 1.0
                }
                if hapticFeedback {
                    HapticManager.shared.success()
                }
            }
        } message: {
            Text("This will reset all settings to their default values.")
        }
        .sheet(isPresented: $showVoicePicker) {
            voicePickerSheet
        }
    }
    
    
    private var profileSection: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [accentPeach, deepBrown], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 64, height: 64)
                    .glowPulse(color: accentPeach, radius: 12)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("SilentSpeak User")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(deepBrown)
                Text("Personal Settings")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(deepBrown.opacity(0.5))
            }
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(cardBg)
                .shadow(color: accentPeach.opacity(0.1), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 20)
    }
    
    private func settingsGroup<Content: View>(title: String, icon: String, index: Int, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(accentPeach)
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(deepBrown.opacity(0.6))
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(cardBg)
                    .shadow(color: accentPeach.opacity(0.08), radius: 10, x: 0, y: 5)
            )
        }
        .padding(.horizontal, 20)
        .staggeredAppear(index: index, isVisible: animateContent)
    }
    
    private func settingsToggle(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(deepBrown)
                Text(subtitle)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(deepBrown.opacity(0.4))
            }
            Spacer()
            Toggle("", isOn: isOn)
                .tint(accentPeach)
                .labelsHidden()
                .onChange(of: isOn.wrappedValue) { _ in
                    if hapticFeedback {
                        HapticManager.shared.selection()
                    }
                }
        }
        .padding(.vertical, 4)
    }
    
    private func aboutRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(deepBrown)
            Spacer()
            Text(value)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(deepBrown.opacity(0.5))
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Voice Picker Sheet
    private var voicePickerSheet: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [bgColor1, bgColor2.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(getAvailableVoices(), id: \.identifier) { voice in
                            voiceSelectionButton(for: voice)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Select Voice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showVoicePicker = false
                    }
                    .foregroundColor(accentPeach)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func getVoiceName(_ identifier: String) -> String {
        let voices = getAvailableVoices()
        return voices.first(where: { $0.identifier == identifier })?.name ?? "Default Voice"
    }
    
    private func getAvailableVoices() -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") } // Filter for English voices
            .sorted { $0.name < $1.name }
    }
    
    private func voiceSelectionButton(for voice: AVSpeechSynthesisVoice) -> some View {
        Button(action: {
            if hapticFeedback {
                HapticManager.shared.selection()
            }
            selectedVoice = voice.identifier
            showVoicePicker = false
        }) {
            voiceButtonContent(for: voice)
        }
        .buttonStyle(AnimatedPressStyle(scaleAmount: 0.98, glowColor: accentPeach))
    }
    
    private func voiceButtonContent(for voice: AVSpeechSynthesisVoice) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(voice.name)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(deepBrown)
                Text("\(voice.language) • \(qualityDescription(voice.quality))")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(deepBrown.opacity(0.6))
            }
            Spacer()
            if selectedVoice == voice.identifier {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(accentPeach)
                    .font(.system(size: 20))
            }
        }
        .padding(16)
        .background(voiceButtonBackground(isSelected: selectedVoice == voice.identifier))
    }
    
    private func voiceButtonBackground(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(isSelected ? accentPeach.opacity(0.1) : cardBg)
            .shadow(color: accentPeach.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private func qualityDescription(_ quality: AVSpeechSynthesisVoiceQuality) -> String {
        switch quality {
        case .default:
            return "Default"
        case .enhanced:
            return "Enhanced"
        case .premium:
            return "Premium"
        @unknown default:
            return "Standard"
        }
    }
}

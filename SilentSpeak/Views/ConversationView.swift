import SwiftUI
import AVFoundation

struct ConversationView: View {
    @ObservedObject var store: ConversationStore
    let conversationId: UUID
    
    @StateObject private var recognizer = SpeechRecognizer()
    @StateObject private var aslManager = ASLCameraManager()
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("selectedVoice") private var selectedVoice = "com.apple.ttsbundle.Samantha-compact"
    @AppStorage("speechRate") private var speechRate: Double = 0.5
    @AppStorage("speechPitch") private var speechPitch: Double = 1.0
    
    @State private var aslSigns: [ASLSignImage] = []
    @State private var activePanel: ActivePanel = .deaf
    @State private var predictionPop = false
    @State private var micPulse = false
    @State private var showingHelp = false
    @State private var showingDictionary = false
    @State private var showingTutorial = false
    @State private var lastCommittedTranscript = ""
    
    // Shared speech synthesizer
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    enum ActivePanel {
        case deaf, hearing
    }
    
    // Professional colors
    private let bg1 = Color(red: 0.98, green: 0.95, blue: 0.92)
    private let bg2 = Color(red: 0.96, green: 0.91, blue: 0.86)
    private let accent = Color(red: 0.78, green: 0.48, blue: 0.32)
    private let wave = Color(red: 0.85, green: 0.65, blue: 0.45)
    
    private var composedSentence: String {
        let parts = [aslManager.currentSentence, aslManager.currentWord]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts.joined(separator: " ")
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isSmallPhone = geometry.size.width < 700 && geometry.size.height < 950
            let shouldForceLandscape = isSmallPhone && geometry.size.height > geometry.size.width
            let usesCompactTranslator = geometry.size.width < 760
            
            ZStack {
                LinearGradient(
                    colors: [bg1, bg2],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView(isSmallPhone: isSmallPhone)
                    
                    if shouldForceLandscape {
                        rotateToLandscapePrompt
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 8) {
                                Group {
                                    if usesCompactTranslator {
                                        VStack(spacing: 8) {
                                            deafPanel
                                            hearingPanelCard
                                        }
                                    } else {
                                        HStack(spacing: 8) {
                                            deafPanel
                                            hearingPanelCard
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .top)
                                
                                if !isSmallPhone {
                                    messageHistoryBox
                                        .frame(height: min(108, geometry.size.height * 0.14))
                                }
                            }
                            .padding(.horizontal, isSmallPhone ? 6 : 8)
                            .padding(.bottom, 10)
                        }
                        
                        bottomBar
                    }
                }
            }
        }
        .onAppear {
            aslManager.requestCameraPermission()
            aslManager.startSession()
            refreshWordSuggestions()
        }
        .onDisappear {
            finalizeSpeechTranscriptIfNeeded()
            recognizer.stopTranscribing()
            aslManager.stopSession()
        }
        .onChange(of: aslManager.currentGesture) { newGesture in
            if !newGesture.isEmpty && newGesture != "No hand detected" {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    micPulse = true
                }
            }
        }
        .onChange(of: aslManager.currentWord) { _ in
            refreshWordSuggestions()
            syncASLSigns()
        }
        .onChange(of: aslManager.currentSentence) { _ in
            refreshWordSuggestions()
            syncASLSigns()
        }
        .onChange(of: recognizer.isListening) { isListening in
            if !isListening {
                finalizeSpeechTranscriptIfNeeded()
            }
        }
        .sheet(isPresented: $showingHelp) {
            HelpView(
                showingDictionary: $showingDictionary,
                showingTutorial: $showingTutorial
            )
        }
        .sheet(isPresented: $showingDictionary) {
            NavigationView {
                FullDictionaryView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingDictionary = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showingTutorial) {
            TutorialOnboardingView {
                showingTutorial = false
            }
        }
    }
    
    private func headerView(isSmallPhone: Bool) -> some View {
        HStack(spacing: isSmallPhone ? 10 : 14) {
            Button("Back") {
                HapticManager.shared.lightImpact()
                dismiss()
            }
            .foregroundColor(accent)
            
            Spacer()
            
            Text("SilentSpeak")
                .font(isSmallPhone ? .subheadline.weight(.semibold) : .headline)
                .foregroundColor(accent)
            
            Spacer()
            
            Button(action: {
                HapticManager.shared.lightImpact()
                showingHelp = true
            }) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: isSmallPhone ? 18 : 20, weight: .medium))
                    .foregroundColor(accent)
            }
            
            Button(action: {
                HapticManager.shared.mediumImpact()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    switch activePanel {
                    case .deaf: activePanel = .hearing
                    case .hearing: activePanel = .deaf
                    }
                }
            }) {
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .font(.system(size: isSmallPhone ? 18 : 20, weight: .medium))
                    .foregroundColor(accent)
            }
        }
        .padding(.horizontal, isSmallPhone ? 14 : 16)
        .padding(.vertical, isSmallPhone ? 10 : 14)
    }
    
    private var rotateToLandscapePrompt: some View {
        VStack(spacing: 18) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.white.opacity(0.72))
                    .frame(width: 170, height: 120)
                    .shadow(color: accent.opacity(0.15), radius: 18, x: 0, y: 10)
                
                Image(systemName: "iphone.landscape")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(accent)
            }
            
            Text("Rotate Your iPhone")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(DS.Colors.textPrimary)
            
            Text("Use the translator in landscape on smaller screens so the camera, transcript, and send controls all fit properly.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 10)
            
            HStack(spacing: 10) {
                Label("Landscape only", systemImage: "arrow.triangle.2.circlepath")
                Label("Camera fits", systemImage: "camera.viewfinder")
            }
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundColor(accent)
            
            Spacer()
        }
    }
    
    // MARK: Camera View
    private var cameraView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.black.opacity(0.88))
                .shadow(color: wave.opacity(0.25), radius: 12, x: 0, y: 6)
            
            if aslManager.permissionGranted && aslManager.isRunning {
                ASLCameraPreview(cameraManager: aslManager)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            
            if let frame = aslManager.currentFrame {
                Image(decorative: frame, scale: 1.0)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .opacity(aslManager.isRunning ? 0.96 : 0.58)
                    .allowsHitTesting(false)
            }
            
            if aslManager.permissionGranted && aslManager.isRunning {
                
                // Scanning animation border
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [accent.opacity(0.7), wave.opacity(0.3), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
                
                // Gesture chip overlay at bottom of camera
                VStack {
                    HStack {
                        Label(aslManager.currentFrame == nil ? "Waiting for live feed" : "Live camera", systemImage: aslManager.currentFrame == nil ? "camera.metering.unknown" : "dot.radiowaves.left.and.right")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    
                    Spacer()
                    if !aslManager.currentGesture.isEmpty && aslManager.isHandPresent {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 7, height: 7)
                                .shadow(color: .green, radius: 4)
                            
                            Text(aslManager.currentGesture)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("·")
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("\(Int(aslManager.confidence * 100))%")
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 12)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            } else {
                cameraPlaceholder
            }
        }
        .frame(minHeight: 220)
    }
    
    private var cameraPlaceholder: some View {
        VStack(spacing: 10) {
            Image(systemName: aslManager.permissionGranted ? "camera.fill" : "camera.badge.exclamationmark.fill")
                .font(.system(size: 36))
                .foregroundColor(.white.opacity(0.45))
            
            Text(aslManager.permissionGranted ? "Starting camera…" : "Camera access needed")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
            
            if !aslManager.permissionGranted {
                Button("Allow Access") { 
                    aslManager.requestCameraPermission() 
                }
                .buttonStyle(BouncyPressStyle())
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.white.opacity(0.18)))
            }
        }
    }
    
    // MARK: Predictions Panel (top-5 + retry)
    private var predictionsPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(accent)
                
                Text("Predictions — tap to select")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(accent)
                
                Spacer()
                
                // Retry button
                Button(action: {
                    HapticManager.shared.mediumImpact()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        aslManager.clearSelection()
                        refreshWordSuggestions()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Retry")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(accent))
                }
                .buttonStyle(BouncyPressStyle())
            }
            .padding(.horizontal, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(aslManager.lockedPredictions.filter { $0.gesture != "?" }.prefix(8).enumerated()), id: \.offset) { idx, pred in
                        predictionChip(pred, rank: idx)
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(wave.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: wave.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
    
    private func predictionChip(_ pred: (gesture: String, confidence: Float), rank: Int) -> some View {
        let isTop = rank == 0
        return Button(action: {
            HapticManager.shared.selection()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                addGesture(pred.gesture)
                predictionPop = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { 
                predictionPop = false 
            }
        }) {
            VStack(spacing: 3) {
                // Rank badge
                ZStack {
                    Circle()
                        .fill(isTop ? accent : wave.opacity(0.5))
                        .frame(width: 22, height: 22)
                    Text("\(rank + 1)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Text(pred.gesture)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(isTop ? accent : Color(red: 0.4, green: 0.28, blue: 0.2))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                
                Text("\(Int(pred.confidence * 100))%")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(isTop ? accent.opacity(0.85) : wave)
                
                // Confidence bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(isTop ? accent : wave)
                            .frame(width: geo.size.width * CGFloat(pred.confidence), height: 4)
                    }
                }
                .frame(height: 4)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(minWidth: 64)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isTop ? accent.opacity(0.12) : Color.white.opacity(0.55))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isTop ? accent.opacity(0.4) : wave.opacity(0.3), lineWidth: 1.5)
                    )
            )
            .scaleEffect(isTop ? 1.0 : 0.93)
        }
        .buttonStyle(BouncyPressStyle())
    }
    
    // MARK: Word Builder Bar
    private var wordBuilderBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "pencil.tip")
                .font(.system(size: 13))
                .foregroundColor(accent)
            
            Text(aslManager.currentWord)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(accent.opacity(0.12)))
            
            Spacer()
            
            // Delete last letter
            Button(action: { 
                HapticManager.shared.lightImpact()
                if !aslManager.currentWord.isEmpty { 
                    aslManager.currentWord.removeLast() 
                    refreshWordSuggestions()
                } 
            }) {
                Image(systemName: "delete.left.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                    .padding(9)
                    .background(Circle().fill(Color.orange.opacity(0.1)))
            }
            .buttonStyle(BouncyPressStyle())
            
            // Space = commit word to sentence
            Button(action: { 
                HapticManager.shared.mediumImpact()
                commitWord() 
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "space")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Add")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(accent))
            }
            .buttonStyle(BouncyPressStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.7))
                .shadow(color: wave.opacity(0.18), radius: 6, x: 0, y: 3)
        )
    }
    
    private var sentenceAssistBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(accent)
                Text(aslManager.currentWord.isEmpty ? "Next-word ideas" : "Finish this word")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(accent)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(aslManager.wordSuggestions, id: \.self) { suggestion in
                        Button(action: {
                            HapticManager.shared.selection()
                            applySuggestion(suggestion)
                        }) {
                            Text(suggestion)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(accent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.75))
                                        .overlay(
                                            Capsule()
                                                .stroke(accent.opacity(0.22), lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(BouncyPressStyle())
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.62))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(wave.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: Signed Words Strip
    private var signedWordsStrip: some View {
        VStack(spacing: 6) {
            if aslSigns.isEmpty && composedSentence.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Image(systemName: "hand.raised.fingers.spread.fill")
                            .font(.system(size: 26))
                            .foregroundColor(wave.opacity(0.6))
                            .floatingAnimation(offset: 5, duration: 2.2)
                        
                        Text("Sign to build a sentence")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(accent.opacity(0.7))
                    }
                    Spacer()
                }
                .frame(height: 84)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(wave.opacity(0.25), lineWidth: 1)
                        )
                )
            } else {
                VStack(spacing: 6) {
                    // Audio play button for sentence
                    HStack {
                        Button(action: {
                            HapticManager.shared.mediumImpact()
                            speakText(composedSentence)
                        }) {
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(
                                            colors: [
                                                Color(red: 0.3, green: 0.7, blue: 0.45),
                                                Color(red: 0.2, green: 0.6, blue: 0.35)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(width: 32, height: 32)
                                        .shadow(color: Color.green.opacity(0.4), radius: 6, x: 0, y: 3)
                                    
                                    Image(systemName: "speaker.wave.3.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Text("Speak Aloud")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(accent)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.green.opacity(0.3), lineWidth: 1.5)
                                    )
                            )
                        }
                        .buttonStyle(BouncyPressStyle())

                        Spacer()
                        
                        // Send button with proper icon
                        Button(action: {
                            HapticManager.shared.mediumImpact()
                            sendMessage(composedSentence)
                        }) {
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(accent)
                                        .frame(width: 32, height: 32)
                                        .shadow(color: accent.opacity(0.4), radius: 6, x: 0, y: 3)
                                    
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .rotationEffect(.degrees(45)) // Proper send icon orientation
                                }
                                
                                Text("Send & Speak")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(accent)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(accent.opacity(0.3), lineWidth: 1.5)
                                    )
                            )
                        }
                        .buttonStyle(BouncyPressStyle())
                    }
                    .padding(.horizontal, 10)
                    
                    // Images strip
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(aslSigns) { sign in
                                ImprovedWordHandCard(sign: sign, accentColor: accent, waveColor: wave, cardSize: 60)
                                    .transition(.scale(scale: 0.85).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                    }
                    .frame(height: 94)
                }
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.55))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(wave.opacity(0.25), lineWidth: 1)
                        )
                )
            }
            
            // Editable sentence field
            if !aslManager.currentSentence.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 13))
                        .foregroundColor(accent.opacity(0.7))
                    
                    TextField("Edit sentence…", text: $aslManager.currentSentence)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.15))
                    
                    Button(action: { 
                        aslManager.currentSentence = ""
                        aslSigns = []
                        refreshWordSuggestions()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(wave.opacity(0.7))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.7))
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Message History Box
    private var messageHistoryBox: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "message.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(accent)
                
                Text("Conversation History")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(accent)
                
                Spacer()
                
                if let conversation = store.conversations.first(where: { $0.id == conversationId }) {
                    Text("\(conversation.messages.count) messages")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(accent.opacity(0.6))
                }
            }
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    if let conversation = store.conversations.first(where: { $0.id == conversationId }),
                       !conversation.messages.isEmpty {
                        ForEach(conversation.messages.suffix(10)) { message in
                            messageRow(message)
                        }
                    } else {
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.system(size: 20))
                                    .foregroundColor(accent.opacity(0.4))
                                
                                Text("Start your conversation")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(accent.opacity(0.6))
                            }
                            Spacer()
                        }
                        .frame(height: 60)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(accent.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: accent.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func messageRow(_ message: ConversationMessage) -> some View {
        HStack(alignment: .top, spacing: 8) {
            // User type indicator
            Circle()
                .fill(message.isFromDeafUser ? Color.blue : Color.green)
                .frame(width: 8, height: 8)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(message.isFromDeafUser ? "Deaf User" : "Speaker")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(message.isFromDeafUser ? Color.blue : Color.green)
                    
                    Spacer()
                    
                    Text(message.timestamp, style: .time)
                        .font(.system(size: 9, design: .rounded))
                        .foregroundColor(accent.opacity(0.5))
                }
                
                Text(message.text)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.14, blue: 0.10))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(message.isFromDeafUser ? Color.blue.opacity(0.05) : Color.green.opacity(0.05))
        )
    }
    
    // MARK: ━━━━━━━━━━━━┫ HEARING PANEL ┣━━━━━━━━━━━━
    private var hearingPanel: some View {
        VStack(spacing: 8) {
            // Transcript card
            transcriptCard
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // ASL strip for the speech
            if !recognizer.transcript.isEmpty && recognizer.transcript != "Say something..." {
                speechSignStrip
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
            
            // Mic section
            micSection
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var transcriptCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.68))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(wave.opacity(0.35), lineWidth: 1.5)
                )
                .shadow(color: wave.opacity(0.18), radius: 10, x: 0, y: 5)
            
            let speech = recognizer.transcript == "Say something..." ? "" : recognizer.transcript
            
            if speech.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "waveform.path")
                        .font(.system(size: 26))
                        .foregroundColor(wave.opacity(0.5))
                        .breathingScale(min: 0.92, max: 1.08, duration: 2.0)
                    
                    Text("Spoken words appear here")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(accent.opacity(0.6))
                }
            } else {
                ScrollView {
                    Text(speech)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.14, blue: 0.10))
                        .multilineTextAlignment(.center)
                        .padding(18)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: speech)
                }
            }
        }
    }
    
    private var speechSignStrip: some View {
        let signs = ASLTextConverter.convertToASL(recognizer.transcript)
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(signs) { sign in
                    ImprovedWordHandCard(sign: sign, accentColor: accent, waveColor: wave, cardSize: 58)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
        }
        .frame(height: 82)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(wave.opacity(0.25), lineWidth: 1)
                )
        )
    }
    
    private var micSection: some View {
        VStack(spacing: 6) {
            Button(action: {
                HapticManager.shared.mediumImpact()
                if recognizer.isListening { 
                    recognizer.stopTranscribing() 
                } else { 
                    lastCommittedTranscript = recognizer.transcript
                    recognizer.startTranscribing() 
                }
            }) {
                ZStack {
                    // Glow ring when listening
                    if recognizer.isListening {
                        Circle()
                            .fill(accent.opacity(0.18))
                            .frame(width: 84, height: 84)
                            .scaleEffect(micPulse ? 1.15 : 0.9)
                            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: micPulse)
                    }
                    
                    Circle()
                        .fill(RadialGradient(
                            colors: recognizer.isListening
                                ? [Color(red: 0.85, green: 0.50, blue: 0.34), Color(red: 0.70, green: 0.34, blue: 0.20)]
                                : [wave, accent.opacity(0.8)],
                            center: .center, 
                            startRadius: 0, 
                            endRadius: 38
                        ))
                        .frame(width: 66, height: 66)
                        .shadow(
                            color: recognizer.isListening ? accent.opacity(0.45) : Color.black.opacity(0.10),
                            radius: recognizer.isListening ? 18 : 6,
                            x: 0, y: 4
                        )
                    
                    Image(systemName: recognizer.isListening ? "mic.fill" : "mic.slash.fill")
                        .font(.system(size: 25, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(BouncyPressStyle())
            
            Text(recognizer.isListening ? "Listening…" : "Tap to speak")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(recognizer.isListening ? accent : accent.opacity(0.5))
                .animation(.easeInOut(duration: 0.3), value: recognizer.isListening)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.62))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(wave.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: wave.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: ━━━━━━━━━━━━┫ BOTTOM BAR ┣━━━━━━━━━━━━
    private var bottomBar: some View {
        ZStack {
            // Clean gradient background
            LinearGradient(
                colors: [bg2.opacity(0.95), bg1.opacity(0.90)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .shadow(color: wave.opacity(0.2), radius: 8, x: 0, y: -4)
            
            HStack(spacing: 12) {
                // Replay button
                Button(action: {
                    HapticManager.shared.mediumImpact()
                    // Replay the last message from conversation
                    if let lastMessage = store.conversations.first(where: { $0.id == conversationId })?.messages.last {
                        speakText(lastMessage.text)
                    } else {
                        // Fallback to current sentence if no messages
                        let textToSpeak = aslManager.currentSentence.isEmpty ? recognizer.transcript : aslManager.currentSentence
                        if !textToSpeak.isEmpty && textToSpeak != "Say something..." {
                            speakText(textToSpeak)
                        }
                    }
                }) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(accent)
                                .frame(width: 36, height: 36)
                                .shadow(color: accent.opacity(0.3), radius: 4, x: 0, y: 2)
                            
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Replay")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(accent)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(accent.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: accent.opacity(0.15), radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(BouncyPressStyle())
                
                Spacer()
                
                // Mode Switch Button
                Button(action: {
                    HapticManager.shared.mediumImpact()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        switch activePanel {
                        case .deaf: activePanel = .hearing
                        case .hearing: activePanel = .deaf
                        }
                    }
                }) {
                    switchButtonContent
                }
                .buttonStyle(BouncyPressStyle())
                
                Spacer()
                
                // Clear button
                Button(action: {
                    HapticManager.shared.error()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        aslManager.currentSentence   = ""
                        aslManager.currentWord       = ""
                        aslManager.usedGestures.removeAll()
                        aslManager.lockedPredictions = []
                        recognizer.transcript        = ""
                        aslSigns                     = []
                        aslManager.wordSuggestions   = []
                    }
                }) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 36, height: 36)
                                .shadow(color: Color.red.opacity(0.3), radius: 4, x: 0, y: 2)
                            
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Clear")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: Color.red.opacity(0.15), radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(BouncyPressStyle())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .frame(height: 74)
    }
    
    private var switchButtonContent: some View {
        HStack(spacing: 12) {
            // Animated icon with elevation effect
            ZStack {
                Circle()
                    .fill(activePanelColor)
                    .frame(width: 44, height: 44)
                    .shadow(color: activePanelColor.opacity(0.4), radius: 8, x: 0, y: 4)
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: activePanel)
                
                Image(systemName: activePanelIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: activePanel)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Mode")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(accent.opacity(0.7))
                
                Text(activePanelLabel)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(accent)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: activePanel)
            }
            
            Spacer()
            
            // Animated status indicators
            HStack(spacing: 4) {
                ForEach(0..<2) { i in
                    Circle()
                        .fill(getIndicatorColor(for: i))
                        .frame(width: 8, height: 8)
                        .scaleEffect(getIndicatorColor(for: i) == accent ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: activePanel)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(activePanelColor.opacity(0.4), lineWidth: 2)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: activePanel)
                )
                .shadow(color: activePanelColor.opacity(0.2), radius: 12, x: 0, y: 6)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: activePanel)
        )
    }
    
    // MARK: ━━━━━━━━━━━━┫ HELPERS ┣━━━━━━━━━━━━
    private func getIndicatorColor(for index: Int) -> Color {
        switch activePanel {
        case .deaf:
            return index == 0 ? accent : accent.opacity(0.3)
        case .hearing:
            return index == 1 ? accent : accent.opacity(0.3)
        }
    }
    
    private func getIndicatorScale(for index: Int) -> CGFloat {
        return 1.0
    }
    
    private var activePanelColor: Color {
        return accent
    }
    
    private var activePanelIcon: String {
        switch activePanel {
        case .deaf: return "hand.raised"
        case .hearing: return "waveform"
        }
    }
    
    private var activePanelLabel: String {
        switch activePanel {
        case .deaf: return "Deaf"
        case .hearing: return "Hearing"
        }
    }
    
    // MARK: ━━━━━━━━━━━━┫ HELPERS ┣━━━━━━━━━━━━
    private func addGesture(_ gesture: String) {
        let clean = gesture
            .replacingOccurrences(of: " (draw J)", with: "")
            .replacingOccurrences(of: " (draw hook)", with: "")
            .replacingOccurrences(of: " (draw Z)", with: "")
            .replacingOccurrences(of: " (draw zigzag)", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        aslManager.currentWord += clean
        aslManager.lockedPredictions = []
        aslManager.isHandPresent     = false
        refreshWordSuggestions()
        syncASLSigns()
    }
    
    private func commitWord() {
        guard !aslManager.currentWord.isEmpty else { return }
        
        if aslManager.currentSentence.isEmpty {
            aslManager.currentSentence = aslManager.currentWord
        } else {
            aslManager.currentSentence += " " + aslManager.currentWord
        }
        
        aslManager.currentWord = ""
        aslManager.usedGestures.removeAll()
        refreshWordSuggestions()
        syncASLSigns()
    }
    
    private func speakText(_ text: String) {
        guard !text.isEmpty else { return }
        
        // Stop any current speech
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("🔇 Audio session error: \(error.localizedDescription)")
        }
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Use selected voice from settings
        if let voice = AVSpeechSynthesisVoice(identifier: selectedVoice) {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        utterance.rate = Float(speechRate)
        utterance.pitchMultiplier = Float(speechPitch)
        
        print("🔊 Speaking: \(text)")
        speechSynthesizer.speak(utterance)
    }
    
    private func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        
        // This sends the deaf person's message to the hearing person by speaking it aloud
        // Add the message to the conversation store
        store.addMessage(to: conversationId, text: text, isFromDeafUser: true)
        
        // Speak the message aloud for the hearing person to hear
        speakText(text)
        
        // Clear the current sentence and signs after sending
        aslManager.currentSentence = ""
        aslManager.currentWord = ""
        aslSigns = []
        refreshWordSuggestions()
    }
    
    private func refreshWordSuggestions() {
        if !aslManager.currentWord.isEmpty {
            aslManager.wordSuggestions = WordSuggestions.getSuggestions(for: aslManager.currentWord, maxResults: 6)
        } else if let lastWord = aslManager.currentSentence.split(separator: " ").last {
            aslManager.wordSuggestions = WordSuggestions.getNextWordSuggestions(after: String(lastWord))
        } else {
            aslManager.wordSuggestions = WordSuggestions.getSuggestions(for: "", maxResults: 5)
        }
    }
    
    private func syncASLSigns() {
        let displayText = composedSentence
        aslSigns = displayText.isEmpty ? [] : ASLTextConverter.convertToASL(displayText)
    }
    
    private func applySuggestion(_ suggestion: String) {
        if !aslManager.currentWord.isEmpty {
            aslManager.currentWord = suggestion
            commitWord()
        } else {
            if aslManager.currentSentence.isEmpty {
                aslManager.currentSentence = suggestion
            } else {
                aslManager.currentSentence += " " + suggestion
            }
            refreshWordSuggestions()
        }
    }
    
    private func finalizeSpeechTranscriptIfNeeded() {
        let transcript = recognizer.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !transcript.isEmpty,
              transcript != "Say something...",
              transcript != "Listening...",
              transcript != lastCommittedTranscript,
              !transcript.hasPrefix("Permission denied"),
              !transcript.hasPrefix("Audio session error"),
              !transcript.hasPrefix("Could not") else {
            return
        }
        
        store.addMessage(to: conversationId, text: transcript, isFromDeafUser: false)
        lastCommittedTranscript = transcript
    }
    
    private var deafPanel: some View {
        VStack {
            cameraView
            
            if aslManager.isHandPresent {
                predictionsPanel
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.92).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            
            if !aslManager.currentWord.isEmpty {
                wordBuilderBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            if !aslManager.wordSuggestions.isEmpty {
                sentenceAssistBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            signedWordsStrip
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .opacity(activePanel == .deaf ? 1.0 : 0.4)
        .scaleEffect(activePanel == .deaf ? 1.0 : 0.97)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(activePanel == .deaf ? accent : Color.clear, lineWidth: 2)
                .shadow(color: activePanel == .deaf ? accent.opacity(0.3) : Color.clear, radius: 8)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: activePanel)
    }
    
    private var hearingPanelCard: some View {
        hearingPanel
            .frame(maxWidth: .infinity)
            .opacity(activePanel == .hearing ? 1.0 : 0.4)
            .scaleEffect(activePanel == .hearing ? 1.0 : 0.97)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(activePanel == .hearing ? accent : Color.clear, lineWidth: 2)
                    .shadow(color: activePanel == .hearing ? accent.opacity(0.3) : Color.clear, radius: 8)
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: activePanel)
    }
}

// MARK: - Improved Word Hand Card (uses actual JPEG files)
struct ImprovedWordHandCard: View {
    let sign: ASLSignImage
    let accentColor: Color
    let waveColor: Color
    var cardSize: CGFloat = 72
    
    var body: some View {
        // Handle space character
        if sign.character == " " {
            Spacer()
                .frame(width: cardSize * 0.28, height: cardSize)
        } else {
            let uiImage = ASLImageLoader.loadImage(for: sign.imageUrl) ?? ASLImageLoader.createFallbackImage(for: sign.character, size: CGSize(width: cardSize, height: cardSize))
            VStack(spacing: 5) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(LinearGradient(
                            colors: [Color.white.opacity(0.95), Color.white.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: cardSize, height: cardSize)
                        .shadow(color: accentColor.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: cardSize * 0.94, height: cardSize * 0.94)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Text(sign.character)
                    .font(.system(size: max(10, cardSize * 0.15), weight: .bold, design: .rounded))
                    .foregroundColor(accentColor.opacity(0.9))
                    .lineLimit(1)
                    .frame(width: cardSize)
            }
        }
    }
}


#Preview {
    ConversationView(store: ConversationStore(), conversationId: UUID())
}

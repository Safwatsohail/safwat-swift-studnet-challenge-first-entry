import SwiftUI
import SoundAnalysis

struct SoundDetectionView: View {
    @StateObject private var manager = SoundDetectionManager()
    @State private var pulseRings = false
    @State private var animateIn = false
    @State private var showHistory = false
    @Environment(\.dismiss) private var dismiss
    
    private var visibleDetections: ArraySlice<(type: SoundType, confidence: Double)> {
        manager.currentDetections.prefix(5)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientView(colors: [
                    DS.Colors.backgroundPrimary,
                    DS.Colors.backgroundSecondary,
                    manager.dominantSound != nil ? urgencyColor.opacity(0.08) : DS.Colors.accent.opacity(0.05)
                ])
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1), value: manager.dominantSound?.urgencyLevel)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Top header
                        headerSection
                        
                        // Main radar / detection display
                        radarSection
                            .padding(.top, 8)
                        
                        // Dominant detection card
                        if let sound = manager.dominantSound {
                            dominantSoundCard(sound)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Recent detections bar
                        if !manager.currentDetections.isEmpty {
                            detectionsBar
                                .padding(.top, 16)
                        }
                        
                        // Event history
                        if !manager.recentEvents.isEmpty {
                            eventHistorySection
                                .padding(.top, 24)
                        }
                        
                        Spacer(minLength: 80)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { animateIn = true }
                manager.requestPermission()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if manager.permissionGranted { manager.startListening() }
                }
            }
            .onDisappear { manager.stopListening() }
            .onChange(of: manager.permissionGranted) { granted in
                if granted { manager.startListening() }
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle().fill(DS.Colors.cardBackground).frame(width: 38, height: 38)
                        .shadow(color: DS.Colors.accent.opacity(0.1), radius: 6, x: 0, y: 3)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DS.Colors.accent)
                }
            }
            .buttonStyle(BouncyPressStyle())
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("Sound Detector")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Colors.accentGradient)
                Text(manager.isListening ? "Listening actively..." : "Tap to activate")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DS.Colors.textTertiary)
            }
            
            Spacer()
            
            // Toggle listen
            Button(action: {
                HapticManager.shared.mediumImpact()
                if manager.isListening { manager.stopListening() } else { manager.startListening() }
            }) {
                ZStack {
                    Circle()
                        .fill(manager.isListening ? Color.green.opacity(0.15) : DS.Colors.cardBackground)
                        .frame(width: 38, height: 38)
                        .shadow(color: DS.Colors.accent.opacity(0.1), radius: 6, x: 0, y: 3)
                    Image(systemName: manager.isListening ? "mic.fill" : "mic.slash.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(manager.isListening ? .green : DS.Colors.accent)
                }
            }
            .buttonStyle(BouncyPressStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Radar Section
    private var radarSection: some View {
        ZStack {
            // Pulse rings (only when listening)
            if manager.isListening {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(
                            manager.dominantSound != nil ? urgencyColor.opacity(0.2 - Double(i) * 0.05) : DS.Colors.accent.opacity(0.15 - Double(i) * 0.04),
                            lineWidth: 1.5
                        )
                        .frame(
                            width: 100 + CGFloat(i) * 60 + (pulseRings ? 20 : 0),
                            height: 100 + CGFloat(i) * 60 + (pulseRings ? 20 : 0)
                        )
                        .animation(.easeInOut(duration: 1.5).delay(Double(i) * 0.3).repeatForever(autoreverses: true), value: pulseRings)
                }
            }
            
            // Center circle
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: manager.isListening
                                ? [urgencyColor.opacity(0.3), urgencyColor.opacity(0.1), Color.clear]
                                : [DS.Colors.accent.opacity(0.2), DS.Colors.accent.opacity(0.05), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 55
                        )
                    )
                    .frame(width: 110, height: 110)
                
                // Audio level indicator ring
                Circle()
                    .stroke(
                        manager.isListening ? urgencyColor.opacity(0.5) : DS.Colors.accent.opacity(0.3),
                        lineWidth: 2
                    )
                    .frame(
                        width: 110 + CGFloat(manager.backgroundLevel) * 30,
                        height: 110 + CGFloat(manager.backgroundLevel) * 30
                    )
                    .animation(.linear(duration: 0.1), value: manager.backgroundLevel)
                
                VStack(spacing: 4) {
                    if let sound = manager.dominantSound {
                        Text(sound.emoji)
                            .font(.system(size: 36))
                        Text(sound.displayName)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    } else if manager.isListening {
                        Image(systemName: "waveform")
                            .font(.system(size: 28))
                            .foregroundColor(DS.Colors.accent.opacity(0.7))
                            .opacity(pulseRings ? 1 : 0.3)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseRings)
                        Text("Listening")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(DS.Colors.textSecondary)
                    } else {
                        Image(systemName: "mic.slash")
                            .font(.system(size: 28))
                            .foregroundColor(DS.Colors.textTertiary.opacity(0.5))
                        Text("Paused")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(DS.Colors.textTertiary)
                    }
                }
            }
        }
        .frame(height: 240)
        .onAppear { pulseRings = true }
    }
    
    // MARK: - Dominant Sound Card
    private func dominantSoundCard(_ sound: SoundType) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(urgencyColor.opacity(0.2))
                    .frame(width: 56, height: 56)
                Text(sound.emoji)
                    .font(.system(size: 28))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(sound.displayName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(Int(manager.dominantConfidence * 100))%")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(urgencyColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(urgencyColor.opacity(0.15)))
                }
                
                Text(sound.alertMessage)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                
                // Confidence bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.1)).frame(height: 4)
                        RoundedRectangle(cornerRadius: 4).fill(urgencyColor)
                            .frame(width: geo.size.width * manager.dominantConfidence, height: 4)
                            .animation(.spring(response: 0.3), value: manager.dominantConfidence)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(urgencyColor.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(urgencyColor.opacity(0.35), lineWidth: 1)
                )
        )
        .shadow(color: urgencyColor.opacity(0.2), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Detections Bar
    private var detectionsBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Priority Signals")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(DS.Colors.textSecondary)
                Text("Showing the strongest alert plus four lower-confidence matches.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(DS.Colors.textTertiary)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(visibleDetections.enumerated()), id: \.element.type.rawValue) { index, detection in
                        soundChip(detection.type, confidence: detection.1, isPrimary: index == 0)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func soundChip(_ type: SoundType, confidence: Double, isPrimary: Bool) -> some View {
        VStack(spacing: 4) {
            Text(type.emoji)
                .font(.system(size: isPrimary ? 24 : 20))
            Text(type.displayName)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(isPrimary ? 0.9 : 0.58))
                .lineLimit(1)
            Text("\(Int(confidence * 100))%")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(soundColor(for: type.urgencyLevel).opacity(isPrimary ? 1 : 0.6))
        }
        .frame(width: isPrimary ? 78 : 68)
        .padding(.vertical, 10)
        .opacity(isPrimary ? 1 : 0.7)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(DS.Colors.cardBackground.opacity(isPrimary ? 0.86 : 0.58))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(soundColor(for: type.urgencyLevel).opacity(isPrimary ? 0.38 : 0.16), lineWidth: 1)
                )
        )
        .shadow(color: soundColor(for: type.urgencyLevel).opacity(isPrimary ? 0.15 : 0.04), radius: isPrimary ? 10 : 4, x: 0, y: 4)
    }
    
    // MARK: - Event History
    private var eventHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Alerts")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(DS.Colors.textPrimary)
                Spacer()
                Button("Clear") {
                    withAnimation { manager.recentEvents.removeAll() }
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DS.Colors.accent)
            }
            .padding(.horizontal, 20)
            
            ForEach(manager.recentEvents.prefix(10)) { event in
                eventRow(event)
            }
        }
    }
    
    private func eventRow(_ event: SoundEvent) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(soundColor(for: event.type.urgencyLevel).opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(event.type.emoji)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(event.type.displayName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(DS.Colors.textPrimary)
                Text(event.type.alertMessage)
                    .font(.system(size: 12))
                    .foregroundColor(DS.Colors.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(event.timeAgo)
                    .font(.system(size: 11))
                    .foregroundColor(DS.Colors.textTertiary)
                Text("\(Int(event.confidence * 100))%")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(soundColor(for: event.type.urgencyLevel))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(DS.Colors.cardBackground)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helpers
    private var urgencyColor: Color {
        switch manager.dominantSound?.urgencyLevel {
        case .critical: return .red
        case .important: return .orange
        default: return DS.Colors.accent
        }
    }
    
    private func soundColor(for level: UrgencyLevel) -> Color {
        switch level {
        case .critical: return .red
        case .important: return .orange
        case .normal: return DS.Colors.accent
        }
    }
}

#Preview {
    SoundDetectionView()
}

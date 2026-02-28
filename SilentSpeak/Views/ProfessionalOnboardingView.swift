import SwiftUI

struct ProfessionalOnboardingView: View {
    @State private var currentPage = 0
    @State private var animateContent = false
    @State private var showPermissions = false
    let onComplete: () -> Void
    
    let totalPages = 7
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientView(colors: [
                DS.Colors.backgroundPrimary,
                DS.Colors.backgroundSecondary,
                DS.Colors.accent.opacity(0.1)
            ])
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(DS.Colors.accent.opacity(0.2))
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(DS.Colors.accentGradient)
                            .frame(width: geometry.size.width * CGFloat(currentPage + 1) / CGFloat(totalPages), height: 4)
                            .animation(DS.Animation.smooth, value: currentPage)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, DS.Spacing.xxl)
                .padding(.top, DS.Spacing.lg)
                
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < totalPages - 1 {
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            withAnimation(DS.Animation.smooth) {
                                currentPage = totalPages - 1
                            }
                        }) {
                            Text("Skip")
                                .font(DS.Typography.subheadline())
                                .foregroundColor(DS.Colors.textTertiary)
                                .padding(.horizontal, DS.Spacing.lg)
                                .padding(.vertical, DS.Spacing.sm)
                        }
                        .buttonStyle(BouncyPressStyle())
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, DS.Spacing.xl)
                .frame(height: 44)
                
                // Page content
                TabView(selection: $currentPage) {
                    WelcomePagePro()
                        .tag(0)
                    
                    FeatureHighlightPage(
                        icon: "hands.sparkles.fill",
                        title: "ASL to Speech",
                        subtitle: "Real-time Translation",
                        description: "Sign naturally and watch your gestures transform into spoken words instantly. Our advanced AI recognizes 26 letters and 10 numbers with 95% accuracy.",
                        color: DS.Colors.accent
                    )
                    .tag(1)
                    
                    FeatureHighlightPage(
                        icon: "waveform.badge.mic",
                        title: "Speech to ASL",
                        subtitle: "Visual Communication",
                        description: "Speak clearly and see your words displayed as ASL signs. Perfect for learning or communicating with deaf individuals.",
                        color: Color(red: 0.3, green: 0.7, blue: 0.45)
                    )
                    .tag(2)
                    
                    FeatureHighlightPage(
                        icon: "waveform.badge.exclamationmark",
                        title: "Sound Detection",
                        subtitle: "Stay Aware",
                        description: "Get instant visual alerts for 100+ important sounds including doorbells, alarms, sirens, and more. Never miss what matters.",
                        color: Color(red: 1.0, green: 0.7, blue: 0)
                    )
                    .tag(3)
                    
                    FeatureHighlightPage(
                        icon: "bubble.left.and.bubble.right.fill",
                        title: "Conversation Mode",
                        subtitle: "Seamless Dialogue",
                        description: "Switch effortlessly between ASL and speech in real-time conversations. Save and review your conversations anytime.",
                        color: Color(red: 0.4, green: 0.6, blue: 1.0)
                    )
                    .tag(4)
                    
                    InteractiveGuidePage()
                        .tag(5)
                    
                    PermissionsPage(onComplete: onComplete)
                        .tag(6)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(DS.Animation.smooth, value: currentPage)
                
                // Navigation
                HStack(spacing: DS.Spacing.lg) {
                    // Back button
                    if currentPage > 0 {
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            withAnimation(DS.Animation.smooth) {
                                currentPage -= 1
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Back")
                                    .font(DS.Typography.subheadline())
                            }
                            .foregroundColor(DS.Colors.textSecondary)
                            .padding(.horizontal, DS.Spacing.xl)
                            .padding(.vertical, DS.Spacing.md)
                        }
                        .buttonStyle(BouncyPressStyle())
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                    }
                    
                    Spacer()
                    
                    // Page dots
                    HStack(spacing: DS.Spacing.sm) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? DS.Colors.accent : DS.Colors.accent.opacity(0.2))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(DS.Animation.quick, value: currentPage)
                        }
                    }
                    
                    Spacer()
                    
                    // Next button
                    if currentPage < totalPages - 1 {
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            withAnimation(DS.Animation.smooth) {
                                currentPage += 1
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text("Next")
                                    .font(DS.Typography.subheadline())
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, DS.Spacing.xl)
                            .padding(.vertical, DS.Spacing.md)
                            .background(
                                Capsule().fill(DS.Colors.elevatedGradient)
                            )
                        }
                        .buttonStyle(GlowButtonStyle(primaryColor: DS.Colors.accent))
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }
                .padding(.horizontal, DS.Spacing.xxl)
                .padding(.bottom, DS.Spacing.xxxl)
                .frame(height: 80)
            }
        }
        .onAppear {
            withAnimation(DS.Animation.gentle.delay(0.3)) {
                animateContent = true
            }
        }
    }
}

// MARK: - Welcome Page Pro
struct WelcomePagePro: View {
    @State private var animateHand = false
    @State private var animateTitle = false
    @State private var animateSubtitle = false
    
    var body: some View {
        VStack(spacing: DS.Spacing.xxxl) {
            Spacer()
            
            // Animated hand icon
            ZStack {
                // Outer glow
                Circle()
                    .fill(DS.Colors.accent.opacity(0.05))
                    .frame(width: 220, height: 220)
                    .scaleEffect(animateHand ? 1.1 : 0.9)
                    .opacity(animateHand ? 0.5 : 0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateHand)
                
                // Middle glow
                Circle()
                    .fill(DS.Colors.accent.opacity(0.1))
                    .frame(width: 160, height: 160)
                    .scaleEffect(animateHand ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateHand)
                
                // Icon
                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 80, weight: .light))
                    .foregroundStyle(DS.Colors.accentGradient)
                    .rotationEffect(.degrees(animateHand ? 5 : -5))
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateHand)
            }
            .offset(y: animateTitle ? 0 : -30)
            .opacity(animateTitle ? 1 : 0)
            
            VStack(spacing: DS.Spacing.lg) {
                Text("Welcome to")
                    .font(DS.Typography.title3())
                    .foregroundColor(DS.Colors.textTertiary)
                    .offset(y: animateTitle ? 0 : 20)
                    .opacity(animateTitle ? 1 : 0)
                
                Text("SilentSpeak")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Colors.accentGradient)
                    .offset(y: animateTitle ? 0 : 20)
                    .opacity(animateTitle ? 1 : 0)
                
                Text("Breaking barriers through\nthe power of communication")
                    .font(DS.Typography.title3())
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .offset(y: animateSubtitle ? 0 : 20)
                    .opacity(animateSubtitle ? 1 : 0)
            }
            .padding(.horizontal, DS.Spacing.xxl)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(DS.Animation.smooth.delay(0.2)) {
                animateTitle = true
            }
            withAnimation(DS.Animation.smooth.delay(0.4)) {
                animateSubtitle = true
            }
            withAnimation(DS.Animation.smooth.delay(0.6)) {
                animateHand = true
            }
        }
    }
}

// MARK: - Feature Highlight Page
struct FeatureHighlightPage: View {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let color: Color
    
    @State private var animateIcon = false
    @State private var animateContent = false
    
    var body: some View {
        VStack(spacing: DS.Spacing.xxxl) {
            Spacer()
            
            // Icon with animation
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 160, height: 160)
                    .scaleEffect(animateIcon ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateIcon)
                
                Image(systemName: icon)
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(color)
                    .rotationEffect(.degrees(animateIcon ? 3 : -3))
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: animateIcon)
            }
            .offset(y: animateContent ? 0 : -20)
            .opacity(animateContent ? 1 : 0)
            
            VStack(spacing: DS.Spacing.md) {
                Text(title)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(DS.Colors.textPrimary)
                    .offset(y: animateContent ? 0 : 20)
                    .opacity(animateContent ? 1 : 0)
                
                Text(subtitle)
                    .font(DS.Typography.title3())
                    .foregroundColor(color)
                    .offset(y: animateContent ? 0 : 20)
                    .opacity(animateContent ? 1 : 0)
                
                Text(description)
                    .font(DS.Typography.body())
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, DS.Spacing.xxl)
                    .padding(.top, DS.Spacing.sm)
                    .offset(y: animateContent ? 0 : 20)
                    .opacity(animateContent ? 1 : 0)
            }
            
            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(DS.Animation.smooth.delay(0.2)) {
                animateContent = true
            }
            withAnimation(DS.Animation.smooth.delay(0.4)) {
                animateIcon = true
            }
        }
    }
}

// MARK: - Permissions Page
struct PermissionsPage: View {
    let onComplete: () -> Void
    
    @State private var cameraGranted = false
    @State private var micGranted = false
    @State private var notificationsGranted = false
    @State private var animateContent = false
    
    var allGranted: Bool {
        cameraGranted && micGranted && notificationsGranted
    }
    
    var body: some View {
        VStack(spacing: DS.Spacing.xxxl) {
            Spacer()
            
            VStack(spacing: DS.Spacing.lg) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(DS.Colors.accentGradient)
                    .offset(y: animateContent ? 0 : -20)
                    .opacity(animateContent ? 1 : 0)
                
                Text("Permissions")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(DS.Colors.textPrimary)
                    .offset(y: animateContent ? 0 : 20)
                    .opacity(animateContent ? 1 : 0)
                
                Text("We need a few permissions to provide\nthe best experience")
                    .font(DS.Typography.body())
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .offset(y: animateContent ? 0 : 20)
                    .opacity(animateContent ? 1 : 0)
            }
            
            VStack(spacing: DS.Spacing.lg) {
                PermissionRow(
                    icon: "camera.fill",
                    title: "Camera",
                    description: "To recognize ASL gestures",
                    isGranted: $cameraGranted
                )
                .staggeredAppear(index: 0, isVisible: animateContent)
                
                PermissionRow(
                    icon: "mic.fill",
                    title: "Microphone",
                    description: "For speech recognition and sound detection",
                    isGranted: $micGranted
                )
                .staggeredAppear(index: 1, isVisible: animateContent)
                
                PermissionRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    description: "To alert you of important sounds",
                    isGranted: $notificationsGranted
                )
                .staggeredAppear(index: 2, isVisible: animateContent)
            }
            .padding(.horizontal, DS.Spacing.xxl)
            
            Button(action: {
                HapticManager.shared.success()
                onComplete()
            }) {
                HStack(spacing: DS.Spacing.sm) {
                    Text(allGranted ? "Get Started" : "Continue")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, DS.Spacing.xxxl)
                .padding(.vertical, DS.Spacing.lg)
                .background(
                    Capsule().fill(DS.Colors.elevatedGradient)
                )
            }
            .buttonStyle(GlowButtonStyle(primaryColor: DS.Colors.accent))
            .offset(y: animateContent ? 0 : 20)
            .opacity(animateContent ? 1 : 0)
            
            Spacer()
        }
        .onAppear {
            withAnimation(DS.Animation.smooth.delay(0.2)) {
                animateContent = true
            }
        }
    }
}

// MARK: - Permission Row
struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isGranted: Bool
    
    var body: some View {
        HStack(spacing: DS.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(isGranted ? Color.green.opacity(0.15) : DS.Colors.accent.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: isGranted ? "checkmark" : icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isGranted ? .green : DS.Colors.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DS.Typography.headline())
                    .foregroundColor(DS.Colors.textPrimary)
                
                Text(description)
                    .font(DS.Typography.caption())
                    .foregroundColor(DS.Colors.textTertiary)
            }
            
            Spacer()
            
            if !isGranted {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    requestPermission()
                }) {
                    Text("Allow")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, DS.Spacing.lg)
                        .padding(.vertical, DS.Spacing.sm)
                        .background(
                            Capsule().fill(DS.Colors.accent)
                        )
                }
                .buttonStyle(BouncyPressStyle())
            }
        }
        .padding(DS.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .light)
        )
    }
    
    private func requestPermission() {
        // Simulate permission request
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(DS.Animation.smooth) {
                isGranted = true
            }
            HapticManager.shared.success()
        }
    }
}

// MARK: - Interactive Guide Page
struct InteractiveGuidePage: View {
    @State private var animateContent = false
    @State private var selectedFeature: Int? = nil
    
    struct FeatureGuide: Identifiable {
        let id: Int
        let icon: String
        let title: String
        let description: String
        let color: Color
    }
    
    let features: [FeatureGuide] = [
        FeatureGuide(
            id: 0,
            icon: "hand.raised.fill",
            title: "Camera View",
            description: "Shows your hand gestures in real-time. Position your hand clearly in frame for best recognition.",
            color: Color(red: 0.3, green: 0.7, blue: 0.45)
        ),
        FeatureGuide(
            id: 1,
            icon: "sparkles",
            title: "Predictions Panel",
            description: "Displays top 5 gesture predictions with confidence scores. Tap any prediction to select it.",
            color: Color(red: 0.82, green: 0.53, blue: 0.43)
        ),
        FeatureGuide(
            id: 2,
            icon: "mic.fill",
            title: "Microphone Button",
            description: "Tap to start/stop speech recognition. Your spoken words will appear as text and ASL signs.",
            color: Color(red: 0.4, green: 0.6, blue: 1.0)
        ),
        FeatureGuide(
            id: 3,
            icon: "arrow.left.arrow.right",
            title: "Switch Button",
            description: "Toggle between deaf user mode, hearing user mode, or both panels active simultaneously.",
            color: Color(red: 1.0, green: 0.7, blue: 0)
        ),
        FeatureGuide(
            id: 4,
            icon: "waveform.badge.exclamationmark",
            title: "Sound Detection",
            description: "Get visual alerts for 100+ important sounds like doorbells, alarms, and emergency sirens.",
            color: Color(red: 1.0, green: 0.4, blue: 0.4)
        ),
        FeatureGuide(
            id: 5,
            icon: "bubble.left.and.bubble.right",
            title: "Conversations",
            description: "All your conversations are automatically saved. Access them anytime from the home screen.",
            color: Color(red: 0.6, green: 0.4, blue: 0.8)
        )
    ]
    
    var body: some View {
        VStack(spacing: DS.Spacing.xxxl) {
            Spacer()
            
            VStack(spacing: DS.Spacing.lg) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .offset(y: animateContent ? 0 : -20)
                    .opacity(animateContent ? 1 : 0)
                
                Text("Interactive Guide")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(DS.Colors.textPrimary)
                    .offset(y: animateContent ? 0 : 20)
                    .opacity(animateContent ? 1 : 0)
                
                Text("Tap any feature to learn what it does")
                    .font(DS.Typography.body())
                    .foregroundColor(DS.Colors.textSecondary)
                    .offset(y: animateContent ? 0 : 20)
                    .opacity(animateContent ? 1 : 0)
            }
            
            ScrollView {
                VStack(spacing: DS.Spacing.md) {
                    ForEach(features) { feature in
                        FeatureGuideCard(
                            feature: feature,
                            isSelected: selectedFeature == feature.id,
                            onTap: {
                                HapticManager.shared.lightImpact()
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    selectedFeature = selectedFeature == feature.id ? nil : feature.id
                                }
                            }
                        )
                        .staggeredAppear(index: feature.id, isVisible: animateContent)
                    }
                }
                .padding(.horizontal, DS.Spacing.xxl)
            }
            .frame(maxHeight: 400)
            
            Spacer()
        }
        .onAppear {
            withAnimation(DS.Animation.smooth.delay(0.2)) {
                animateContent = true
            }
        }
    }
}

// MARK: - Feature Guide Card
struct FeatureGuideCard: View {
    let feature: InteractiveGuidePage.FeatureGuide
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                HStack(spacing: DS.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(feature.color.opacity(0.15))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: feature.icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(feature.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(feature.title)
                            .font(DS.Typography.headline())
                            .foregroundColor(DS.Colors.textPrimary)
                        
                        if !isSelected {
                            Text("Tap to learn more")
                                .font(DS.Typography.caption())
                                .foregroundColor(DS.Colors.textTertiary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DS.Colors.textTertiary)
                        .rotationEffect(.degrees(isSelected ? 180 : 0))
                }
                
                if isSelected {
                    Text(feature.description)
                        .font(DS.Typography.body())
                        .foregroundColor(DS.Colors.textSecondary)
                        .lineSpacing(4)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
            .padding(DS.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .light)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                            .stroke(isSelected ? feature.color.opacity(0.4) : Color.clear, lineWidth: 2)
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(BouncyPressStyle())
    }
}

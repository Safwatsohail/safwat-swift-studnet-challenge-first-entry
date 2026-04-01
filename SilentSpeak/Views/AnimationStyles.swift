import SwiftUI


// MARK: - Glow Button Style
struct GlowButtonStyle: ButtonStyle {
    let primaryColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(
                color: primaryColor.opacity(configuration.isPressed ? 0.8 : 0.4),
                radius: configuration.isPressed ? 25 : 15,
                x: 0,
                y: configuration.isPressed ? 12 : 8
            )
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Shimmer Effect Modifier
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    var duration: Double = 2.5
    var shimmerColor: Color = .white
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            shimmerColor.opacity(0),
                            shimmerColor.opacity(0.3),
                            shimmerColor.opacity(0),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: -geo.size.width * 0.3 + phase * (geo.size.width * 1.6))
                    .mask(content)
                }
            )
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Glow Pulse Modifier
struct GlowPulse: ViewModifier {
    @State private var isGlowing = false
    var color: Color = Color(red: 0.82, green: 0.53, blue: 0.43)
    var radius: CGFloat = 15
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: color.opacity(isGlowing ? 0.6 : 0.15),
                radius: isGlowing ? radius * 1.5 : radius * 0.5,
                x: 0,
                y: isGlowing ? 8 : 4
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    isGlowing = true
                }
            }
    }
}

// MARK: - Breathing Scale Modifier
struct BreathingScale: ViewModifier {
    @State private var isBreathing = false
    var minScale: CGFloat = 0.97
    var maxScale: CGFloat = 1.03
    var duration: Double = 2.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isBreathing ? maxScale : minScale)
            .animation(.easeInOut(duration: duration).repeatForever(autoreverses: true), value: isBreathing)
            .onAppear {
                isBreathing = true
            }
    }
}

// MARK: - Float Animation Modifier
struct FloatingAnimation: ViewModifier {
    @State private var isFloating = false
    var offset: CGFloat = 6
    var duration: Double = 2.5
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -offset : offset)
            .animation(.easeInOut(duration: duration).repeatForever(autoreverses: true), value: isFloating)
            .onAppear {
                isFloating = true
            }
    }
}

// MARK: - Typewriter Effect
struct TypewriterText: View {
    let fullText: String
    @State private var displayedText = ""
    @State private var currentIndex = 0
    var speed: Double = 0.05
    var onComplete: (() -> Void)?
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                startTyping()
            }
    }
    
    private func startTyping() {
        displayedText = ""
        currentIndex = 0
        typeNextCharacter()
    }
    
    private func typeNextCharacter() {
        guard currentIndex < fullText.count else {
            onComplete?()
            return
        }
        let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + speed) {
            displayedText += String(fullText[index])
            currentIndex += 1
            typeNextCharacter()
        }
    }
}

// MARK: - Particle System
struct ParticleView: View {
    @State private var particles: [Particle] = []
    var color: Color = Color(red: 0.82, green: 0.53, blue: 0.43)
    var count: Int = 20
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var speed: Double
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(color.opacity(particle.opacity))
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                        .blur(radius: particle.size * 0.3)
                }
            }
            .onAppear {
                generateParticles(in: geo.size)
            }
        }
    }
    
    private func generateParticles(in size: CGSize) {
        particles = (0..<count).map { _ in
            Particle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 4...20),
                opacity: Double.random(in: 0.05...0.2),
                speed: Double.random(in: 1.5...4)
            )
        }
        animateParticles(in: size)
    }
    
    private func animateParticles(in size: CGSize) {
        for i in particles.indices {
            let duration = particles[i].speed
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                particles[i].x = CGFloat.random(in: 0...size.width)
                particles[i].y = CGFloat.random(in: 0...size.height)
            }
        }
    }
}

// MARK: - Card Tap Overlay (shows ripple on tap)
struct TapRippleOverlay: ViewModifier {
    @State private var tapLocation: CGPoint = .zero
    @State private var showRipple = false
    var color: Color = Color(red: 0.82, green: 0.53, blue: 0.43)
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    if showRipple {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: showRipple ? 200 : 0, height: showRipple ? 200 : 0)
                            .position(tapLocation)
                            .opacity(showRipple ? 0 : 0.5)
                            .animation(.easeOut(duration: 0.6), value: showRipple)
                    }
                }
                .clipped()
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        tapLocation = value.location
                        showRipple = true
                    }
                    .onEnded { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showRipple = false
                        }
                    }
            )
    }
}

// MARK: - Floating Particles (Peaceful Background Animation)
struct FloatingParticles: View {
    @State private var particles: [FloatingParticle] = []
    
    struct FloatingParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var duration: Double
        var delay: Double
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.88, green: 0.68, blue: 0.58).opacity(particle.opacity),
                                    Color(red: 0.78, green: 0.48, blue: 0.32).opacity(particle.opacity * 0.5)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: particle.size / 2
                            )
                        )
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                        .blur(radius: particle.size * 0.4)
                }
            }
            .onAppear {
                generateParticles(in: geo.size)
                animateParticles(in: geo.size)
            }
        }
    }
    
    private func generateParticles(in size: CGSize) {
        particles = (0..<15).map { i in
            FloatingParticle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 30...80),
                opacity: Double.random(in: 0.08...0.18),
                duration: Double.random(in: 8...15),
                delay: Double(i) * 0.3
            )
        }
    }
    
    private func animateParticles(in size: CGSize) {
        for i in particles.indices {
            let particle = particles[i]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + particle.delay) {
                withAnimation(
                    .easeInOut(duration: particle.duration)
                    .repeatForever(autoreverses: true)
                ) {
                    particles[i].x = CGFloat.random(in: -50...size.width + 50)
                    particles[i].y = CGFloat.random(in: -50...size.height + 50)
                    particles[i].opacity = Double.random(in: 0.05...0.15)
                }
            }
        }
    }
}

// MARK: - Crazy Animated Background (Morphing Blobs)
struct MorphingBlobsBackground: View {
    @State private var blob1Offset: CGSize = .zero
    @State private var blob2Offset: CGSize = .zero
    @State private var blob3Offset: CGSize = .zero
    @State private var blob1Scale: CGFloat = 1.0
    @State private var blob2Scale: CGFloat = 1.0
    @State private var blob3Scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Blob 1 - Purple/Pink
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.8, green: 0.4, blue: 0.9).opacity(0.4),
                                Color(red: 0.6, green: 0.2, blue: 0.8).opacity(0.2)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 300, height: 300)
                    .scaleEffect(blob1Scale)
                    .offset(blob1Offset)
                    .blur(radius: 40)
                    .position(x: geo.size.width * 0.3, y: geo.size.height * 0.2)
                
                // Blob 2 - Orange/Peach
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.6, blue: 0.3).opacity(0.5),
                                Color(red: 0.9, green: 0.4, blue: 0.2).opacity(0.3)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 250
                        )
                    )
                    .frame(width: 350, height: 350)
                    .scaleEffect(blob2Scale)
                    .offset(blob2Offset)
                    .blur(radius: 50)
                    .position(x: geo.size.width * 0.7, y: geo.size.height * 0.5)
                
                // Blob 3 - Blue/Cyan
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.3, green: 0.7, blue: 1.0).opacity(0.4),
                                Color(red: 0.2, green: 0.5, blue: 0.9).opacity(0.2)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 220
                        )
                    )
                    .frame(width: 320, height: 320)
                    .scaleEffect(blob3Scale)
                    .offset(blob3Offset)
                    .blur(radius: 45)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.7)
                
                // Rotating gradient overlay
                Rectangle()
                    .fill(
                        AngularGradient(
                            colors: [
                                Color.clear,
                                Color(red: 0.9, green: 0.5, blue: 0.4).opacity(0.1),
                                Color.clear,
                                Color(red: 0.5, green: 0.3, blue: 0.8).opacity(0.1),
                                Color.clear
                            ],
                            center: .center
                        )
                    )
                    .rotationEffect(.degrees(rotation))
                    .blur(radius: 30)
            }
            .onAppear {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        // Blob 1 animations
        withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
            blob1Offset = CGSize(width: 80, height: -60)
            blob1Scale = 1.3
        }
        
        // Blob 2 animations (different timing)
        withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
            blob2Offset = CGSize(width: -70, height: 90)
            blob2Scale = 1.4
        }
        
        // Blob 3 animations
        withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
            blob3Offset = CGSize(width: 60, height: -80)
            blob3Scale = 1.2
        }
        
        // Rotation animation
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
}

// MARK: - Extensions
extension View {
    func shimmer(duration: Double = 2.5, color: Color = .white) -> some View {
        modifier(ShimmerEffect(duration: duration, shimmerColor: color))
    }
    
    func glowPulse(color: Color = Color(red: 0.82, green: 0.53, blue: 0.43), radius: CGFloat = 15) -> some View {
        modifier(GlowPulse(color: color, radius: radius))
    }
    
    func tapRipple(color: Color = Color(red: 0.82, green: 0.53, blue: 0.43)) -> some View {
        modifier(TapRippleOverlay(color: color))
    }
    
    func animatedPress(scale: CGFloat = 0.95, glow: Color = Color(red: 0.82, green: 0.53, blue: 0.43)) -> some View {
        self.buttonStyle(AnimatedPressStyle(scaleAmount: scale, glowColor: glow))
    }
    
    func staggeredAppear(index: Int, isVisible: Bool) -> some View {
        self
            .offset(y: isVisible ? 0 : 30)
            .opacity(isVisible ? 1 : 0)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.7)
                .delay(Double(index) * 0.07),
                value: isVisible
            )
    }
    
    func floatingAnimation(offset: CGFloat, duration: Double) -> some View {
        modifier(FloatingAnimation(offset: offset, duration: duration))
    }
    
    func breathingScale(min: CGFloat, max: CGFloat, duration: Double) -> some View {
        modifier(BreathingScale(minScale: min, maxScale: max, duration: duration))
    }
}
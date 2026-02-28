import SwiftUI

struct SplashScreen: View {
    @State private var logoScale: CGFloat  = 0.3
    @State private var logoOpacity: Double = 0
    @State private var ring1Scale: CGFloat = 0.4
    @State private var ring2Scale: CGFloat = 0.2
    @State private var ring3Scale: CGFloat = 0.1
    @State private var titleOffset: CGFloat = 32
    @State private var titleOpacity: Double = 0
    @State private var tagOpacity: Double   = 0
    @State private var pillOpacity: Double  = 0
    @State private var exitScale: CGFloat   = 1.0
    @State private var exitOpacity: Double  = 1.0
    @State private var handFloat: CGFloat   = 0
    @State private var handRotate: Double   = 0

    // Color palette — warm peach/rose matching the app
    private let bgTop    = Color(red: 0.97, green: 0.93, blue: 0.89)
    private let bgBottom = Color(red: 0.93, green: 0.83, blue: 0.76)
    private let primary  = Color(red: 0.72, green: 0.40, blue: 0.26)
    private let soft     = Color(red: 0.88, green: 0.67, blue: 0.55)

    let onFinished: () -> Void

    var body: some View {
        ZStack {
            // — Background —
            WavyBackground(color1: bgTop, color2: bgBottom, color3: soft)
                .ignoresSafeArea()

            FloatingOrbs(color: soft)
                .ignoresSafeArea()
                .opacity(0.45)

            VStack(spacing: 0) {
                Spacer()

                // — Logo stack —
                ZStack {
                    // Outer glow ring 3
                    Circle()
                        .fill(
                            RadialGradient(colors: [soft.opacity(0.08), .clear],
                                           center: .center, startRadius: 60, endRadius: 160)
                        )
                        .frame(width: 320, height: 320)
                        .scaleEffect(ring3Scale)
                        .opacity(ring3Scale > 0.3 ? 1 : 0)

                    // Outer ring 2
                    Circle()
                        .strokeBorder(soft.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 240, height: 240)
                        .scaleEffect(ring2Scale)
                        .opacity(ring2Scale > 0.3 ? 1 : 0)

                    // Inner ring 1
                    Circle()
                        .strokeBorder(primary.opacity(0.25), lineWidth: 2)
                        .frame(width: 170, height: 170)
                        .scaleEffect(ring1Scale)
                        .opacity(ring1Scale > 0.3 ? 1 : 0)

                    // Main circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [primary, soft, Color(red: 0.90, green: 0.70, blue: 0.58)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 128, height: 128)
                        .shadow(color: primary.opacity(0.35), radius: 28, x: 0, y: 12)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)

                    // Icon inside circle
                    VStack(spacing: 6) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                            .offset(y: handFloat)
                            .rotationEffect(.degrees(handRotate))

                        Image(systemName: "waveform")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                }

                Spacer().frame(height: 44)

                // — App Name —
                Text("SilentSpeak")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [primary, soft],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                Spacer().frame(height: 10)

                // — Tagline —
                Text("Empowering Every Voice")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(primary.opacity(0.72))
                    .opacity(tagOpacity)
                    .offset(y: titleOffset * 0.6)

                Spacer().frame(height: 48)

                // — Feature pills —
                HStack(spacing: 16) {
                    featurePill(icon: "hand.raised.fill",   label: "Sign Language")
                    featurePill(icon: "waveform.badge.mic", label: "Speech")
                    featurePill(icon: "ear.fill",           label: "Sound Alert")
                }
                .opacity(pillOpacity)

                Spacer()
            }
        }
        .scaleEffect(exitScale)
        .opacity(exitOpacity)
        .onAppear { runAnimation() }
    }

    // MARK: - Feature Pill
    private func featurePill(icon: String, label: String) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(primary.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(primary)
            }
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(primary.opacity(0.75))
        }
    }

    // MARK: - Animation sequence
    private func runAnimation() {
        // Logo pops in
        withAnimation(.spring(response: 0.75, dampingFraction: 0.62)) {
            logoScale   = 1.0
            logoOpacity = 1.0
        }

        // Rings expand
        withAnimation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.08)) {
            ring1Scale = 1.0
        }
        withAnimation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.16)) {
            ring2Scale = 1.0
        }
        withAnimation(.spring(response: 1.2, dampingFraction: 0.55).delay(0.24)) {
            ring3Scale = 1.0
        }

        // Hand floats
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.5)) {
            handFloat  = -8
            handRotate = 6
        }

        // Title slides up
        withAnimation(.spring(response: 0.7, dampingFraction: 0.78).delay(0.45)) {
            titleOffset  = 0
            titleOpacity = 1.0
        }

        // Tagline
        withAnimation(.easeOut(duration: 0.6).delay(0.75)) {
            tagOpacity = 1.0
        }

        // Pills
        withAnimation(.spring(response: 0.7, dampingFraction: 0.72).delay(1.0)) {
            pillOpacity = 1.0
        }

        // Auto-dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeInOut(duration: 0.55)) {
                exitScale   = 1.06
                exitOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                onFinished()
            }
        }
    }
}

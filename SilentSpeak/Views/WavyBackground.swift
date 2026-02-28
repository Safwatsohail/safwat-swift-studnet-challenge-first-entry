import SwiftUI

// MARK: - Wavy Animated Background
struct WavyBackground: View {
    let color1: Color
    let color2: Color
    let color3: Color
    @State private var phase1: CGFloat = 0
    @State private var phase2: CGFloat = 0
    @State private var phase3: CGFloat = 0
    @State private var shift: CGFloat = 0

    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [color1, color2],
                startPoint: UnitPoint(x: 0.3 + sin(shift) * 0.2, y: 0),
                endPoint: UnitPoint(x: 0.7 + cos(shift * 0.7) * 0.2, y: 1)
            )
            .ignoresSafeArea()
            .animation(.linear(duration: 6).repeatForever(autoreverses: true), value: shift)

            // Wave 1 – slow, wide
            WaveShape(phase: phase1, amplitude: 32, frequency: 1.1)
                .fill(color3.opacity(0.18))
                .ignoresSafeArea()

            // Wave 2 – medium
            WaveShape(phase: phase2, amplitude: 22, frequency: 1.5)
                .fill(color3.opacity(0.12))
                .ignoresSafeArea()

            // Wave 3 – fast, narrow
            WaveShape(phase: phase3, amplitude: 14, frequency: 2.1)
                .fill(color3.opacity(0.09))
                .ignoresSafeArea()
        }
        .onAppear {
            // Start all wave animations
            withAnimation(.linear(duration: 7).repeatForever(autoreverses: false)) { phase1 = .pi * 2 }
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) { phase2 = .pi * 2 }
            withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) { phase3 = .pi * 2 }
            withAnimation(.linear(duration: 9).repeatForever(autoreverses: true)) { shift = .pi }
        }
    }
}

// MARK: - Wave Shape
struct WaveShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    var frequency: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midY = height * 0.52

        path.move(to: CGPoint(x: 0, y: midY))

        stride(from: 0, through: width, by: 1).forEach { x in
            let relX = x / width
            let sine = sin(relX * .pi * 2 * frequency + phase)
            let y = midY + sine * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        return path
    }
}

// MARK: - Floating Orbs (ambient round blobs)
struct FloatingOrbs: View {
    let color: Color
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.18), color.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80 + CGFloat(i) * 30
                        )
                    )
                    .frame(width: 160 + CGFloat(i) * 40, height: 160 + CGFloat(i) * 40)
                    .offset(
                        x: animate ? CGFloat.random(in: -120...120) : CGFloat.random(in: -80...80),
                        y: animate ? CGFloat.random(in: -200...200) : CGFloat.random(in: -150...150)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 6...12))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.8),
                        value: animate
                    )
                    .blendMode(.plusLighter)
            }
        }
        .onAppear { animate = true }
    }
}

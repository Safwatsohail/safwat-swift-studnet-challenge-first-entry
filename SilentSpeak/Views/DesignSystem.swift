import SwiftUI

// MARK: - SilentSpeak Design System
// Unified design tokens following Apple HIG principles

struct DS {
    // MARK: - Colors
    struct Colors {
        // Primary palette
        static let backgroundPrimary = Color(red: 0.98, green: 0.93, blue: 0.88)
        static let backgroundSecondary = Color(red: 0.96, green: 0.88, blue: 0.82)
        
        // Accent colors
        static let accent = Color(red: 0.82, green: 0.53, blue: 0.43)
        static let accentDark = Color(red: 0.58, green: 0.35, blue: 0.28)
        static let accentLight = Color(red: 0.92, green: 0.72, blue: 0.63)
        
        // Surfaces
        static let cardBackground = Color.white.opacity(0.88)
        static let cardBackgroundElevated = Color.white.opacity(0.95)
        static let surfaceThin = Color.white.opacity(0.6)
        
        // Text
        static let textPrimary = Color(red: 0.2, green: 0.15, blue: 0.12)
        static let textSecondary = Color(red: 0.45, green: 0.38, blue: 0.34)
        static let textTertiary = Color(red: 0.6, green: 0.55, blue: 0.52)
        static let textOnAccent = Color.white
        
        // Semantic colors
        static let success = Color(red: 0.3, green: 0.7, blue: 0.45)
        static let danger = Color(red: 0.85, green: 0.3, blue: 0.3)
        static let info = Color(red: 0.3, green: 0.55, blue: 0.85)
        
        // Gradients
        static let accentGradient = LinearGradient(
            colors: [accentLight, accent, accentDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let elevatedGradient = LinearGradient(
            colors: [accent, accentDark],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let dangerGradient = LinearGradient(
            colors: [Color(red: 0.95, green: 0.4, blue: 0.4), danger],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let backgroundGradient = LinearGradient(
            colors: [backgroundPrimary, backgroundSecondary.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let subtleGradient = LinearGradient(
            colors: [backgroundPrimary, backgroundSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Typography
    struct Typography {
        static func largeTitle() -> Font { .system(size: 34, weight: .bold, design: .rounded) }
        static func title() -> Font { .system(size: 28, weight: .bold, design: .rounded) }
        static func title2() -> Font { .system(size: 22, weight: .bold, design: .rounded) }
        static func title3() -> Font { .system(size: 20, weight: .semibold, design: .rounded) }
        static func headline() -> Font { .system(size: 17, weight: .semibold, design: .rounded) }
        static func body() -> Font { .system(size: 17, weight: .regular, design: .rounded) }
        static func callout() -> Font { .system(size: 16, weight: .regular, design: .rounded) }
        static func subheadline() -> Font { .system(size: 15, weight: .regular, design: .rounded) }
        static func footnote() -> Font { .system(size: 13, weight: .regular, design: .rounded) }
        static func caption() -> Font { .system(size: 12, weight: .medium, design: .rounded) }
        static func caption2() -> Font { .system(size: 11, weight: .regular, design: .rounded) }
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }
    
    // MARK: - Radius (Enhanced for Polished UI)
    struct Radius {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 18
        static let lg: CGFloat = 24
        static let xl: CGFloat = 28
        static let xxl: CGFloat = 32
        static let pill: CGFloat = 1000
        static let circle: CGFloat = 50 // For perfectly rounded buttons
    }
    
    // MARK: - Shadows (Soft & Multi-layered)
    struct Shadows {
        // Soft shadows for peaceful UI
        static let softColor = Color.black.opacity(0.08)
        static let softerColor = Color.black.opacity(0.04)
        
        // Card shadows
        static let cardRadius: CGFloat = 16
        static let cardY: CGFloat = 6
        
        // Elevated shadows (multi-layer)
        static let elevatedRadius: CGFloat = 24
        static let elevatedY: CGFloat = 12
        
        // Button shadows
        static let buttonRadius: CGFloat = 12
        static let buttonY: CGFloat = 4
        
        // Floating shadows
        static let floatingRadius: CGFloat = 20
        static let floatingY: CGFloat = 8
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.75)
        static let smooth = SwiftUI.Animation.spring(response: 0.45, dampingFraction: 0.8)
        static let gentle = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.85)
        static let subtle = SwiftUI.Animation.easeInOut(duration: 0.25)
        
        static func staggered(index: Int) -> SwiftUI.Animation {
            .spring(response: 0.45, dampingFraction: 0.8).delay(Double(index) * 0.05)
        }
    }
}

// MARK: - Reusable Card Modifier (Enhanced)
struct DSCard: ViewModifier {
    var elevated: Bool = false
    var accentBorder: Bool = false
    var glass: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if glass {
                        RoundedRectangle(cornerRadius: DS.Radius.xl, style: .continuous)
                            .fill(.ultraThinMaterial)
                    } else {
                        RoundedRectangle(cornerRadius: DS.Radius.xl, style: .continuous)
                            .fill(elevated ? DS.Colors.cardBackgroundElevated : DS.Colors.cardBackground)
                    }
                }
                .shadow(
                    color: DS.Shadows.softerColor,
                    radius: elevated ? DS.Shadows.elevatedRadius * 0.6 : DS.Shadows.cardRadius * 0.6,
                    x: 0,
                    y: elevated ? DS.Shadows.elevatedY * 0.5 : DS.Shadows.cardY * 0.5
                )
                .shadow(
                    color: DS.Shadows.softColor,
                    radius: elevated ? DS.Shadows.elevatedRadius : DS.Shadows.cardRadius,
                    x: 0,
                    y: elevated ? DS.Shadows.elevatedY : DS.Shadows.cardY
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.xl, style: .continuous)
                    .stroke(accentBorder ? DS.Colors.accent.opacity(0.2) : Color.clear, lineWidth: 1.5)
            )
    }
}

// MARK: - Glassmorphism Modifier
struct DSGlass: ViewModifier {
    var radius: CGFloat = DS.Radius.xl
    var tint: Color = .white
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(tint.opacity(0.1))
                    )
            )
    }
}

// MARK: - Floating Button Modifier
struct DSFloatingButton: ViewModifier {
    var isPressed: Bool = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(
                color: DS.Shadows.softerColor,
                radius: isPressed ? DS.Shadows.buttonRadius * 0.5 : DS.Shadows.buttonRadius * 0.7,
                y: isPressed ? DS.Shadows.buttonY * 0.5 : DS.Shadows.buttonY * 0.7
            )
            .shadow(
                color: DS.Shadows.softColor,
                radius: isPressed ? DS.Shadows.buttonRadius * 0.8 : DS.Shadows.buttonRadius,
                y: isPressed ? DS.Shadows.buttonY * 0.8 : DS.Shadows.buttonY
            )
    }
}

// MARK: - Section Header
struct DSSectionHeader: View {
    let title: String
    let icon: String
    var color: Color = DS.Colors.textTertiary
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(color)
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .tracking(0.8)
            
            Rectangle()
                .fill(color.opacity(0.15))
                .frame(height: 0.5)
        }
        .padding(.horizontal, DS.Spacing.xxl + 4)
    }
}

// MARK: - View Extensions for Design System
extension View {
    func dsCard(elevated: Bool = false, accentBorder: Bool = false, glass: Bool = false) -> some View {
        modifier(DSCard(elevated: elevated, accentBorder: accentBorder, glass: glass))
    }
    
    func dsBackground() -> some View {
        self.background(DS.Colors.backgroundGradient.ignoresSafeArea())
    }
    
    func dsGlass(radius: CGFloat = DS.Radius.xl, tint: Color = .white) -> some View {
        modifier(DSGlass(radius: radius, tint: tint))
    }
    
    func dsFloatingButton(isPressed: Bool = false) -> some View {
        modifier(DSFloatingButton(isPressed: isPressed))
    }
}
// MARK: - Button Styles
struct BouncyPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AnimatedPressStyle: ButtonStyle {
    let scaleAmount: CGFloat
    let glowColor: Color
    
    init(scaleAmount: CGFloat = 0.95, glowColor: Color = .blue) {
        self.scaleAmount = scaleAmount
        self.glowColor = glowColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .shadow(color: configuration.isPressed ? glowColor.opacity(0.3) : Color.clear, radius: 8)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
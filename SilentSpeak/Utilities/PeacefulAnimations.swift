//
//  PeacefulAnimations.swift
//  SilentSpeak
//
//  Peaceful animation utilities for a calm user experience
//

import SwiftUI

// MARK: - Peaceful Animation Modifiers

struct FloatingModifier: ViewModifier {
    @State private var isFloating = false
    let offset: CGFloat
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -offset : offset)
            .animation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: true),
                value: isFloating
            )
            .onAppear {
                isFloating = true
            }
    }
}
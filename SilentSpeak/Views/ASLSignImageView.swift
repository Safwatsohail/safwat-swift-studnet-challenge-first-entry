//
//  ASLSignImageView.swift
//  SilentSpeak
//
//  Displays ASL hand sign images from URLs
//

import SwiftUI

struct ASLSignImageView: View {
    let sign: ASLSignImage
    let size: CGFloat
    
    @State private var isLoading = true
    @State private var loadError = false
    
    init(sign: ASLSignImage, size: CGFloat = 60) {
        self.sign = sign
        self.size = size
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Image container
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(DS.Colors.surfaceThin)
                    .frame(width: size, height: size)
                
                if sign.isLocal {
                    // Load local bundled image
                    Image(sign.imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.85, height: size * 0.85)
                } else if loadError {
                    // Error state - show letter/word as text
                    Text(sign.character)
                        .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                        .foregroundColor(DS.Colors.textSecondary)
                } else {
                    // Load image from URL
                    AsyncImage(url: URL(string: sign.imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .scaleEffect(0.7)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size * 0.85, height: size * 0.85)
                                .onAppear {
                                    isLoading = false
                                }
                        case .failure:
                            // Fallback to text
                            Text(sign.character)
                                .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                                .foregroundColor(DS.Colors.textSecondary)
                                .onAppear {
                                    loadError = true
                                    isLoading = false
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            
            // Label below image
            Text(sign.character)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(sign.isWord ? DS.Colors.accent : DS.Colors.textSecondary)
                .lineLimit(1)
                .frame(width: size)
        }
    }
}

// Horizontal scrollable row of ASL signs
struct ASLSignRow: View {
    let signs: [ASLSignImage]
    let signSize: CGFloat
    
    init(signs: [ASLSignImage], signSize: CGFloat = 60) {
        self.signs = signs
        self.signSize = signSize
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(signs) { sign in
                    ASLSignImageView(sign: sign, size: signSize)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

// Preview
struct ASLSignImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Single letter (URL)
            ASLSignImageView(
                sign: ASLSignImage(
                    character: "A",
                    imageUrl: "https://www.lifeprint.com/asl101/gifs/a/a.gif",
                    isWord: false,
                    isLocal: false
                ),
                size: 80
            )
            
            // Word (local)
            ASLSignImageView(
                sign: ASLSignImage(
                    character: "HELLO",
                    imageUrl: "ASL_HELLO",
                    isWord: true,
                    isLocal: true
                ),
                size: 80
            )
            
            // Row of signs
            ASLSignRow(
                signs: ASLTextConverter.convertToASL("HELLO I AM"),
                signSize: 70
            )
        }
        .padding()
        .background(Color.black)
    }
}

//
// ASLImageProvider.swift
// SilentSpeak - Professional ASL Image Loading System
//

import SwiftUI

/// Professional ASL image provider with local-first strategy
struct ASLImageProvider {
    
    // MARK: - Image Sources Priority
    
    /// Priority 1: Local bundled images (fastest, most reliable)
    static func localImageName(for gesture: String) -> String? {
        // Check if image exists in bundle
        let gestureName = gesture.uppercased()
        if Bundle.main.path(forResource: "ASL_\(gestureName)", ofType: "png") != nil ||
           Bundle.main.path(forResource: "ASL_\(gestureName)", ofType: "jpg") != nil ||
           Bundle.main.path(forResource: "ASL_\(gestureName)", ofType: "gif") != nil {
            return "ASL_\(gestureName)"
        }
        return nil
    }
    
    /// Priority 2: Handspeak.com (professional, educational use)
    static func handSpeakURL(for gesture: String) -> URL? {
        let gestureName = gesture.lowercased()
        // Handspeak uses format: https://www.handspeak.com/word/search/index.php?id=<word>
        // For letters: a-z, numbers: 0-10
        if gesture.count == 1 {
            if let asciiValue = gesture.uppercased().first?.asciiValue {
                // Letters A-Z
                if (65...90).contains(asciiValue) {
                    return URL(string: "https://www.handspeak.com/word/search/index.php?id=\(asciiValue - 64)")
                }
                // Numbers 0-9
                if (48...57).contains(asciiValue) {
                    return URL(string: "https://www.handspeak.com/word/search/index.php?id=\(asciiValue - 48 + 100)")
                }
            }
        }
        return nil
    }
    
    /// Priority 3: ASL University (Dr. Bill Vicars, free educational resource)
    static func aslUniversityURL(for gesture: String) -> URL? {
        let gestureName = gesture.lowercased()
        // Format: https://www.lifeprint.com/asl101/gifs/<letter>.gif
        if gesture.count == 1 {
            return URL(string: "https://www.lifeprint.com/asl101/gifs/\(gestureName).gif")
        } else {
            // Common words
            return URL(string: "https://www.lifeprint.com/asl101/gifs/\(gestureName).gif")
        }
    }
    
    /// Priority 4: Signing Savvy (reliable backup)
    static func signingavvyURL(for gesture: String) -> URL? {
        let gestureName = gesture.lowercased().addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? gesture
        return URL(string: "https://www.signingsavvy.com/media/words/\(gestureName)/\(gestureName).gif")
    }
    
    // MARK: - Image Loading Strategy
    
    /// Get the best available image URL for a gesture
    static func imageURL(for gesture: String) -> URL? {
        // Try local first (Priority 1)
        if let localName = localImageName(for: gesture) {
            // Return local file URL (will be handled by AsyncImage)
            if let path = Bundle.main.path(forResource: localName, ofType: "png") ??
                          Bundle.main.path(forResource: localName, ofType: "jpg") ??
                          Bundle.main.path(forResource: localName, ofType: "gif") {
                return URL(fileURLWithPath: path)
            }
        }
        
        // Fallback to online sources (Priority 2-4)
        return aslUniversityURL(for: gesture) ??
               signingavvyURL(for: gesture) ??
               handSpeakURL(for: gesture)
    }
    
    /// Check if gesture has a local bundled image
    static func hasLocalImage(for gesture: String) -> Bool {
        return localImageName(for: gesture) != nil
    }
    
    // MARK: - Image Caching
    
    private static var imageCache = NSCache<NSString, UIImage>()
    
    /// Load and cache image
    static func loadImage(for gesture: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = gesture.uppercased() as NSString
        
        // Check cache first
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }
        
        // Try to load from URL
        guard let url = imageURL(for: gesture) else {
            completion(nil)
            return
        }
        
        // Load image asynchronously
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Cache the image
            imageCache.setObject(image, forKey: cacheKey)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    /// Prefetch images for common gestures
    static func prefetchCommonGestures() {
        let commonGestures = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                             "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
                             "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
                             "HELLO", "THANK YOU", "PLEASE", "SORRY", "YES", "NO"]
        
        for gesture in commonGestures {
            loadImage(for: gesture) { _ in
                // Silently prefetch
            }
        }
    }
    
    // MARK: - Image Quality Validation
    
    /// Validate image quality (minimum size, aspect ratio)
    static func isValidImage(_ image: UIImage?) -> Bool {
        guard let image = image else { return false }
        
        let size = image.size
        let minDimension: CGFloat = 100
        let maxAspectRatio: CGFloat = 3.0
        
        // Check minimum size
        guard size.width >= minDimension && size.height >= minDimension else {
            return false
        }
        
        // Check aspect ratio (too wide or too tall = likely wrong image)
        let aspectRatio = max(size.width, size.height) / min(size.width, size.height)
        guard aspectRatio <= maxAspectRatio else {
            return false
        }
        
        return true
    }
}

// MARK: - SwiftUI View Extension

extension View {
    /// Load ASL image with fallback
    func loadASLImage(for gesture: String) -> some View {
        AsyncImage(url: ASLImageProvider.imageURL(for: gesture)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: 60, height: 60)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                // Fallback to text if image fails
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.gray.opacity(0.2))
                    Text(gesture)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                }
                .frame(width: 60, height: 60)
            @unknown default:
                EmptyView()
            }
        }
    }
}
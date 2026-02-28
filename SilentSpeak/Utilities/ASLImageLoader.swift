//
//  ASLImageLoader.swift
//  SilentSpeak
//
//  Simple ASL image loader
//

import SwiftUI
import UIKit

class ASLImageLoader {
    
    /// Load ASL image from the available image folders
    static func loadImage(for imageName: String) -> UIImage? {
        // Handle space character
        if imageName == "space" || imageName.isEmpty {
            return nil // Return nil for spaces, will be handled in UI
        }
        
        let cleanName = imageName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // PRIORITY 1: Try to load from your ASL_Gestures folder structure first
        if let image = loadFromASLGesturesFolder(cleanName) {
            return image
        }
        
        // PRIORITY 2: Fallback to bundle resources with different naming conventions
        let formattedName: String
        let upperName = cleanName.uppercased()
        
        if upperName.count == 1 && upperName.isLetter {
            // Single letter: A -> Letter_A (fallback naming)
            formattedName = "Letter_\(upperName)"
        } else if upperName.count == 1 && upperName.isNumber {
            // Single number: 1 -> Number_1 (fallback naming)
            formattedName = "Number_\(upperName)"
        } else if upperName == "10" {
            formattedName = "Number_10"
        } else {
            // Check if it's a word or ASL sign
            if ["AND", "ANGRY", "AT", "BUT", "CAN", "DO", "EAT", "FAMILY", "FOR", "FRIEND", "FROM", "GOOD", "HAPPY", "HAVE", "HELP", "HOME", "KNOW", "LEARN", "LIKE", "LOVE", "NAME", "NEED", "NOW", "OK", "PLAY", "SAD", "SCHOOL", "SICK", "SLEEP", "STOP", "TEACH", "THAT", "THEIR", "TIRED", "TOMORROW", "UNDERSTAND", "WANT", "WHAT", "WHEN", "WHERE", "WHO", "WHY", "WITH", "WITHOUT", "YES", "YESTERDAY"].contains(upperName) {
                formattedName = "ASL_\(upperName)"
            } else {
                formattedName = "Word_\(upperName)"
            }
        }
        
        print("🖼️ Loading fallback image: \(formattedName)")
        
        // Try to load the image from bundle resources
        if let image = UIImage(named: formattedName) {
            print("✅ Found fallback image: \(formattedName)")
            return image
        }
        
        print("❌ Image not found: \(formattedName)")
        return nil
    }
    
    /// Load images from your ASL_Gestures folder structure
    private static func loadFromASLGesturesFolder(_ name: String) -> UIImage? {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if it's a letter first (you have A-Z available)
        if cleanName.count == 1 && cleanName.uppercased().isLetter {
            let letter = cleanName.uppercased()
            
            // Try loading directly from bundle with different extensions
            let extensions = ["jpg", "jpeg", "png"]
            for ext in extensions {
                if let bundlePath = Bundle.main.path(forResource: letter, ofType: ext, inDirectory: "ASL_Gestures/Alphabets"),
                   let image = UIImage(contentsOfFile: bundlePath) {
                    print("✅ Found ASL letter image: \(letter).\(ext)")
                    return image
                }
            }
            
            // Fallback: try full path approach
            let possiblePaths = [
                "ASL_Gestures/Alphabets/\(letter).jpg",
                "ASL_Gestures/Alphabets/\(letter).jpeg", 
                "ASL_Gestures/Alphabets/\(letter).png"
            ]
            
            for path in possiblePaths {
                if let bundlePath = Bundle.main.path(forResource: path, ofType: nil),
                   let image = UIImage(contentsOfFile: bundlePath) {
                    print("✅ Found ASL letter image: \(path)")
                    return image
                }
            }
        }
        
        // Check if it's a number
        if let number = Int(cleanName), number >= 0 && number <= 10 {
            let imageName = "\(number)"
            
            // Try loading directly from bundle
            let extensions = ["jpg", "jpeg", "png"]
            for ext in extensions {
                if let bundlePath = Bundle.main.path(forResource: imageName, ofType: ext, inDirectory: "ASL_Gestures/Numbers"),
                   let image = UIImage(contentsOfFile: bundlePath) {
                    print("✅ Found ASL number image: \(imageName).\(ext)")
                    return image
                }
            }
            
            // Fallback: try full path approach
            let possiblePaths = [
                "ASL_Gestures/Numbers/\(imageName).jpg",
                "ASL_Gestures/Numbers/\(imageName).jpeg",
                "ASL_Gestures/Numbers/\(imageName).png"
            ]
            
            for path in possiblePaths {
                if let bundlePath = Bundle.main.path(forResource: path, ofType: nil),
                   let image = UIImage(contentsOfFile: bundlePath) {
                    print("✅ Found ASL number image: \(path)")
                    return image
                }
            }
        }
        
        return nil
    }
    
    /// Create a fallback placeholder image with the character
    static func createFallbackImage(for character: String, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Background gradient
            let colors = [
                UIColor(red: 0.94, green: 0.87, blue: 0.81, alpha: 1.0).cgColor,
                UIColor(red: 0.85, green: 0.75, blue: 0.68, alpha: 1.0).cgColor
            ]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: colors as CFArray,
                                     locations: [0.0, 1.0])!
            context.cgContext.drawLinearGradient(gradient,
                                                 start: CGPoint(x: 0, y: 0),
                                                 end: CGPoint(x: size.width, y: size.height),
                                                 options: [])
            
            // Draw character
            let text = String(character.prefix(2))
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 80, weight: .black),
                .foregroundColor: UIColor(red: 0.85, green: 0.50, blue: 0.34, alpha: 1.0)
            ]
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
            
            // Draw "ASL" label at bottom
            let label = "ASL"
            let labelAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                .foregroundColor: UIColor(red: 0.85, green: 0.50, blue: 0.34, alpha: 0.6)
            ]
            let labelSize = label.size(withAttributes: labelAttributes)
            let labelRect = CGRect(
                x: (size.width - labelSize.width) / 2,
                y: size.height - labelSize.height - 20,
                width: labelSize.width,
                height: labelSize.height
            )
            label.draw(in: labelRect, withAttributes: labelAttributes)
        }
    }
}

// MARK: - SwiftUI Image Extension
extension Image {
    /// Load ASL image with fallback
    static func aslImage(for imageName: String, character: String) -> Image {
        if let uiImage = ASLImageLoader.loadImage(for: imageName) {
            return Image(uiImage: uiImage)
        } else {
            // Return fallback image
            let fallback = ASLImageLoader.createFallbackImage(for: character)
            return Image(uiImage: fallback)
        }
    }
}

// MARK: - String Extensions
extension String {
    var isLetter: Bool {
        return self.rangeOfCharacter(from: CharacterSet.letters) != nil
    }
    
    var isNumber: Bool {
        return self.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
    }
}
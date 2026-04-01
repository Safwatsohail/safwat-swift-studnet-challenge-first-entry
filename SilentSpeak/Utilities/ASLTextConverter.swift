//
//  ASLTextConverter.swift
//  SilentSpeak
//
//  Converts spoken text to ASL hand sign images
//

import Foundation
import SwiftUI

struct ASLSignImage: Identifiable {
    let id = UUID()
    let character: String  // The letter or word
    let imageUrl: String
    let isWord: Bool  // true if it's a word, false if it's a letter
    let isLocal: Bool  // true if image is bundled locally, false if URL
}

class ASLTextConverter {
    
    /// Convert a sentence to ASL sign images
    /// - Parameter text: The spoken text (e.g., "HELLO I AM SAFWAT")
    /// - Returns: Array of ASL sign images for each word/letter with spaces
    static func convertToASL(_ text: String) -> [ASLSignImage] {
        var signs: [ASLSignImage] = []
        
        // Split into words
        let words = text.uppercased().split(separator: " ").map { String($0) }
        
        print("🔤 Converting to ASL: \(text)")
        print("📝 Words: \(words)")
        
        for (wordIndex, word) in words.enumerated() {
            print("🔍 Checking word: '\(word)'")
            
            if let directWordImage = FullASLDictionary.all.first(where: { $0.word.uppercased() == word })?.imageAssetName,
               ASLImageLoader.hasImage(for: directWordImage) {
                signs.append(ASLSignImage(character: word, imageUrl: directWordImage, isWord: true, isLocal: true))
            } else
            // Check if the word has a direct ASL sign
            if let imageUrl = ASLDictionaryData.getImageUrl(for: word) {
                let isLocal = ASLDictionaryData.isLocalImage(for: word)
                // Word has a sign (like HELLO, THANK YOU, etc.)
                print("✅ Found word sign for: \(word) (local: \(isLocal))")
                signs.append(ASLSignImage(character: word, imageUrl: imageUrl, isWord: true, isLocal: isLocal))
            } else {
                // Word doesn't have a sign, spell it letter by letter
                print("📖 Spelling word letter-by-letter: \(word)")
                for char in word {
                    let letter = String(char)
                    if let imageUrl = ASLDictionaryData.getImageUrl(for: letter) {
                        let isLocal = ASLDictionaryData.isLocalImage(for: letter)
                        print("  ✅ Letter: \(letter) (local: \(isLocal))")
                        signs.append(ASLSignImage(character: letter, imageUrl: imageUrl, isWord: false, isLocal: isLocal))
                    } else {
                        // Character not found (punctuation, etc.), skip it
                        print("  ⚠️ No ASL sign for: \(letter)")
                    }
                }
            }
            
            // Add space between words (except after the last word)
            if wordIndex < words.count - 1 {
                signs.append(ASLSignImage(character: " ", imageUrl: "space", isWord: false, isLocal: true))
            }
        }
        
        print("🎯 Total signs generated: \(signs.count)")
        return signs
    }
    
    /// Check if a word has a direct ASL sign (not spelled)
    static func hasDirectSign(for word: String) -> Bool {
        return ASLDictionaryData.hasSign(for: word)
    }
    
    /// Get all available words with direct signs
    static func getAvailableWords() -> [String] {
        return ASLDictionaryData.items
            .filter { $0.word.count > 1 }  // Filter out single letters
            .map { $0.word }
    }
}

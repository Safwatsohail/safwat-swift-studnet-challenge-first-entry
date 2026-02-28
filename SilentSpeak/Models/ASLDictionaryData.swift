import Foundation

struct DictionaryItem: Identifiable, Hashable {
    let id = UUID()
    let word: String
    let meaning: String
    let imageUrl: String
    let hasLocalImage: Bool
    
    init(word: String, meaning: String, imageUrl: String, hasLocalImage: Bool = false) {
        self.word = word
        self.meaning = meaning
        self.imageUrl = imageUrl
        self.hasLocalImage = hasLocalImage
    }
}

class ASLDictionaryData {
    static let items: [DictionaryItem] = [
        // Letters A-Z (26 items)
        DictionaryItem(word: "A", meaning: "The letter A", imageUrl: "A", hasLocalImage: true),
        DictionaryItem(word: "B", meaning: "The letter B", imageUrl: "B", hasLocalImage: true),
        DictionaryItem(word: "C", meaning: "The letter C", imageUrl: "C", hasLocalImage: true),
        DictionaryItem(word: "D", meaning: "The letter D", imageUrl: "D", hasLocalImage: true),
        DictionaryItem(word: "E", meaning: "The letter E", imageUrl: "E", hasLocalImage: true),
        DictionaryItem(word: "F", meaning: "The letter F", imageUrl: "F", hasLocalImage: true),
        DictionaryItem(word: "G", meaning: "The letter G", imageUrl: "G", hasLocalImage: true),
        DictionaryItem(word: "H", meaning: "The letter H", imageUrl: "H", hasLocalImage: true),
        DictionaryItem(word: "I", meaning: "The letter I", imageUrl: "I", hasLocalImage: true),
        DictionaryItem(word: "J", meaning: "The letter J", imageUrl: "J", hasLocalImage: true),
        DictionaryItem(word: "K", meaning: "The letter K", imageUrl: "K", hasLocalImage: true),
        DictionaryItem(word: "L", meaning: "The letter L", imageUrl: "L", hasLocalImage: true),
        DictionaryItem(word: "M", meaning: "The letter M", imageUrl: "M", hasLocalImage: true),
        DictionaryItem(word: "N", meaning: "The letter N", imageUrl: "N", hasLocalImage: true),
        DictionaryItem(word: "O", meaning: "The letter O", imageUrl: "O", hasLocalImage: true),
        DictionaryItem(word: "P", meaning: "The letter P", imageUrl: "P", hasLocalImage: true),
        DictionaryItem(word: "Q", meaning: "The letter Q", imageUrl: "Q", hasLocalImage: true),
        DictionaryItem(word: "R", meaning: "The letter R", imageUrl: "R", hasLocalImage: true),
        DictionaryItem(word: "S", meaning: "The letter S", imageUrl: "S", hasLocalImage: true),
        DictionaryItem(word: "T", meaning: "The letter T", imageUrl: "T", hasLocalImage: true),
        DictionaryItem(word: "U", meaning: "The letter U", imageUrl: "U", hasLocalImage: true),
        DictionaryItem(word: "V", meaning: "The letter V", imageUrl: "V", hasLocalImage: true),
        DictionaryItem(word: "W", meaning: "The letter W", imageUrl: "W", hasLocalImage: true),
        DictionaryItem(word: "X", meaning: "The letter X", imageUrl: "X", hasLocalImage: true),
        DictionaryItem(word: "Y", meaning: "The letter Y", imageUrl: "Y", hasLocalImage: true),
        DictionaryItem(word: "Z", meaning: "The letter Z", imageUrl: "Z", hasLocalImage: true),
        
        // Numbers 0-10 (11 items)
        DictionaryItem(word: "0", meaning: "The number 0", imageUrl: "0", hasLocalImage: true),
        DictionaryItem(word: "1", meaning: "The number 1", imageUrl: "1", hasLocalImage: true),
        DictionaryItem(word: "2", meaning: "The number 2", imageUrl: "2", hasLocalImage: true),
        DictionaryItem(word: "3", meaning: "The number 3", imageUrl: "3", hasLocalImage: true),
        DictionaryItem(word: "4", meaning: "The number 4", imageUrl: "4", hasLocalImage: true),
        DictionaryItem(word: "5", meaning: "The number 5", imageUrl: "5", hasLocalImage: true),
        DictionaryItem(word: "6", meaning: "The number 6", imageUrl: "6", hasLocalImage: true),
        DictionaryItem(word: "7", meaning: "The number 7", imageUrl: "7", hasLocalImage: true),
        DictionaryItem(word: "8", meaning: "The number 8", imageUrl: "8", hasLocalImage: true),
        DictionaryItem(word: "9", meaning: "The number 9", imageUrl: "9", hasLocalImage: true),
        DictionaryItem(word: "10", meaning: "The number 10", imageUrl: "10", hasLocalImage: true)
    ]
    
    static func getImageUrl(for word: String) -> String? {
        return items.first { $0.word.uppercased() == word.uppercased() }?.imageUrl
    }
    
    static func isLocalImage(for word: String) -> Bool {
        return items.first { $0.word.uppercased() == word.uppercased() }?.hasLocalImage ?? false
    }
    
    static func hasSign(for word: String) -> Bool {
        return items.contains { $0.word.uppercased() == word.uppercased() }
    }
}
//
//  LanguageManager.swift
//  SilentSpeak
//
//  Multilingual support for ASL signs across different languages
//

import Foundation
import SwiftUI

// MARK: - Supported Languages
enum SupportedLanguage: String, CaseIterable {
    case english = "en-US"
    case spanish = "es-ES"
    case french = "fr-FR"
    case german = "de-DE"
    case arabic = "ar-SA"
    case hindi = "hi-IN"
    case chinese = "zh-CN"
    case japanese = "ja-JP"
    case korean = "ko-KR"
    case portuguese = "pt-BR"
    case russian = "ru-RU"
    case turkish = "tr-TR"
    case urdu = "ur-PK"
    case italian = "it-IT"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .arabic: return "العربية"
        case .hindi: return "हिन्दी"
        case .chinese: return "中文"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .portuguese: return "Português"
        case .russian: return "Русский"
        case .turkish: return "Türkçe"
        case .urdu: return "اردو"
        case .italian: return "Italiano"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .arabic: return "🇸🇦"
        case .hindi: return "🇮🇳"
        case .chinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .portuguese: return "🇧🇷"
        case .russian: return "🇷🇺"
        case .turkish: return "🇹🇷"
        case .urdu: return "🇵🇰"
        case .italian: return "🇮🇹"
        }
    }
    
    // Alphabet mapping for each language
    var alphabet: [String] {
        switch self {
        case .english:
            return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        case .spanish:
            return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "Ñ", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        case .french:
            return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        case .german:
            return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "Ä", "Ö", "Ü", "ß"]
        case .arabic:
            return ["ا", "ب", "ت", "ث", "ج", "ح", "خ", "د", "ذ", "ر", "ز", "س", "ش", "ص", "ض", "ط", "ظ", "ع", "غ", "ف", "ق", "ك", "ل", "م", "ن", "ه", "و", "ي"]
        case .hindi:
            return ["अ", "आ", "इ", "ई", "उ", "ऊ", "ए", "ऐ", "ओ", "औ", "क", "ख", "ग", "घ", "च", "छ", "ज", "झ", "ट", "ठ", "ड", "ढ", "ण", "त", "थ", "द", "ध", "न", "प", "फ", "ब", "भ", "म", "य", "र", "ल", "व", "श", "ष", "स", "ह"]
        case .chinese:
            return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"] // Pinyin
        case .japanese:
            return ["あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ", "わ", "を", "ん"]
        case .korean:
            return ["ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
        case .portuguese:
            return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        case .russian:
            return ["А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж", "З", "И", "Й", "К", "Л", "М", "Н", "О", "П", "Р", "С", "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш", "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я"]
        case .turkish:
            return ["A", "B", "C", "Ç", "D", "E", "F", "G", "Ğ", "H", "I", "İ", "J", "K", "L", "M", "N", "O", "Ö", "P", "R", "S", "Ş", "T", "U", "Ü", "V", "Y", "Z"]
        case .urdu:
            return ["ا", "ب", "پ", "ت", "ٹ", "ث", "ج", "چ", "ح", "خ", "د", "ڈ", "ذ", "ر", "ڑ", "ز", "ژ", "س", "ش", "ص", "ض", "ط", "ظ", "ع", "غ", "ف", "ق", "ک", "گ", "ل", "م", "ن", "ں", "و", "ہ", "ھ", "ی", "ے"]
        case .italian:
            return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "Z"]
        }
    }
}

// MARK: - Language Manager
@MainActor
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: SupportedLanguage = .english
    @AppStorage("selectedLanguage") private var selectedLanguageCode = "en-US"
    
    init() {
        if let language = SupportedLanguage(rawValue: selectedLanguageCode) {
            currentLanguage = language
        }
    }
    
    func setLanguage(_ language: SupportedLanguage) {
        currentLanguage = language
        selectedLanguageCode = language.rawValue
        HapticManager.shared.success()
    }
    
    // Convert character to ASL-compatible format
    func normalizeCharacter(_ char: String) -> String {
        let normalized = char.uppercased()
        
        // For non-Latin scripts, map to closest Latin equivalent or use transliteration
        switch currentLanguage {
        case .arabic, .urdu:
            return transliterateArabic(normalized)
        case .hindi:
            return transliterateHindi(normalized)
        case .chinese:
            return normalized // Already in Pinyin
        case .japanese:
            return transliterateJapanese(normalized)
        case .korean:
            return transliterateKorean(normalized)
        case .russian:
            return transliterateRussian(normalized)
        default:
            return normalized
        }
    }
    
    // Transliteration helpers (simplified)
    private func transliterateArabic(_ char: String) -> String {
        let arabicToLatin: [String: String] = [
            "ا": "A", "ب": "B", "ت": "T", "ث": "TH", "ج": "J", "ح": "H", "خ": "KH",
            "د": "D", "ذ": "DH", "ر": "R", "ز": "Z", "س": "S", "ش": "SH", "ص": "S",
            "ض": "D", "ط": "T", "ظ": "Z", "ع": "A", "غ": "GH", "ف": "F", "ق": "Q",
            "ك": "K", "ل": "L", "م": "M", "ن": "N", "ه": "H", "و": "W", "ي": "Y"
        ]
        return arabicToLatin[char] ?? char
    }
    
    private func transliterateHindi(_ char: String) -> String {
        let hindiToLatin: [String: String] = [
            "अ": "A", "आ": "A", "इ": "I", "ई": "I", "उ": "U", "ऊ": "U",
            "क": "K", "ख": "KH", "ग": "G", "घ": "GH", "च": "CH", "छ": "CH",
            "ज": "J", "झ": "JH", "ट": "T", "ठ": "TH", "ड": "D", "ढ": "DH",
            "त": "T", "थ": "TH", "द": "D", "ध": "DH", "न": "N", "प": "P",
            "फ": "PH", "ब": "B", "भ": "BH", "म": "M", "य": "Y", "र": "R",
            "ल": "L", "व": "V", "श": "SH", "ष": "SH", "स": "S", "ह": "H"
        ]
        return hindiToLatin[char] ?? char
    }
    
    private func transliterateJapanese(_ char: String) -> String {
        let hiraganaToLatin: [String: String] = [
            "あ": "A", "い": "I", "う": "U", "え": "E", "お": "O",
            "か": "KA", "き": "KI", "く": "KU", "け": "KE", "こ": "KO",
            "さ": "SA", "し": "SHI", "す": "SU", "せ": "SE", "そ": "SO",
            "た": "TA", "ち": "CHI", "つ": "TSU", "て": "TE", "と": "TO",
            "な": "NA", "に": "NI", "ぬ": "NU", "ね": "NE", "の": "NO",
            "は": "HA", "ひ": "HI", "ふ": "FU", "へ": "HE", "ほ": "HO",
            "ま": "MA", "み": "MI", "む": "MU", "め": "ME", "も": "MO",
            "や": "YA", "ゆ": "YU", "よ": "YO",
            "ら": "RA", "り": "RI", "る": "RU", "れ": "RE", "ろ": "RO",
            "わ": "WA", "を": "WO", "ん": "N"
        ]
        return hiraganaToLatin[char] ?? char
    }
    
    private func transliterateKorean(_ char: String) -> String {
        let koreanToLatin: [String: String] = [
            "ㄱ": "G", "ㄴ": "N", "ㄷ": "D", "ㄹ": "R", "ㅁ": "M",
            "ㅂ": "B", "ㅅ": "S", "ㅇ": "O", "ㅈ": "J", "ㅊ": "CH",
            "ㅋ": "K", "ㅌ": "T", "ㅍ": "P", "ㅎ": "H"
        ]
        return koreanToLatin[char] ?? char
    }
    
    private func transliterateRussian(_ char: String) -> String {
        let russianToLatin: [String: String] = [
            "А": "A", "Б": "B", "В": "V", "Г": "G", "Д": "D", "Е": "E", "Ё": "YO",
            "Ж": "ZH", "З": "Z", "И": "I", "Й": "Y", "К": "K", "Л": "L", "М": "M",
            "Н": "N", "О": "O", "П": "P", "Р": "R", "С": "S", "Т": "T", "У": "U",
            "Ф": "F", "Х": "KH", "Ц": "TS", "Ч": "CH", "Ш": "SH", "Щ": "SCH",
            "Ъ": "", "Ы": "Y", "Ь": "", "Э": "E", "Ю": "YU", "Я": "YA"
        ]
        return russianToLatin[char] ?? char
    }
}

//
//  WordSuggestions.swift
//  SilentSpeak
//
//  Word prediction and autocomplete system
//

import Foundation

class WordSuggestions {
    
    // MARK: - Common Words Database
    
    static let commonWords: [String: [String]] = [
        // Single letters
        "I": ["I", "IS", "IT", "IN", "IF", "I'M", "I'LL", "I'VE"],
        "A": ["A", "AM", "AN", "AT", "AS", "AND", "ARE", "ALL"],
        "T": ["THE", "TO", "THAT", "THIS", "THEY", "THEM", "THERE"],
        "H": ["HE", "HI", "HER", "HIS", "HOW", "HAVE", "HAS", "HELLO"],
        "W": ["WE", "WHO", "WHY", "WHAT", "WHEN", "WHERE", "WITH", "WILL"],
        "Y": ["YOU", "YOUR", "YES", "YEAH"],
        "N": ["NO", "NOT", "NOW", "NEED"],
        "M": ["ME", "MY", "MORE"],
        "B": ["BE", "BY", "BUT"],
        "C": ["CAN", "COME"],
        "D": ["DO", "DID", "DON'T"],
        "F": ["FOR", "FROM"],
        "G": ["GO", "GET", "GOOD"],
        "O": ["OR", "ON", "OF", "OK"],
        "S": ["SO", "SEE"],
        
        // Two letters
        "AM": ["AM", "AMAZING"],
        "AN": ["AN", "AND", "ANY"],
        "AS": ["AS", "ASK"],
        "AT": ["AT", "ATE"],
        "BE": ["BE", "BED", "BEEN", "BEST"],
        "BY": ["BY", "BYE"],
        "DO": ["DO", "DON'T", "DONE", "DOES"],
        "GO": ["GO", "GOT", "GOOD", "GOING"],
        "HE": ["HE", "HER", "HEY", "HELP", "HERE", "HELLO"],
        "HI": ["HI", "HIM", "HIS"],
        "IF": ["IF"],
        "IN": ["IN", "INTO", "INDIA"],
        "IS": ["IS"],
        "IT": ["IT", "ITS"],
        "ME": ["ME"],
        "MY": ["MY"],
        "NO": ["NO", "NOT", "NOW"],
        "OF": ["OF", "OFF"],
        "ON": ["ON", "ONE"],
        "OR": ["OR", "OUR"],
        "SO": ["SO", "SOME"],
        "TO": ["TO", "TOO", "TODAY"],
        "UP": ["UP"],
        "US": ["US", "USE"],
        "WE": ["WE", "WELL"],
        
        // Three letters
        "ALL": ["ALL", "ALSO"],
        "AND": ["AND"],
        "ARE": ["ARE"],
        "BUT": ["BUT"],
        "CAN": ["CAN", "CAN'T"],
        "DID": ["DID", "DIDN'T"],
        "FOR": ["FOR"],
        "GET": ["GET", "GETTING"],
        "GOT": ["GOT"],
        "HAD": ["HAD"],
        "HAS": ["HAS"],
        "HER": ["HER", "HERE"],
        "HIM": ["HIM"],
        "HIS": ["HIS"],
        "HOW": ["HOW"],
        "NOT": ["NOT"],
        "NOW": ["NOW"],
        "ONE": ["ONE"],
        "OUR": ["OUR"],
        "OUT": ["OUT"],
        "SEE": ["SEE", "SEEN"],
        "SHE": ["SHE"],
        "THE": ["THE", "THEY", "THEM", "THEN", "THERE"],
        "TOO": ["TOO"],
        "TWO": ["TWO"],
        "WAS": ["WAS"],
        "WAY": ["WAY"],
        "WHO": ["WHO"],
        "WHY": ["WHY"],
        "YES": ["YES"],
        "YOU": ["YOU", "YOUR"],
        
        // Four+ letters
        "HAVE": ["HAVE", "HAVEN'T"],
        "THAT": ["THAT"],
        "THIS": ["THIS"],
        "THEY": ["THEY", "THEIR"],
        "WHAT": ["WHAT"],
        "WHEN": ["WHEN"],
        "WITH": ["WITH"],
        "WILL": ["WILL", "WON'T"],
        "YOUR": ["YOUR"],
        "BEEN": ["BEEN"],
        "COME": ["COME", "COMING"],
        "GOOD": ["GOOD"],
        "HELP": ["HELP"],
        "HERE": ["HERE"],
        "JUST": ["JUST"],
        "KNOW": ["KNOW"],
        "LIKE": ["LIKE"],
        "MAKE": ["MAKE"],
        "MORE": ["MORE"],
        "NEED": ["NEED"],
        "SOME": ["SOME"],
        "TAKE": ["TAKE"],
        "THAN": ["THAN", "THANK", "THANKS"],
        "THEM": ["THEM"],
        "THEN": ["THEN"],
        "WANT": ["WANT"],
        "WELL": ["WELL"],
        "WERE": ["WERE"],
        "WORK": ["WORK"],
        "WOULD": ["WOULD"],
        "COULD": ["COULD"],
        "SHOULD": ["SHOULD"],
        "PLEASE": ["PLEASE"],
        "SORRY": ["SORRY"],
        "THANK": ["THANK", "THANKS"],
        "HELLO": ["HELLO"],
        "WHERE": ["WHERE"],
        "WHICH": ["WHICH"],
        "THEIR": ["THEIR"],
        "THERE": ["THERE"],
        "THESE": ["THESE"],
        "THOSE": ["THOSE"],
        "ABOUT": ["ABOUT"],
        "AFTER": ["AFTER"],
        "AGAIN": ["AGAIN"],
        "BECAUSE": ["BECAUSE"],
        "BEFORE": ["BEFORE"],
        "PEOPLE": ["PEOPLE"],
        "REALLY": ["REALLY"],
        "SOMETHING": ["SOMETHING"],
        "UNDERSTAND": ["UNDERSTAND"],
        
        // Names and places
        "IND": ["INDIA", "INDIAN"],
        "INDI": ["INDIA", "INDIAN"]
    ]
    
    // Common names
    static let commonNames = [
        "JOHN", "MARY", "JAMES", "SARAH", "MICHAEL", "DAVID", "EMMA", "OLIVIA",
        "WILLIAM", "SOPHIA", "ROBERT", "ISABELLA", "JOSEPH", "MIA", "CHARLES",
        "INDIA", "AMERICA", "CHINA", "JAPAN", "CANADA", "MEXICO", "BRAZIL"
    ]
    
    // Common places
    static let commonPlaces = [
        "HOME", "WORK", "SCHOOL", "HOSPITAL", "STORE", "PARK", "RESTAURANT",
        "OFFICE", "LIBRARY", "BANK", "AIRPORT", "STATION", "HOTEL", "CHURCH"
    ]
    
    // Helping verbs
    static let helpingVerbs = [
        "AM", "IS", "ARE", "WAS", "WERE", "BE", "BEEN", "BEING",
        "HAVE", "HAS", "HAD", "DO", "DOES", "DID",
        "CAN", "COULD", "MAY", "MIGHT", "MUST", "SHALL", "SHOULD", "WILL", "WOULD"
    ]
    
    // MARK: - Suggestion Methods
    
    /// Get word suggestions based on current input
    static func getSuggestions(for input: String, maxResults: Int = 5) -> [String] {
        let upperInput = input.uppercased()
        
        // If empty, return most common words
        if upperInput.isEmpty {
            return ["I", "YOU", "THE", "HELLO", "THANKS"]
        }
        
        var suggestions: [String] = []
        
        // 1. Exact match from dictionary
        if let exactMatches = commonWords[upperInput] {
            suggestions.append(contentsOf: exactMatches)
        }
        
        // 2. Starts with match
        for (key, words) in commonWords {
            if key.hasPrefix(upperInput) && key != upperInput {
                suggestions.append(contentsOf: words)
            }
        }
        
        // 3. Contains match
        for (key, words) in commonWords {
            if key.contains(upperInput) && !key.hasPrefix(upperInput) {
                suggestions.append(contentsOf: words)
            }
        }
        
        // 4. Add names if input matches
        for name in commonNames {
            if name.hasPrefix(upperInput) {
                suggestions.append(name)
            }
        }
        
        // 5. Add places if input matches
        for place in commonPlaces {
            if place.hasPrefix(upperInput) {
                suggestions.append(place)
            }
        }
        
        // 6. Add helping verbs if input matches
        for verb in helpingVerbs {
            if verb.hasPrefix(upperInput) {
                suggestions.append(verb)
            }
        }
        
        // Remove duplicates and limit results
        let uniqueSuggestions = Array(Set(suggestions)).sorted()
        return Array(uniqueSuggestions.prefix(maxResults))
    }
    
    /// Get suggestions for completing a sentence
    static func getNextWordSuggestions(after lastWord: String) -> [String] {
        let upperWord = lastWord.uppercased()
        
        // Common word pairs
        let wordPairs: [String: [String]] = [
            "I": ["AM", "WILL", "CAN", "NEED", "WANT"],
            "YOU": ["ARE", "CAN", "WILL", "NEED", "WANT"],
            "THE": ["BEST", "MOST", "ONLY", "FIRST", "LAST"],
            "CAN": ["YOU", "I", "WE", "THEY", "HE"],
            "WILL": ["YOU", "I", "WE", "THEY", "BE"],
            "THANK": ["YOU"],
            "HELLO": ["THERE", "EVERYONE"],
            "GOOD": ["MORNING", "NIGHT", "DAY", "JOB"],
            "HOW": ["ARE", "DO", "CAN", "WILL"],
            "WHAT": ["IS", "ARE", "DO", "CAN"],
            "WHERE": ["IS", "ARE", "DO", "CAN"],
            "WHEN": ["IS", "ARE", "DO", "CAN", "WILL"]
        ]
        
        if let suggestions = wordPairs[upperWord] {
            return suggestions
        }
        
        // Default common next words
        return ["THE", "A", "TO", "AND", "IS"]
    }
}

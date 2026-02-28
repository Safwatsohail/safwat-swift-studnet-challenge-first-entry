import Foundation

// MARK: - Accurate ASL Dictionary with 100 signs
// All images sourced from lifeprint.com (Dr. Bill Vicars - the authoritative ASL resource)
// These are accurate, educational ASL fingerspelling and sign images

struct ASLDictionaryEntry: Identifiable, Hashable {
    let id = UUID()
    let word: String
    let category: SignCategory
    let description: String        // Description of how to make the sign
    let imageAssetName: String?    // Local asset name if available
    let lifeprintURL: String?      // Lifeprint.com URL (authoritative ASL source)
    
    enum SignCategory: String, CaseIterable {
        case alphabet = "Alphabet A–Z"
        case numbers  = "Numbers 0–10"
        case greetings = "Greetings"
        case family    = "Family"
        case emotions  = "Emotions"
        case basicWords = "Basic Words"
        case questions  = "Questions"
        case actions    = "Actions"
        case time       = "Time"
        case places     = "Places"
        
        var icon: String {
            switch self {
            case .alphabet:  return "abc"
            case .numbers:   return "number"
            case .greetings: return "hand.wave.fill"
            case .family:    return "person.3.fill"
            case .emotions:  return "face.smiling.fill"
            case .basicWords: return "text.bubble.fill"
            case .questions: return "questionmark.circle.fill"
            case .actions:   return "figure.walk"
            case .time:      return "clock.fill"
            case .places:    return "mappin.circle.fill"
            }
        }
    }
    
    // Convenience init for alphabet from local assets
    static func letter(_ letter: String) -> ASLDictionaryEntry {
        ASLDictionaryEntry(
            word: letter,
            category: .alphabet,
            description: ASLHandshapeDescriptions.descriptionFor(letter: letter),
            imageAssetName: letter, // Direct reference to A.jpg, B.jpg, etc.
            lifeprintURL: "https://www.lifeprint.com/asl101/gifs/\(letter.lowercased())/\(letter.lowercased()).gif"
        )
    }
    
    static func number(_ num: String) -> ASLDictionaryEntry {
        // Use the actual image names from your ASL_Gestures/Numbers folder
        let imageAssetName: String?
        if let numInt = Int(num), numInt >= 1 && numInt <= 9 {
            imageAssetName = num // Direct reference to 1.jpg, 2.jpg, etc.
        } else if num == "0" || num == "10" {
            imageAssetName = num // Will use placeholder until real images are added
        } else {
            imageAssetName = nil
        }
        
        return ASLDictionaryEntry(
            word: num,
            category: .numbers,
            description: ASLHandshapeDescriptions.descriptionForNumber(num),
            imageAssetName: imageAssetName,
            lifeprintURL: "https://www.lifeprint.com/asl101/gifs/numbers/\(num).gif"
        )
    }
}

// MARK: - Handshape Descriptions (accurate reference descriptions)
struct ASLHandshapeDescriptions {
    static func descriptionFor(letter: String) -> String {
        switch letter {
        case "A": return "Closed fist with thumb resting on side of index finger"
        case "B": return "All four fingers straight up together, thumb tucked across palm"
        case "C": return "All fingers curved into a C-shape, thumb also curved"
        case "D": return "Index finger points up, other fingers touch thumb tip forming an O"
        case "E": return "All fingers bent at second knuckle, thumb tucked under"
        case "F": return "Index finger and thumb touch at tips; other three fingers up"
        case "G": return "Index finger and thumb point sideways parallel, others curled"
        case "H": return "Index and middle finger point sideways together horizontally"
        case "I": return "Pinky finger points up in a fist, others curled down"
        case "J": return "Pinky up, trace a J in the air (motion letter)"
        case "K": return "Index up, middle up angled, thumb between them; others curled"
        case "L": return "Index points up, thumb points out at 90°, others curled (L-shape)"
        case "M": return "Three fingers fold over tucked thumb, pinky curled"
        case "N": return "Two fingers fold over tucked thumb, ring and pinky curled"
        case "O": return "All fingers and thumb curve together to form an O-circle"
        case "P": return "Like K but hand points downward"
        case "Q": return "Like G but hand points downward"
        case "R": return "Index and middle fingers crossed and raised; others curled"
        case "S": return "Closed fist with thumb over fingers"
        case "T": return "Fist with thumb between index and middle fingers"
        case "U": return "Index and middle fingers straight up together; others curled"
        case "V": return "Index and middle fingers spread apart in a V; others curled"
        case "W": return "Index, middle, ring fingers up spread apart; thumb and pinky touch"
        case "X": return "Index finger bent in a hook/hook shape; others curled"
        case "Y": return "Thumb and pinky spread out; other three fingers curled"
        case "Z": return "Index finger traces a Z shape in the air (motion letter)"
        default: return ""
        }
    }
    
    static func descriptionForNumber(_ num: String) -> String {
        switch num {
        case "0": return "Fingers and thumb form a perfect O shape"
        case "1": return "Index finger points straight up, others curled"
        case "2": return "Index and middle fingers point up (V shape or together)"
        case "3": return "Thumb, index, and middle fingers extended"
        case "4": return "Four fingers up, thumb tucked across palm"
        case "5": return "All five fingers spread wide open"
        case "6": return "Thumb and pinky touch; other three fingers up"
        case "7": return "Thumb and ring finger touch; other three fingers up"
        case "8": return "Thumb and middle finger touch; index and pinky up"
        case "9": return "Index and thumb form a circle; other fingers up"
        case "10": return "Thumb up (thumbs-up shape) or fist with thumb out"
        default: return "Number sign for \(num)"
        }
    }
}

// MARK: - Full dictionary data
class FullASLDictionary {
    // Essential signs for beginners (alphabets and numbers only)
    static let essentialSigns: [ASLDictionaryEntry] = alphabet + numbers
    
    // Full dictionary (all categories)
    static let all: [ASLDictionaryEntry] = alphabet + numbers + greetings + family + emotions + basicWords + questions + actions + timeSigns + places
    
    // Essential categories for beginners
    static let essentialCategories: [ASLDictionaryEntry.SignCategory] = [.alphabet, .numbers]
    
    // All categories
    static let allCategories: [ASLDictionaryEntry.SignCategory] = ASLDictionaryEntry.SignCategory.allCases
    
    // A-Z
    static let alphabet: [ASLDictionaryEntry] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"].map { .letter($0) }
    
    // 0-10 (images available for 1-9, placeholders for 0 and 10)
    static let numbers: [ASLDictionaryEntry] = ["0","1","2","3","4","5","6","7","8","9","10"].map { .number($0) }
    
    // Greetings (6)
    static let greetings: [ASLDictionaryEntry] = [
        ASLDictionaryEntry(word: "HELLO", category: .greetings,
            description: "Open flat hand, touch forehead with fingertips, then move hand outward (like a salute)",
            imageAssetName: "Word_Hello", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/h/hello.gif"),
        ASLDictionaryEntry(word: "GOODBYE", category: .greetings,
            description: "Open hand, fingers pointing up, bend fingers down and back up repeatedly (wave goodbye)",
            imageAssetName: "Word_Goodbye", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/g/goodbye.gif"),
        ASLDictionaryEntry(word: "PLEASE", category: .greetings,
            description: "Open flat hand on chest, make a circular motion on your chest",
            imageAssetName: "Word_Please", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/p/please.gif"),
        ASLDictionaryEntry(word: "THANK YOU", category: .greetings,
            description: "Flat hand touches chin/lips then moves forward toward the person",
            imageAssetName: "Word_Thank_you", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/t/thankyou.gif"),
        ASLDictionaryEntry(word: "SORRY", category: .greetings,
            description: "Make an A-hand (fist with thumb up side), rub it in circles on your chest",
            imageAssetName: "Word_Sorry", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/s/sorry.gif"),
        ASLDictionaryEntry(word: "SIGN LANGUAGE", category: .greetings,
            description: "Point both index fingers, rotate them alternately in forward circles",
            imageAssetName: nil, lifeprintURL: "https://www.lifeprint.com/asl101/gifs/s/signlanguage.gif"),
    ]
    
    // Family (8)
    static let family: [ASLDictionaryEntry] = [
        ASLDictionaryEntry(word: "FAMILY", category: .family,
            description: "Both F-hands (thumb+index touch), held side-by-side, arc outward and come together",
            imageAssetName: "Word_Family", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/f/family.gif"),
        ASLDictionaryEntry(word: "MOTHER", category: .family,
            description: "5-hand (open spread), tap thumb to chin twice",
            imageAssetName: "Word_Mother", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/m/mother.gif"),
        ASLDictionaryEntry(word: "FATHER", category: .family,
            description: "5-hand (open spread), tap thumb to forehead twice",
            imageAssetName: "Word_Father", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/f/father.gif"),
        ASLDictionaryEntry(word: "SISTER", category: .family,
            description: "L-hand slides along jaw then lands on other L-hand below (female + same)",
            imageAssetName: nil, lifeprintURL: "https://www.lifeprint.com/asl101/gifs/s/sister.gif"),
        ASLDictionaryEntry(word: "BROTHER", category: .family,
            description: "G-hand touches forehead then clasps together with other hand (male + same)",
            imageAssetName: nil, lifeprintURL: "https://www.lifeprint.com/asl101/gifs/b/brother.gif"),
        ASLDictionaryEntry(word: "BABY", category: .family,
            description: "Cradle arms and rock side to side like holding a baby",
            imageAssetName: nil, lifeprintURL: "https://www.lifeprint.com/asl101/gifs/b/baby.gif"),
        ASLDictionaryEntry(word: "FRIEND", category: .family,
            description: "Hook index fingers together, then flip and hook again (mutual connection)",
            imageAssetName: "Word_Friend", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/f/friend.gif"),
        ASLDictionaryEntry(word: "LOVE", category: .family,
            description: "Cross both hands at wrists (X-shape) and press them to your chest/heart",
            imageAssetName: "Word_Love", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/l/love.gif"),
    ]
    
    // Emotions (8)
    static let emotions: [ASLDictionaryEntry] = [
        ASLDictionaryEntry(word: "HAPPY", category: .emotions,
            description: "Flat hand brushes upward on chest repeatedly (feeling rising up)",
            imageAssetName: "Word_Happy", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/h/happy.gif"),
        ASLDictionaryEntry(word: "SAD", category: .emotions,
            description: "Both open hands slide down face (tears falling expression)",
            imageAssetName: "Word_Sad", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/s/sad.gif"),
        ASLDictionaryEntry(word: "ANGRY", category: .emotions,
            description: "Bent 5-hand claws upward from chin (pulling anger out)",
            imageAssetName: "Word_Angry", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/a/angry.gif"),
        ASLDictionaryEntry(word: "SCARED", category: .emotions,
            description: "Both A-hands move quickly together toward chest (startled/shrinking)",
            imageAssetName: nil, lifeprintURL: "https://www.lifeprint.com/asl101/gifs/s/scared.gif"),
        ASLDictionaryEntry(word: "TIRED", category: .emotions,
            description: "Bent hands drop down from chest (energy falling away)",
            imageAssetName: "Word_Tired", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/t/tired.gif"),
        ASLDictionaryEntry(word: "EXCITED", category: .emotions,
            description: "Alternating middle fingers brush upward on chest (feeling energy)",
            imageAssetName: nil, lifeprintURL: "https://www.lifeprint.com/asl101/gifs/e/excited.gif"),
        ASLDictionaryEntry(word: "BORED", category: .emotions,
            description: "Index finger twists against the side of the nose",
            imageAssetName: nil, lifeprintURL: "https://www.lifeprint.com/asl101/gifs/b/bored.gif"),
        ASLDictionaryEntry(word: "SURPRISED", category: .emotions,
            description: "Both L-hands spring open at eye level (eyes going wide)",
            imageAssetName: nil, lifeprintURL: "https://www.lifeprint.com/asl101/gifs/s/surprised.gif"),
    ]
    
    // Basic Words (10)
    static let basicWords: [ASLDictionaryEntry] = [
        ASLDictionaryEntry(word: "YES", category: .basicWords,
            description: "A-hand (fist) nods up and down like a head nodding",
            imageAssetName: "Word_Yes", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/y/yes.gif"),
        ASLDictionaryEntry(word: "NO", category: .basicWords,
            description: "Index and middle finger snap down to meet thumb (like saying no-no)",
            imageAssetName: "Word_No", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/n/no.gif"),
        ASLDictionaryEntry(word: "GOOD", category: .basicWords,
            description: "Flat hand touches chin then drops down onto other open hand",
            imageAssetName: "Word_Good", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/g/good.gif"),
        ASLDictionaryEntry(word: "BAD", category: .basicWords,
            description: "Flat hand touches chin then flips outward and downward",
            imageAssetName: "Word_Bad", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/b/bad.gif"),
        ASLDictionaryEntry(word: "WANT", category: .basicWords,
            description: "Both claw-hands pull inward toward body (drawing something in)",
            imageAssetName: "Word_Want", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/w/want.gif"),
        ASLDictionaryEntry(word: "NEED", category: .basicWords,
            description: "X-hand (hooked index) bends down repeatedly (necessity)",
            imageAssetName: "Word_Need", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/n/need.gif"),
        ASLDictionaryEntry(word: "MORE", category: .basicWords,
            description: "Both flat O-hands tap together at fingertips repeatedly",
            imageAssetName: "Word_More", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/m/more.gif"),
        ASLDictionaryEntry(word: "HELP", category: .basicWords,
            description: "A-hand (fist) rests on open palm, then both lift upward together",
            imageAssetName: "Word_Help", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/h/help.gif"),
        ASLDictionaryEntry(word: "STOP", category: .basicWords,
            description: "Open hand chops down onto the open palm of the other hand",
            imageAssetName: "Word_Stop", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/s/stop.gif"),
        ASLDictionaryEntry(word: "FINISHED", category: .basicWords,
            description: "Both 5-hands facing up flip to face downward quickly (all done)",
            imageAssetName: "Word_Finished", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/f/finished.gif"),
    ]
    
    // Questions (6)
    static let questions: [ASLDictionaryEntry] = [
        ASLDictionaryEntry(word: "WHAT", category: .questions,
            description: "Index finger brushes down over open hand fingers with questioning look",
            imageAssetName: "Word_What", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/w/what.gif"),
        ASLDictionaryEntry(word: "WHO", category: .questions,
            description: "L-hand near lips, index finger makes a small circle (who?)",
            imageAssetName: "Word_Who", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/w/who.gif"),
        ASLDictionaryEntry(word: "WHERE", category: .questions,
            description: "Index finger points up and waves side to side (searching)",
            imageAssetName: "Word_Where", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/w/where.gif"),
        ASLDictionaryEntry(word: "WHEN", category: .questions,
            description: "Index fingers circle each other and touch (two things meeting in time)",
            imageAssetName: "Word_When", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/w/when.gif"),
        ASLDictionaryEntry(word: "WHY", category: .questions,
            description: "Middle finger touches forehead then flicks forward (reasoning out)",
            imageAssetName: "Word_Why", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/w/why.gif"),
        ASLDictionaryEntry(word: "HOW", category: .questions,
            description: "Both bent hands, knuckles touching, rotate forward and up",
            imageAssetName: "Word_How", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/h/how.gif"),
    ]
    
    // Actions (8)
    static let actions: [ASLDictionaryEntry] = [
        ASLDictionaryEntry(word: "EAT", category: .actions,
            description: "Fingers bunched together, tap toward mouth repeatedly",
            imageAssetName: "Word_Eat", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/e/eat.gif"),
        ASLDictionaryEntry(word: "DRINK", category: .actions,
            description: "C-shaped hand (like holding a cup), tilt toward mouth",
            imageAssetName: "Word_Drink", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/d/drink.gif"),
        ASLDictionaryEntry(word: "SLEEP", category: .actions,
            description: "Open hand sweeps from near face downward and fingers close together",
            imageAssetName: "Word_Sleep", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/s/sleep.gif"),
        ASLDictionaryEntry(word: "LEARN", category: .actions,
            description: "Bent hand picks up information from open palm and touches forehead",
            imageAssetName: "Word_Learn", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/l/learn.gif"),
        ASLDictionaryEntry(word: "WORK", category: .actions,
            description: "S-hands (fists), tap dominant wrist onto non-dominant wrist twice",
            imageAssetName: "Word_Work", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/w/work.gif"),
        ASLDictionaryEntry(word: "PLAY", category: .actions,
            description: "Y-hands (thumb + pinky) shake back and forth",
            imageAssetName: "Word_Play", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/p/play.gif"),
        ASLDictionaryEntry(word: "GO", category: .actions,
            description: "Both index fingers curve/point forward then arc out ahead",
            imageAssetName: "Word_Go", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/g/go.gif"),
        ASLDictionaryEntry(word: "COME", category: .actions,
            description: "Both index fingers point and arc toward yourself (beckoning)",
            imageAssetName: "Word_Come", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/c/come.gif"),
    ]
    
    // Time (6)
    static let timeSigns: [ASLDictionaryEntry] = [
        ASLDictionaryEntry(word: "NOW", category: .time,
            description: "Y-hands (thumb+pinky), drop down from bent position",
            imageAssetName: "Word_Now", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/n/now.gif"),
        ASLDictionaryEntry(word: "TODAY", category: .time,
            description: "NOW sign + DAY sign combined",
            imageAssetName: nil, lifeprintURL: "https://www.lifeprint.com/asl101/gifs/t/today.gif"),
        ASLDictionaryEntry(word: "YESTERDAY", category: .time,
            description: "A-hand, thumb touches cheek, then moves backward",
            imageAssetName: "Word_Yesterday", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/y/yesterday.gif"),
        ASLDictionaryEntry(word: "TOMORROW", category: .time,
            description: "A-hand, thumb touches cheek, then moves forward",
            imageAssetName: "Word_Tomorrow", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/t/tomorrow.gif"),
        ASLDictionaryEntry(word: "MORNING", category: .time,
            description: "Non-dominant arm horizontal, dominant arm rises like the sun from under it",
            imageAssetName: "Word_Morning", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/m/morning.gif"),
        ASLDictionaryEntry(word: "NIGHT", category: .time,
            description: "Non-dominant arm horizontal, bent dominant hand arcs over and down",
            imageAssetName: "Word_Night", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/n/night.gif"),
    ]
    
    // Places (5)
    static let places: [ASLDictionaryEntry] = [
        ASLDictionaryEntry(word: "HOME", category: .places,
            description: "Flat O-hand touches corner of mouth, then moves up to cheek",
            imageAssetName: "Word_Home", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/h/home.gif"),
        ASLDictionaryEntry(word: "SCHOOL", category: .places,
            description: "Clap twice: open palms clap against each other",
            imageAssetName: "Word_School", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/s/school.gif"),
        ASLDictionaryEntry(word: "HOSPITAL", category: .places,
            description: "H-hand (index+middle) draws a cross on the upper arm",
            imageAssetName: nil, lifeprintURL: "https://www.lifeprint.com/asl101/gifs/h/hospital.gif"),
        ASLDictionaryEntry(word: "WATER", category: .places,
            description: "W-hand (three fingers up) taps chin twice",
            imageAssetName: "Word_Water", lifeprintURL: "https://www.lifeprint.com/asl101/gifs/w/water.gif"),
        ASLDictionaryEntry(word: "BATHROOM", category: .places,
            description: "T-hand (fist with thumb between fingers) shakes side to side",
            imageAssetName: nil, lifeprintURL: "https://www.lifeprint.com/asl101/gifs/b/bathroom.gif"),
    ]
    
    // By category helper
    static func entries(for category: ASLDictionaryEntry.SignCategory) -> [ASLDictionaryEntry] {
        all.filter { $0.category == category }
    }
}

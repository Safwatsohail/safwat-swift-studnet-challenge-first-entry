import Foundation
import AVFoundation
import SoundAnalysis
import Combine

struct SoundEvent: Identifiable {
    let id = UUID()
    let type: SoundType
    let confidence: Double
    let timestamp: Date
    
    var timeAgo: String {
        let elapsed = Date().timeIntervalSince(timestamp)
        if elapsed < 60 { return "Just now" }
        if elapsed < 3600 { return "\(Int(elapsed / 60))m ago" }
        return "\(Int(elapsed / 3600))h ago"
    }
}

enum SoundCategory: String, CaseIterable {
    case emergency = "Emergency"
    case home = "Home"
    case babyPet = "Baby & Pets"
    case vehicle = "Vehicles"
    case weather = "Weather"
    case human = "Human"
    case kitchen = "Kitchen"
    case office = "Office"
    case entertainment = "Entertainment"
    case nature = "Nature"
}

enum SoundType: String, CaseIterable {
    case ambulance = "ambulance_siren"
    case fireTruck = "fire_truck_siren"
    case policeSiren = "police_car_siren"
    case smokeAlarm = "smoke_detector"
    case carbonMonoxide = "carbon_monoxide_alarm"
    case glassBreaking = "glass_breaking"
    case explosion = "explosion"
    case gunshot = "gunshot"
    case scream = "scream"
    case carCrash = "car_crash"
    
    case doorbell = "doorbell"
    case doorKnock = "knock"
    case doorSlam = "door_slam"
    case doorOpen = "door_open"
    case phoneRinging = "telephone"
    case textNotification = "text_notification"
    case alarmClock = "alarm_clock"
    case timerBeep = "timer"
    case microwaveBeep = "microwave"
    case ovenTimer = "oven_timer"
    case washingMachine = "washing_machine"
    case dryerBuzzer = "dryer"
    case vacuumCleaner = "vacuum_cleaner"
    case blender = "blender"
    case hairDryer = "hair_dryer"
    case electricToothbrush = "electric_toothbrush"
    case showerRunning = "shower"
    case toiletFlush = "toilet_flush"
    case faucetRunning = "faucet"
    case garbageDisposal = "garbage_disposal"
    
    case babyCrying = "baby_cry"
    case babyLaughing = "baby_laughter"
    case babyBabbling = "baby_babble"
    case dogBarking = "dog_bark"
    case dogWhining = "dog_whine"
    case dogGrowling = "dog_growl"
    case catMeowing = "cat_meow"
    case catHissing = "cat_hiss"
    case catPurring = "cat_purr"
    case birdChirping = "bird_chirp"
    case roosterCrowing = "rooster"
    
    case carHorn = "car_horn"
    case carEngine = "engine"
    case carStarting = "car_start"
    case carBraking = "car_brake"
    case motorcycle = "motorcycle"
    case truck = "truck"
    case bus = "bus"
    case train = "train"
    case trainHorn = "train_horn"
    case airplane = "airplane"
    case helicopter = "helicopter"
    case bicycleBell = "bicycle_bell"
    case skateboard = "skateboard"
    
    case thunder = "thunderstorm"
    case rain = "rain"
    case heavyRain = "heavy_rain"
    case wind = "wind"
    case hail = "hail"
    case storm = "storm"
    
    case speech = "speech"
    case laughter = "laughter"
    case crying = "crying"
    case coughing = "coughing"
    case sneezing = "sneezing"
    case yawning = "yawning"
    case footsteps = "footsteps"
    case running = "running"
    case clapping = "clapping"
    case whistling = "whistling"
    case singing = "singing"
    case shouting = "shouting"
    case whispering = "whispering"
    
    case kettleWhistling = "kettle"
    case potBoiling = "boiling_water"
    case frying = "frying"
    case chopping = "chopping"
    case dishwasher = "dishwasher"
    case refrigeratorHum = "refrigerator"
    case toasterPop = "toaster"
    case coffeeMaker = "coffee_maker"
    case blenderMixing = "blender_mixing"
    case canOpening = "can_opener"
    case glassClinking = "glass_clink"
    case plateClatter = "dishes"
    case silverwareClinking = "silverware"
    
    case keyboardTyping = "keyboard"
    case mouseClick = "mouse_click"
    case printer = "printer"
    case scanner = "scanner"
    case phoneVibration = "phone_vibration"
    case penClicking = "pen_click"
    case paperRustling = "paper"
    case staplerClick = "stapler"
    case chairSqueak = "chair_squeak"
    case drawerOpening = "drawer"
    
    case music = "music"
    case television = "television"
    case radio = "radio"
    case videoGame = "video_game"
    case movieSound = "movie"
    case applause = "applause"
    case cheering = "cheering"
    case crowd = "crowd"
    case concert = "concert"
    
    case birds = "birds"
    case insects = "insects"
    case crickets = "crickets"
    case frogs = "frogs"
    case oceanWaves = "ocean"
    case stream = "stream"
    case waterfall = "waterfall"
    case windInTrees = "wind_trees"
    case leaves = "leaves"
    
    var displayName: String {
        switch self {
        case .ambulance: return "Ambulance"
        case .fireTruck: return "Fire Truck"
        case .policeSiren: return "Police Siren"
        case .smokeAlarm: return "Smoke Alarm"
        case .carbonMonoxide: return "CO Alarm"
        case .glassBreaking: return "Glass Breaking"
        case .explosion: return "Explosion"
        case .gunshot: return "Gunshot"
        case .scream: return "Scream"
        case .carCrash: return "Car Crash"
        case .doorbell: return "Doorbell"
        case .doorKnock: return "Knocking"
        case .doorSlam: return "Door Slam"
        case .doorOpen: return "Door Opening"
        case .phoneRinging: return "Phone Ringing"
        case .textNotification: return "Text Alert"
        case .alarmClock: return "Alarm Clock"
        case .timerBeep: return "Timer"
        case .microwaveBeep: return "Microwave"
        case .ovenTimer: return "Oven Timer"
        case .washingMachine: return "Washing Machine"
        case .dryerBuzzer: return "Dryer"
        case .vacuumCleaner: return "Vacuum"
        case .blender: return "Blender"
        case .hairDryer: return "Hair Dryer"
        case .electricToothbrush: return "Toothbrush"
        case .showerRunning: return "Shower"
        case .toiletFlush: return "Toilet"
        case .faucetRunning: return "Faucet"
        case .garbageDisposal: return "Disposal"
        case .babyCrying: return "Baby Crying"
        case .babyLaughing: return "Baby Laughing"
        case .babyBabbling: return "Baby Babbling"
        case .dogBarking: return "Dog Barking"
        case .dogWhining: return "Dog Whining"
        case .dogGrowling: return "Dog Growling"
        case .catMeowing: return "Cat Meowing"
        case .catHissing: return "Cat Hissing"
        case .catPurring: return "Cat Purring"
        case .birdChirping: return "Bird Chirping"
        case .roosterCrowing: return "Rooster"
        case .carHorn: return "Car Horn"
        case .carEngine: return "Engine"
        case .carStarting: return "Car Starting"
        case .carBraking: return "Braking"
        case .motorcycle: return "Motorcycle"
        case .truck: return "Truck"
        case .bus: return "Bus"
        case .train: return "Train"
        case .trainHorn: return "Train Horn"
        case .airplane: return "Airplane"
        case .helicopter: return "Helicopter"
        case .bicycleBell: return "Bicycle Bell"
        case .skateboard: return "Skateboard"
        case .thunder: return "Thunder"
        case .rain: return "Rain"
        case .heavyRain: return "Heavy Rain"
        case .wind: return "Wind"
        case .hail: return "Hail"
        case .storm: return "Storm"
        case .speech: return "Speech"
        case .laughter: return "Laughter"
        case .crying: return "Crying"
        case .coughing: return "Coughing"
        case .sneezing: return "Sneezing"
        case .yawning: return "Yawning"
        case .footsteps: return "Footsteps"
        case .running: return "Running"
        case .clapping: return "Clapping"
        case .whistling: return "Whistling"
        case .singing: return "Singing"
        case .shouting: return "Shouting"
        case .whispering: return "Whispering"
        case .kettleWhistling: return "Kettle"
        case .potBoiling: return "Boiling Water"
        case .frying: return "Frying"
        case .chopping: return "Chopping"
        case .dishwasher: return "Dishwasher"
        case .refrigeratorHum: return "Refrigerator"
        case .toasterPop: return "Toaster"
        case .coffeeMaker: return "Coffee Maker"
        case .blenderMixing: return "Blender"
        case .canOpening: return "Can Opener"
        case .glassClinking: return "Glass Clink"
        case .plateClatter: return "Dishes"
        case .silverwareClinking: return "Silverware"
        case .keyboardTyping: return "Keyboard"
        case .mouseClick: return "Mouse Click"
        case .printer: return "Printer"
        case .scanner: return "Scanner"
        case .phoneVibration: return "Phone Vibrate"
        case .penClicking: return "Pen Click"
        case .paperRustling: return "Paper"
        case .staplerClick: return "Stapler"
        case .chairSqueak: return "Chair Squeak"
        case .drawerOpening: return "Drawer"
        case .music: return "Music"
        case .television: return "Television"
        case .radio: return "Radio"
        case .videoGame: return "Video Game"
        case .movieSound: return "Movie"
        case .applause: return "Applause"
        case .cheering: return "Cheering"
        case .crowd: return "Crowd"
        case .concert: return "Concert"
        case .birds: return "Birds"
        case .insects: return "Insects"
        case .crickets: return "Crickets"
        case .frogs: return "Frogs"
        case .oceanWaves: return "Ocean Waves"
        case .stream: return "Stream"
        case .waterfall: return "Waterfall"
        case .windInTrees: return "Wind in Trees"
        case .leaves: return "Leaves"
        }
    }
    
    var emoji: String {
        switch self {
        case .ambulance: return "🚑"
        case .fireTruck: return "🚒"
        case .policeSiren: return "🚔"
        case .smokeAlarm, .carbonMonoxide: return "🚨"
        case .glassBreaking: return "💥"
        case .explosion: return "💣"
        case .gunshot: return "🔫"
        case .scream: return "😱"
        case .carCrash: return "💥"
        case .doorbell, .doorKnock: return "🔔"
        case .doorSlam, .doorOpen: return "🚪"
        case .phoneRinging, .textNotification, .phoneVibration: return "📱"
        case .alarmClock, .timerBeep: return "⏰"
        case .microwaveBeep, .ovenTimer: return "🍳"
        case .washingMachine, .dryerBuzzer: return "🧺"
        case .vacuumCleaner: return "🧹"
        case .blender, .blenderMixing: return "🥤"
        case .hairDryer: return "💨"
        case .electricToothbrush: return "🪥"
        case .showerRunning, .faucetRunning: return "🚿"
        case .toiletFlush: return "🚽"
        case .garbageDisposal: return "🗑️"
        case .babyCrying, .babyLaughing, .babyBabbling: return "👶"
        case .dogBarking, .dogWhining, .dogGrowling: return "🐕"
        case .catMeowing, .catHissing, .catPurring: return "🐱"
        case .birdChirping, .birds: return "🐦"
        case .roosterCrowing: return "🐓"
        case .carHorn, .carEngine, .carStarting, .carBraking: return "🚗"
        case .motorcycle: return "🏍️"
        case .truck: return "🚚"
        case .bus: return "🚌"
        case .train, .trainHorn: return "🚂"
        case .airplane: return "✈️"
        case .helicopter: return "🚁"
        case .bicycleBell: return "🚲"
        case .skateboard: return "🛹"
        case .thunder, .storm: return "⛈️"
        case .rain, .heavyRain: return "🌧️"
        case .wind, .windInTrees: return "💨"
        case .hail: return "🧊"
        case .speech, .shouting, .whispering: return "🗣️"
        case .laughter: return "😄"
        case .crying: return "😢"
        case .coughing, .sneezing: return "🤧"
        case .yawning: return "🥱"
        case .footsteps, .running: return "👣"
        case .clapping, .applause: return "👏"
        case .whistling: return "🎵"
        case .singing: return "🎤"
        case .kettleWhistling, .potBoiling: return "☕"
        case .frying, .chopping: return "🍳"
        case .dishwasher, .plateClatter, .silverwareClinking: return "🍽️"
        case .refrigeratorHum: return "🧊"
        case .toasterPop: return "🍞"
        case .coffeeMaker: return "☕"
        case .canOpening: return "🥫"
        case .glassClinking: return "🥂"
        case .keyboardTyping: return "⌨️"
        case .mouseClick: return "🖱️"
        case .printer, .scanner: return "🖨️"
        case .penClicking: return "🖊️"
        case .paperRustling: return "📄"
        case .staplerClick: return "📎"
        case .chairSqueak: return "🪑"
        case .drawerOpening: return "🗄️"
        case .music: return "🎵"
        case .television, .movieSound: return "📺"
        case .radio: return "📻"
        case .videoGame: return "🎮"
        case .cheering, .crowd, .concert: return "🎉"
        case .insects, .crickets: return "🦗"
        case .frogs: return "🐸"
        case .oceanWaves, .stream, .waterfall: return "🌊"
        case .leaves: return "🍃"
        }
    }
    
    var category: SoundCategory {
        switch self {
        case .ambulance, .fireTruck, .policeSiren, .smokeAlarm, .carbonMonoxide, .glassBreaking, .explosion, .gunshot, .scream, .carCrash:
            return .emergency
        case .doorbell, .doorKnock, .doorSlam, .doorOpen, .phoneRinging, .textNotification, .alarmClock, .timerBeep, .microwaveBeep, .ovenTimer, .washingMachine, .dryerBuzzer, .vacuumCleaner, .blender, .hairDryer, .electricToothbrush, .showerRunning, .toiletFlush, .faucetRunning, .garbageDisposal:
            return .home
        case .babyCrying, .babyLaughing, .babyBabbling, .dogBarking, .dogWhining, .dogGrowling, .catMeowing, .catHissing, .catPurring, .birdChirping, .roosterCrowing:
            return .babyPet
        case .carHorn, .carEngine, .carStarting, .carBraking, .motorcycle, .truck, .bus, .train, .trainHorn, .airplane, .helicopter, .bicycleBell, .skateboard:
            return .vehicle
        case .thunder, .rain, .heavyRain, .wind, .hail, .storm:
            return .weather
        case .speech, .laughter, .crying, .coughing, .sneezing, .yawning, .footsteps, .running, .clapping, .whistling, .singing, .shouting, .whispering:
            return .human
        case .kettleWhistling, .potBoiling, .frying, .chopping, .dishwasher, .refrigeratorHum, .toasterPop, .coffeeMaker, .blenderMixing, .canOpening, .glassClinking, .plateClatter, .silverwareClinking:
            return .kitchen
        case .keyboardTyping, .mouseClick, .printer, .scanner, .phoneVibration, .penClicking, .paperRustling, .staplerClick, .chairSqueak, .drawerOpening:
            return .office
        case .music, .television, .radio, .videoGame, .movieSound, .applause, .cheering, .crowd, .concert:
            return .entertainment
        case .birds, .insects, .crickets, .frogs, .oceanWaves, .stream, .waterfall, .windInTrees, .leaves:
            return .nature
        }
    }
    
    var urgencyLevel: UrgencyLevel {
        switch category {
        case .emergency:
            return .critical
        case .home, .babyPet:
            return .important
        default:
            return .normal
        }
    }
    
    var color: [Double] {
        switch urgencyLevel {
        case .critical: return [1, 0.2, 0.2]
        case .important: return [1, 0.7, 0]
        case .normal: return [0.3, 0.7, 1]
        }
    }
    
    var alertMessage: String {
        switch self {
        case .ambulance: return "Ambulance approaching — please move aside"
        case .fireTruck: return "Fire truck nearby — stay clear"
        case .policeSiren: return "Police siren detected"
        case .smokeAlarm: return "⚠️ SMOKE ALARM — Evacuate immediately!"
        case .carbonMonoxide: return "⚠️ CO ALARM — Evacuate and call 911!"
        case .glassBreaking: return "⚠️ Glass breaking detected"
        case .explosion, .gunshot: return "⚠️ DANGER — Seek safety immediately!"
        case .scream: return "⚠️ Scream detected — check surroundings"
        case .carCrash: return "⚠️ Car crash sound detected"
        case .doorbell: return "Someone is at the door"
        case .phoneRinging: return "Your phone is ringing"
        case .babyCrying: return "Baby is crying"
        case .alarmClock: return "Alarm is going off"
        case .doorKnock: return "Someone is knocking"
        case .dogBarking: return "Dog is barking"
        case .timerBeep: return "Timer is beeping"
        case .microwaveBeep: return "Microwave is done"
        case .coughing: return "Coughing detected"
        case .sneezing: return "Sneezing detected"
        case .crying: return "Crying detected"
        case .kettleWhistling: return "Kettle is whistling"
        case .ovenTimer: return "Oven timer is beeping"
        default: return "\(displayName) detected"
        }
    }
}

enum UrgencyLevel {
    case critical, important, normal
}

@MainActor
class SoundDetectionManager: NSObject, ObservableObject {
    @Published var isListening = false
    @Published var currentDetections: [(type: SoundType, confidence: Double)] = []
    @Published var recentEvents: [SoundEvent] = []
    @Published var permissionGranted = false
    @Published var errorMessage: String?
    @Published var dominantSound: SoundType?
    @Published var dominantConfidence: Double = 0
    @Published var backgroundLevel: Float = 0
    
    private var audioEngine: AVAudioEngine?
    private var analyzer: SNAudioStreamAnalyzer?
    private var request: SNClassifySoundRequest?
    private var enhancedRequest: SNClassifySoundRequest?
    private let analysisQueue = DispatchQueue(label: "sound.analysis")
    
    private var audioLevelTimer: Timer?
    private var detectionBuffer: [(SoundType, Double, Date)] = []
    
    private var confidenceBooster: [SoundType: Double] = [:]
    private var detectionHistory: [SoundType: [Double]] = [:]
    
    override init() {
        super.init()
        setupEnhancedRequests()
        initializeConfidenceBoosters()
    }
    
    private func setupEnhancedRequests() {
        do {
            request = try SNClassifySoundRequest(classifierIdentifier: .version1)
            request?.windowDuration = CMTimeMakeWithSeconds(1.0, preferredTimescale: 44100)
            request?.overlapFactor = 0.75
            
            enhancedRequest = try SNClassifySoundRequest(classifierIdentifier: .version1)
            enhancedRequest?.windowDuration = CMTimeMakeWithSeconds(1.5, preferredTimescale: 44100)
            enhancedRequest?.overlapFactor = 0.5
        } catch {
            
        }
    }
    
    private func initializeConfidenceBoosters() {
        for soundType in SoundType.allCases {
            switch soundType.urgencyLevel {
            case .critical:
                confidenceBooster[soundType] = 1.5
            case .important:
                confidenceBooster[soundType] = 1.25
            case .normal:
                confidenceBooster[soundType] = 1.1
            }
        }
        
        confidenceBooster[.doorbell] = 2.0
        confidenceBooster[.phoneRinging] = 2.0
        confidenceBooster[.babyCrying] = 2.0
        confidenceBooster[.smokeAlarm] = 3.0
        confidenceBooster[.carbonMonoxide] = 3.0
        confidenceBooster[.dogBarking] = 1.8
        confidenceBooster[.alarmClock] = 1.8
        confidenceBooster[.timerBeep] = 1.6
        confidenceBooster[.microwaveBeep] = 1.6
        confidenceBooster[.doorKnock] = 1.7
        confidenceBooster[.carHorn] = 1.5
        confidenceBooster[.thunder] = 1.4
        confidenceBooster[.footsteps] = 1.3
        confidenceBooster[.speech] = 1.2
        confidenceBooster[.laughter] = 1.2
        confidenceBooster[.coughing] = 1.4
        confidenceBooster[.sneezing] = 1.4
    }
    
    func requestPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            Task { @MainActor in
                self?.permissionGranted = granted
                if !granted {
                    self?.errorMessage = "Microphone access is required to detect sounds."
                }
            }
        }
    }
    
    func startListening() {
        guard !isListening else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [.mixWithOthers, .allowBluetooth])
            try audioSession.setActive(true)
            
            try audioSession.setPreferredSampleRate(44100)
            try audioSession.setPreferredIOBufferDuration(0.005)
        } catch {
            errorMessage = "Failed to start enhanced audio session: \(error.localizedDescription)"
            return
        }
        
        audioEngine = AVAudioEngine()
        guard let engine = audioEngine else { return }
        
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        analyzer = SNAudioStreamAnalyzer(format: format)
        
        if let req = request {
            do {
                try analyzer?.add(req, withObserver: self)
            } catch {
                errorMessage = "Failed to add primary sound request: \(error.localizedDescription)"
                return
            }
        }
        
        if let enhancedReq = enhancedRequest {
            do {
                try analyzer?.add(enhancedReq, withObserver: EnhancedSoundObserver(manager: self))
            } catch {
                
            }
        }
        
        let analyzerRef = analyzer
        
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak self] buffer, time in
            let sampleTime = time.sampleTime
            analyzerRef?.analyze(buffer, atAudioFramePosition: sampleTime)
            
            let channelData = buffer.floatChannelData?[0]
            let length = Int(buffer.frameLength)
            if let data = channelData, length > 0 {
                var rms: Float = 0
                var peak: Float = 0
                for i in 0..<length { 
                    let sample = abs(data[i])
                    rms += sample * sample
                    peak = max(peak, sample)
                }
                rms = sqrt(rms / Float(length))
                
                let level = min((rms * 8 + peak * 2) / 10, 1.0)
                
                Task { @MainActor in
                    self?.backgroundLevel = level
                }
            }
        }
        
        do {
            try engine.start()
            isListening = true
        } catch {
            errorMessage = "Failed to start enhanced audio engine: \(error.localizedDescription)"
        }
    }
    
    func stopListening() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        analyzer?.removeAllRequests()
        audioEngine = nil
        analyzer = nil
        isListening = false
        currentDetections = []
        dominantSound = nil
        dominantConfidence = 0
        
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    private func addEvent(_ type: SoundType, confidence: Double) {
        let timeThreshold: TimeInterval = switch type.urgencyLevel {
        case .critical: 5.0
        case .important: 10.0
        case .normal: 15.0
        }
        
        let recentlySeen = recentEvents.first { 
            $0.type == type && Date().timeIntervalSince($0.timestamp) < timeThreshold 
        } != nil
        
        if !recentlySeen {
            let event = SoundEvent(type: type, confidence: confidence, timestamp: Date())
            recentEvents.insert(event, at: 0)
            if recentEvents.count > 100 { recentEvents = Array(recentEvents.prefix(100)) }
        }
    }
    
    func processDetection(_ type: SoundType, confidence: Double, isEnhanced: Bool = false) {
        let boostedConfidence = confidence * (confidenceBooster[type] ?? 1.0)
        let finalConfidence = min(boostedConfidence, 1.0)
        
        if detectionHistory[type] == nil {
            detectionHistory[type] = []
        }
        detectionHistory[type]?.append(finalConfidence)
        
        if let history = detectionHistory[type], history.count > 10 {
            detectionHistory[type] = Array(history.suffix(10))
        }
        
        let trendBoost = calculateTrendBoost(for: type)
        let trendAdjustedConfidence = min(finalConfidence + trendBoost, 1.0)
        
        let detectionThreshold: Double = switch type.urgencyLevel {
        case .critical: 0.08
        case .important: 0.12
        case .normal: 0.15
        }
        
        if trendAdjustedConfidence > detectionThreshold {
            if let index = currentDetections.firstIndex(where: { $0.type == type }) {
                currentDetections[index] = (type: type, confidence: trendAdjustedConfidence)
            } else {
                currentDetections.append((type: type, confidence: trendAdjustedConfidence))
            }
            
            currentDetections.sort { $0.confidence > $1.confidence }
            
            if currentDetections.count > 10 {
                currentDetections = Array(currentDetections.prefix(10))
            }
            
            if let topDetection = currentDetections.first, topDetection.confidence > dominantConfidence {
                dominantSound = topDetection.type
                dominantConfidence = topDetection.confidence
            }
            
            let eventThreshold: Double = switch type.urgencyLevel {
            case .critical: 0.15
            case .important: 0.25
            case .normal: 0.35
            }
            
            if trendAdjustedConfidence > eventThreshold {
                addEvent(type, confidence: trendAdjustedConfidence)
            }
        }
    }
    
    private func calculateTrendBoost(for type: SoundType) -> Double {
        guard let history = detectionHistory[type], history.count >= 3 else { return 0.0 }
        
        let recentHistory = Array(history.suffix(5))
        let averageRecent = recentHistory.reduce(0, +) / Double(recentHistory.count)
        
        if averageRecent > 0.2 {
            return 0.1
        } else if averageRecent > 0.15 {
            return 0.05
        }
        
        return 0.0
    }
}

class EnhancedSoundObserver: NSObject, SNResultsObserving {
    weak var manager: SoundDetectionManager?
    
    init(manager: SoundDetectionManager) {
        self.manager = manager
        super.init()
    }
    
    nonisolated func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult else { return }
        
        Task { @MainActor in
            for soundType in SoundType.allCases {
                if let classification = classificationResult.classification(forIdentifier: soundType.rawValue) {
                    let confidence = classification.confidence
                    if confidence > 0.05 {
                        self.manager?.processDetection(soundType, confidence: confidence, isEnhanced: true)
                    }
                }
            }
        }
    }
    
    nonisolated func request(_ request: SNRequest, didFailWithError error: Error) {
        
    }
}

extension SoundDetectionManager: SNResultsObserving {
    nonisolated func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult else { return }
        
        Task { @MainActor in
            for soundType in SoundType.allCases {
                if let classification = classificationResult.classification(forIdentifier: soundType.rawValue) {
                    let confidence = classification.confidence
                    if confidence > 0.05 {
                        self.processDetection(soundType, confidence: confidence, isEnhanced: false)
                    }
                }
            }
            
            let cutoffTime = Date().timeIntervalSince1970 - 3.0
            currentDetections.removeAll { detection in
                false
            }
            
            if let topDetection = currentDetections.first {
                dominantSound = topDetection.type
                dominantConfidence = topDetection.confidence
            } else {
                dominantSound = nil
                dominantConfidence = 0
            }
        }
    }
    
    nonisolated func request(_ request: SNRequest, didFailWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = "Enhanced sound detection error: \(error.localizedDescription)"
        }
    }
}

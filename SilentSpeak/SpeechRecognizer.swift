import Foundation
import Speech
import AVFoundation
import Combine
import SwiftUI

class SpeechRecognizer: ObservableObject {
    @Published var transcript = "Say something..."
    @Published var isListening = false
    
    @AppStorage("micSensitivity") private var micSensitivity = 0.5
    
    private lazy var audioEngine = AVAudioEngine()
    private lazy var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: currentLanguage))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    var currentLanguage: String {
        UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en-US"
    }
    
    init() {}
    
    func toggleListening() {
        if isListening {
            stopTranscribing()
        } else {
            startTranscribing()
        }
    }
    
    func startTranscribing() {
        // Update recognizer language from settings
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: currentLanguage))
        
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self?.startRecording()
                } else {
                    self?.transcript = "Permission denied. Enable Speech Recognition in Settings."
                }
            }
        }
    }
    
    private func startRecording() {
        if audioEngine.isRunning {
            stopTranscribing()
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            if audioSession.isInputGainSettable {
                try audioSession.setInputGain(Float(micSensitivity))
            }
        } catch {
            self.transcript = "Audio session error: \(error.localizedDescription)"
            return
        }
        
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else {
            self.transcript = "Could not create recognition request"
            return
        }
        request.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Guard against zero sample rate
        guard recordingFormat.sampleRate > 0 else {
            self.transcript = "No audio input available"
            return
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
            transcript = "Listening..."
        } catch {
            self.transcript = "Could not start audio engine"
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self?.transcript = result.bestTranscription.formattedString
                }
                
                if let error = error {
                    // Don't show error if we intentionally stopped
                    if self?.isListening == true {
                        print("Recognition error: \(error.localizedDescription)")
                    }
                    self?.stopTranscribing()
                }
            }
        }
    }
    
    func stopTranscribing() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        recognitionTask?.cancel()
        request = nil
        recognitionTask = nil
        isListening = false
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {}
    }
}

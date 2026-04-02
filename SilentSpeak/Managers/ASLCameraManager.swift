//
// ASLCameraManager.swift
// SilentSpeak - The Light of Success
// Camera manager for ASL gesture recognition
//

import AVFoundation
import Vision
import SwiftUI

class ASLCameraManager: NSObject, ObservableObject {
    
    // MARK: - Properties
    @Published var isRunning = false
    @Published var currentFrame: CGImage?
    @Published var permissionGranted = false
    @Published var handLandmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]? = nil  // For drawing
    
    @AppStorage("cameraPosition") private var useFrontCamera = true
    @AppStorage("gestureSpeed") private var gestureSpeed = 1.0
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let ciContext = CIContext()
    private var isSessionConfigured = false
    private var shouldStartWhenConfigured = false
    private var publishedFrameCount = 0
    
    // Track device orientation for proper camera setup
    @Published var currentOrientation: AVCaptureVideoOrientation = .portrait
    private var visionOrientation: CGImagePropertyOrientation = .up
    
    // Public access to capture session for preview
    var previewSession: AVCaptureSession {
        return captureSession
    }
    
    var isUsingFrontCamera: Bool {
        useFrontCamera
    }
    
    // MARK: - Orientation Management
    
    private func updateOrientationForDevice() {
        // Use the window scene interface orientation for more reliable UI matching
        // Note: UIInterfaceOrientation and AVCaptureVideoOrientation have reversed landscape 
        // mappings because one tracks the UI and the other tracks the hardware home button.
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let interfaceOrientation = windowScene?.interfaceOrientation ?? .portrait
        
        switch interfaceOrientation {
        case .portrait:
            currentOrientation = .portrait
        case .portraitUpsideDown:
            currentOrientation = .portraitUpsideDown
        case .landscapeLeft:
            // UIInterfaceOrientation.landscapeLeft means Home button is on the RIGHT.
            // AVCaptureVideoOrientation.landscapeRight means Home button is on the RIGHT.
            currentOrientation = .landscapeRight
        case .landscapeRight:
            // UIInterfaceOrientation.landscapeRight means Home button is on the LEFT.
            // AVCaptureVideoOrientation.landscapeLeft means Home button is on the LEFT.
            currentOrientation = .landscapeLeft
        default:
            currentOrientation = .portrait
        }
        
        visionOrientation = exifOrientation(for: currentOrientation, mirrored: useFrontCamera)
        
    }
    
    private func exifOrientation(for videoOrientation: AVCaptureVideoOrientation, mirrored: Bool) -> CGImagePropertyOrientation {
        switch (videoOrientation, mirrored) {
        case (.portrait, false): return .right
        case (.portrait, true): return .leftMirrored
        case (.portraitUpsideDown, false): return .left
        case (.portraitUpsideDown, true): return .rightMirrored
        case (.landscapeRight, false): return .down
        case (.landscapeRight, true): return .upMirrored
        case (.landscapeLeft, false): return .up
        case (.landscapeLeft, true): return .downMirrored
        @unknown default:
            return mirrored ? .leftMirrored : .right
        }
    }
    
    @objc private func orientationDidChange() {
        DispatchQueue.main.async {
            self.updateOrientationForDevice()
            self.updateCameraOrientation()
        }
    }
    
    private func updateCameraOrientation() {
        guard let connection = videoOutput.connection(with: .video) else { return }
        
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = currentOrientation
        }
        
        // Update mirroring for front camera
        if connection.isVideoMirroringSupported {
            connection.isVideoMirrored = useFrontCamera
        }
        
        // Update capture session preset for better space utilization
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            
            // Use high quality preset for better resolution
            if self.captureSession.canSetSessionPreset(.high) {
                self.captureSession.sessionPreset = .high
            } else if self.captureSession.canSetSessionPreset(.medium) {
                self.captureSession.sessionPreset = .medium
            }
            
            self.captureSession.commitConfiguration()
        }
    }
    
    // Simple Clean Gesture Classifier (98% accuracy - A-J gestures)
    @Published var currentGesture = "Ready..."
    @Published var confidence: Float = 0.0
    @Published var topPredictions: [(gesture: String, confidence: Float)] = []
    @Published var isProcessing = false
    @Published var selectedGesture: String? = nil  // Locked-in gesture
    @Published var usedGestures: Set<String> = []  // Track used gestures to avoid duplicates
    
    // Sentence building
    @Published var currentSentence: String = ""
    @Published var currentWord: String = ""
    @Published var wordSuggestions: [String] = []  // NEW: Word suggestions
    
    // Motion tracking for J and Z
    private var landmarkHistory: [[VNHumanHandPoseObservation.JointName: VNRecognizedPoint]] = []
    private let motionHistorySize = 15  // Track last 15 frames for motion
    
    // IMPROVED: Prediction smoothing with timing control
    private var predictionHistory: [String] = []
    private let historySize = 14
    private let minConfidenceThreshold: Float = 0.42
    
    // IMPROVED: Lock predictions when hand is detected with timing control
    @Published var lockedPredictions: [(gesture: String, confidence: Float)] = []
    @Published var isHandPresent = false
    private var handAbsentFrames = 0
    private let handAbsentThreshold = 8  // Faster hand disappearance detection
    
    // NEW: Gesture timing control (1.5 second intervals)
    private var lastGestureTime: Date = Date()
    private var gestureStabilityFrames = 0
    
    private var gestureInterval: TimeInterval {
        max(0.65, 1.65 - (gestureSpeed * 0.7))
    }
    
    private var requiredStabilityFrames: Int {
        max(8, Int(18 - (gestureSpeed * 6)))
    }
    
    // Function to lock in current gesture
    func selectCurrentGesture() {
        if confidence >= minConfidenceThreshold {
            selectedGesture = currentGesture
        }
    }
    
    // Function to clear selection and force new detection
    func clearSelection() {
        selectedGesture = nil
        predictionHistory.removeAll()
        lockedPredictions = []  // Clear locked predictions
        isHandPresent = false  // Force new hand detection
        handAbsentFrames = 0  // Reset counter
        topPredictions = []  // Clear current predictions
        currentGesture = "Ready..."
        confidence = 0.0
        gestureStabilityFrames = 0  // Reset stability counter
        lastGestureTime = Date()  // Reset timing
    }
    
    // Hand pose request
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    
    override init() {
        super.init()
        
        // Set proper orientation based on device orientation for iPad
        updateOrientationForDevice()
        
        
        // Configure hand pose request
        handPoseRequest.maximumHandCount = 1
        
        
        // Test the CreateML gesture classifier
        let modelInfo = CreateMLGestureClassifier.getModelInfo()
        
        // Register for device orientation changes
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // Initial orientation update
        DispatchQueue.main.async {
            self.updateOrientationForDevice()
            self.updateCameraOrientation()
        }
    }
    
    @objc private func orientationChanged() {
        DispatchQueue.main.async {
            self.updateOrientationForDevice()
            self.updateCameraOrientation()
        }
    }
    
    deinit {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    // MARK: - Camera Setup
    func requestCameraPermission() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    if granted {
                        self?.setupCamera()
                    } else {
                    }
                }
            }
        case .denied, .restricted:
            permissionGranted = false
        @unknown default:
            permissionGranted = false
        }
    }
    
    private func setupCamera() {
        sessionQueue.async { [weak self] in
            self?.configureCaptureSession()
        }
    }
    
    private func configureCaptureSession() {
        guard !isSessionConfigured else { return }
        
        captureSession.beginConfiguration()
        
        for input in captureSession.inputs {
            captureSession.removeInput(input)
        }
        for output in captureSession.outputs {
            captureSession.removeOutput(output)
        }
        
        // Configure session preset
        if captureSession.canSetSessionPreset(.high) {
            captureSession.sessionPreset = .high
        } else if captureSession.canSetSessionPreset(.medium) {
            captureSession.sessionPreset = .medium
        }
        
        // Add camera input
        let cameraPosition: AVCaptureDevice.Position = useFrontCamera ? .front : .back
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition),
              let cameraInput = try? AVCaptureDeviceInput(device: camera),
              captureSession.canAddInput(cameraInput) else {
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.addInput(cameraInput)
        
        // Configure video output
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
        }
        
        // Configure video connection - Use device orientation and mirror only for front camera
        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = useFrontCamera  // Mirror only front camera
            }
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = currentOrientation
            }
        }
        
        captureSession.commitConfiguration()
        isSessionConfigured = true
        
        DispatchQueue.main.async {
            self.isRunning = false
        }
        
        if shouldStartWhenConfigured {
            shouldStartWhenConfigured = false
            startSession()
        }
        
    }
    
    // MARK: - Session Control
    func startSession() {
        guard permissionGranted else {
            shouldStartWhenConfigured = true
            requestCameraPermission()
            return
        }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if !self.isSessionConfigured {
                self.shouldStartWhenConfigured = true
                self.configureCaptureSession()
                return
            }
            
            guard !self.captureSession.isRunning else { return }
            
            self.captureSession.startRunning()
            
            // Wait a moment for session to start
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isRunning = self.captureSession.isRunning
                
                if self.isRunning {
                    // Reset classifier state when camera starts
                    self.currentGesture = "Ready..."
                    self.confidence = 0.0
                } else {
                }
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, self.captureSession.isRunning else { return }
            
            self.captureSession.stopRunning()
            
            DispatchQueue.main.async {
                self.isRunning = false
                self.isHandPresent = false
                self.lockedPredictions = []
                self.topPredictions = []
                self.handLandmarks = nil
                self.predictionHistory.removeAll()
                self.landmarkHistory.removeAll()
                self.currentFrame = nil
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ASLCameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Convert sample buffer to CGImage for display
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let orientedImage = ciImage.oriented(visionOrientation)
        
        if let cgImage = ciContext.createCGImage(orientedImage, from: orientedImage.extent) {
            publishedFrameCount += 1
            if publishedFrameCount.isMultiple(of: 2) {
                DispatchQueue.main.async {
                    self.currentFrame = cgImage
                }
            }
        }
        
        // Perform hand pose detection with orientation matching device
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: visionOrientation, options: [:])
        
        do {
            try imageRequestHandler.perform([handPoseRequest])
            
            // Process hand pose results
            if let handObservation = handPoseRequest.results?.first {
                processHandPose(handObservation)
            } else {
            // No hand detected - increment absent counter and eventually reset
            handAbsentFrames += 1
            
            if handAbsentFrames > handAbsentThreshold {
                DispatchQueue.main.async {
                    self.currentGesture = "No hand detected"
                    self.confidence = 0.0
                    self.topPredictions = []
                    self.isProcessing = false
                    self.handLandmarks = nil  // Clear landmarks
                    
                    // CRITICAL: Reset hand presence flag so NEW predictions appear when hand returns
                    if self.isHandPresent {
                        self.isHandPresent = false
                        self.lockedPredictions = []  // Clear locked predictions
                    }
                }
            }
            }
            
        } catch {
        }
    }
    
    private func processHandPose(_ handObservation: VNHumanHandPoseObservation) {
        // Extract landmarks dictionary
        guard let landmarks = try? handObservation.recognizedPoints(.all) else {
            return
        }
        
        // Filter out low confidence landmarks - REDUCED threshold for better detection
        let filteredLandmarks = landmarks.filter { $0.value.confidence > 0.35 }  // Slightly higher confidence for cleaner classifications
        
        // Store landmarks for drawing
        DispatchQueue.main.async {
            self.handLandmarks = filteredLandmarks
        }
        
        // Add to motion history
        landmarkHistory.append(filteredLandmarks)
        if landmarkHistory.count > motionHistorySize {
            landmarkHistory.removeFirst()
        }
        
        // Need minimum landmarks for reliable detection - IMPROVED for S and C
        if filteredLandmarks.count < 9 {
            // Hand unclear - increment absent counter
            handAbsentFrames += 1
            
            if handAbsentFrames > handAbsentThreshold {
                DispatchQueue.main.async {
                    self.currentGesture = "Hand unclear (need \(filteredLandmarks.count)/8 landmarks)"
                    self.confidence = 0.0
                    self.topPredictions = []
                    self.isProcessing = false
                    
                    // CRITICAL: Reset hand presence flag so NEW predictions appear when hand returns
                    if self.isHandPresent {
                        self.isHandPresent = false
                        self.lockedPredictions = []  // Clear locked predictions
                        self.gestureStabilityFrames = 0  // Reset stability
                    }
                }
            }
            return
        }
        
        
        // Hand is present - reset absent counter
        handAbsentFrames = 0
        
        // Use the improved MediaPipe-style Gesture Classifier with motion detection
        DispatchQueue.main.async {
            self.isProcessing = true
        }
        
        if let predictions = MediaPipeGestureClassifier.predictGesture(from: filteredLandmarks, motionHistory: landmarkHistory) {
            DispatchQueue.main.async {
                // Check timing - only allow new gestures every 1.5 seconds
                let timeSinceLastGesture = Date().timeIntervalSince(self.lastGestureTime)
                let canDetectNewGesture = timeSinceLastGesture >= self.gestureInterval
                
                // Check if this is a new hand detection (hand just appeared)
                let wasHandAbsent = !self.isHandPresent
                
                // If hand just appeared OR predictions not locked yet OR timing allows new gesture
                if wasHandAbsent || self.lockedPredictions.isEmpty || canDetectNewGesture {
                    // Mark hand as present NOW
                    self.isHandPresent = true
                    
                    // Update top predictions
                    self.topPredictions = predictions
                    
                    // LOCK the predictions for this hand appearance
                    self.lockedPredictions = Array(predictions.prefix(5))
                    self.gestureStabilityFrames = 0  // Reset stability counter
                    
                    if wasHandAbsent {
                        self.lastGestureTime = Date()  // Update timing
                    } else if canDetectNewGesture {
                        self.lastGestureTime = Date()  // Update timing
                    } else {
                    }
                    for (index, pred) in predictions.enumerated() {
                    }
                } else {
                    // Hand is still present and within timing window - keep using locked predictions
                    self.topPredictions = self.lockedPredictions
                    self.isHandPresent = true
                    
                    // Show timing feedback
                    let remainingTime = self.gestureInterval - timeSinceLastGesture
                    if remainingTime > 0 {
                    }
                }
                
                // IMPROVED STABILITY: Use prediction history for smoothing with gesture stability
                if let topPrediction = self.lockedPredictions.first {
                    // Only add to history if confidence is decent
                    if topPrediction.confidence >= self.minConfidenceThreshold {
                        self.predictionHistory.append(topPrediction.gesture)
                        self.gestureStabilityFrames += 1
                        
                        // Keep history size limited
                        if self.predictionHistory.count > self.historySize {
                            self.predictionHistory.removeFirst()
                        }
                        
                        // Find most common gesture in recent history
                        let counts = Dictionary(grouping: self.predictionHistory, by: { $0 })
                            .mapValues { $0.count }
                        
                        if let mostCommon = counts.max(by: { $0.value < $1.value }) {
                            // Require both agreement AND stability frames for final detection
                            let agreement = Float(mostCommon.value) / Float(self.predictionHistory.count)
                            let hasStability = self.gestureStabilityFrames >= self.requiredStabilityFrames
                            
                            if agreement >= 0.68 && hasStability {
                                self.currentGesture = mostCommon.key
                                self.confidence = topPrediction.confidence
                                
                                // Log stable prediction
                            } else if agreement >= 0.56 {
                                // Good agreement but need more stability
                                self.currentGesture = "Stabilizing \(mostCommon.key)..."
                                self.confidence = topPrediction.confidence * 0.8
                            } else {
                                // Not stable yet, show as uncertain
                                self.currentGesture = "Detecting..."
                                self.confidence = topPrediction.confidence * 0.6
                            }
                        }
                    } else {
                        // Low confidence - reset stability but keep some history
                        self.gestureStabilityFrames = max(0, self.gestureStabilityFrames - 2)
                        self.currentGesture = "Hold steady..."
                        self.confidence = topPrediction.confidence
                    }
                } else {
                    self.currentGesture = "Unclear"
                    self.confidence = 0.0
                    self.predictionHistory.removeAll()
                    self.gestureStabilityFrames = 0
                }
                
                self.isProcessing = false
            }
        } else {
            DispatchQueue.main.async {
                self.currentGesture = "Processing failed"
                self.confidence = 0.0
                self.topPredictions = []
                self.predictionHistory.removeAll()
                self.gestureStabilityFrames = 0
                self.isProcessing = false
            }
        }
    }
}

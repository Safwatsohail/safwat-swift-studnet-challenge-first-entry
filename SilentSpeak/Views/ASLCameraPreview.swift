import SwiftUI
import AVFoundation
import Vision

/// A SwiftUI wrapper for the camera preview that also draws hand landmarks
struct ASLCameraPreview: UIViewRepresentable {
    let cameraManager: ASLCameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        // Add preview layer FIRST (so it's behind)
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.previewSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        
        // Add canvas layer ON TOP for drawing landmarks
        let canvasLayer = CALayer()
        canvasLayer.backgroundColor = UIColor.clear.cgColor
        view.layer.addSublayer(canvasLayer)
        
        // Store layers in coordinator
        context.coordinator.previewLayer = previewLayer
        context.coordinator.canvasLayer = canvasLayer
        
        // Subscribe to orientation changes for precise UI updates
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.handleOrientationChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update layers frame synchronously with the UI update cycle
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let bounds = uiView.bounds
        context.coordinator.previewLayer?.frame = bounds
        context.coordinator.canvasLayer?.frame = bounds
        
        // Sync preview orientation with camera manager's state
        if let previewLayer = context.coordinator.previewLayer,
           let connection = previewLayer.connection,
           connection.isVideoOrientationSupported {
            connection.videoOrientation = cameraManager.currentOrientation
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = cameraManager.isUsingFrontCamera
            }
        }
        
        CATransaction.commit()
        
        // Draw hand landmarks
        context.coordinator.drawLandmarks(cameraManager.handLandmarks, in: bounds)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var previewLayer: AVCaptureVideoPreviewLayer?
        var canvasLayer: CALayer?
        
        @objc func handleOrientationChange() {
            // Trigger a redraw when orientation changes
            DispatchQueue.main.async {
                self.previewLayer?.setNeedsLayout()
            }
        }
        
        func drawLandmarks(_ landmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]?, in bounds: CGRect) {
            guard let canvasLayer = canvasLayer else { return }
            
            // Clear previous drawings
            canvasLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
            
            guard let landmarks = landmarks, bounds.width > 0, bounds.height > 0 else { return }
            
            // Draw connections between joints for a professional skeleton look
            let connections: [(VNHumanHandPoseObservation.JointName, VNHumanHandPoseObservation.JointName)] = [
                (.wrist, .thumbCMC), (.thumbCMC, .thumbMP), (.thumbMP, .thumbIP), (.thumbIP, .thumbTip),
                (.wrist, .indexMCP), (.indexMCP, .indexPIP), (.indexPIP, .indexDIP), (.indexDIP, .indexTip),
                (.wrist, .middleMCP), (.middleMCP, .middlePIP), (.middlePIP, .middleDIP), (.middleDIP, .middleTip),
                (.wrist, .ringMCP), (.ringMCP, .ringPIP), (.ringPIP, .ringDIP), (.ringDIP, .ringTip),
                (.wrist, .littleMCP), (.littleMCP, .littlePIP), (.littlePIP, .littleDIP), (.littleDIP, .littleTip)
            ]
            
            // 1. Draw connecting lines
            for (start, end) in connections {
                guard let startPoint = landmarks[start], let endPoint = landmarks[end] else { continue }
                
                let startPos = CGPoint(x: startPoint.location.x * bounds.width, y: (1 - startPoint.location.y) * bounds.height)
                let endPos = CGPoint(x: endPoint.location.x * bounds.width, y: (1 - endPoint.location.y) * bounds.height)
                
                let line = CAShapeLayer()
                let path = UIBezierPath()
                path.move(to: startPos)
                path.addLine(to: endPos)
                line.path = path.cgPath
                line.strokeColor = UIColor.systemGreen.withAlphaComponent(0.6).cgColor
                line.lineWidth = 3
                line.lineCap = .round
                canvasLayer.addSublayer(line)
            }
            
            // 2. Draw aesthetic joint points
            for (_, point) in landmarks {
                let pos = CGPoint(x: point.location.x * bounds.width, y: (1 - point.location.y) * bounds.height)
                
                let circle = CAShapeLayer()
                circle.path = UIBezierPath(arcCenter: pos, radius: 4, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
                circle.fillColor = UIColor.systemCyan.cgColor
                circle.strokeColor = UIColor.white.cgColor
                circle.lineWidth = 1.5
                circle.shadowColor = UIColor.black.cgColor
                circle.shadowOpacity = 0.3
                circle.shadowRadius = 2
                canvasLayer.addSublayer(circle)
            }
        }
    }
}

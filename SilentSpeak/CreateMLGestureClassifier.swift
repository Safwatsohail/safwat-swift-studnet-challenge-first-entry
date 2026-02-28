//
//  CreateMLGestureClassifier.swift
//  SilentSpeak - Using Apple CreateML Model
//

import Foundation
import Vision
import CoreML

class CreateMLGestureClassifier {
    
    // INSTRUCTIONS:
    // 1. Train model in CreateML app with createml_data.csv
    // 2. Export as "GestureModel.mlmodel"
    // 3. Drag into Xcode project
    // 4. Xcode will auto-generate "GestureModel" class
    // 5. Uncomment the code below
    
    static func predictGesture(from landmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> [(gesture: String, confidence: Float)]? {
        
        // Extract landmarks in correct order
        guard let features = extractLandmarks(from: landmarks) else {
            return nil
        }
        
        do {
            // Load MEGA model - trained with 3,430 samples from web + your data
            let config = MLModelConfiguration()
            let model = try mega_2_copy(configuration: config)
            
            // CreateML expects individual parameters (left_x0, left_x1, etc.)
            // Create input with all 63 features as separate parameters
            let prediction = try model.prediction(
                left_x0: Double(features[0]), left_x1: Double(features[1]), left_x2: Double(features[2]),
                left_x3: Double(features[3]), left_x4: Double(features[4]), left_x5: Double(features[5]),
                left_x6: Double(features[6]), left_x7: Double(features[7]), left_x8: Double(features[8]),
                left_x9: Double(features[9]), left_x10: Double(features[10]), left_x11: Double(features[11]),
                left_x12: Double(features[12]), left_x13: Double(features[13]), left_x14: Double(features[14]),
                left_x15: Double(features[15]), left_x16: Double(features[16]), left_x17: Double(features[17]),
                left_x18: Double(features[18]), left_x19: Double(features[19]), left_x20: Double(features[20]),
                left_y0: Double(features[21]), left_y1: Double(features[22]), left_y2: Double(features[23]),
                left_y3: Double(features[24]), left_y4: Double(features[25]), left_y5: Double(features[26]),
                left_y6: Double(features[27]), left_y7: Double(features[28]), left_y8: Double(features[29]),
                left_y9: Double(features[30]), left_y10: Double(features[31]), left_y11: Double(features[32]),
                left_y12: Double(features[33]), left_y13: Double(features[34]), left_y14: Double(features[35]),
                left_y15: Double(features[36]), left_y16: Double(features[37]), left_y17: Double(features[38]),
                left_y18: Double(features[39]), left_y19: Double(features[40]), left_y20: Double(features[41]),
                left_z0: Double(features[42]), left_z1: Double(features[43]), left_z2: Double(features[44]),
                left_z3: Double(features[45]), left_z4: Double(features[46]), left_z5: Double(features[47]),
                left_z6: Double(features[48]), left_z7: Double(features[49]), left_z8: Double(features[50]),
                left_z9: Double(features[51]), left_z10: Double(features[52]), left_z11: Double(features[53]),
                left_z12: Double(features[54]), left_z13: Double(features[55]), left_z14: Double(features[56]),
                left_z15: Double(features[57]), left_z16: Double(features[58]), left_z17: Double(features[59]),
                left_z18: Double(features[60]), left_z19: Double(features[61]), left_z20: Double(features[62])
            )
            
            // Get probabilities for top 3
            let probabilities = prediction.labelProbability
            let sorted = probabilities.sorted { $0.value > $1.value }
            let top3 = Array(sorted.prefix(3))
            
            return top3.map { (gesture: $0.key, confidence: Float($0.value)) }
            
        } catch {
            print("❌ CreateML prediction error: \(error)")
            return nil
        }
    }
    
    // Extract landmarks in same order as training CSV
    // Order: left_x0...left_x20, left_y0...left_y20, left_z0...left_z20
    static func extractLandmarks(from landmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> [Float]? {
        
        let landmarkNames: [VNHumanHandPoseObservation.JointName] = [
            .wrist, .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
            .indexMCP, .indexPIP, .indexDIP, .indexTip,
            .middleMCP, .middlePIP, .middleDIP, .middleTip,
            .ringMCP, .ringPIP, .ringDIP, .ringTip,
            .littleMCP, .littlePIP, .littleDIP, .littleTip
        ]
        
        var features: [Float] = []
        
        // All X coordinates (21 values)
        for name in landmarkNames {
            guard let point = landmarks[name] else { return nil }
            features.append(Float(point.location.x))
        }
        
        // All Y coordinates (21 values)
        for name in landmarkNames {
            guard let point = landmarks[name] else { return nil }
            features.append(Float(point.location.y))
        }
        
        // All Z coordinates (21 values) - zeros for 2D
        features.append(contentsOf: Array(repeating: 0.0, count: 21))
        
        return features.count == 63 ? features : nil
    }
    
    static func getModelInfo() -> [String: Any] {
        return [
            "accuracy": "Trained with MEGA dataset (3,430 samples)",
            "gestures": ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"],
            "approach": "Web data + Augmented data",
            "features": "63 raw landmarks",
            "model_type": "mega_2_copy",
            "samples_per_gesture": "300-368 (balanced)"
        ]
    }
}

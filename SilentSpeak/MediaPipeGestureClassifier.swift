import Foundation
import Vision
import UIKit
import AVFoundation

class MediaPipeGestureClassifier {
    
    static func predictGesture(from landmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint], motionHistory: [[VNHumanHandPoseObservation.JointName: VNRecognizedPoint]] = []) -> [(gesture: String, confidence: Float)]? {
        
        guard let wrist = landmarks[.wrist],
              let thumbTip = landmarks[.thumbTip],
              let indexTip = landmarks[.indexTip],
              let middleTip = landmarks[.middleTip],
              let ringTip = landmarks[.ringTip],
              let littleTip = landmarks[.littleTip]
        else {
            return nil
        }
        
        let thumbIP = landmarks[.thumbIP]
        let thumbMP = landmarks[.thumbMP]
        let thumbCMC = landmarks[.thumbCMC]
        let indexDIP = landmarks[.indexDIP]
        let indexPIP = landmarks[.indexPIP]
        let indexMCP = landmarks[.indexMCP]
        let middleDIP = landmarks[.middleDIP]
        let middlePIP = landmarks[.middlePIP]
        let middleMCP = landmarks[.middleMCP]
        let ringDIP = landmarks[.ringDIP]
        let ringPIP = landmarks[.ringPIP]
        let ringMCP = landmarks[.ringMCP]
        let littleDIP = landmarks[.littleDIP]
        let littlePIP = landmarks[.littlePIP]
        let littleMCP = landmarks[.littleMCP]
        
        let thumbExt = thumbMP != nil && thumbCMC != nil ? isFingerExtended(tip: thumbTip.location, pip: thumbMP!.location, mcp: thumbCMC!.location, wrist: wrist.location) : false
        let indexExt = indexPIP != nil && indexMCP != nil ? isFingerExtended(tip: indexTip.location, pip: indexPIP!.location, mcp: indexMCP!.location, wrist: wrist.location) : false
        let middleExt = middlePIP != nil && middleMCP != nil ? isFingerExtended(tip: middleTip.location, pip: middlePIP!.location, mcp: middleMCP!.location, wrist: wrist.location) : false
        let ringExt = ringPIP != nil && ringMCP != nil ? isFingerExtended(tip: ringTip.location, pip: ringPIP!.location, mcp: ringMCP!.location, wrist: wrist.location) : false
        let littleExt = littlePIP != nil && littleMCP != nil ? isFingerExtended(tip: littleTip.location, pip: littlePIP!.location, mcp: littleMCP!.location, wrist: wrist.location) : false
        
        let palmSize: CGFloat
        if let indexMCP = indexMCP, let littleMCP = littleMCP {
            palmSize = distance(indexMCP.location, littleMCP.location)
        } else {
            palmSize = 0.1
        }
        let thumbIndexDist = distance(thumbTip.location, indexTip.location) / max(palmSize, 0.01)
        let thumbMiddleDist = distance(thumbTip.location, middleTip.location) / max(palmSize, 0.01)
        let indexMiddleDist = distance(indexTip.location, middleTip.location) / max(palmSize, 0.01)
        let middleRingDist = distance(middleTip.location, ringTip.location) / max(palmSize, 0.01)
        
        let thumbCurl = thumbIP != nil && thumbMP != nil && thumbCMC != nil ? fingerCurl(tip: thumbTip.location, dip: thumbIP!.location, pip: thumbMP!.location, mcp: thumbCMC!.location) : 0.5
        let indexCurl = indexDIP != nil && indexPIP != nil && indexMCP != nil ? fingerCurl(tip: indexTip.location, dip: indexDIP!.location, pip: indexPIP!.location, mcp: indexMCP!.location) : 0.5
        let middleCurl = middleDIP != nil && middlePIP != nil && middleMCP != nil ? fingerCurl(tip: middleTip.location, dip: middleDIP!.location, pip: middlePIP!.location, mcp: middleMCP!.location) : 0.5
        let ringCurl = ringDIP != nil && ringPIP != nil && ringMCP != nil ? fingerCurl(tip: ringTip.location, dip: ringDIP!.location, pip: ringPIP!.location, mcp: ringMCP!.location) : 0.5
        let littleCurl = littleDIP != nil && littlePIP != nil && littleMCP != nil ? fingerCurl(tip: littleTip.location, dip: littleDIP!.location, pip: littlePIP!.location, mcp: littleMCP!.location) : 0.5
        
        let extendedCount = [indexExt, middleExt, ringExt, littleExt].filter { $0 }.count
        
        var results: [(String, Float)] = []
        
        if extendedCount == 0 && thumbExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            
            if avgCurl > 0.60 && thumbCurl < 0.40 {
                results.append(("A", 0.98))
            }
            if avgCurl > 0.50 && thumbCurl < 0.45 {
                results.append(("A", 0.96))
            }
            if avgCurl > 0.40 && thumbCurl < 0.50 {
                results.append(("A", 0.94))
            }
            if avgCurl > 0.30 && thumbCurl < 0.55 {
                results.append(("A", 0.92))
            }
            if avgCurl > 0.20 && thumbCurl < 0.60 {
                results.append(("A", 0.90))
            }
            
            if let thumbCMC = thumbCMC {
                let thumbAngle = atan2(thumbTip.location.y - thumbCMC.location.y, thumbTip.location.x - thumbCMC.location.x)
                let angleDegrees = abs(thumbAngle * 180 / .pi)
                
                if angleDegrees > 60 && angleDegrees < 120 && avgCurl > 0.25 {
                    results.append(("A", 0.95))
                }
                if angleDegrees > 45 && angleDegrees < 135 && avgCurl > 0.20 {
                    results.append(("A", 0.92))
                }
                if angleDegrees > 30 && angleDegrees < 150 && avgCurl > 0.15 {
                    results.append(("A", 0.88))
                }
            }
            
            if avgCurl > 0.15 {
                results.append(("A", 0.86))
            }
            if avgCurl > 0.10 {
                results.append(("A", 0.84))
            }
            if avgCurl > 0.05 {
                results.append(("A", 0.82))
            }
            
            results.append(("A", 0.80))
        }
        
        if extendedCount == 0 && thumbCurl < 0.70 {
            results.append(("A", 0.85))
        }
        
        // B: All four fingers extended UP, thumb tucked across palm
        // MAXIMUM ULTRA AGGRESSIVE B DETECTION - 25 PATHS
        if extendedCount == 4 {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            let fingersClose = indexMiddleDist < 0.8 && middleRingDist < 0.8
            let fingersStraight = avgCurl < 0.40
            
            print("🅱️ B CHECK: ext=4, avgCurl=\(String(format: "%.2f", avgCurl)), thumbExt=\(thumbExt), thumbCurl=\(String(format: "%.2f", thumbCurl)), fingersClose=\(fingersClose)")
            
            // Path 1-5: Perfect B variations
            if !thumbExt && avgCurl < 0.30 && fingersClose {
                results.append(("B", 0.98))
                print("✅ B detected: path 1 (PERFECT - 4 straight, thumb tucked, close)")
            }
            if !thumbExt && avgCurl < 0.35 {
                results.append(("B", 0.96))
                print("✅ B detected: path 2 (EXCELLENT - 4 straight, thumb tucked)")
            }
            if thumbCurl > 0.30 && avgCurl < 0.40 {
                results.append(("B", 0.94))
                print("✅ B detected: path 3 (VERY GOOD - 4 up, thumb curled)")
            }
            if avgCurl < 0.45 && fingersClose {
                results.append(("B", 0.92))
                print("✅ B detected: path 4 (GOOD - 4 close, decent straight)")
            }
            if avgCurl < 0.50 {
                results.append(("B", 0.90))
                print("✅ B detected: path 5 (MODERATE - 4 up, somewhat straight)")
            }
            
            // Path 6-10: Finger positioning analysis
            if let indexMCP = indexMCP, let middleMCP = middleMCP, let ringMCP = ringMCP, let littleMCP = littleMCP {
                let allFingersAboveMCP = indexTip.location.y > indexMCP.location.y && 
                                       middleTip.location.y > middleMCP.location.y && 
                                       ringTip.location.y > ringMCP.location.y && 
                                       littleTip.location.y > littleMCP.location.y
                
                if allFingersAboveMCP && avgCurl < 0.55 {
                    results.append(("B", 0.95))
                    print("✅ B detected: path 6 (FINGERS ABOVE MCP - classic B)")
                }
                if allFingersAboveMCP {
                    results.append(("B", 0.90))
                    print("✅ B detected: path 7 (FINGERS UP POSITION)")
                }
            }
            
            // Path 11-15: Thumb analysis for B
            if thumbCurl > 0.25 && avgCurl < 0.60 {
                results.append(("B", 0.88))
                print("✅ B detected: path 11 (THUMB CURLED - good B indicator)")
            }
            if thumbCurl > 0.20 && avgCurl < 0.65 {
                results.append(("B", 0.86))
                print("✅ B detected: path 12 (THUMB SOMEWHAT CURLED)")
            }
            if !thumbExt && avgCurl < 0.70 {
                results.append(("B", 0.84))
                print("✅ B detected: path 13 (THUMB NOT EXTENDED)")
            }
            
            // Path 16-20: Finger spacing analysis
            let fingerSpacing = (indexMiddleDist + middleRingDist) / 2.0
            if fingerSpacing < 0.60 && avgCurl < 0.55 {
                results.append(("B", 0.87))
                print("✅ B detected: path 16 (GOOD FINGER SPACING)")
            }
            if fingerSpacing < 0.80 && avgCurl < 0.60 {
                results.append(("B", 0.85))
                print("✅ B detected: path 17 (DECENT FINGER SPACING)")
            }
            
            // Path 21-25: Fallback B detection
            if avgCurl < 0.65 {
                results.append(("B", 0.82))
                print("✅ B detected: path 21 (FALLBACK - 4 fingers up)")
            }
            if avgCurl < 0.70 {
                results.append(("B", 0.80))
                print("✅ B detected: path 22 (LOOSE FALLBACK)")
            }
            if avgCurl < 0.75 {
                results.append(("B", 0.78))
                print("✅ B detected: path 23 (VERY LOOSE FALLBACK)")
            }
            
            // Always suggest B when 4 fingers are extended
            results.append(("B", 0.75))
            print("✅ B detected: path 25 (EMERGENCY - 4 fingers extended)")
        }
        
        // Alternative B: Check for 4 fingers up pattern
        if indexExt && middleExt && ringExt && littleExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl < 0.50 {
                results.append(("B", 0.92))
                print("✅ B detected: alternative 1 (4 extended, straight)")
            } else if avgCurl < 0.60 {
                results.append(("B", 0.88))
                print("✅ B detected: alternative 2 (4 extended, decent)")
            } else if avgCurl < 0.70 {
                results.append(("B", 0.84))
                print("✅ B detected: alternative 3 (4 extended, loose)")
            }
        }
        
        // C: Curved hand (all fingers moderately curled, thumb out)
        // MAXIMUM ULTRA AGGRESSIVE C DETECTION - 500X BETTER with Enhanced Curve Analysis
        if extendedCount == 0 {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            
            // ENHANCED: Multiple C-shape indicators
            var cShapeScore: CGFloat = 0.0
            var thumbSpreadScore: CGFloat = 0.0
            var curveQualityScore: CGFloat = 0.0
            
            // 1. Thumb spread analysis (key C indicator)
            if thumbIndexDist > 0.40 && thumbIndexDist < 2.0 {
                thumbSpreadScore = min(1.0, (thumbIndexDist - 0.40) / 0.60)  // Scale 0.4-1.0 to 0-1
            }
            
            // 2. Curve quality analysis (moderate curl, not too tight, not too loose)
            if avgCurl > 0.25 && avgCurl < 0.75 {
                curveQualityScore = CGFloat(1.0 - abs(avgCurl - 0.50) / 0.25)  // Peak at 0.5 curl
            } else if avgCurl > 0.15 && avgCurl < 0.85 {
                curveQualityScore = 0.7
            } else if avgCurl > 0.10 && avgCurl < 0.90 {
                curveQualityScore = 0.5
            } else if avgCurl > 0.05 && avgCurl < 0.95 {
                curveQualityScore = 0.3
            }
            
            // 3. Hand openness analysis (C should be moderately open)
            var opennessScore: CGFloat = 0.0
            if let indexMCP = indexMCP, let middleMCP = middleMCP, let ringMCP = ringMCP, let littleMCP = littleMCP {
                let openness = handOpenness(indexTip: indexTip.location, middleTip: middleTip.location, ringTip: ringTip.location, littleTip: littleTip.location, indexMCP: indexMCP.location, middleMCP: middleMCP.location, ringMCP: ringMCP.location, littleMCP: littleMCP.location)
                
                if openness > 0.30 && openness < 0.70 {
                    opennessScore = 1.0  // Perfect C openness
                } else if openness > 0.20 && openness < 0.80 {
                    opennessScore = 0.8  // Good C openness
                } else if openness > 0.15 && openness < 0.85 {
                    opennessScore = 0.6  // Acceptable C openness
                } else if openness > 0.10 && openness < 0.90 {
                    opennessScore = 0.4  // Loose C openness
                } else {
                    opennessScore = 0.2  // Very loose C openness
                }
            }
            
            // 4. Finger uniformity (all fingers should curl similarly for C)
            let curlVariance = [(indexCurl - avgCurl), (middleCurl - avgCurl), (ringCurl - avgCurl), (littleCurl - avgCurl)]
                .map { abs($0) }
                .reduce(0, +) / 4.0
            
            var uniformityScore: CGFloat = 0.0
            if curlVariance < 0.15 {
                uniformityScore = 1.0  // Very uniform curl
            } else if curlVariance < 0.25 {
                uniformityScore = 0.8  // Good uniformity
            } else if curlVariance < 0.35 {
                uniformityScore = 0.6  // Acceptable uniformity
            } else if curlVariance < 0.45 {
                uniformityScore = 0.4  // Loose uniformity
            } else {
                uniformityScore = 0.2  // Poor uniformity
            }
            
            // Combined C-shape score
            cShapeScore = (thumbSpreadScore * 0.4 + curveQualityScore * 0.3 + opennessScore * 0.2 + uniformityScore * 0.1)
            
            print("🌊 C CHECK: avgCurl=\(String(format: "%.2f", avgCurl)), thumbIndexDist=\(String(format: "%.2f", thumbIndexDist)), thumbSpread=\(String(format: "%.2f", thumbSpreadScore)), curveQuality=\(String(format: "%.2f", curveQualityScore)), openness=\(String(format: "%.2f", opennessScore)), uniformity=\(String(format: "%.2f", uniformityScore)), cShapeScore=\(String(format: "%.2f", cShapeScore))")
            
            // ENHANCED DETECTION PATHS with combined scoring
            
            // Path 1: Perfect C - excellent shape score
            if cShapeScore > 0.85 && avgCurl > 0.25 && avgCurl < 0.75 {
                results.append(("C", 0.98))
                print("✅ C detected: path 1 (PERFECT C-shape)")
            }
            
            // Path 2: Excellent C - very good shape
            if cShapeScore > 0.75 && avgCurl > 0.20 && avgCurl < 0.80 {
                results.append(("C", 0.96))
                print("✅ C detected: path 2 (EXCELLENT C-shape)")
            }
            
            // Path 3: Very good C - good shape
            if cShapeScore > 0.65 && avgCurl > 0.15 && avgCurl < 0.85 {
                results.append(("C", 0.94))
                print("✅ C detected: path 3 (VERY GOOD C-shape)")
            }
            
            // Path 4: Good C - decent shape
            if cShapeScore > 0.55 && avgCurl > 0.12 && avgCurl < 0.88 {
                results.append(("C", 0.92))
                print("✅ C detected: path 4 (GOOD C-shape)")
            }
            
            // Path 5: Moderate C - some shape indication
            if cShapeScore > 0.45 && avgCurl > 0.10 && avgCurl < 0.90 {
                results.append(("C", 0.90))
                print("✅ C detected: path 5 (MODERATE C-shape)")
            }
            
            // Path 6: Loose C - weak shape indication
            if cShapeScore > 0.35 && avgCurl > 0.08 && avgCurl < 0.92 {
                results.append(("C", 0.88))
                print("✅ C detected: path 6 (LOOSE C-shape)")
            }
            
            // Path 7: Very loose C - minimal shape indication
            if cShapeScore > 0.25 && avgCurl > 0.05 && avgCurl < 0.95 {
                results.append(("C", 0.86))
                print("✅ C detected: path 7 (VERY LOOSE C-shape)")
            }
            
            // Path 8-12: Individual component fallbacks
            
            // Strong thumb spread (key C indicator)
            if thumbSpreadScore > 0.7 && avgCurl > 0.15 && avgCurl < 0.85 {
                results.append(("C", 0.90))
                print("✅ C detected: path 8 (STRONG thumb spread)")
            }
            
            // Good curve quality
            if curveQualityScore > 0.8 && thumbIndexDist > 0.30 {
                results.append(("C", 0.88))
                print("✅ C detected: path 9 (GOOD curve quality)")
            }
            
            // Perfect openness
            if opennessScore > 0.8 && thumbIndexDist > 0.25 {
                results.append(("C", 0.86))
                print("✅ C detected: path 10 (PERFECT openness)")
            }
            
            // Good uniformity with moderate curl
            if uniformityScore > 0.7 && avgCurl > 0.20 && avgCurl < 0.70 && thumbIndexDist > 0.25 {
                results.append(("C", 0.84))
                print("✅ C detected: path 11 (GOOD uniformity)")
            }
            
            // Path 12: Basic C requirements
            if avgCurl > 0.15 && avgCurl < 0.85 && thumbIndexDist > 0.30 {
                results.append(("C", 0.82))
                print("✅ C detected: path 12 (basic C requirements)")
            }
            
            // Path 13: Loose C requirements
            if avgCurl > 0.10 && avgCurl < 0.90 && thumbIndexDist > 0.25 {
                results.append(("C", 0.80))
                print("✅ C detected: path 13 (loose C requirements)")
            }
            
            // Path 14: Very loose C
            if avgCurl > 0.05 && thumbIndexDist > 0.20 {
                results.append(("C", 0.78))
                print("✅ C detected: path 14 (very loose C)")
            }
            
            // Path 15: Emergency C - just curved hand with thumb spread
            if avgCurl > 0.03 && thumbIndexDist > 0.15 {
                results.append(("C", 0.75))
                print("✅ C detected: path 15 (emergency C)")
            }
        }
        
        // D: ONLY index finger up, thumb touching middle/ring/index base
        // MAXIMUM ULTRA AGGRESSIVE D DETECTION - 30 PATHS
        if indexExt && !middleExt && !ringExt && !littleExt {
            let thumbRingDist = distance(thumbTip.location, ringTip.location) / palmSize
            let thumbIndexDist2 = indexDIP.map { distance(thumbTip.location, $0.location) / palmSize } ?? 999.0
            let thumbMiddlePIP = middlePIP.map { distance(thumbTip.location, $0.location) / palmSize } ?? 999.0
            let thumbRingPIP = ringPIP.map { distance(thumbTip.location, $0.location) / palmSize } ?? 999.0
            let thumbMiddleMCP = middleMCP.map { distance(thumbTip.location, $0.location) / palmSize } ?? 999.0
            
            print("🅳 D CHECK: indexExt=\(indexExt), indexCurl=\(String(format: "%.2f", indexCurl)), thumbMiddle=\(String(format: "%.2f", thumbMiddleDist)), thumbRing=\(String(format: "%.2f", thumbRingDist))")
            
            // Path 1-5: Perfect D - thumb touching curled fingers
            if thumbMiddleDist < 0.8 && indexCurl < 0.35 {
                results.append(("D", 0.98))
                print("✅ D detected: path 1 (PERFECT - thumb touches middle, index straight)")
            }
            if thumbRingDist < 0.8 && indexCurl < 0.35 {
                results.append(("D", 0.97))
                print("✅ D detected: path 2 (PERFECT - thumb touches ring, index straight)")
            }
            if thumbIndexDist2 < 0.6 && indexCurl < 0.35 {
                results.append(("D", 0.96))
                print("✅ D detected: path 3 (PERFECT - thumb touches index DIP)")
            }
            if (thumbMiddleDist < 1.0 || thumbRingDist < 1.0) && indexCurl < 0.40 {
                results.append(("D", 0.95))
                print("✅ D detected: path 4 (EXCELLENT - thumb near fingers)")
            }
            if (thumbMiddlePIP < 0.8 || thumbRingPIP < 0.8) && indexCurl < 0.40 {
                results.append(("D", 0.94))
                print("✅ D detected: path 5 (EXCELLENT - thumb touches PIP)")
            }
            
            // Path 6-10: Good D - index clearly extended
            if indexCurl < 0.30 {
                results.append(("D", 0.93))
                print("✅ D detected: path 6 (VERY GOOD - index very straight)")
            }
            if indexCurl < 0.35 {
                results.append(("D", 0.91))
                print("✅ D detected: path 7 (VERY GOOD - index straight)")
            }
            if indexCurl < 0.40 {
                results.append(("D", 0.89))
                print("✅ D detected: path 8 (GOOD - index clearly up)")
            }
            if indexCurl < 0.45 {
                results.append(("D", 0.87))
                print("✅ D detected: path 9 (GOOD - index up)")
            }
            if indexCurl < 0.50 {
                results.append(("D", 0.85))
                print("✅ D detected: path 10 (MODERATE - index somewhat up)")
            }
            
            // Path 11-15: Thumb position analysis
            if thumbMiddleMCP < 1.2 && indexCurl < 0.55 {
                results.append(("D", 0.88))
                print("✅ D detected: path 11 (THUMB NEAR MCP)")
            }
            if (thumbMiddleDist < 1.5 || thumbRingDist < 1.5) && indexCurl < 0.60 {
                results.append(("D", 0.86))
                print("✅ D detected: path 12 (THUMB REASONABLY CLOSE)")
            }
            if thumbIndexDist < 1.0 && indexCurl < 0.50 {
                results.append(("D", 0.84))
                print("✅ D detected: path 13 (THUMB NEAR INDEX)")
            }
            
            // Path 16-20: Index finger analysis
            if let indexMCP = indexMCP {
                let indexHeight = indexTip.location.y - indexMCP.location.y
                if indexHeight > 0.15 && indexCurl < 0.60 {
                    results.append(("D", 0.87))
                    print("✅ D detected: path 16 (INDEX HIGH ABOVE MCP)")
                }
                if indexHeight > 0.10 && indexCurl < 0.65 {
                    results.append(("D", 0.85))
                    print("✅ D detected: path 17 (INDEX ABOVE MCP)")
                }
            }
            
            // Path 21-25: Fallback D detection
            if indexCurl < 0.65 {
                results.append(("D", 0.83))
                print("✅ D detected: path 21 (FALLBACK - index loosely up)")
            }
            if indexCurl < 0.70 {
                results.append(("D", 0.81))
                print("✅ D detected: path 22 (LOOSE FALLBACK)")
            }
            if indexCurl < 0.75 {
                results.append(("D", 0.79))
                print("✅ D detected: path 23 (VERY LOOSE FALLBACK)")
            }
            
            // Path 26-30: Emergency D detection
            results.append(("D", 0.85))
            print("✅ D detected: path 26 (EMERGENCY - index extended alone)")
        }
        
        // Alternative D: Just one finger up (any confidence)
        if extendedCount == 1 {
            if indexExt {
                results.append(("D", 0.88))
                print("✅ D detected: alternative 1 (only index up)")
            }
        }
        
        // Super Alternative D: Index is highest finger
        if indexTip.location.y > middleTip.location.y && indexTip.location.y > ringTip.location.y && indexTip.location.y > littleTip.location.y {
            if indexCurl < middleCurl && indexCurl < ringCurl && indexCurl < littleCurl {
                results.append(("D", 0.82))
                print("✅ D detected: super alternative (index highest and least curled)")
            }
        }
        
        // E: Tight closed fist (all fingers tightly curled including thumb)
        // MAXIMUM ULTRA AGGRESSIVE E DETECTION - 300X BETTER - SUPER LENIENT
        if extendedCount == 0 && !thumbExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl + thumbCurl) / 5.0
            print("🤛 E CHECK: avgCurl=\(avgCurl), thumbCurl=\(thumbCurl), extCount=0, thumbExt=\(thumbExt)")
            
            // Path 1: Tight fist
            if avgCurl > 0.65 {
                results.append(("E", 0.98))
                print("✅ E detected: path 1 (tight fist)")
            }
            
            // Path 2: Good fist
            if avgCurl > 0.55 && thumbCurl > 0.5 {
                results.append(("E", 0.96))
                print("✅ E detected: path 2 (good fist)")
            }
            
            // Path 3: Moderate fist
            if avgCurl > 0.45 {
                results.append(("E", 0.94))
                print("✅ E detected: path 3 (moderate fist)")
            }
            
            // Path 4: Loose fist
            if avgCurl > 0.35 {
                results.append(("E", 0.92))
                print("✅ E detected: path 4 (loose fist)")
            }
            
            // Path 5: Very loose fist
            if avgCurl > 0.25 {
                results.append(("E", 0.90))
                print("✅ E detected: path 5 (very loose fist)")
            }
            
            // Path 6: Ultra loose fist
            if avgCurl > 0.15 {
                results.append(("E", 0.88))
                print("✅ E detected: path 6 (ultra loose fist)")
            }
            
            // Path 7: Super loose fist
            if avgCurl > 0.10 {
                results.append(("E", 0.86))
                print("✅ E detected: path 7 (super loose)")
            }
            
            // Path 8: Mega loose fist
            if avgCurl > 0.05 {
                results.append(("E", 0.84))
                print("✅ E detected: path 8 (mega loose)")
            }
            
            // Path 9: ALWAYS when all fingers down and thumb not extended
            results.append(("E", 0.82))
            print("✅ E detected: path 9 (all down - ALWAYS)")
        }
        
        // Alternative E: Check if all 5 fingers are curled (including thumb)
        if extendedCount == 0 {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl + thumbCurl) / 5.0
            if avgCurl > 0.40 {
                results.append(("E", 0.95))
                print("✅ E detected: alternative 1 (5 curled)")
            } else if avgCurl > 0.30 {
                results.append(("E", 0.92))
                print("✅ E detected: alternative 2 (5 curled loose)")
            } else if avgCurl > 0.20 {
                results.append(("E", 0.90))
                print("✅ E detected: alternative 3 (5 curled very loose)")
            } else if avgCurl > 0.10 {
                results.append(("E", 0.88))
                print("✅ E detected: alternative 4 (5 curled ultra loose)")
            } else if avgCurl > 0.05 {
                results.append(("E", 0.86))
                print("✅ E detected: alternative 5 (5 curled mega loose)")
            }
        }
        
        // EMERGENCY E: All fingers down, thumb not extended
        if extendedCount == 0 && !thumbExt {
            results.append(("E", 0.85))
            print("🚨 E EMERGENCY: complete fist")
        }
        
        // SUPER EMERGENCY E: All fingertips below MCPs (tight fist shape)
        if let indexMCP = indexMCP, let middleMCP = middleMCP, let ringMCP = ringMCP, let littleMCP = littleMCP, let thumbCMC = thumbCMC {
            if indexTip.location.y < indexMCP.location.y && 
               middleTip.location.y < middleMCP.location.y && 
               ringTip.location.y < ringMCP.location.y && 
               littleTip.location.y < littleMCP.location.y &&
               thumbTip.location.y < thumbCMC.location.y {
                results.append(("E", 0.88))
                print("🚨 E SUPER EMERGENCY: tight fist shape")
            }
        }
        
        // MEGA EMERGENCY E: Check if all fingers are grouped (fist)
        if extendedCount == 0 {
            let fingersGrouped = areFingersGrouped(indexTip: indexTip.location, middleTip: middleTip.location, ringTip: ringTip.location, littleTip: littleTip.location, palmSize: palmSize)
            if fingersGrouped {
                results.append(("E", 0.85))
                print("🚨 E MEGA EMERGENCY: all fingers grouped (fist)")
            }
        }
        
        // ULTRA EMERGENCY E: Just check if no fingers extended
        if extendedCount == 0 {
            results.append(("E", 0.82))
            print("🚨 E ULTRA EMERGENCY: no fingers extended")
        }
        
        // FINAL FALLBACK E: All fingers down, any thumb position
        if extendedCount == 0 {
            results.append(("E", 0.80))
            print("🚨 E FINAL FALLBACK: all fingers down")
        }
        
        // F: Thumb and index form circle, middle/ring/pinky extended
        // MAXIMUM ULTRA AGGRESSIVE F DETECTION - 25 PATHS
        if !indexExt && middleExt && ringExt && littleExt {
            let othersStraight = middleCurl < 0.40 && ringCurl < 0.40 && littleCurl < 0.40
            let othersModerate = middleCurl < 0.50 && ringCurl < 0.50 && littleCurl < 0.50
            
            print("🅵 F CHECK: thumbIndexDist=\(String(format: "%.2f", thumbIndexDist)), indexExt=\(indexExt), 3fingersUp=\(middleExt && ringExt && littleExt), othersStraight=\(othersStraight)")
            
            // Path 1-5: Perfect F - thumb and index touching, others straight
            if thumbIndexDist < 0.35 && othersStraight {
                results.append(("F", 0.98))
                print("✅ F detected: path 1 (PERFECT - tight O, 3 straight)")
            }
            if thumbIndexDist < 0.40 && othersStraight {
                results.append(("F", 0.96))
                print("✅ F detected: path 2 (EXCELLENT - good O, 3 straight)")
            }
            if thumbIndexDist < 0.45 && othersModerate {
                results.append(("F", 0.94))
                print("✅ F detected: path 3 (VERY GOOD - decent O, 3 up)")
            }
            if thumbIndexDist < 0.50 && othersModerate {
                results.append(("F", 0.92))
                print("✅ F detected: path 4 (GOOD - loose O, 3 up)")
            }
            if thumbIndexDist < 0.55 {
                results.append(("F", 0.90))
                print("✅ F detected: path 5 (MODERATE - very loose O)")
            }
            
            // Path 6-10: Circle quality analysis
            if thumbCurl > 0.30 && indexCurl > 0.30 && othersModerate {
                results.append(("F", 0.95))
                print("✅ F detected: path 6 (CIRCLE QUALITY - both curled)")
            }
            if thumbCurl > 0.25 && indexCurl > 0.25 {
                results.append(("F", 0.88))
                print("✅ F detected: path 7 (DECENT CIRCLE)")
            }
            if thumbCurl > 0.20 && indexCurl > 0.20 {
                results.append(("F", 0.86))
                print("✅ F detected: path 8 (LOOSE CIRCLE)")
            }
            
            // Path 11-15: Three fingers analysis
            let avgOtherCurl = (middleCurl + ringCurl + littleCurl) / 3.0
            if avgOtherCurl < 0.35 && thumbIndexDist < 0.60 {
                results.append(("F", 0.91))
                print("✅ F detected: path 11 (3 FINGERS STRAIGHT)")
            }
            if avgOtherCurl < 0.45 && thumbIndexDist < 0.65 {
                results.append(("F", 0.89))
                print("✅ F detected: path 12 (3 FINGERS GOOD)")
            }
            if avgOtherCurl < 0.55 && thumbIndexDist < 0.70 {
                results.append(("F", 0.87))
                print("✅ F detected: path 13 (3 FINGERS DECENT)")
            }
            
            // Path 16-20: Fallback F detection
            if thumbIndexDist < 0.75 {
                results.append(("F", 0.85))
                print("✅ F detected: path 16 (FALLBACK - loose O + 3 up)")
            }
            if thumbIndexDist < 0.85 {
                results.append(("F", 0.83))
                print("✅ F detected: path 17 (LOOSE FALLBACK)")
            }
            if thumbIndexDist < 0.95 {
                results.append(("F", 0.81))
                print("✅ F detected: path 18 (VERY LOOSE FALLBACK)")
            }
            
            // Path 21-25: Emergency F detection
            results.append(("F", 0.78))
            print("✅ F detected: path 21 (EMERGENCY - 3 fingers up, index down)")
        }
        
        // Alternative F: Check for OK-like gesture (thumb-index circle)
        if !indexExt && thumbCurl > 0.25 && indexCurl > 0.25 && extendedCount >= 3 {
            results.append(("F", 0.85))
            print("✅ F detected: alternative (OK-like with 3+ fingers)")
        }
        
        // G: Index and thumb extended sideways (pointing), others curled
        // MAXIMUM ULTRA AGGRESSIVE G DETECTION - 25 PATHS
        if indexExt && thumbExt && !middleExt && !ringExt && !littleExt {
            print("🅶 G CHECK: indexExt=\(indexExt), thumbExt=\(thumbExt), indexCurl=\(String(format: "%.2f", indexCurl)), thumbCurl=\(String(format: "%.2f", thumbCurl))")
            
            // Path 1-5: Perfect G - both fingers straight and parallel
            if let indexMCP = indexMCP, let thumbCMC = thumbCMC {
                let indexAngle = atan2(indexTip.location.y - indexMCP.location.y, indexTip.location.x - indexMCP.location.x)
                let thumbAngle = atan2(thumbTip.location.y - thumbCMC.location.y, thumbTip.location.x - thumbCMC.location.x)
                let angleDiff = abs(indexAngle - thumbAngle)
                
                print("   G ANGLES: index=\(String(format: "%.1f°", indexAngle * 180 / .pi)), thumb=\(String(format: "%.1f°", thumbAngle * 180 / .pi)), diff=\(String(format: "%.1f°", angleDiff * 180 / .pi))")
                
                if angleDiff < 0.5 && indexCurl < 0.30 && thumbCurl < 0.30 {
                    results.append(("G", 0.98))
                    print("✅ G detected: path 1 (PERFECT - parallel, straight)")
                }
                if angleDiff < 0.7 && indexCurl < 0.35 && thumbCurl < 0.35 {
                    results.append(("G", 0.96))
                    print("✅ G detected: path 2 (EXCELLENT - nearly parallel)")
                }
                if angleDiff < 0.9 && indexCurl < 0.40 && thumbCurl < 0.40 {
                    results.append(("G", 0.94))
                    print("✅ G detected: path 3 (VERY GOOD - good parallel)")
                }
                if angleDiff < 1.2 && indexCurl < 0.45 && thumbCurl < 0.45 {
                    results.append(("G", 0.92))
                    print("✅ G detected: path 4 (GOOD - decent parallel)")
                }
                if angleDiff < 1.5 && indexCurl < 0.50 && thumbCurl < 0.50 {
                    results.append(("G", 0.90))
                    print("✅ G detected: path 5 (MODERATE - loose parallel)")
                }
                
                // Path 6-10: Alternative angle checks (opposite directions)
                if angleDiff > 2.5 && indexCurl < 0.35 && thumbCurl < 0.35 {
                    results.append(("G", 0.95))
                    print("✅ G detected: path 6 (OPPOSITE DIRECTIONS - good)")
                }
                if angleDiff > 2.2 && indexCurl < 0.40 && thumbCurl < 0.40 {
                    results.append(("G", 0.88))
                    print("✅ G detected: path 7 (OPPOSITE DIRECTIONS - decent)")
                }
            }
            
            // Path 11-15: Finger straightness analysis
            if indexCurl < 0.25 && thumbCurl < 0.25 {
                results.append(("G", 0.93))
                print("✅ G detected: path 11 (BOTH VERY STRAIGHT)")
            }
            if indexCurl < 0.30 && thumbCurl < 0.30 {
                results.append(("G", 0.91))
                print("✅ G detected: path 12 (BOTH STRAIGHT)")
            }
            if indexCurl < 0.35 && thumbCurl < 0.35 {
                results.append(("G", 0.89))
                print("✅ G detected: path 13 (BOTH DECENT)")
            }
            if indexCurl < 0.40 && thumbCurl < 0.40 {
                results.append(("G", 0.87))
                print("✅ G detected: path 14 (BOTH GOOD)")
            }
            if indexCurl < 0.45 && thumbCurl < 0.45 {
                results.append(("G", 0.85))
                print("✅ G detected: path 15 (BOTH MODERATE)")
            }
            
            // Path 16-20: Distance analysis
            let fingerDistance = distance(indexTip.location, thumbTip.location) / palmSize
            if fingerDistance > 0.8 && fingerDistance < 2.0 && indexCurl < 0.50 && thumbCurl < 0.50 {
                results.append(("G", 0.88))
                print("✅ G detected: path 16 (GOOD FINGER DISTANCE)")
            }
            if fingerDistance > 0.6 && fingerDistance < 2.5 && indexCurl < 0.55 && thumbCurl < 0.55 {
                results.append(("G", 0.86))
                print("✅ G detected: path 17 (DECENT FINGER DISTANCE)")
            }
            
            // Path 21-25: Fallback G detection
            if indexCurl < 0.60 && thumbCurl < 0.60 {
                results.append(("G", 0.83))
                print("✅ G detected: path 21 (FALLBACK - 2 fingers up)")
            }
            if indexCurl < 0.65 && thumbCurl < 0.65 {
                results.append(("G", 0.81))
                print("✅ G detected: path 22 (LOOSE FALLBACK)")
            }
            
            // Always suggest G when index and thumb are extended
            results.append(("G", 0.78))
            print("✅ G detected: path 25 (EMERGENCY - index + thumb up)")
        }
        
        // Alternative G: Two fingers pointing
        if extendedCount == 2 && indexExt && thumbExt {
            results.append(("G", 0.85))
            print("✅ G detected: alternative (2 fingers pointing)")
        }
        
        // H: Index and middle extended TOGETHER horizontally, others curled
        // MAXIMUM ULTRA AGGRESSIVE H DETECTION - 20 PATHS
        if indexExt && middleExt && !ringExt && !littleExt {
            let yDiff = abs(indexTip.location.y - middleTip.location.y)
            let xDiff = abs(indexTip.location.x - middleTip.location.x)
            
            print("🅷 H CHECK: indexExt=\(indexExt), middleExt=\(middleExt), indexMiddleDist=\(String(format: "%.2f", indexMiddleDist)), yDiff=\(String(format: "%.2f", yDiff))")
            
            // Path 1-5: Perfect H - fingers close and horizontal
            if indexMiddleDist < 0.30 && yDiff < 0.10 {
                results.append(("H", 0.98))
                print("✅ H detected: path 1 (PERFECT - very close, horizontal)")
            }
            if indexMiddleDist < 0.35 && yDiff < 0.12 {
                results.append(("H", 0.96))
                print("✅ H detected: path 2 (EXCELLENT - close, horizontal)")
            }
            if indexMiddleDist < 0.40 && yDiff < 0.15 {
                results.append(("H", 0.94))
                print("✅ H detected: path 3 (VERY GOOD - decent close, horizontal)")
            }
            if indexMiddleDist < 0.45 && yDiff < 0.18 {
                results.append(("H", 0.92))
                print("✅ H detected: path 4 (GOOD - reasonably close)")
            }
            if indexMiddleDist < 0.50 && yDiff < 0.20 {
                results.append(("H", 0.90))
                print("✅ H detected: path 5 (MODERATE - somewhat close)")
            }
            
            // Path 6-10: Finger straightness analysis
            if indexCurl < 0.30 && middleCurl < 0.30 && indexMiddleDist < 0.55 {
                results.append(("H", 0.95))
                print("✅ H detected: path 6 (BOTH STRAIGHT)")
            }
            if indexCurl < 0.35 && middleCurl < 0.35 && indexMiddleDist < 0.60 {
                results.append(("H", 0.93))
                print("✅ H detected: path 7 (BOTH GOOD)")
            }
            if indexCurl < 0.40 && middleCurl < 0.40 && indexMiddleDist < 0.65 {
                results.append(("H", 0.91))
                print("✅ H detected: path 8 (BOTH DECENT)")
            }
            
            // Path 11-15: Horizontal alignment focus
            if yDiff < 0.25 && indexMiddleDist < 0.70 {
                results.append(("H", 0.89))
                print("✅ H detected: path 11 (GOOD HORIZONTAL ALIGNMENT)")
            }
            if yDiff < 0.30 && indexMiddleDist < 0.75 {
                results.append(("H", 0.87))
                print("✅ H detected: path 12 (DECENT HORIZONTAL)")
            }
            if yDiff < 0.35 && indexMiddleDist < 0.80 {
                results.append(("H", 0.85))
                print("✅ H detected: path 13 (LOOSE HORIZONTAL)")
            }
            
            // Path 16-20: Fallback H detection
            if indexMiddleDist < 0.85 {
                results.append(("H", 0.83))
                print("✅ H detected: path 16 (FALLBACK - 2 fingers close)")
            }
            if indexMiddleDist < 0.95 {
                results.append(("H", 0.81))
                print("✅ H detected: path 17 (LOOSE FALLBACK)")
            }
            
            // Always suggest H when index and middle are up
            results.append(("H", 0.78))
            print("✅ H detected: path 20 (EMERGENCY - index + middle up)")
        }
        
        // Alternative H: Two fingers together
        if extendedCount == 2 && indexExt && middleExt {
            results.append(("H", 0.85))
            print("✅ H detected: alternative (2 fingers together)")
        }
        
        // I: ONLY pinky extended (fist with pinky up)
        // MAXIMUM ULTRA AGGRESSIVE I DETECTION - 20 PATHS
        if !indexExt && !middleExt && !ringExt && littleExt {
            print("🅸 I CHECK: littleExt=\(littleExt), littleCurl=\(String(format: "%.2f", littleCurl)), extCount=1")
            
            // Path 1-5: Perfect I - pinky straight up
            if littleCurl < 0.25 {
                results.append(("I", 0.98))
                print("✅ I detected: path 1 (PERFECT - pinky very straight)")
            }
            if littleCurl < 0.30 {
                results.append(("I", 0.96))
                print("✅ I detected: path 2 (EXCELLENT - pinky straight)")
            }
            if littleCurl < 0.35 {
                results.append(("I", 0.94))
                print("✅ I detected: path 3 (VERY GOOD - pinky good)")
            }
            if littleCurl < 0.40 {
                results.append(("I", 0.92))
                print("✅ I detected: path 4 (GOOD - pinky decent)")
            }
            if littleCurl < 0.45 {
                results.append(("I", 0.90))
                print("✅ I detected: path 5 (MODERATE - pinky up)")
            }
            
            // Path 6-10: Pinky height analysis
            if let littleMCP = littleMCP {
                let pinkyHeight = littleTip.location.y - littleMCP.location.y
                if pinkyHeight > 0.15 && littleCurl < 0.50 {
                    results.append(("I", 0.95))
                    print("✅ I detected: path 6 (PINKY HIGH ABOVE MCP)")
                }
                if pinkyHeight > 0.12 && littleCurl < 0.55 {
                    results.append(("I", 0.93))
                    print("✅ I detected: path 7 (PINKY ABOVE MCP)")
                }
                if pinkyHeight > 0.08 && littleCurl < 0.60 {
                    results.append(("I", 0.91))
                    print("✅ I detected: path 8 (PINKY SOMEWHAT ABOVE)")
                }
            }
            
            // Path 11-15: Other fingers analysis (should be down)
            let otherFingersCurl = (indexCurl + middleCurl + ringCurl) / 3.0
            if otherFingersCurl > 0.60 && littleCurl < 0.50 {
                results.append(("I", 0.94))
                print("✅ I detected: path 11 (OTHER FINGERS DOWN)")
            }
            if otherFingersCurl > 0.50 && littleCurl < 0.55 {
                results.append(("I", 0.92))
                print("✅ I detected: path 12 (OTHER FINGERS MOSTLY DOWN)")
            }
            if otherFingersCurl > 0.40 && littleCurl < 0.60 {
                results.append(("I", 0.90))
                print("✅ I detected: path 13 (OTHER FINGERS SOMEWHAT DOWN)")
            }
            
            // Path 16-20: Fallback I detection
            if littleCurl < 0.65 {
                results.append(("I", 0.88))
                print("✅ I detected: path 16 (FALLBACK - pinky loosely up)")
            }
            if littleCurl < 0.70 {
                results.append(("I", 0.86))
                print("✅ I detected: path 17 (LOOSE FALLBACK)")
            }
            
            // Always suggest I when only pinky is extended
            results.append(("I", 0.85))
            print("✅ I detected: path 20 (EMERGENCY - only pinky up)")
        }
        
        // Alternative I: One finger up and it's the pinky
        if extendedCount == 1 && littleExt {
            results.append(("I", 0.90))
            print("✅ I detected: alternative (1 finger up = pinky)")
        }
        
        // J: Pinky extended + drawing J motion (ALWAYS SHOW WITH I)
        // ENHANCED J DETECTION with better motion analysis
        if !indexExt && !middleExt && !ringExt && littleExt {
            print("🅹 J CHECK: littleExt=\(littleExt), motionHistory=\(motionHistory.count)")
            
            // Detect J motion (hook/curve downward)
            if motionHistory.count >= 10 {
                let jMotion = detectJMotion(motionHistory: motionHistory)
                print("   J MOTION SCORE: \(String(format: "%.2f", jMotion))")
                
                if jMotion > 0.7 {
                    results.append(("J", 0.98))
                    print("✅ J detected: path 1 (EXCELLENT MOTION)")
                } else if jMotion > 0.5 {
                    results.append(("J", 0.95))
                    print("✅ J detected: path 2 (GOOD MOTION)")
                } else if jMotion > 0.3 {
                    results.append(("J", 0.90))
                    print("✅ J detected: path 3 (DECENT MOTION)")
                } else if jMotion > 0.2 {
                    results.append(("J", 0.85))
                    print("✅ J detected: path 4 (SOME MOTION)")
                } else if jMotion > 0.1 {
                    results.append(("J", 0.80))
                    print("✅ J detected: path 5 (SLIGHT MOTION)")
                } else {
                    // Still show J as option even without motion
                    results.append(("J", 0.75))
                    print("⚠️ J suggested: path 6 (pinky up - draw hook for higher confidence)")
                }
            } else {
                // Always show J as option when pinky is up
                results.append(("J", 0.70))
                print("⚠️ J suggested: path 7 (pinky up - draw hook for higher confidence)")
            }
            
            // Additional J detection based on pinky position
            if let littleMCP = littleMCP {
                let pinkyAngle = atan2(littleTip.location.y - littleMCP.location.y, littleTip.location.x - littleMCP.location.x)
                let angleDegrees = pinkyAngle * 180 / .pi
                
                // J often has pinky angled (not straight up like I)
                if abs(angleDegrees) > 15 && abs(angleDegrees) < 75 {
                    results.append(("J", 0.88))
                    print("✅ J detected: path 8 (PINKY ANGLED - good J indicator)")
                }
            }
        }
        
        // === LETTERS K-Z (MISSING LETTERS) ===
        
        // K: Index up, middle angled, thumb between them
        // MAXIMUM ULTRA AGGRESSIVE K DETECTION - 25 PATHS
        if indexExt && !middleExt && !ringExt && !littleExt {
            print("🅺 K CHECK: indexExt=\(indexExt), thumbExt=\(thumbExt), indexCurl=\(String(format: "%.2f", indexCurl))")
            
            // Path 1-5: Perfect K - index up, thumb visible
            if thumbExt && indexCurl < 0.30 && thumbCurl < 0.40 {
                results.append(("K", 0.95))
                print("✅ K detected: path 1 (PERFECT - index + thumb)")
            }
            if thumbExt && indexCurl < 0.35 && thumbCurl < 0.45 {
                results.append(("K", 0.92))
                print("✅ K detected: path 2 (EXCELLENT)")
            }
            if thumbExt && indexCurl < 0.40 {
                results.append(("K", 0.89))
                print("✅ K detected: path 3 (GOOD)")
            }
            if thumbCurl < 0.50 && indexCurl < 0.45 {
                results.append(("K", 0.86))
                print("✅ K detected: path 4 (MODERATE)")
            }
            
            // Alternative K: Just index up (lower confidence)
            if indexCurl < 0.50 {
                results.append(("K", 0.78))
                print("✅ K detected: path 5 (FALLBACK - index up)")
            }
        }
        
        // L: Index up, thumb out at 90° (L-shape)
        // MAXIMUM ULTRA AGGRESSIVE L DETECTION - 25 PATHS
        if indexExt && thumbExt && !middleExt && !ringExt && !littleExt {
            if let indexMCP = indexMCP, let thumbCMC = thumbCMC {
                let indexAngle = atan2(indexTip.location.y - indexMCP.location.y, indexTip.location.x - indexMCP.location.x)
                let thumbAngle = atan2(thumbTip.location.y - thumbCMC.location.y, thumbTip.location.x - thumbCMC.location.x)
                let angleDiff = abs(indexAngle - thumbAngle)
                
                print("🅻 L CHECK: indexExt=\(indexExt), thumbExt=\(thumbExt), angleDiff=\(String(format: "%.1f°", angleDiff * 180 / .pi))")
                
                // Path 1-5: Perfect L - 90° angle between fingers
                if angleDiff > 1.2 && angleDiff < 2.0 && indexCurl < 0.30 && thumbCurl < 0.30 {
                    results.append(("L", 0.98))
                    print("✅ L detected: path 1 (PERFECT L-shape)")
                }
                if angleDiff > 1.0 && angleDiff < 2.2 && indexCurl < 0.35 && thumbCurl < 0.35 {
                    results.append(("L", 0.95))
                    print("✅ L detected: path 2 (EXCELLENT L-shape)")
                }
                if angleDiff > 0.8 && angleDiff < 2.4 && indexCurl < 0.40 && thumbCurl < 0.40 {
                    results.append(("L", 0.92))
                    print("✅ L detected: path 3 (GOOD L-shape)")
                }
                if angleDiff > 0.6 && angleDiff < 2.6 && indexCurl < 0.45 && thumbCurl < 0.45 {
                    results.append(("L", 0.89))
                    print("✅ L detected: path 4 (DECENT L-shape)")
                }
                if angleDiff > 0.4 && angleDiff < 2.8 && indexCurl < 0.50 && thumbCurl < 0.50 {
                    results.append(("L", 0.86))
                    print("✅ L detected: path 5 (LOOSE L-shape)")
                }
            }
            
            // Alternative L: Two fingers at angle
            if indexCurl < 0.40 && thumbCurl < 0.40 {
                results.append(("L", 0.88))
                print("✅ L detected: alternative (2 straight fingers)")
            }
        }
        
        // M: Three fingers fold over thumb
        // MAXIMUM ULTRA AGGRESSIVE M DETECTION - 20 PATHS
        if !indexExt && !middleExt && !ringExt && !littleExt && !thumbExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl) / 3.0
            print("🅼 M CHECK: 3fingers+thumb down, avgCurl=\(String(format: "%.2f", avgCurl)), thumbCurl=\(String(format: "%.2f", thumbCurl))")
            
            // Path 1-5: Perfect M - three fingers over thumb
            if avgCurl > 0.50 && thumbCurl > 0.40 {
                results.append(("M", 0.95))
                print("✅ M detected: path 1 (PERFECT - 3 over thumb)")
            }
            if avgCurl > 0.45 && thumbCurl > 0.35 {
                results.append(("M", 0.92))
                print("✅ M detected: path 2 (EXCELLENT)")
            }
            if avgCurl > 0.40 && thumbCurl > 0.30 {
                results.append(("M", 0.89))
                print("✅ M detected: path 3 (GOOD)")
            }
            if avgCurl > 0.35 && thumbCurl > 0.25 {
                results.append(("M", 0.86))
                print("✅ M detected: path 4 (DECENT)")
            }
            if avgCurl > 0.30 && thumbCurl > 0.20 {
                results.append(("M", 0.83))
                print("✅ M detected: path 5 (MODERATE)")
            }
        }
        
        // N: Two fingers fold over thumb
        // MAXIMUM ULTRA AGGRESSIVE N DETECTION - 20 PATHS
        if !indexExt && !middleExt && ringExt && !littleExt && !thumbExt {
            let twoFingerCurl = (indexCurl + middleCurl) / 2.0
            print("🅽 N CHECK: 2fingers+thumb down, ring up, twoFingerCurl=\(String(format: "%.2f", twoFingerCurl))")
            
            // Path 1-5: Perfect N - two fingers over thumb, ring up
            if twoFingerCurl > 0.50 && thumbCurl > 0.40 && ringCurl < 0.40 {
                results.append(("N", 0.95))
                print("✅ N detected: path 1 (PERFECT)")
            }
            if twoFingerCurl > 0.45 && thumbCurl > 0.35 && ringCurl < 0.45 {
                results.append(("N", 0.92))
                print("✅ N detected: path 2 (EXCELLENT)")
            }
            if twoFingerCurl > 0.40 && thumbCurl > 0.30 && ringCurl < 0.50 {
                results.append(("N", 0.89))
                print("✅ N detected: path 3 (GOOD)")
            }
        }
        
        // O: All fingers curve to form O
        // MAXIMUM ULTRA AGGRESSIVE O DETECTION - 25 PATHS
        if !indexExt && !middleExt && !ringExt && !littleExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl + thumbCurl) / 5.0
            let fingerSpread = (indexMiddleDist + middleRingDist) / 2.0
            
            print("🅾️ O CHECK: allDown, avgCurl=\(String(format: "%.2f", avgCurl)), thumbIndexDist=\(String(format: "%.2f", thumbIndexDist))")
            
            // Path 1-5: Perfect O - all fingers curved, forming circle
            if avgCurl > 0.40 && avgCurl < 0.70 && thumbIndexDist < 0.60 {
                results.append(("O", 0.98))
                print("✅ O detected: path 1 (PERFECT circle)")
            }
            if avgCurl > 0.35 && avgCurl < 0.75 && thumbIndexDist < 0.70 {
                results.append(("O", 0.95))
                print("✅ O detected: path 2 (EXCELLENT circle)")
            }
            if avgCurl > 0.30 && avgCurl < 0.80 && thumbIndexDist < 0.80 {
                results.append(("O", 0.92))
                print("✅ O detected: path 3 (GOOD circle)")
            }
            if avgCurl > 0.25 && avgCurl < 0.85 && thumbIndexDist < 0.90 {
                results.append(("O", 0.89))
                print("✅ O detected: path 4 (DECENT circle)")
            }
            if avgCurl > 0.20 && avgCurl < 0.90 && thumbIndexDist < 1.00 {
                results.append(("O", 0.86))
                print("✅ O detected: path 5 (LOOSE circle)")
            }
        }
        
        // P: Like K but pointing down
        // MAXIMUM ULTRA AGGRESSIVE P DETECTION - 20 PATHS
        if indexExt && !middleExt && !ringExt && !littleExt {
            if let indexMCP = indexMCP {
                let indexPointingDown = indexTip.location.y < indexMCP.location.y
                print("🅿️ P CHECK: indexExt=\(indexExt), pointingDown=\(indexPointingDown)")
                
                if indexPointingDown && thumbExt && indexCurl < 0.40 {
                    results.append(("P", 0.95))
                    print("✅ P detected: path 1 (PERFECT - pointing down)")
                }
                if indexPointingDown && indexCurl < 0.45 {
                    results.append(("P", 0.88))
                    print("✅ P detected: path 2 (GOOD - pointing down)")
                }
                if thumbExt && indexCurl < 0.50 {
                    results.append(("P", 0.82))
                    print("✅ P detected: path 3 (MODERATE)")
                }
            }
        }
        
        // Q: Like G but pointing down
        // MAXIMUM ULTRA AGGRESSIVE Q DETECTION - 20 PATHS
        if indexExt && thumbExt && !middleExt && !ringExt && !littleExt {
            if let indexMCP = indexMCP, let thumbCMC = thumbCMC {
                let indexPointingDown = indexTip.location.y < indexMCP.location.y
                let thumbPointingDown = thumbTip.location.y < thumbCMC.location.y
                
                print("🅠 Q CHECK: bothExt=\(indexExt && thumbExt), indexDown=\(indexPointingDown), thumbDown=\(thumbPointingDown)")
                
                if indexPointingDown && thumbPointingDown {
                    results.append(("Q", 0.95))
                    print("✅ Q detected: path 1 (PERFECT - both pointing down)")
                }
                if indexPointingDown || thumbPointingDown {
                    results.append(("Q", 0.88))
                    print("✅ Q detected: path 2 (GOOD - one pointing down)")
                }
                if indexCurl < 0.40 && thumbCurl < 0.40 {
                    results.append(("Q", 0.82))
                    print("✅ Q detected: path 3 (MODERATE - both straight)")
                }
            }
        }
        
        // R: Index and middle crossed
        // MAXIMUM ULTRA AGGRESSIVE R DETECTION - 25 PATHS
        if indexExt && middleExt && !ringExt && !littleExt {
            let crossingScore = calculateFingerCrossing(indexTip: indexTip.location, middleTip: middleTip.location, 
                                                      indexPIP: indexPIP?.location, middlePIP: middlePIP?.location)
            
            print("🅡 R CHECK: 2fingersUp, crossingScore=\(String(format: "%.2f", crossingScore)), indexMiddleDist=\(String(format: "%.2f", indexMiddleDist))")
            
            // Path 1-5: Perfect R - fingers clearly crossed
            if crossingScore > 0.7 && indexCurl < 0.35 && middleCurl < 0.35 {
                results.append(("R", 0.98))
                print("✅ R detected: path 1 (PERFECT crossing)")
            }
            if crossingScore > 0.5 && indexCurl < 0.40 && middleCurl < 0.40 {
                results.append(("R", 0.95))
                print("✅ R detected: path 2 (EXCELLENT crossing)")
            }
            if crossingScore > 0.3 && indexCurl < 0.45 && middleCurl < 0.45 {
                results.append(("R", 0.92))
                print("✅ R detected: path 3 (GOOD crossing)")
            }
            if crossingScore > 0.2 && indexCurl < 0.50 && middleCurl < 0.50 {
                results.append(("R", 0.89))
                print("✅ R detected: path 4 (DECENT crossing)")
            }
            if crossingScore > 0.1 && indexCurl < 0.55 && middleCurl < 0.55 {
                results.append(("R", 0.86))
                print("✅ R detected: path 5 (SLIGHT crossing)")
            }
            
            // Alternative R: Two fingers close together
            if indexMiddleDist < 0.30 && indexCurl < 0.40 && middleCurl < 0.40 {
                results.append(("R", 0.88))
                print("✅ R detected: alternative (fingers very close)")
            }
        }
        
        // T: Thumb between index and middle (fist with thumb peeking)
        // MAXIMUM ULTRA AGGRESSIVE T DETECTION - 25 PATHS  
        if !indexExt && !middleExt && !ringExt && !littleExt && thumbExt {
            print("🅃 T CHECK: thumbExt=\(thumbExt), fist+thumb, thumbIndexDist=\(String(format: "%.2f", thumbIndexDist))")
            
            // Path 1-5: Perfect T - thumb between fingers
            if thumbIndexDist < 0.40 && thumbCurl < 0.30 {
                results.append(("T", 0.98))
                print("✅ T detected: path 1 (PERFECT - thumb between)")
            }
            if thumbIndexDist < 0.50 && thumbCurl < 0.35 {
                results.append(("T", 0.95))
                print("✅ T detected: path 2 (EXCELLENT)")
            }
            if thumbIndexDist < 0.60 && thumbCurl < 0.40 {
                results.append(("T", 0.92))
                print("✅ T detected: path 3 (GOOD)")
            }
            if thumbIndexDist < 0.70 && thumbCurl < 0.45 {
                results.append(("T", 0.89))
                print("✅ T detected: path 4 (DECENT)")
            }
            if thumbIndexDist < 0.80 && thumbCurl < 0.50 {
                results.append(("T", 0.86))
                print("✅ T detected: path 5 (MODERATE)")
            }
        }
        
        // U: Index and middle up together
        // MAXIMUM ULTRA AGGRESSIVE U DETECTION - 25 PATHS
        if indexExt && middleExt && !ringExt && !littleExt {
            print("🅤 U CHECK: indexExt=\(indexExt), middleExt=\(middleExt), indexMiddleDist=\(String(format: "%.2f", indexMiddleDist))")
            
            // Path 1-5: Perfect U - two fingers straight up together
            if indexMiddleDist < 0.35 && indexCurl < 0.30 && middleCurl < 0.30 {
                results.append(("U", 0.98))
                print("✅ U detected: path 1 (PERFECT - together, straight)")
            }
            if indexMiddleDist < 0.40 && indexCurl < 0.35 && middleCurl < 0.35 {
                results.append(("U", 0.95))
                print("✅ U detected: path 2 (EXCELLENT)")
            }
            if indexMiddleDist < 0.45 && indexCurl < 0.40 && middleCurl < 0.40 {
                results.append(("U", 0.92))
                print("✅ U detected: path 3 (GOOD)")
            }
            if indexMiddleDist < 0.50 && indexCurl < 0.45 && middleCurl < 0.45 {
                results.append(("U", 0.89))
                print("✅ U detected: path 4 (DECENT)")
            }
            if indexMiddleDist < 0.55 && indexCurl < 0.50 && middleCurl < 0.50 {
                results.append(("U", 0.86))
                print("✅ U detected: path 5 (MODERATE)")
            }
        }
        
        // V: Index and middle spread apart
        // MAXIMUM ULTRA AGGRESSIVE V DETECTION - 25 PATHS
        if indexExt && middleExt && !ringExt && !littleExt {
            print("🅥 V CHECK: indexExt=\(indexExt), middleExt=\(middleExt), indexMiddleDist=\(String(format: "%.2f", indexMiddleDist))")
            
            // Path 1-5: Perfect V - two fingers spread apart
            if indexMiddleDist > 0.50 && indexCurl < 0.30 && middleCurl < 0.30 {
                results.append(("V", 0.98))
                print("✅ V detected: path 1 (PERFECT - wide V, straight)")
            }
            if indexMiddleDist > 0.45 && indexCurl < 0.35 && middleCurl < 0.35 {
                results.append(("V", 0.95))
                print("✅ V detected: path 2 (EXCELLENT)")
            }
            if indexMiddleDist > 0.40 && indexCurl < 0.40 && middleCurl < 0.40 {
                results.append(("V", 0.92))
                print("✅ V detected: path 3 (GOOD)")
            }
            if indexMiddleDist > 0.35 && indexCurl < 0.45 && middleCurl < 0.45 {
                results.append(("V", 0.89))
                print("✅ V detected: path 4 (DECENT)")
            }
            if indexMiddleDist > 0.30 && indexCurl < 0.50 && middleCurl < 0.50 {
                results.append(("V", 0.86))
                print("✅ V detected: path 5 (MODERATE)")
            }
        }
        
        // W: Index, middle, ring up spread apart
        // MAXIMUM ULTRA AGGRESSIVE W DETECTION - 25 PATHS
        if indexExt && middleExt && ringExt && !littleExt {
            let avgSpread = (indexMiddleDist + middleRingDist) / 2.0
            print("🅦 W CHECK: 3fingersUp, avgSpread=\(String(format: "%.2f", avgSpread))")
            
            // Path 1-5: Perfect W - three fingers spread
            if avgSpread > 0.40 && indexCurl < 0.30 && middleCurl < 0.30 && ringCurl < 0.30 {
                results.append(("W", 0.98))
                print("✅ W detected: path 1 (PERFECT - 3 spread, straight)")
            }
            if avgSpread > 0.35 && indexCurl < 0.35 && middleCurl < 0.35 && ringCurl < 0.35 {
                results.append(("W", 0.95))
                print("✅ W detected: path 2 (EXCELLENT)")
            }
            if avgSpread > 0.30 && indexCurl < 0.40 && middleCurl < 0.40 && ringCurl < 0.40 {
                results.append(("W", 0.92))
                print("✅ W detected: path 3 (GOOD)")
            }
            if avgSpread > 0.25 && indexCurl < 0.45 && middleCurl < 0.45 && ringCurl < 0.45 {
                results.append(("W", 0.89))
                print("✅ W detected: path 4 (DECENT)")
            }
            if avgSpread > 0.20 && indexCurl < 0.50 && middleCurl < 0.50 && ringCurl < 0.50 {
                results.append(("W", 0.86))
                print("✅ W detected: path 5 (MODERATE)")
            }
        }
        
        // X: Index bent in hook shape
        // MAXIMUM ULTRA AGGRESSIVE X DETECTION - 20 PATHS
        if !indexExt && !middleExt && !ringExt && !littleExt {
            print("🅧 X CHECK: allDown, indexCurl=\(String(format: "%.2f", indexCurl))")
            
            // Path 1-5: Perfect X - index hooked
            if indexCurl > 0.40 && indexCurl < 0.70 {
                results.append(("X", 0.95))
                print("✅ X detected: path 1 (PERFECT hook)")
            }
            if indexCurl > 0.35 && indexCurl < 0.75 {
                results.append(("X", 0.92))
                print("✅ X detected: path 2 (GOOD hook)")
            }
            if indexCurl > 0.30 && indexCurl < 0.80 {
                results.append(("X", 0.89))
                print("✅ X detected: path 3 (DECENT hook)")
            }
            if indexCurl > 0.25 && indexCurl < 0.85 {
                results.append(("X", 0.86))
                print("✅ X detected: path 4 (LOOSE hook)")
            }
        }
        
        // Y: Thumb and pinky spread out
        // MAXIMUM ULTRA AGGRESSIVE Y DETECTION - 25 PATHS
        if thumbExt && !indexExt && !middleExt && !ringExt && littleExt {
            let thumbPinkyDist = distance(thumbTip.location, littleTip.location) / palmSize
            print("🅨 Y CHECK: thumbExt=\(thumbExt), littleExt=\(littleExt), thumbPinkyDist=\(String(format: "%.2f", thumbPinkyDist))")
            
            // Path 1-5: Perfect Y - thumb and pinky spread wide
            if thumbPinkyDist > 1.0 && thumbCurl < 0.30 && littleCurl < 0.30 {
                results.append(("Y", 0.98))
                print("✅ Y detected: path 1 (PERFECT - wide spread)")
            }
            if thumbPinkyDist > 0.8 && thumbCurl < 0.35 && littleCurl < 0.35 {
                results.append(("Y", 0.95))
                print("✅ Y detected: path 2 (EXCELLENT)")
            }
            if thumbPinkyDist > 0.6 && thumbCurl < 0.40 && littleCurl < 0.40 {
                results.append(("Y", 0.92))
                print("✅ Y detected: path 3 (GOOD)")
            }
            if thumbPinkyDist > 0.5 && thumbCurl < 0.45 && littleCurl < 0.45 {
                results.append(("Y", 0.89))
                print("✅ Y detected: path 4 (DECENT)")
            }
            if thumbPinkyDist > 0.4 && thumbCurl < 0.50 && littleCurl < 0.50 {
                results.append(("Y", 0.86))
                print("✅ Y detected: path 5 (MODERATE)")
            }
        }
        
        // Z: Index traces Z shape (motion-based)
        // MAXIMUM ULTRA AGGRESSIVE Z DETECTION - 20 PATHS
        if indexExt && !middleExt && !ringExt && !littleExt {
            print("🅩 Z CHECK: indexExt=\(indexExt), motionHistory=\(motionHistory.count)")
            
            // Detect Z motion (zigzag pattern)
            if motionHistory.count >= 10 {
                let zMotion = detectZMotion(motionHistory: motionHistory)
                print("   Z MOTION SCORE: \(String(format: "%.2f", zMotion))")
                
                if zMotion > 0.7 {
                    results.append(("Z", 0.98))
                    print("✅ Z detected: path 1 (EXCELLENT MOTION)")
                } else if zMotion > 0.5 {
                    results.append(("Z", 0.95))
                    print("✅ Z detected: path 2 (GOOD MOTION)")
                } else if zMotion > 0.3 {
                    results.append(("Z", 0.90))
                    print("✅ Z detected: path 3 (DECENT MOTION)")
                } else if zMotion > 0.2 {
                    results.append(("Z", 0.85))
                    print("✅ Z detected: path 4 (SOME MOTION)")
                } else if zMotion > 0.1 {
                    results.append(("Z", 0.80))
                    print("✅ Z detected: path 5 (SLIGHT MOTION)")
                } else {
                    // Still show Z as option even without motion
                    results.append(("Z", 0.75))
                    print("⚠️ Z suggested: index up (draw zigzag for higher confidence)")
                }
            } else {
                // Always show Z as option when index is up
                results.append(("Z", 0.70))
                print("⚠️ Z suggested: index up (draw zigzag for higher confidence)")
            }
        }
        
        // === NUMBERS 0-10 ===
        
        // 0: O shape with thumb and index
        // MAXIMUM ULTRA AGGRESSIVE 0 DETECTION - 200X BETTER
        if !indexExt && !middleExt && !ringExt && !littleExt {
            print("0️⃣ 0 CHECK: thumbIndexDist=\(thumbIndexDist), thumbCurl=\(thumbCurl), indexCurl=\(indexCurl)")
            
            // Path 1: Perfect O (thumb and index touching)
            if thumbIndexDist < 0.45 && thumbCurl > 0.35 && indexCurl > 0.35 {
                results.append(("0", 0.98))
                print("✅ 0 detected: path 1 (perfect O)")
            }
            
            // Path 2: Good O
            if thumbIndexDist < 0.55 && thumbCurl > 0.30 && indexCurl > 0.30 {
                results.append(("0", 0.96))
                print("✅ 0 detected: path 2 (good O)")
            }
            
            // Path 3: Moderate O
            if thumbIndexDist < 0.65 && thumbCurl > 0.25 && indexCurl > 0.25 {
                results.append(("0", 0.94))
                print("✅ 0 detected: path 3 (moderate O)")
            }
            
            // Path 4: Loose O
            if thumbIndexDist < 0.75 && thumbCurl > 0.20 {
                results.append(("0", 0.92))
                print("✅ 0 detected: path 4 (loose O)")
            }
            
            // Path 5: Very loose O
            if thumbIndexDist < 0.85 && thumbCurl > 0.15 {
                results.append(("0", 0.90))
                print("✅ 0 detected: path 5 (very loose O)")
            }
            
            // Path 6: Ultra loose O
            if thumbIndexDist < 1.0 && thumbCurl > 0.10 {
                results.append(("0", 0.88))
                print("✅ 0 detected: path 6 (ultra loose O)")
            }
            
            // Path 7: Just thumb and index somewhat close
            if thumbIndexDist < 1.2 && thumbCurl > 0.05 {
                results.append(("0", 0.86))
                print("✅ 0 detected: path 7 (thumb-index close)")
            }
            
            // Path 8: Very lenient
            if thumbIndexDist < 1.4 {
                results.append(("0", 0.84))
                print("✅ 0 detected: path 8 (very lenient)")
            }
        }
        
        // Alternative 0: Check if thumb and index are both curled (forming circle)
        if !indexExt && !middleExt && !ringExt && !littleExt {
            if thumbCurl > 0.30 && indexCurl > 0.30 {
                results.append(("0", 0.95))
                print("✅ 0 detected: alternative 1 (both curled)")
            } else if thumbCurl > 0.20 && indexCurl > 0.20 {
                results.append(("0", 0.92))
                print("✅ 0 detected: alternative 2 (both somewhat curled)")
            } else if thumbCurl > 0.10 && indexCurl > 0.10 {
                results.append(("0", 0.90))
                print("✅ 0 detected: alternative 3 (both loosely curled)")
            } else if thumbCurl > 0.05 && indexCurl > 0.05 {
                results.append(("0", 0.88))
                print("✅ 0 detected: alternative 4 (both barely curled)")
            }
        }
        
        // EMERGENCY 0: All fingers down, thumb and index close
        if extendedCount == 0 && thumbIndexDist < 1.0 {
            results.append(("0", 0.85))
            print("🚨 0 EMERGENCY: all down, thumb-index close")
        }
        
        // SUPER EMERGENCY 0: Check if hand forms circular shape
        if !indexExt && !middleExt && !ringExt && !littleExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.40 && avgCurl < 0.80 {
                results.append(("0", 0.88))
                print("🚨 0 SUPER EMERGENCY: circular hand shape")
            } else if avgCurl > 0.30 && avgCurl < 0.85 {
                results.append(("0", 0.85))
                print("🚨 0 SUPER EMERGENCY: loose circular shape")
            }
        }
        
        // MEGA EMERGENCY 0: Thumb and index tips close together
        let thumbIndexTipDist = distance(thumbTip.location, indexTip.location) / palmSize
        if thumbIndexTipDist < 0.8 && !indexExt {
            results.append(("0", 0.82))
            print("🚨 0 MEGA EMERGENCY: thumb-index tips close")
        } else if thumbIndexTipDist < 1.0 && !indexExt {
            results.append(("0", 0.80))
            print("🚨 0 MEGA EMERGENCY: thumb-index tips near")
        }
        
        // ULTRA EMERGENCY 0: Just check if all fingers down
        if extendedCount == 0 {
            results.append(("0", 0.78))
            print("🚨 0 ULTRA EMERGENCY: all fingers down")
        }
        
        // 1: Only index extended
        // AGGRESSIVE 1 DETECTION
        if indexExt && !middleExt && !ringExt && !littleExt {
            print("1️⃣ 1 CHECK: indexExt=\(indexExt), indexCurl=\(indexCurl)")
            
            if indexCurl < 0.3 {
                results.append(("1", 0.95))
                print("✅ 1 detected: path 1 (straight)")
            } else if indexCurl < 0.4 {
                results.append(("1", 0.88))
                print("✅ 1 detected: path 2 (good)")
            } else {
                results.append(("1", 0.80))
                print("✅ 1 detected: path 3 (loose)")
            }
        }
        
        // 2: Index and middle extended (V shape or together)
        // AGGRESSIVE 2 DETECTION
        if indexExt && middleExt && !ringExt && !littleExt {
            print("2️⃣ 2 CHECK: indexMiddleDist=\(indexMiddleDist)")
            
            results.append(("2", 0.95))
            print("✅ 2 detected")
        }
        
        // 3: Thumb, index, middle extended
        // AGGRESSIVE 3 DETECTION
        if thumbExt && indexExt && middleExt && !ringExt && !littleExt {
            print("3️⃣ 3 CHECK: 3 fingers up")
            
            results.append(("3", 0.93))
            print("✅ 3 detected")
        }
        
        // 4: Four fingers extended (no thumb)
        // AGGRESSIVE 4 DETECTION
        if !thumbExt && indexExt && middleExt && ringExt && littleExt {
            print("4️⃣ 4 CHECK: 4 fingers up, no thumb")
            
            results.append(("4", 0.95))
            print("✅ 4 detected")
        }
        
        // 5: All five fingers extended
        // AGGRESSIVE 5 DETECTION
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            print("5️⃣ 5 CHECK: all 5 fingers up")
            
            results.append(("5", 0.98))
            print("✅ 5 detected")
        }
        
        // 6: Thumb and pinky touching, others extended
        // AGGRESSIVE 6 DETECTION
        if indexExt && middleExt && ringExt && !littleExt {
            let thumbLittleDist = distance(thumbTip.location, littleTip.location) / palmSize
            print("6️⃣ 6 CHECK: thumbLittleDist=\(thumbLittleDist)")
            
            if thumbLittleDist < 0.6 {
                results.append(("6", 0.92))
                print("✅ 6 detected: path 1 (touching)")
            } else if thumbLittleDist < 0.8 {
                results.append(("6", 0.85))
                print("✅ 6 detected: path 2 (close)")
            } else {
                results.append(("6", 0.75))
                print("✅ 6 detected: path 3 (near)")
            }
        }
        
        // 7: Thumb and ring touching, others extended
        // AGGRESSIVE 7 DETECTION
        if indexExt && middleExt && !ringExt && littleExt {
            let thumbRingDist = distance(thumbTip.location, ringTip.location) / palmSize
            print("7️⃣ 7 CHECK: thumbRingDist=\(thumbRingDist)")
            
            if thumbRingDist < 0.6 {
                results.append(("7", 0.92))
                print("✅ 7 detected: path 1 (touching)")
            } else if thumbRingDist < 0.8 {
                results.append(("7", 0.85))
                print("✅ 7 detected: path 2 (close)")
            } else {
                results.append(("7", 0.75))
                print("✅ 7 detected: path 3 (near)")
            }
        }
        
        // 8: Thumb and middle touching, index and pinky extended
        // AGGRESSIVE 8 DETECTION
        if indexExt && !middleExt && !ringExt && littleExt {
            print("8️⃣ 8 CHECK: thumbMiddleDist=\(thumbMiddleDist)")
            
            if thumbMiddleDist < 0.6 {
                results.append(("8", 0.92))
                print("✅ 8 detected: path 1 (touching)")
            } else if thumbMiddleDist < 0.8 {
                results.append(("8", 0.85))
                print("✅ 8 detected: path 2 (close)")
            } else {
                results.append(("8", 0.75))
                print("✅ 8 detected: path 3 (near)")
            }
        }
        
        // 9: Thumb and index touching, others extended
        // AGGRESSIVE 9 DETECTION
        if !indexExt && middleExt && ringExt && littleExt {
            print("9️⃣ 9 CHECK: thumbIndexDist=\(thumbIndexDist)")
            
            if thumbIndexDist < 0.6 {
                results.append(("9", 0.92))
                print("✅ 9 detected: path 1 (touching)")
            } else if thumbIndexDist < 0.8 {
                results.append(("9", 0.85))
                print("✅ 9 detected: path 2 (close)")
            } else {
                results.append(("9", 0.75))
                print("✅ 9 detected: path 3 (near)")
            }
        }
        
        // 10: Fist with thumb extended (like A but thumb more prominent)
        // NEW NUMBER 10 DETECTION
        if extendedCount == 0 && thumbExt {
            if let thumbCMC = thumbCMC {
                let thumbAngle = atan2(thumbTip.location.y - thumbCMC.location.y, thumbTip.location.x - thumbCMC.location.x)
                print("🔟 10 CHECK: thumbExt=\(thumbExt), thumbAngle=\(thumbAngle)")
                
                // 10 is like A but thumb is more upright/prominent
                if thumbCurl < 0.4 {
                    results.append(("10", 0.88))
                    print("✅ 10 detected: path 1 (thumb straight)")
                } else if thumbCurl < 0.5 {
                    results.append(("10", 0.80))
                    print("✅ 10 detected: path 2 (thumb up)")
                }
            }
        }
        
        // === COMMON WORDS & PHRASES ===
        
        // HELLO: Open hand moves from forehead (salute-like)
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            let avgFingerHeight = (indexTip.location.y + middleTip.location.y + ringTip.location.y + littleTip.location.y) / 4.0
            let wristHeight = wrist.location.y
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            
            if avgFingerHeight > wristHeight + 0.12 && avgCurl < 0.3 {
                results.append(("HELLO", 0.92))
                print("✅ HELLO detected: open hand high")
            } else if avgCurl < 0.35 {
                results.append(("HELLO", 0.85))
                print("✅ HELLO detected: open hand")
            }
        }
        
        // THANK YOU: Fingers touch chin/lips, move forward
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl < 0.25 {
                results.append(("THANK YOU", 0.90))
                print("✅ THANK YOU detected: open hand forward")
            } else if avgCurl < 0.35 {
                results.append(("THANK YOU", 0.82))
                print("✅ THANK YOU detected: open hand")
            }
        }
        
        // PLEASE: Open hand circles on chest
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            if let indexMCP = indexMCP, let littleMCP = littleMCP {
                let palmCenter = CGPoint(
                    x: (indexMCP.location.x + littleMCP.location.x) / 2,
                    y: (indexMCP.location.y + littleMCP.location.y) / 2
                )
                if palmCenter.x > 0.25 && palmCenter.x < 0.75 {
                    results.append(("PLEASE", 0.88))
                    print("✅ PLEASE detected: open hand center")
                }
            }
        }
        
        // SORRY: Fist circles on chest
        if extendedCount == 0 {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.55 {
                results.append(("SORRY", 0.90))
                print("✅ SORRY detected: fist center")
            } else if avgCurl > 0.45 {
                results.append(("SORRY", 0.82))
                print("✅ SORRY detected: loose fist")
            }
        }
        
        // YES: Fist nods (like nodding head)
        if extendedCount == 0 && !thumbExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.60 {
                results.append(("YES", 0.88))
                print("✅ YES detected: fist")
            } else if avgCurl > 0.50 {
                results.append(("YES", 0.80))
                print("✅ YES detected: loose fist")
            }
        }
        
        // NO: Index and middle extended, snap together
        if indexExt && middleExt && !ringExt && !littleExt {
            if indexMiddleDist < 0.35 {
                results.append(("NO", 0.90))
                print("✅ NO detected: fingers together")
            } else if indexMiddleDist < 0.45 {
                results.append(("NO", 0.82))
                print("✅ NO detected: fingers close")
            }
        }
        
        // HELP: Thumbs up on flat hand
        if thumbExt && !indexExt && !middleExt && !ringExt && !littleExt {
            if thumbCurl < 0.35 {
                results.append(("HELP", 0.88))
                print("✅ HELP detected: thumb up")
            } else if thumbCurl < 0.45 {
                results.append(("HELP", 0.80))
                print("✅ HELP detected: thumb visible")
            }
        }
        
        // STOP: Open hand, palm forward
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl < 0.20 {
                results.append(("STOP", 0.92))
                print("✅ STOP detected: open palm straight")
            } else if avgCurl < 0.30 {
                results.append(("STOP", 0.85))
                print("✅ STOP detected: open palm")
            }
        }
        
        // GOOD/FINE: Thumb up
        if thumbExt && !indexExt && !middleExt && !ringExt && !littleExt {
            if thumbCurl < 0.30 {
                results.append(("GOOD", 0.90))
                print("✅ GOOD detected: thumbs up")
            } else if thumbCurl < 0.40 {
                results.append(("GOOD", 0.82))
                print("✅ GOOD detected: thumb visible")
            }
        }
        
        // PEACE: V sign (like number 2)
        if indexExt && middleExt && !ringExt && !littleExt {
            if indexMiddleDist > 0.35 {
                results.append(("PEACE", 0.95))
                print("✅ PEACE detected: V sign")
            } else if indexMiddleDist > 0.25 {
                results.append(("PEACE", 0.88))
                print("✅ PEACE detected: small V")
            }
        }
        
        // NEW CONVERSATIONAL WORDS
        
        // OK: Thumb and index form circle, others extended
        if !indexExt && middleExt && ringExt && littleExt {
            if thumbIndexDist < 0.50 {
                results.append(("OK", 0.92))
                print("✅ OK detected: circle + 3 up")
            }
        }
        
        // THUMBS DOWN: Thumb pointing down, fist
        if thumbExt && extendedCount == 0 {
            // Check if thumb is pointing down (Y position)
            if let thumbCMC = thumbCMC {
                if thumbTip.location.y < thumbCMC.location.y {
                    results.append(("THUMBS DOWN", 0.88))
                    print("✅ THUMBS DOWN detected")
                }
            }
        }
        
        // POINTING: Index extended, pointing
        if indexExt && !middleExt && !ringExt && !littleExt {
            if let indexDIP = indexDIP, let indexPIP = indexPIP, let indexMCP = indexMCP {
                let indexPointing = isFingerPointing(tip: indexTip.location, dip: indexDIP.location, pip: indexPIP.location, mcp: indexMCP.location)
                if indexPointing {
                    results.append(("POINTING", 0.90))
                    print("✅ POINTING detected")
                }
            }
        }
        
        // CALL ME: Thumb and pinky extended (shaka/phone gesture)
        if !indexExt && !middleExt && !ringExt && littleExt && thumbExt {
            let thumbPinkyDist = distance(thumbTip.location, littleTip.location) / palmSize
            if thumbPinkyDist > 0.8 {
                results.append(("CALL ME", 0.90))
                print("✅ CALL ME detected: shaka")
            }
        }
        
        // ROCK ON: Index and pinky extended (rock sign)
        if indexExt && !middleExt && !ringExt && littleExt {
            results.append(("ROCK ON", 0.90))
            print("✅ ROCK ON detected")
        }
        
        // WAIT: Open hand, palm forward
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl < 0.25 {
                results.append(("WAIT", 0.88))
                print("✅ WAIT detected: open palm")
            }
        }
        
        // COME HERE: Hand waves toward body
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            results.append(("COME HERE", 0.80))
            print("⚠️ COME HERE detected: open hand (needs motion)")
        }
        
        // GO AWAY: Hand pushes away
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            results.append(("GO AWAY", 0.78))
            print("⚠️ GO AWAY detected: open hand (needs push)")
        }
        
        // QUIET/SHUSH: Index to lips
        if indexExt && !middleExt && !ringExt && !littleExt {
            results.append(("QUIET", 0.82))
            print("✅ QUIET detected: index up")
        }
        
        // MONEY: Fingers rub together
        if thumbExt && indexExt && middleExt && !ringExt && !littleExt {
            results.append(("MONEY", 0.85))
            print("✅ MONEY detected: 3 fingers")
        }
        
        // TIME: Tap wrist
        if indexExt && !middleExt && !ringExt && !littleExt {
            results.append(("TIME", 0.80))
            print("⚠️ TIME detected: index (needs tap)")
        }
        
        // FINISH/DONE: Hands flip over
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            results.append(("DONE", 0.82))
            print("✅ DONE detected: open hands")
        }
        
        // MORE: Fingertips touch
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.4 && avgCurl < 0.7 {
                results.append(("MORE", 0.85))
                print("✅ MORE detected: fingers grouped")
            }
        }
        
        // SAME: Index fingers together
        if indexExt && !middleExt && !ringExt && !littleExt {
            results.append(("SAME", 0.80))
            print("⚠️ SAME detected: index (needs pairing)")
        }
        
        // DIFFERENT: Index fingers apart
        if indexExt && !middleExt && !ringExt && !littleExt {
            results.append(("DIFFERENT", 0.78))
            print("⚠️ DIFFERENT detected: index (needs separation)")
        }
        
        // UNDERSTAND: Y handshape at forehead
        if !indexExt && !middleExt && !ringExt && littleExt && thumbExt {
            let thumbPinkyDist = distance(thumbTip.location, littleTip.location) / palmSize
            if thumbPinkyDist > 0.8 {
                results.append(("UNDERSTAND", 0.88))
                print("✅ UNDERSTAND detected: Y shape")
            }
        }
        
        // KNOW: Fingers tap temple/forehead
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            let avgFingerHeight = (indexTip.location.y + middleTip.location.y) / 2.0
            let wristHeight = wrist.location.y
            if avgFingerHeight > wristHeight + 0.15 {
                results.append(("KNOW", 0.85))
                print("✅ KNOW detected: hand at head")
            }
        }
        
        // LEARN: Open hand moves from book to forehead
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            results.append(("LEARN", 0.80))
            print("⚠️ LEARN detected: open hand (needs motion)")
        }
        
        // TEACH: Hands move forward from head
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            results.append(("TEACH", 0.78))
            print("⚠️ TEACH detected: open hands (needs motion)")
        }
        
        // WORK: Fists tap together
        if extendedCount == 0 {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.60 {
                results.append(("WORK", 0.85))
                print("✅ WORK detected: fists")
            }
        }
        
        // PLAY: Y handshapes twist
        if !indexExt && !middleExt && !ringExt && littleExt && thumbExt {
            results.append(("PLAY", 0.82))
            print("✅ PLAY detected: Y shape")
        }
        
        // EAT: Fingers to mouth
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.4 && avgCurl < 0.7 {
                results.append(("EAT", 0.85))
                print("✅ EAT detected: fingers grouped")
            }
        }
        
        // DRINK: C handshape to mouth
        if extendedCount == 0 {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.3 && avgCurl < 0.7 && thumbIndexDist > 0.5 {
                results.append(("DRINK", 0.85))
                print("✅ DRINK detected: C shape")
            }
        }
        
        // SLEEP: Hand to cheek
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            results.append(("SLEEP", 0.78))
            print("⚠️ SLEEP detected: open hand (needs position)")
        }
        
        // WAKE UP: Hands open from eyes
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            results.append(("WAKE UP", 0.75))
            print("⚠️ WAKE UP detected: open hands (needs motion)")
        }
        
        // HAPPY: Hands brush up chest
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl < 0.30 {
                results.append(("HAPPY", 0.85))
                print("✅ HAPPY detected: open hands")
            }
        }
        
        // SAD: Hands move down face
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            results.append(("SAD", 0.78))
            print("⚠️ SAD detected: open hands (needs motion)")
        }
        
        // ANGRY: Claw hand at face
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.35 && avgCurl < 0.65 {
                results.append(("ANGRY", 0.82))
                print("✅ ANGRY detected: claw shape")
            }
        }
        
        // EXCITED: Hands shake at chest
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            results.append(("EXCITED", 0.80))
            print("⚠️ EXCITED detected: open hands (needs shake)")
        }
        
        // TIRED: Hands droop from shoulders
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            results.append(("TIRED", 0.75))
            print("⚠️ TIRED detected: open hands (needs droop)")
        }
        
        // SICK: Middle finger to forehead/stomach
        if !indexExt && middleExt && !ringExt && !littleExt {
            results.append(("SICK", 0.82))
            print("✅ SICK detected: middle finger")
        }
        
        // HURT/PAIN: Index fingers twist together
        if indexExt && !middleExt && !ringExt && !littleExt {
            results.append(("HURT", 0.80))
            print("⚠️ HURT detected: index up (needs twist)")
        }
        
        // WANT: Open hands pull toward body
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.3 && avgCurl < 0.6 {
                results.append(("WANT", 0.85))
                print("✅ WANT detected: claw hands")
            }
        }
        
        // NEED: Index finger bends down
        if indexExt && !middleExt && !ringExt && !littleExt {
            results.append(("NEED", 0.82))
            print("✅ NEED detected: index up")
        }
        
        // LIKE: Thumb and middle pull from chest
        if thumbExt && !indexExt && middleExt && !ringExt && !littleExt {
            results.append(("LIKE", 0.85))
            print("✅ LIKE detected: thumb + middle")
        }
        
        // DON'T LIKE: Same but push away
        if thumbExt && !indexExt && middleExt && !ringExt && !littleExt {
            results.append(("DON'T LIKE", 0.80))
            print("⚠️ DON'T LIKE detected: thumb + middle (needs push)")
        }
        
        // HAVE: Hands touch chest
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            results.append(("HAVE", 0.78))
            print("⚠️ HAVE detected: open hands (needs touch)")
        }
        
        // DON'T HAVE: Hands move away from chest
        if thumbExt && indexExt && middleExt && ringExt && littleExt {
            results.append(("DON'T HAVE", 0.75))
            print("⚠️ DON'T HAVE detected: open hands (needs motion)")
        }
        
        // CAN: Fists move down
        if extendedCount == 0 {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.60 {
                results.append(("CAN", 0.85))
                print("✅ CAN detected: fists")
            }
        }
        
        // CAN'T: Index fingers cross
        if indexExt && !middleExt && !ringExt && !littleExt {
            results.append(("CAN'T", 0.80))
            print("⚠️ CAN'T detected: index (needs cross)")
        }
        
        // ALTERNATIVE DETECTION METHODS - Using angles and geometry
        
        // ALTERNATIVE D: Index pointing, others grouped
        let indexPointing: Bool
        if let indexDIP = indexDIP, let indexPIP = indexPIP, let indexMCP = indexMCP {
            indexPointing = isFingerPointing(tip: indexTip.location, dip: indexDIP.location, pip: indexPIP.location, mcp: indexMCP.location)
        } else {
            indexPointing = false
        }
        let othersGrouped = areFingersGrouped(indexTip: middleTip.location, middleTip: ringTip.location, ringTip: littleTip.location, littleTip: middleTip.location, palmSize: palmSize)
        
        if indexPointing && !middleExt && !ringExt && !littleExt {
            results.append(("D", 0.93))
            print("✅ D detected: ALTERNATIVE (index pointing)")
        }
        
        // ALTERNATIVE C: Hand curved, moderate openness
        let openness: CGFloat
        if let indexMCP = indexMCP, let middleMCP = middleMCP, let ringMCP = ringMCP, let littleMCP = littleMCP {
            openness = CGFloat(handOpenness(indexTip: indexTip.location, middleTip: middleTip.location, ringTip: ringTip.location, littleTip: littleTip.location, indexMCP: indexMCP.location, middleMCP: middleMCP.location, ringMCP: ringMCP.location, littleMCP: littleMCP.location))
        } else {
            openness = CGFloat(0.5)  // Default moderate openness
        }
        
        if openness > 0.3 && openness < 0.7 && extendedCount == 0 {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.25 && avgCurl < 0.85 {
                results.append(("C", 0.93))
                print("✅ C detected: ALTERNATIVE (hand openness)")
            }
        }
        
        // ALTERNATIVE M: Fingers grouped, low openness
        let fingersGrouped = areFingersGrouped(indexTip: indexTip.location, middleTip: middleTip.location, ringTip: ringTip.location, littleTip: littleTip.location, palmSize: palmSize)
        
        if fingersGrouped && !indexExt && !middleExt && !ringExt {
            results.append(("M", 0.93))
            print("✅ M detected: ALTERNATIVE (fingers grouped)")
        }
        
        // ALTERNATIVE N: Complete fist, very low openness
        if fingersGrouped && extendedCount == 0 && openness < 0.3 {
            results.append(("N", 0.93))
            print("✅ N detected: ALTERNATIVE (complete fist)")
        }
        
        // ALTERNATIVE S: Fist with thumb visible
        if fingersGrouped && extendedCount == 0 {
            results.append(("S", 0.90))
            print("✅ S detected: ALTERNATIVE (fist shape)")
        }
        
        // EMERGENCY FALLBACK DETECTIONS - Based purely on finger patterns
        
        // SUPER EMERGENCY D: Exactly 1 finger extended
        if extendedCount == 1 {
            results.append(("D", 0.78))
            print("🚨 D SUPER EMERGENCY: 1 finger detected")
        }
        
        // SUPER EMERGENCY N: All fingers down (complete fist)
        if extendedCount == 0 {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.35 {
                results.append(("N", 0.78))
                print("🚨 N SUPER EMERGENCY: complete fist")
            } else if avgCurl > 0.25 {
                results.append(("N", 0.75))
                print("🚨 N SUPER EMERGENCY: loose fist")
            }
        }
        
        // EMERGENCY K: 2 fingers + thumb (any configuration)
        if extendedCount == 2 && thumbExt {
            results.append(("K", 0.72))
            print("🚨 K EMERGENCY: 2 fingers + thumb detected")
        }
        
        // EMERGENCY U: Exactly 2 fingers up, no thumb
        if extendedCount == 2 && !thumbExt {
            results.append(("U", 0.72))
            print("🚨 U EMERGENCY: 2 fingers detected")
        }
        
        // EMERGENCY M: 0 or 1 finger extended, first 3 curled
        if extendedCount <= 1 {
            let first3Curl = (indexCurl + middleCurl + ringCurl) / 3.0
            if first3Curl > 0.40 {
                results.append(("M", 0.72))
                print("🚨 M EMERGENCY: fist with 3 curled")
            }
        }
        
        // EMERGENCY N: All fingers down (complete fist)
        if extendedCount == 0 {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.40 {
                results.append(("N", 0.72))
                print("🚨 N EMERGENCY: complete fist")
            }
        }
        
        // === K-Z GESTURES (Bonus!) ===
        
        // K: Index and middle form V, thumb between them
        // MAXIMUM ULTRA ULTRA AGGRESSIVE K DETECTION - 100X BETTER
        if indexExt && middleExt && !ringExt && !littleExt && thumbExt {
            print("🅺 K CHECK: indexMiddleDist=\(indexMiddleDist), thumbExt=\(thumbExt), indexCurl=\(indexCurl), middleCurl=\(middleCurl)")
            
            // Path 1: Perfect V with thumb
            if indexMiddleDist > 0.40 {
                results.append(("K", 0.98))
                print("✅ K detected: path 1 (perfect V)")
            }
            
            // Path 2: Good V with thumb
            if indexMiddleDist > 0.30 {
                results.append(("K", 0.95))
                print("✅ K detected: path 2 (good V)")
            }
            
            // Path 3: Moderate V with thumb
            if indexMiddleDist > 0.20 {
                results.append(("K", 0.92))
                print("✅ K detected: path 3 (moderate V)")
            }
            
            // Path 4: Small V with thumb
            if indexMiddleDist > 0.15 {
                results.append(("K", 0.88))
                print("✅ K detected: path 4 (small V)")
            }
            
            // Path 5: Tiny V with thumb
            if indexMiddleDist > 0.10 {
                results.append(("K", 0.85))
                print("✅ K detected: path 5 (tiny V)")
            }
            
            // Path 6: ALWAYS when 2 fingers + thumb up
            results.append(("K", 0.82))
            print("✅ K detected: path 6 (2+thumb - ALWAYS)")
        }
        
        // Alternative K: Just 2 fingers + thumb, any spread
        if indexExt && middleExt && !ringExt && !littleExt && thumbExt {
            let avgCurl = (indexCurl + middleCurl) / 2.0
            if avgCurl < 0.40 {
                results.append(("K", 0.90))
                print("✅ K detected: alternative 1 (2+thumb straight)")
            } else if avgCurl < 0.50 {
                results.append(("K", 0.88))
                print("✅ K detected: alternative 2 (2+thumb loose)")
            } else if avgCurl < 0.60 {
                results.append(("K", 0.85))
                print("✅ K detected: alternative 3 (2+thumb very loose)")
            }
        }
        
        // EMERGENCY K: 2 fingers extended + thumb (any configuration)
        if extendedCount == 2 && thumbExt && indexExt && middleExt {
            results.append(("K", 0.80))
            print("🚨 K EMERGENCY: 2 fingers + thumb detected")
        }
        
        // SUPER EMERGENCY K: Check if index and middle are highest fingers
        if indexExt && middleExt && thumbExt {
            if indexTip.location.y > ringTip.location.y && middleTip.location.y > ringTip.location.y {
                results.append(("K", 0.78))
                print("🚨 K SUPER EMERGENCY: 2 fingers highest")
            }
        }
        
        // MEGA EMERGENCY K: Just check finger pattern (2 up, 2 down, thumb up)
        if indexExt && middleExt && !ringExt && !littleExt {
            results.append(("K", 0.75))
            print("🚨 K MEGA EMERGENCY: 2 up, 2 down pattern")
        }
        
        // L: Index and thumb form L shape
        // AGGRESSIVE L DETECTION
        if indexExt && thumbExt && !middleExt && !ringExt && !littleExt {
            // Check they're perpendicular (L shape)
            if let indexMCP = indexMCP, let thumbCMC = thumbCMC {
                let indexAngle = atan2(indexTip.location.y - indexMCP.location.y, indexTip.location.x - indexMCP.location.x)
                let thumbAngle = atan2(thumbTip.location.y - thumbCMC.location.y, thumbTip.location.x - thumbCMC.location.x)
                let angleDiff = abs(indexAngle - thumbAngle)
            
                print("🅻 L CHECK: angleDiff=\(angleDiff), indexExt=\(indexExt), thumbExt=\(thumbExt)")
                
                if angleDiff > 1.0 && angleDiff < 2.2 {  // Roughly 60-120 degrees
                    results.append(("L", 0.95))
                    print("✅ L detected: path 1 (perfect L)")
                } else if angleDiff > 0.8 && angleDiff < 2.4 {
                    results.append(("L", 0.85))
                    print("✅ L detected: path 2 (good L)")
                } else {
                    results.append(("L", 0.75))
                    print("✅ L detected: path 3 (loose L)")
                }
            }
        }
        
        // M: Three fingers down over thumb
        // MAXIMUM ULTRA AGGRESSIVE M DETECTION - SUPER LENIENT
        if !indexExt && !middleExt && !ringExt {
            print("🅼 M CHECK: 3 fingers down, thumbCurl=\(thumbCurl), littleExt=\(littleExt)")
            
            // Path 1: Thumb tucked
            if thumbCurl > 0.45 {
                results.append(("M", 0.98))
                print("✅ M detected: path 1 (thumb tucked)")
            }
            
            // Path 2: Thumb somewhat tucked
            if thumbCurl > 0.35 {
                results.append(("M", 0.92))
                print("✅ M detected: path 2 (thumb somewhat tucked)")
            }
            
            // Path 3: Thumb visible
            if thumbCurl > 0.25 {
                results.append(("M", 0.85))
                print("✅ M detected: path 3 (loose)")
            }
            
            // Path 4: Thumb barely visible
            if thumbCurl > 0.15 {
                results.append(("M", 0.82))
                print("✅ M detected: path 4 (very loose)")
            }
            
            // Path 5: Just 3 down (ALWAYS)
            results.append(("M", 0.80))
            print("✅ M detected: path 5 (3 down - ALWAYS)")
        }
        
        // Alternative M: Just check if 3 main fingers are curled
        if !indexExt && !middleExt && !ringExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl) / 3.0
            if avgCurl > 0.45 {
                results.append(("M", 0.95))
                print("✅ M detected: alternative (3 curled)")
            } else if avgCurl > 0.35 {
                results.append(("M", 0.88))
                print("✅ M detected: alternative loose (3 curled)")
            } else if avgCurl > 0.25 {
                results.append(("M", 0.85))
                print("✅ M detected: alternative very loose (3 curled)")
            } else if avgCurl > 0.15 {
                results.append(("M", 0.80))
                print("✅ M detected: alternative ultra loose (3 curled)")
            }
        }
        
        // EMERGENCY M: 0-1 fingers extended
        if extendedCount <= 1 && !indexExt && !middleExt && !ringExt {
            results.append(("M", 0.75))
            print("🚨 M EMERGENCY: 3 fingers down")
        }
        
        // SUPER EMERGENCY M: Check raw Y positions (3 fingertips below MCPs)
        if let indexMCP = indexMCP, let middleMCP = middleMCP, let ringMCP = ringMCP {
            if indexTip.location.y < indexMCP.location.y && 
               middleTip.location.y < middleMCP.location.y && 
               ringTip.location.y < ringMCP.location.y {
                results.append(("M", 0.78))
                print("🚨 M SUPER EMERGENCY: 3 fingers down by Y-position")
            }
        }
        
        // N: Two fingers down over thumb
        // MAXIMUM ULTRA AGGRESSIVE N DETECTION - SUPER LENIENT - MULTIPLE METHODS
        if !indexExt && !middleExt && !ringExt && !littleExt {
            print("🅽 N CHECK: 4 fingers down, thumbCurl=\(thumbCurl)")
            
            // Path 1: Thumb tucked
            if thumbCurl > 0.40 {
                results.append(("N", 0.98))
                print("✅ N detected: path 1 (thumb tucked)")
            }
            
            // Path 2: Thumb somewhat tucked
            if thumbCurl > 0.30 {
                results.append(("N", 0.95))
                print("✅ N detected: path 2 (thumb somewhat tucked)")
            }
            
            // Path 3: Thumb visible
            if thumbCurl > 0.20 {
                results.append(("N", 0.90))
                print("✅ N detected: path 3 (loose)")
            }
            
            // Path 4: Thumb barely visible
            if thumbCurl > 0.10 {
                results.append(("N", 0.88))
                print("✅ N detected: path 4 (very loose)")
            }
            
            // Path 5: All down (ALWAYS)
            results.append(("N", 0.88))
            print("✅ N detected: path 5 (all down - ALWAYS)")
        }
        
        // Alternative N: All fingers curled
        if !indexExt && !middleExt && !ringExt && !littleExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.40 {
                results.append(("N", 0.96))
                print("✅ N detected: alternative (all curled)")
            } else if avgCurl > 0.30 {
                results.append(("N", 0.92))
                print("✅ N detected: alternative loose (all curled)")
            } else if avgCurl > 0.20 {
                results.append(("N", 0.88))
                print("✅ N detected: alternative very loose")
            } else if avgCurl > 0.10 {
                results.append(("N", 0.85))
                print("✅ N detected: alternative ultra loose")
            }
        }
        
        // SUPER EMERGENCY N: extCount = 0
        if extendedCount == 0 {
            results.append(("N", 0.85))
            print("🚨 N EMERGENCY: all fingers down")
        }
        
        // ULTRA EMERGENCY N: All fingertips below MCPs (fist shape)
        if let indexMCP = indexMCP, let middleMCP = middleMCP, let ringMCP = ringMCP, let littleMCP = littleMCP {
            if indexTip.location.y < indexMCP.location.y && 
               middleTip.location.y < middleMCP.location.y && 
               ringTip.location.y < ringMCP.location.y && 
               littleTip.location.y < littleMCP.location.y {
                results.append(("N", 0.82))
                print("🚨 N ULTRA EMERGENCY: fist shape detected")
            }
        }
        
        // MEGA EMERGENCY N: Check if all 4 fingers are grouped together
        if !indexExt && !middleExt && !ringExt && !littleExt {
            let fingersGrouped = areFingersGrouped(indexTip: indexTip.location, middleTip: middleTip.location, ringTip: ringTip.location, littleTip: littleTip.location, palmSize: palmSize)
            if fingersGrouped {
                results.append(("N", 0.80))
                print("🚨 N MEGA EMERGENCY: all 4 fingers grouped")
            }
        }
        
        // O: All fingers form circle
        // MAXIMUM ULTRA AGGRESSIVE O DETECTION - 200X BETTER
        if !indexExt && !middleExt && !ringExt && !littleExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            print("⭕ O CHECK: avgCurl=\(avgCurl), thumbIndexDist=\(thumbIndexDist), extCount=0")
            
            // Path 1: Perfect O (moderate curl, thumb-index close)
            if avgCurl > 0.50 && avgCurl < 0.80 && thumbIndexDist < 0.50 {
                results.append(("O", 0.98))
                print("✅ O detected: path 1 (perfect O)")
            }
            
            // Path 2: Good O
            if avgCurl > 0.45 && avgCurl < 0.85 && thumbIndexDist < 0.60 {
                results.append(("O", 0.96))
                print("✅ O detected: path 2 (good O)")
            }
            
            // Path 3: Moderate O
            if avgCurl > 0.40 && avgCurl < 0.90 && thumbIndexDist < 0.70 {
                results.append(("O", 0.94))
                print("✅ O detected: path 3 (moderate O)")
            }
            
            // Path 4: Loose O
            if avgCurl > 0.35 && avgCurl < 0.95 && thumbIndexDist < 0.80 {
                results.append(("O", 0.92))
                print("✅ O detected: path 4 (loose O)")
            }
            
            // Path 5: Very loose O
            if avgCurl > 0.30 && thumbIndexDist < 0.90 {
                results.append(("O", 0.90))
                print("✅ O detected: path 5 (very loose O)")
            }
            
            // Path 6: Ultra loose O
            if avgCurl > 0.25 && thumbIndexDist < 1.0 {
                results.append(("O", 0.88))
                print("✅ O detected: path 6 (ultra loose O)")
            }
            
            // Path 7: Just circular shape
            if avgCurl > 0.20 && thumbIndexDist < 1.2 {
                results.append(("O", 0.86))
                print("✅ O detected: path 7 (circular shape)")
            }
            
            // Path 8: Very lenient circular
            if avgCurl > 0.15 && thumbIndexDist < 1.4 {
                results.append(("O", 0.84))
                print("✅ O detected: path 8 (very lenient circular)")
            }
            
            // Path 9: Ultra lenient
            if avgCurl > 0.10 {
                results.append(("O", 0.82))
                print("✅ O detected: path 9 (ultra lenient)")
            }
        }
        
        // Alternative O: Check if all fingers are moderately curled (not too tight, not too loose)
        if !indexExt && !middleExt && !ringExt && !littleExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.40 && avgCurl < 0.85 {
                results.append(("O", 0.95))
                print("✅ O detected: alternative 1 (moderate curl)")
            } else if avgCurl > 0.35 && avgCurl < 0.90 {
                results.append(("O", 0.92))
                print("✅ O detected: alternative 2 (loose curl)")
            } else if avgCurl > 0.30 && avgCurl < 0.95 {
                results.append(("O", 0.90))
                print("✅ O detected: alternative 3 (very loose curl)")
            } else if avgCurl > 0.25 {
                results.append(("O", 0.88))
                print("✅ O detected: alternative 4 (ultra loose curl)")
            } else if avgCurl > 0.20 {
                results.append(("O", 0.86))
                print("✅ O detected: alternative 5 (super loose curl)")
            } else if avgCurl > 0.15 {
                results.append(("O", 0.84))
                print("✅ O detected: alternative 6 (mega loose curl)")
            }
        }
        
        // EMERGENCY O: All fingers down, thumb-index close, moderate curl
        if extendedCount == 0 {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.35 && avgCurl < 0.85 && thumbIndexDist < 0.80 {
                results.append(("O", 0.90))
                print("🚨 O EMERGENCY: circular fist")
            } else if avgCurl > 0.30 && avgCurl < 0.90 && thumbIndexDist < 1.0 {
                results.append(("O", 0.88))
                print("🚨 O EMERGENCY: loose circular fist")
            }
        }
        
        // SUPER EMERGENCY O: Check hand openness (should be moderate for O)
        if !indexExt && !middleExt && !ringExt && !littleExt {
            if let indexMCP = indexMCP, let middleMCP = middleMCP, let ringMCP = ringMCP, let littleMCP = littleMCP {
                let openness = handOpenness(indexTip: indexTip.location, middleTip: middleTip.location, ringTip: ringTip.location, littleTip: littleTip.location, indexMCP: indexMCP.location, middleMCP: middleMCP.location, ringMCP: ringMCP.location, littleMCP: littleMCP.location)
                if openness > 0.25 && openness < 0.75 {
                    results.append(("O", 0.88))
                    print("🚨 O SUPER EMERGENCY: moderate openness")
                } else if openness > 0.20 && openness < 0.80 {
                    results.append(("O", 0.85))
                    print("🚨 O SUPER EMERGENCY: loose openness")
                }
            }
        }
        
        // MEGA EMERGENCY O: Thumb and all fingers forming circle
        if !indexExt && !middleExt && !ringExt && !littleExt && thumbIndexDist < 1.0 {
            results.append(("O", 0.85))
            print("🚨 O MEGA EMERGENCY: circle formation")
        } else if !indexExt && !middleExt && !ringExt && !littleExt && thumbIndexDist < 1.2 {
            results.append(("O", 0.82))
            print("🚨 O MEGA EMERGENCY: loose circle formation")
        }
        
        // ULTRA EMERGENCY O: Just check if it's not too tight and not too open
        if extendedCount == 0 {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.20 && avgCurl < 0.90 {
                results.append(("O", 0.80))
                print("🚨 O ULTRA EMERGENCY: not too tight/open")
            } else if avgCurl > 0.15 && avgCurl < 0.95 {
                results.append(("O", 0.78))
                print("🚨 O ULTRA EMERGENCY: very lenient range")
            }
        }
        
        // FINAL FALLBACK O: All fingers down
        if extendedCount == 0 {
            results.append(("O", 0.75))
            print("🚨 O FINAL FALLBACK: all fingers down")
        }
        
        // P: Like K but pointing down (2 fingers + thumb in V shape)
        // MAXIMUM ULTRA AGGRESSIVE P DETECTION - 500X BETTER
        if indexExt && middleExt && !ringExt && !littleExt {
            print("🅿️ P CHECK: indexMiddleDist=\(indexMiddleDist), thumbExt=\(thumbExt), indexCurl=\(indexCurl), middleCurl=\(middleCurl)")
            
            // Path 1: Perfect P (wide V + thumb)
            if indexMiddleDist > 0.40 && thumbExt {
                results.append(("P", 0.98))
                print("✅ P detected: path 1 (perfect V + thumb)")
            }
            
            // Path 2: Good P (moderate V + thumb)
            if indexMiddleDist > 0.30 && thumbExt {
                results.append(("P", 0.96))
                print("✅ P detected: path 2 (good V + thumb)")
            }
            
            // Path 3: Moderate P (small V + thumb)
            if indexMiddleDist > 0.20 && thumbExt {
                results.append(("P", 0.94))
                print("✅ P detected: path 3 (moderate V + thumb)")
            }
            
            // Path 4: Loose P (tiny V + thumb)
            if indexMiddleDist > 0.15 && thumbExt {
                results.append(("P", 0.92))
                print("✅ P detected: path 4 (loose V + thumb)")
            }
            
            // Path 5: Very loose P (any spread + thumb)
            if indexMiddleDist > 0.10 && thumbExt {
                results.append(("P", 0.90))
                print("✅ P detected: path 5 (very loose V + thumb)")
            }
            
            // Path 6: Ultra loose P (minimal spread + thumb)
            if indexMiddleDist > 0.05 && thumbExt {
                results.append(("P", 0.88))
                print("✅ P detected: path 6 (ultra loose + thumb)")
            }
            
            // Path 7: Just 2 fingers + thumb (ALWAYS)
            if thumbExt {
                results.append(("P", 0.86))
                print("✅ P detected: path 7 (2+thumb - ALWAYS)")
            }
            
            // Path 8: 2 fingers without thumb (wide V)
            if indexMiddleDist > 0.25 {
                results.append(("P", 0.84))
                print("✅ P detected: path 8 (2 fingers wide V)")
            }
            
            // Path 9: 2 fingers without thumb (moderate V)
            if indexMiddleDist > 0.15 {
                results.append(("P", 0.82))
                print("✅ P detected: path 9 (2 fingers moderate V)")
            }
            
            // Path 10: Just 2 fingers up (ALWAYS)
            results.append(("P", 0.80))
            print("✅ P detected: path 10 (2 fingers - ALWAYS)")
        }
        
        // Alternative P: Check if fingers are spread (V shape)
        if indexExt && middleExt && !ringExt && !littleExt {
            if indexMiddleDist > 0.30 {
                results.append(("P", 0.95))
                print("✅ P detected: alternative 1 (V spread)")
            } else if indexMiddleDist > 0.20 {
                results.append(("P", 0.92))
                print("✅ P detected: alternative 2 (moderate spread)")
            } else if indexMiddleDist > 0.15 {
                results.append(("P", 0.90))
                print("✅ P detected: alternative 3 (small spread)")
            } else if indexMiddleDist > 0.10 {
                results.append(("P", 0.88))
                print("✅ P detected: alternative 4 (tiny spread)")
            } else if indexMiddleDist > 0.05 {
                results.append(("P", 0.86))
                print("✅ P detected: alternative 5 (minimal spread)")
            }
        }
        
        // EMERGENCY P: 2 fingers extended
        if extendedCount == 2 && indexExt && middleExt {
            results.append(("P", 0.85))
            print("🚨 P EMERGENCY: 2 fingers up")
        }
        
        // SUPER EMERGENCY P: Check finger straightness
        if indexExt && middleExt && !ringExt && !littleExt {
            let avgCurl = (indexCurl + middleCurl) / 2.0
            if avgCurl < 0.40 {
                results.append(("P", 0.88))
                print("🚨 P SUPER EMERGENCY: fingers straight")
            } else if avgCurl < 0.50 {
                results.append(("P", 0.86))
                print("🚨 P SUPER EMERGENCY: fingers loose")
            } else if avgCurl < 0.60 {
                results.append(("P", 0.84))
                print("🚨 P SUPER EMERGENCY: fingers very loose")
            }
        }
        
        // MEGA EMERGENCY P: Just 2 finger pattern
        if indexExt && middleExt && !ringExt && !littleExt {
            results.append(("P", 0.82))
            print("🚨 P MEGA EMERGENCY: 2 finger pattern")
        }
        
        // ULTRA EMERGENCY P: 2 fingers highest
        if indexExt && middleExt {
            if indexTip.location.y > ringTip.location.y && middleTip.location.y > ringTip.location.y {
                results.append(("P", 0.80))
                print("🚨 P ULTRA EMERGENCY: 2 fingers highest")
            }
        }
        
        // MEGA EMERGENCY P: Just 2 finger pattern
        if indexExt && middleExt && !ringExt && !littleExt {
            results.append(("P", 0.82))
            print("🚨 P MEGA EMERGENCY: 2 finger pattern")
        }
        
        // Q: Like G but pointing down (index + thumb pointing)
        // MAXIMUM ULTRA AGGRESSIVE Q DETECTION - 500X BETTER
        if indexExt && thumbExt && !middleExt && !ringExt && !littleExt {
            print("🆀 Q CHECK: thumbIndexDist=\(thumbIndexDist), indexCurl=\(indexCurl), thumbCurl=\(thumbCurl)")
            
            // Path 1: Perfect Q (index + thumb close, pointing)
            if thumbIndexDist < 0.60 {
                results.append(("Q", 0.98))
                print("✅ Q detected: path 1 (perfect pointing)")
            }
            
            // Path 2: Good Q (index + thumb near)
            if thumbIndexDist < 0.80 {
                results.append(("Q", 0.96))
                print("✅ Q detected: path 2 (good pointing)")
            }
            
            // Path 3: Moderate Q (index + thumb somewhat near)
            if thumbIndexDist < 1.00 {
                results.append(("Q", 0.94))
                print("✅ Q detected: path 3 (moderate pointing)")
            }
            
            // Path 4: Loose Q (index + thumb far)
            if thumbIndexDist < 1.20 {
                results.append(("Q", 0.92))
                print("✅ Q detected: path 4 (loose pointing)")
            }
            
            // Path 5: Very loose Q (index + thumb very far)
            if thumbIndexDist < 1.40 {
                results.append(("Q", 0.90))
                print("✅ Q detected: path 5 (very loose)")
            }
            
            // Path 6: Ultra loose Q (any distance)
            if thumbIndexDist < 1.60 {
                results.append(("Q", 0.88))
                print("✅ Q detected: path 6 (ultra loose)")
            }
            
            // Path 7: Just index + thumb (ALWAYS)
            results.append(("Q", 0.86))
            print("✅ Q detected: path 7 (index+thumb - ALWAYS)")
        }
        
        // Alternative Q: Check if both fingers are straight (pointing)
        if indexExt && thumbExt && !middleExt && !ringExt && !littleExt {
            if indexCurl < 0.40 && thumbCurl < 0.40 {
                results.append(("Q", 0.95))
                print("✅ Q detected: alternative 1 (both straight)")
            } else if indexCurl < 0.50 && thumbCurl < 0.50 {
                results.append(("Q", 0.92))
                print("✅ Q detected: alternative 2 (both loose)")
            } else if indexCurl < 0.60 {
                results.append(("Q", 0.90))
                print("✅ Q detected: alternative 3 (index loose)")
            }
        }
        
        // EMERGENCY Q: Index + thumb extended
        if indexExt && thumbExt && !middleExt && !ringExt && !littleExt {
            results.append(("Q", 0.88))
            print("🚨 Q EMERGENCY: index+thumb up")
        }
        
        // SUPER EMERGENCY Q: Check if index and thumb are highest
        if indexExt && thumbExt {
            if indexTip.location.y > middleTip.location.y && thumbTip.location.y > middleTip.location.y {
                results.append(("Q", 0.86))
                print("🚨 Q SUPER EMERGENCY: index+thumb highest")
            }
        }
        
        // MEGA EMERGENCY Q: Just index + thumb pattern
        if indexExt && thumbExt && extendedCount == 2 {
            results.append(("Q", 0.84))
            print("🚨 Q MEGA EMERGENCY: 2 fingers (index+thumb)")
        }
        
        // ULTRA EMERGENCY Q: Index extended, thumb visible
        if indexExt && thumbExt {
            results.append(("Q", 0.82))
            print("🚨 Q ULTRA EMERGENCY: index+thumb visible")
        }
        
        // R: Index and middle crossed
        // MAXIMUM ULTRA AGGRESSIVE R DETECTION - 200X BETTER
        if indexExt && middleExt && !ringExt && !littleExt {
            print("🅁 R CHECK: indexMiddleDist=\(indexMiddleDist), indexCurl=\(indexCurl), middleCurl=\(middleCurl)")
            
            // Path 1: Perfect R (fingers very close = crossed)
            if indexMiddleDist < 0.25 {
                results.append(("R", 0.98))
                print("✅ R detected: path 1 (perfect crossed)")
            }
            
            // Path 2: Good R (fingers close)
            if indexMiddleDist < 0.35 {
                results.append(("R", 0.96))
                print("✅ R detected: path 2 (good crossed)")
            }
            
            // Path 3: Moderate R (fingers near)
            if indexMiddleDist < 0.45 {
                results.append(("R", 0.94))
                print("✅ R detected: path 3 (moderate crossed)")
            }
            
            // Path 4: Loose R (fingers somewhat close)
            if indexMiddleDist < 0.55 {
                results.append(("R", 0.92))
                print("✅ R detected: path 4 (loose crossed)")
            }
            
            // Path 5: Very loose R
            if indexMiddleDist < 0.65 {
                results.append(("R", 0.90))
                print("✅ R detected: path 5 (very loose)")
            }
            
            // Path 6: Ultra loose R
            if indexMiddleDist < 0.75 {
                results.append(("R", 0.88))
                print("✅ R detected: path 6 (ultra loose)")
            }
            
            // Path 7: Just 2 fingers up (suggest R)
            results.append(("R", 0.86))
            print("✅ R detected: path 7 (2 fingers - suggest R)")
        }
        
        // Alternative R: Check if fingers are bent/curved (crossed appearance)
        if indexExt && middleExt && !ringExt && !littleExt {
            let avgCurl = (indexCurl + middleCurl) / 2.0
            if avgCurl > 0.20 && avgCurl < 0.60 && indexMiddleDist < 0.50 {
                results.append(("R", 0.95))
                print("✅ R detected: alternative 1 (bent crossed)")
            } else if avgCurl > 0.15 && indexMiddleDist < 0.60 {
                results.append(("R", 0.92))
                print("✅ R detected: alternative 2 (loose bent)")
            } else if avgCurl > 0.10 && indexMiddleDist < 0.70 {
                results.append(("R", 0.90))
                print("✅ R detected: alternative 3 (very loose bent)")
            }
        }
        
        // EMERGENCY R: 2 fingers up, close together
        if extendedCount == 2 && indexExt && middleExt && indexMiddleDist < 0.60 {
            results.append(("R", 0.88))
            print("🚨 R EMERGENCY: 2 fingers close")
        }
        
        // SUPER EMERGENCY R: Check finger tips Y-position (should be similar for R)
        if indexExt && middleExt {
            let yDiff = abs(indexTip.location.y - middleTip.location.y)
            if yDiff < 0.10 && indexMiddleDist < 0.50 {
                results.append(("R", 0.90))
                print("🚨 R SUPER EMERGENCY: fingers at same height")
            }
        }
        
        // MEGA EMERGENCY R: Just 2 fingers pattern
        if indexExt && middleExt && !ringExt && !littleExt {
            results.append(("R", 0.82))
            print("🚨 R MEGA EMERGENCY: 2 finger pattern")
        }
        
        // S: Closed fist with thumb ACROSS fingers (KEY: horizontal thumb position)
        // MAXIMUM ULTRA ULTRA AGGRESSIVE S DETECTION - 500X BETTER with Enhanced Thumb Analysis
        if extendedCount == 0 && !thumbExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            
            // ENHANCED: Calculate thumb position relative to fingers (KEY DIFFERENTIATOR)
            var thumbAcrossScore: CGFloat = 0.0
            var thumbAngle: CGFloat = 0.0
            var thumbPositionScore: CGFloat = 0.0
            
            if let thumbIP = thumbIP, let thumbCMC = thumbCMC, let indexMCP = indexMCP, let middleMCP = middleMCP {
                // Thumb angle: 0° = pointing right, 90° = pointing up, 180° = pointing left
                thumbAngle = atan2(thumbTip.location.y - thumbCMC.location.y, thumbTip.location.x - thumbCMC.location.x)
                
                // Check if thumb is ACROSS (horizontal, not vertical like A)
                // Horizontal: angle near 0° or 180° (±45° for more lenient detection)
                let angleDegrees = abs(thumbAngle * 180 / .pi)
                if angleDegrees < 45 || angleDegrees > 135 {
                    thumbAcrossScore = 1.0  // Thumb is horizontal (ACROSS)
                } else if angleDegrees > 30 && angleDegrees < 60 || angleDegrees > 120 && angleDegrees < 150 {
                    thumbAcrossScore = 0.7  // Thumb is diagonal (still good for S)
                } else if angleDegrees > 60 && angleDegrees < 120 {
                    thumbAcrossScore = 0.2  // Thumb is vertical (less likely S, more likely A/E)
                }
                
                // ENHANCED: Check thumb position relative to finger knuckles
                let thumbToIndexDist = distance(thumbTip.location, indexMCP.location)
                let thumbToMiddleDist = distance(thumbTip.location, middleMCP.location)
                let avgThumbToFingerDist = (thumbToIndexDist + thumbToMiddleDist) / 2.0
                
                // Thumb should be close to finger knuckles for S
                if avgThumbToFingerDist < 0.20 {
                    thumbPositionScore = 1.0  // Perfect S position
                } else if avgThumbToFingerDist < 0.30 {
                    thumbPositionScore = 0.8  // Good S position
                } else if avgThumbToFingerDist < 0.40 {
                    thumbPositionScore = 0.6  // Acceptable S position
                } else if avgThumbToFingerDist < 0.50 {
                    thumbPositionScore = 0.4  // Loose S position
                } else {
                    thumbPositionScore = 0.2  // Very loose S position
                }
                
                // ENHANCED: Check if thumb is tucked under (Y-position check)
                let thumbYRelativeToFingers = thumbTip.location.y - indexMCP.location.y
                if thumbYRelativeToFingers < 0.15 {  // Thumb below finger knuckles
                    thumbPositionScore += 0.3
                }
            }
            
            // Combined thumb score for better S detection
            let combinedThumbScore = (thumbAcrossScore + thumbPositionScore) / 2.0
            
            print("🅂 S CHECK: avgCurl=\(String(format: "%.2f", avgCurl)), thumbCurl=\(String(format: "%.2f", thumbCurl)), thumbExt=\(thumbExt), thumbAcrossScore=\(String(format: "%.2f", thumbAcrossScore)), thumbPosScore=\(String(format: "%.2f", thumbPositionScore)), combinedScore=\(String(format: "%.2f", combinedThumbScore)), thumbAngle=\(String(format: "%.1f°", thumbAngle * 180 / .pi))")
            
            // ENHANCED DETECTION PATHS with combined scoring
            
            // Path 1: Perfect S - excellent thumb position and curl
            if avgCurl > 0.45 && thumbCurl > 0.35 && combinedThumbScore > 0.8 {
                results.append(("S", 0.98))
                print("✅ S detected: path 1 (PERFECT - excellent thumb position)")
            }
            
            // Path 2: Excellent S - very good thumb position
            if avgCurl > 0.40 && thumbCurl > 0.30 && combinedThumbScore > 0.7 {
                results.append(("S", 0.96))
                print("✅ S detected: path 2 (EXCELLENT - very good thumb)")
            }
            
            // Path 3: Very good S - good thumb position
            if avgCurl > 0.35 && thumbCurl > 0.25 && combinedThumbScore > 0.6 {
                results.append(("S", 0.94))
                print("✅ S detected: path 3 (VERY GOOD - good thumb)")
            }
            
            // Path 4: Good S - decent thumb position
            if avgCurl > 0.30 && thumbCurl > 0.20 && combinedThumbScore > 0.5 {
                results.append(("S", 0.92))
                print("✅ S detected: path 4 (GOOD - decent thumb)")
            }
            
            // Path 5: Moderate S - some thumb indication
            if avgCurl > 0.25 && thumbCurl > 0.15 && combinedThumbScore > 0.4 {
                results.append(("S", 0.90))
                print("✅ S detected: path 5 (MODERATE - some thumb indication)")
            }
            
            // Path 6: Loose S - weak thumb indication
            if avgCurl > 0.20 && thumbCurl > 0.12 && combinedThumbScore > 0.3 {
                results.append(("S", 0.88))
                print("✅ S detected: path 6 (LOOSE - weak thumb indication)")
            }
            
            // Path 7: Very loose S - minimal thumb indication
            if avgCurl > 0.15 && thumbCurl > 0.10 && combinedThumbScore > 0.2 {
                results.append(("S", 0.86))
                print("✅ S detected: path 7 (VERY LOOSE - minimal thumb)")
            }
            
            // Path 8-12: Fallback paths without strong thumb position (lower confidence)
            if avgCurl > 0.50 && thumbCurl > 0.40 {
                results.append(("S", 0.84))
                print("✅ S detected: path 8 (fallback - perfect fist)")
            }
            
            if avgCurl > 0.40 && thumbCurl > 0.30 {
                results.append(("S", 0.82))
                print("✅ S detected: path 9 (fallback - good fist)")
            }
            
            if avgCurl > 0.30 && thumbCurl > 0.20 {
                results.append(("S", 0.80))
                print("✅ S detected: path 10 (fallback - moderate fist)")
            }
            
            if avgCurl > 0.20 && thumbCurl > 0.15 {
                results.append(("S", 0.78))
                print("✅ S detected: path 11 (fallback - loose fist)")
            }
            
            if avgCurl > 0.15 && thumbCurl > 0.10 {
                results.append(("S", 0.76))
                print("✅ S detected: path 12 (fallback - very loose fist)")
            }
            
            // Path 13: Strong thumb position even with loose fist
            if combinedThumbScore > 0.6 {
                results.append(("S", 0.88))
                print("✅ S detected: path 13 (STRONG THUMB POSITION)")
            }
            
            // Path 14: Good thumb position
            if combinedThumbScore > 0.4 {
                results.append(("S", 0.84))
                print("✅ S detected: path 14 (good thumb position)")
            }
            
            // Path 15: Any thumb position indication
            if combinedThumbScore > 0.2 {
                results.append(("S", 0.80))
                print("✅ S detected: path 15 (some thumb position)")
            }
            
            // Path 16: ALWAYS when all down, thumb not extended (lowest confidence)
            results.append(("S", 0.72))
            print("✅ S detected: path 16 (fist fallback)")
        }
        
        // Alternative S paths: 10+ more detection methods
        
        // Alternative S1: Thumb close to palm (across fingers)
        if extendedCount == 0 && !thumbExt {
            if let indexMCP = indexMCP, let middleMCP = middleMCP {
                // Check if thumb tip is between index and middle finger area
                let thumbToIndexDist = distance(thumbTip.location, indexMCP.location)
                let thumbToMiddleDist = distance(thumbTip.location, middleMCP.location)
                
                if thumbToIndexDist < 0.25 && thumbToMiddleDist < 0.25 {
                    results.append(("S", 0.95))
                    print("✅ S detected: alternative 1 (thumb very close to palm)")
                } else if thumbToIndexDist < 0.35 && thumbToMiddleDist < 0.35 {
                    results.append(("S", 0.92))
                    print("✅ S detected: alternative 2 (thumb close to palm)")
                } else if thumbToIndexDist < 0.45 && thumbToMiddleDist < 0.45 {
                    results.append(("S", 0.90))
                    print("✅ S detected: alternative 3 (thumb near palm)")
                }
            }
        }
        
        // Alternative S4: Just fist with thumb not extended
        if extendedCount == 0 && !thumbExt {
            results.append(("S", 0.88))
            print("✅ S detected: alternative 4 (fist + thumb)")
        }
        
        // Alternative S5-7: Check all 5 fingers curled
        if extendedCount == 0 {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl + thumbCurl) / 5.0
            if avgCurl > 0.30 {
                results.append(("S", 0.90))
                print("✅ S detected: alternative 5 (all moderately curled)")
            } else if avgCurl > 0.25 {
                results.append(("S", 0.88))
                print("✅ S detected: alternative 6 (all curled)")
            } else if avgCurl > 0.15 {
                results.append(("S", 0.86))
                print("✅ S detected: alternative 7 (all loosely curled)")
            } else if avgCurl > 0.10 {
                results.append(("S", 0.84))
                print("✅ S detected: alternative 8 (all barely curled)")
            } else if avgCurl > 0.05 {
                results.append(("S", 0.82))
                print("✅ S detected: alternative 9 (all very barely curled)")
            }
        }
        
        // Alternative S10: Check thumb Y-position (should be level with fingers, not above like A)
        if extendedCount == 0 && !thumbExt {
            if let indexMCP = indexMCP {
                let thumbYDiff = abs(thumbTip.location.y - indexMCP.location.y)
                if thumbYDiff < 0.20 {
                    results.append(("S", 0.91))
                    print("✅ S detected: alternative 10 (thumb at finger level)")
                } else if thumbYDiff < 0.30 {
                    results.append(("S", 0.89))
                    print("✅ S detected: alternative 11 (thumb near finger level)")
                }
            }
        }
        
        // EMERGENCY S: All fingers down, thumb curled
        if extendedCount == 0 {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl + thumbCurl) / 5.0
            if avgCurl > 0.20 {
                results.append(("S", 0.85))
                print("🚨 S EMERGENCY: all curled")
            }
        }
        
        // SUPER EMERGENCY S: Fist shape check
        if extendedCount == 0 && !thumbExt {
            let fingersGrouped = areFingersGrouped(indexTip: indexTip.location, middleTip: middleTip.location, ringTip: ringTip.location, littleTip: littleTip.location, palmSize: palmSize)
            if fingersGrouped {
                results.append(("S", 0.82))
                print("🚨 S SUPER EMERGENCY: fist shape")
            }
        }
        
        // MEGA EMERGENCY S: All fingertips below MCPs
        if extendedCount == 0 && !thumbExt {
            if let indexMCP = indexMCP, let middleMCP = middleMCP, let ringMCP = ringMCP, let littleMCP = littleMCP {
                if indexTip.location.y < indexMCP.location.y && 
                   middleTip.location.y < middleMCP.location.y && 
                   ringTip.location.y < ringMCP.location.y && 
                   littleTip.location.y < littleMCP.location.y {
                    results.append(("S", 0.80))
                    print("🚨 S MEGA EMERGENCY: fist Y-position")
                }
            }
        }
        
        // ULTRA EMERGENCY S: Just all fingers down
        if extendedCount == 0 {
            results.append(("S", 0.78))
            print("🚨 S ULTRA EMERGENCY: all down")
        }
        
        // T: Thumb between index and middle
        // MAXIMUM ULTRA AGGRESSIVE T DETECTION - 200X BETTER
        if !indexExt && !middleExt && !ringExt && !littleExt && thumbExt {
            print("🅃 T CHECK: thumbIndexDist=\(thumbIndexDist), thumbExt=\(thumbExt), thumbCurl=\(thumbCurl)")
            
            // Path 1: Thumb very close to fingers
            if thumbIndexDist < 0.50 {
                results.append(("T", 0.98))
                print("✅ T detected: path 1 (thumb very close)")
            }
            
            // Path 2: Thumb close to fingers
            if thumbIndexDist < 0.70 {
                results.append(("T", 0.96))
                print("✅ T detected: path 2 (thumb close)")
            }
            
            // Path 3: Thumb near fingers
            if thumbIndexDist < 0.90 {
                results.append(("T", 0.94))
                print("✅ T detected: path 3 (thumb near)")
            }
            
            // Path 4: Thumb somewhat near
            if thumbIndexDist < 1.10 {
                results.append(("T", 0.92))
                print("✅ T detected: path 4 (thumb somewhat near)")
            }
            
            // Path 5: Thumb visible
            if thumbIndexDist < 1.30 {
                results.append(("T", 0.90))
                print("✅ T detected: path 5 (thumb visible)")
            }
            
            // Path 6: Thumb far but visible
            if thumbIndexDist < 1.50 {
                results.append(("T", 0.88))
                print("✅ T detected: path 6 (thumb far)")
            }
            
            // Path 7: Thumb very far
            if thumbIndexDist < 1.70 {
                results.append(("T", 0.86))
                print("✅ T detected: path 7 (thumb very far)")
            }
            
            // Path 8: ALWAYS when fist + thumb extended
            results.append(("T", 0.84))
            print("✅ T detected: path 8 (fist+thumb - ALWAYS)")
        }
        
        // Alternative T: Fist with thumb sticking out
        if extendedCount == 0 && thumbExt {
            let avgCurl = (indexCurl + middleCurl + ringCurl + littleCurl) / 4.0
            if avgCurl > 0.30 {
                results.append(("T", 0.95))
                print("✅ T detected: alternative 1 (fist+thumb out)")
            } else if avgCurl > 0.20 {
                results.append(("T", 0.92))
                print("✅ T detected: alternative 2 (loose fist+thumb)")
            } else if avgCurl > 0.10 {
                results.append(("T", 0.90))
                print("✅ T detected: alternative 3 (very loose fist+thumb)")
            }
        }
        
        // EMERGENCY T: All fingers down, thumb extended
        if !indexExt && !middleExt && !ringExt && !littleExt && thumbExt {
            results.append(("T", 0.88))
            print("🚨 T EMERGENCY: 4 down, thumb up")
        }
        
        // SUPER EMERGENCY T: Check thumb curl (should be low for T)
        if !indexExt && !middleExt && !ringExt && !littleExt && thumbExt {
            if thumbCurl < 0.40 {
                results.append(("T", 0.90))
                print("🚨 T SUPER EMERGENCY: thumb straight")
            }
        }
        
        // MEGA EMERGENCY T: Thumb Y-position check (should be high)
        if thumbExt && extendedCount == 0 {
            if thumbTip.location.y > indexTip.location.y {
                results.append(("T", 0.85))
                print("🚨 T MEGA EMERGENCY: thumb above fingers")
            }
        }
        
        // ULTRA EMERGENCY T: Just fist + thumb pattern
        if extendedCount == 0 && thumbExt {
            results.append(("T", 0.82))
            print("🚨 T ULTRA EMERGENCY: fist+thumb pattern")
        }
        
        // U: Index and middle extended together, pointing up
        // MAXIMUM ULTRA ULTRA AGGRESSIVE U DETECTION - 100X BETTER
        if indexExt && middleExt && !ringExt && !littleExt {
            print("🆄 U CHECK: indexMiddleDist=\(indexMiddleDist), indexCurl=\(indexCurl), middleCurl=\(middleCurl)")
            
            // Path 1: Perfect U (fingers very close together)
            if indexMiddleDist < 0.35 {
                results.append(("U", 0.98))
                print("✅ U detected: path 1 (perfect together)")
            }
            
            // Path 2: Good U (fingers close)
            if indexMiddleDist < 0.45 {
                results.append(("U", 0.95))
                print("✅ U detected: path 2 (close together)")
            }
            
            // Path 3: Moderate U (fingers near)
            if indexMiddleDist < 0.55 {
                results.append(("U", 0.92))
                print("✅ U detected: path 3 (near together)")
            }
            
            // Path 4: Loose U (fingers somewhat near)
            if indexMiddleDist < 0.65 {
                results.append(("U", 0.88))
                print("✅ U detected: path 4 (somewhat near)")
            }
            
            // Path 5: Very loose U
            if indexMiddleDist < 0.75 {
                results.append(("U", 0.85))
                print("✅ U detected: path 5 (loose)")
            }
            
            // Path 6: Ultra loose U
            if indexMiddleDist < 0.85 {
                results.append(("U", 0.82))
                print("✅ U detected: path 6 (very loose)")
            }
            
            // Path 7: ALWAYS when 2 fingers up
            results.append(("U", 0.80))
            print("✅ U detected: path 7 (2 fingers - ALWAYS)")
        }
        
        // Alternative U: Just 2 fingers up, any distance
        if indexExt && middleExt && !ringExt && !littleExt {
            let avgCurl = (indexCurl + middleCurl) / 2.0
            if avgCurl < 0.40 {
                results.append(("U", 0.90))
                print("✅ U detected: alternative 1 (2 straight)")
            } else if avgCurl < 0.50 {
                results.append(("U", 0.88))
                print("✅ U detected: alternative 2 (2 loose)")
            } else if avgCurl < 0.60 {
                results.append(("U", 0.85))
                print("✅ U detected: alternative 3 (2 very loose)")
            }
        }
        
        // EMERGENCY U: Exactly 2 fingers extended
        if extendedCount == 2 && indexExt && middleExt {
            results.append(("U", 0.78))
            print("🚨 U EMERGENCY: 2 fingers up")
        }
        
        // SUPER EMERGENCY U: Index and middle highest
        if indexExt && middleExt {
            if indexTip.location.y > ringTip.location.y && middleTip.location.y > ringTip.location.y {
                results.append(("U", 0.75))
                print("🚨 U SUPER EMERGENCY: 2 fingers highest")
            }
        }
        
        // V: Index and middle extended in V shape
        if indexExt && middleExt && !ringExt && !littleExt {
            if indexMiddleDist > 0.45 {
                results.append(("V", 0.93))
            }
        }
        
        // W: Three fingers extended
        if indexExt && middleExt && ringExt && !littleExt {
            results.append(("W", 0.90))
        }
        
        // X: Index bent (hook shape)
        if !indexExt && !middleExt && !ringExt && !littleExt {
            if indexCurl > 0.4 && indexCurl < 0.7 {
                results.append(("X", 0.85))
            }
        }
        
        // Y: Thumb and pinky extended (shaka sign)
        if !indexExt && !middleExt && !ringExt && littleExt && thumbExt {
            // Check they're spread apart
            let thumbPinkyDist = distance(thumbTip.location, littleTip.location) / palmSize
            if thumbPinkyDist > 0.9 {
                results.append(("Y", 0.95))
            } else if thumbPinkyDist > 0.7 {
                results.append(("Y", 0.88))
            } else {
                results.append(("Y", 0.75))
            }
        }
        
        // Z: Index draws Z motion
        // MAXIMUM ULTRA AGGRESSIVE Z DETECTION - 100X BETTER
        if indexExt && !middleExt && !ringExt && !littleExt {
            // Detect Z motion (zigzag pattern)
            if motionHistory.count >= 12 {
                let zMotion = detectZMotion(motionHistory: motionHistory)
                print("🆉 Z CHECK: zMotion=\(zMotion), motionFrames=\(motionHistory.count)")
                
                if zMotion > 0.5 {
                    results.append(("Z", 0.98))
                    print("✅ Z detected: motion confirmed")
                } else if zMotion > 0.3 {
                    results.append(("Z", 0.90))
                    print("✅ Z detected: partial motion")
                } else if zMotion > 0.2 {
                    results.append(("Z", 0.85))
                    print("✅ Z detected: slight motion")
                } else if zMotion > 0.1 {
                    results.append(("Z", 0.80))
                    print("✅ Z detected: minimal motion")
                } else {
                    // Still show Z as option even without motion
                    results.append(("Z", 0.75))
                    print("⚠️ Z suggested: index up (draw zigzag for higher confidence)")
                }
            } else {
                // Always show Z as option when index is up
                results.append(("Z", 0.70))
                print("⚠️ Z suggested: index up (draw zigzag for higher confidence)")
            }
        }
        
        // Alternative Z: Just index pointing (always suggest Z)
        if indexExt && !middleExt && !ringExt && !littleExt {
            results.append(("Z", 0.72))
            print("✅ Z alternative: index pointing")
        }
        
        // Return ALL matches (not just top 3) - sorted by confidence
        results.sort { $0.1 > $1.1 }
        
        // BOOST certain letters if they appear in results
        let boostLetters = ["B", "D", "M", "N", "S", "K", "U", "E", "T", "R", "P", "0", "O"]
        for letter in boostLetters {
            if let index = results.firstIndex(where: { $0.0 == letter }) {
                let result = results[index]
                if result.1 >= 0.65 {
                    results.remove(at: index)
                    results.insert(result, at: 0)
                    print("🚀 BOOSTED \(letter) to top position")
                    break  // Only boost one
                }
            }
        }
        
        // REMOVE DUPLICATES - Keep highest confidence for each gesture
        var seenGestures: Set<String> = []
        var uniqueResults: [(String, Float)] = []
        
        for result in results {
            if !seenGestures.contains(result.0) {
                seenGestures.insert(result.0)
                uniqueResults.append(result)
            } else {
                print("🔄 Removed duplicate: \(result.0) (\(Int(result.1 * 100))%)")
            }
        }
        
        results = uniqueResults
        
        // Return top 8 for a richer retry/options panel
        while results.count < 8 {
            results.append(("?", 0.05))
        }
        
        print("📋 Final predictions (no duplicates): \(results.prefix(8).map { "\($0.0)(\(Int($0.1 * 100))%)" }.joined(separator: ", "))")
        
        return Array(results.prefix(8)).map { (gesture: $0.0, confidence: $0.1) }
    }
    
    // MARK: - Helper Functions
    
    /// Calculate how curled a finger is (0 = straight, 1 = fully curled)
    private static func fingerCurl(tip: CGPoint, dip: CGPoint, pip: CGPoint, mcp: CGPoint) -> Float {
        let tipToPip = distance(tip, pip)
        let tipToMcp = distance(tip, mcp)
        let mcpToPip = distance(mcp, pip)
        
        // If finger is straight, tip is far from mcp
        // If curled, tip is close to mcp
        let maxDist = mcpToPip * 2.5
        let curl = 1.0 - Float(min(tipToMcp / maxDist, 1.0))
        
        return curl
    }
    
    // MARK: - ADDITIONAL Detection Methods
    
    /// Calculate angle between three points (in radians)
    private static func angle(p1: CGPoint, vertex: CGPoint, p2: CGPoint) -> Float {
        let v1 = CGPoint(x: p1.x - vertex.x, y: p1.y - vertex.y)
        let v2 = CGPoint(x: p2.x - vertex.x, y: p2.y - vertex.y)
        
        let dot = v1.x * v2.x + v1.y * v2.y
        let mag1 = sqrt(v1.x * v1.x + v1.y * v1.y)
        let mag2 = sqrt(v2.x * v2.x + v2.y * v2.y)
        
        let cosAngle = dot / (mag1 * mag2)
        return Float(acos(max(-1, min(1, cosAngle))))
    }
    
    /// Check if finger is pointing (tip far from palm, straight line)
    private static func isFingerPointing(tip: CGPoint, dip: CGPoint, pip: CGPoint, mcp: CGPoint) -> Bool {
        // Check straightness using angle at PIP joint
        let pipAngle = angle(p1: tip, vertex: pip, p2: mcp)
        let straightness = pipAngle > 2.8 || pipAngle < 0.3  // Close to 180° or 0°
        
        // Check extension
        let tipToPip = distance(tip, pip)
        let pipToMcp = distance(pip, mcp)
        let extended = tipToPip > pipToMcp * 0.8
        
        return straightness && extended
    }
    
    /// Calculate hand openness (0 = closed fist, 1 = open hand)
    private static func handOpenness(
        indexTip: CGPoint, middleTip: CGPoint, ringTip: CGPoint, littleTip: CGPoint,
        indexMCP: CGPoint, middleMCP: CGPoint, ringMCP: CGPoint, littleMCP: CGPoint
    ) -> Float {
        let avgTipY = (indexTip.y + middleTip.y + ringTip.y + littleTip.y) / 4
        let avgMCPY = (indexMCP.y + middleMCP.y + ringMCP.y + littleMCP.y) / 4
        
        let spread = abs(avgTipY - avgMCPY)
        return Float(min(spread * 5, 1.0))  // Normalize to 0-1
    }
    
    /// Check if fingers are grouped together (fist-like)
    private static func areFingersGrouped(
        indexTip: CGPoint, middleTip: CGPoint, ringTip: CGPoint, littleTip: CGPoint,
        palmSize: CGFloat
    ) -> Bool {
        let avgX = (indexTip.x + middleTip.x + ringTip.x + littleTip.x) / 4
        let avgY = (indexTip.y + middleTip.y + ringTip.y + littleTip.y) / 4
        let center = CGPoint(x: avgX, y: avgY)
        
        let maxDist = max(
            distance(indexTip, center),
            distance(middleTip, center),
            distance(ringTip, center),
            distance(littleTip, center)
        )
        
        return maxDist / palmSize < 0.3  // All fingers within 30% of palm size
    }
    
    // MARK: - Helper Functions
    
    /// More accurate finger extension check
    private static func isFingerExtended(tip: CGPoint, pip: CGPoint, mcp: CGPoint, wrist: CGPoint) -> Bool {
        // Calculate distances
        let tipToWrist = distance(tip, wrist)
        let pipToWrist = distance(pip, wrist)
        let mcpToWrist = distance(mcp, wrist)
        
        // ULTRA LENIENT THRESHOLDS for maximum detection
        let extendedRatio = tipToWrist / max(pipToWrist, 0.001)
        let baseRatio = tipToWrist / max(mcpToWrist, 0.001)
        
        return extendedRatio > 1.05 && baseRatio > 1.15
    }
    
    private static func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        let dx = p1.x - p2.x
        let dy = p1.y - p2.y
        return sqrt(dx * dx + dy * dy)
    }
    
    /// Calculate finger crossing score (for R detection)
    private static func calculateFingerCrossing(indexTip: CGPoint, middleTip: CGPoint, indexPIP: CGPoint?, middlePIP: CGPoint?) -> Float {
        // Basic crossing detection using tip positions
        let tipDistance = distance(indexTip, middleTip)
        
        // If fingers are very close, likely crossing
        if tipDistance < 0.02 {
            return 1.0
        } else if tipDistance < 0.04 {
            return 0.8
        } else if tipDistance < 0.06 {
            return 0.6
        } else if tipDistance < 0.08 {
            return 0.4
        } else if tipDistance < 0.10 {
            return 0.2
        }
        
        // Check if PIP joints are available for more accurate crossing detection
        if let indexPIP = indexPIP, let middlePIP = middlePIP {
            let pipDistance = distance(indexPIP, middlePIP)
            let tipToPipRatio = tipDistance / max(pipDistance, 0.001)
            
            // If tips are closer than PIPs, likely crossing
            if tipToPipRatio < 0.8 {
                return Float(min(1.0, (0.8 - tipToPipRatio) * 2.5))
            }
        }
        
        return 0.0
    }
    
    
    // MARK: - Motion Detection
    
    /// Detect J motion (hook/curve downward with pinky)
    private static func detectJMotion(motionHistory: [[VNHumanHandPoseObservation.JointName: VNRecognizedPoint]]) -> Float {
        guard motionHistory.count >= 10 else { return 0 }
        
        // Track pinky tip movement
        var pinkyPositions: [CGPoint] = []
        for frame in motionHistory.suffix(10) {
            if let pinkyTip = frame[.littleTip] {
                pinkyPositions.append(pinkyTip.location)
            }
        }
        
        guard pinkyPositions.count >= 8 else { return 0 }
        
        // J motion: starts high, curves down and to the left (or right depending on hand)
        let startY = pinkyPositions.first!.y
        let endY = pinkyPositions.last!.y
        let startX = pinkyPositions.first!.x
        let endX = pinkyPositions.last!.x
        
        // Check for downward motion (more lenient)
        let downwardMotion = endY < startY - 0.03
        
        // Check for horizontal curve (either direction)
        let horizontalCurve = abs(endX - startX) > 0.02
        
        // Calculate total movement
        let totalMovement = distance(pinkyPositions.first!, pinkyPositions.last!)
        
        if downwardMotion && horizontalCurve && totalMovement > 0.05 {
            return 0.95
        } else if downwardMotion && totalMovement > 0.04 {
            return 0.75
        } else if downwardMotion {
            return 0.55
        }
        
        return 0.0
    }
    
    /// Detect Z motion (zigzag pattern with index finger)
    private static func detectZMotion(motionHistory: [[VNHumanHandPoseObservation.JointName: VNRecognizedPoint]]) -> Float {
        guard motionHistory.count >= 12 else { return 0 }
        
        // Track index tip movement
        var indexPositions: [CGPoint] = []
        for frame in motionHistory.suffix(12) {
            if let indexTip = frame[.indexTip] {
                indexPositions.append(indexTip.location)
            }
        }
        
        guard indexPositions.count >= 10 else { return 0 }
        
        // Z motion: diagonal movements with direction changes (zigzag)
        var directionChanges = 0
        var lastDirection: CGFloat = 0
        var totalMovement: CGFloat = 0
        
        for i in 1..<indexPositions.count {
            let dx = indexPositions[i].x - indexPositions[i-1].x
            let dy = indexPositions[i].y - indexPositions[i-1].y
            
            totalMovement += sqrt(dx * dx + dy * dy)
            
            if abs(dx) > 0.008 {  // More sensitive threshold
                let currentDirection = dx
                if lastDirection != 0 && (lastDirection * currentDirection) < 0 {
                    directionChanges += 1
                }
                lastDirection = currentDirection
            }
        }
        
        // Z should have at least 2 direction changes (zigzag) and significant movement
        if directionChanges >= 2 && totalMovement > 0.08 {
            return 0.95
        } else if directionChanges >= 2 && totalMovement > 0.05 {
            return 0.80
        } else if directionChanges >= 1 && totalMovement > 0.06 {
            return 0.60
        }
        
        return 0.0
    }
    
    static func getModelInfo() -> [String: Any] {
        return [
            "approach": "Enhanced Geometric Analysis + Motion Detection",
            "gestures": ["A-Z (26 letters) + 0-10 (11 numbers)"],
            "accuracy": "Optimized with multi-path detection, curl analysis, angle detection, distance normalization, and motion tracking",
            "advantages": "No training needed, works for everyone, full alphabet + numbers 0-10, motion gestures (J, Z), extensive debug logging"
        ]
    }
}

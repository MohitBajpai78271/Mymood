import SwiftUI
import CoreML
import Vision
import UIKit

class EmotionAnalysisViewModel: ObservableObject {
    @Published var detectedEmotion: String = "🤔" // Default emoji
    @Published var emotionImage: UIImage?

    private var model: VNCoreMLModel?
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                let coreMLModel = try CNNEmotions(configuration: MLModelConfiguration()).model
//                self.model = try VNCoreMLModel(for: coreMLModel)
//            } catch {
//                print("Error loading CoreML model: \(error)")
//            }
//        }
    }
    // Function to analyze emotion and return corresponding emoji
//    func analyzeEmotion(from image: UIImage, completion: @escaping (String) -> Void) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            guard let ciImage = CIImage(image: image) else {
//                print("Failed to convert UIImage to CIImage")
//                return
//            }
//            
//            guard let loadedModel = self.model else {
//                print("CoreML model not loaded yet.")
//                return
//            }
//            
//            let request = VNCoreMLRequest(model: loadedModel) { request, error in
//                guard let results = request.results as? [VNClassificationObservation] else {
//                    print("Failed to classify image")
//                    return
//                }
//                
//                if let topResult = results.first {
//                    print("Detected Emotion: \(topResult.identifier) with confidence: \(topResult.confidence)")
//                    let emoji = self.getEmoji(for: topResult.identifier)
//                    DispatchQueue.main.async {
//                        self.detectedEmotion = emoji
//                        completion(emoji)
//                    }
//                } else {
//                    print("No emotion detected")
//                }
//            }
//            
//            // Use the image's orientation to help the model process it correctly
//            let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) ?? .up
//            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation, options: [:])
//
//            do {
//                try handler.perform([request])
//            } catch {
//                print("Failed to perform image request: \(error)")
//            }
//        }
//    }

    // Function to map detected emotion to emoji
    func getEmoji(for emotion: String) -> String {
        print("Mapping emotion: \(emotion)") // Debugging print
        switch emotion{
        case "Happy":
            return "😊" // Happy emoji
        case "Disgust":
            return "🤢" // Disgust emoji
        case "Fear":
            return "😨" // Fear emoji
        case "Neutral":
            return "😐" // Neutral emoji
        case "Sad":
            return "😢" // Sad emoji
        case "Surprise":
            return "😲" // Surprise emoji
        default:
            return "🤔" // Default thinking emoji for unknown emotions
        }
    }
}
//import CoreML
//
//class EmotionClassifier {
//    private let model: CNNEmotions
//
//    init?() {
//        guard let loadedModel = try? CNNEmotions(configuration: .init()) else { return nil }
//        self.model = loadedModel
//    }
//
//    func predictEmotion(from pixelBuffer: CVPixelBuffer) -> String? {
//        do {
//            let output = try model.prediction(data: pixelBuffer)
//            return output.classLabel  // This returns the predicted emotion
//        } catch {
//            print("Error making prediction: \(error)")
//            return nil
//        }
//    }
//}
//import UIKit
//import VideoToolbox
//
//extension UIImage {
//    func toCVPixelBuffer() -> CVPixelBuffer? {
//        let width = Int(self.size.width)
//        let height = Int(self.size.height)
//        let attributes = [
//            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
//            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
//        ] as CFDictionary
//
//        var pixelBuffer: CVPixelBuffer?
//        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attributes, &pixelBuffer)
//        guard let buffer = pixelBuffer else { return nil }
//
//        CVPixelBufferLockBaseAddress(buffer, .readOnly)
//        let context = CGContext(
//            data: CVPixelBufferGetBaseAddress(buffer),
//            width: width,
//            height: height,
//            bitsPerComponent: 8,
//            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
//            space: CGColorSpaceCreateDeviceRGB(),
//            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
//        )
//
//        guard let cgImage = self.cgImage else { return nil }
//        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
//        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
//
//        return buffer
//    }
//}


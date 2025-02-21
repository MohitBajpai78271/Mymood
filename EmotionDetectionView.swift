import SwiftUI
import Speech
import AVFoundation
import CoreML
import UIKit
import Vision

struct EmotionDetectionView: View {
    @State private var selectedTab = "Text"
    @State private var textInput = ""
    @State private var detectedEmotion = "🤔"
    @State private var recording = false
    @State private var voiceInput = ""
    @State private var isCameraActive = false
    @State private var capturedImage: UIImage?
    @State private var isImageCaptured = false
    @State private var isLoading = false
    @State private var isCameraPresented: Bool = false
//    @StateObject private var viewModel = EmotionAnalysisViewModel()
    @State private var navigateToHelpMe = false
    @State private var predictedEmotion: String = "No emotion detected"
    @EnvironmentObject var vm: MoodDataStore

    private let openAIService = OpenAIService()
    var onEmotionChanged: ((String) -> Void)?
    
    var body: some View {
        NavigationStack{
        VStack {
            Text("Emotion Detection")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Picker("Detection Mode", selection: $selectedTab) {
                Text("Text").tag("Text")
                Text("Face").tag("Face")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            VStack(spacing: 20) {
                if selectedTab == "Text" {
                    textInputSection
                } else if selectedTab == "Face" {
                    faceInputSection
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
            .shadow(radius: 5)
            .padding()
            Spacer()
            HStack(spacing: 16) {
                Button {
                    // Make sure detectedEmotion has been updated
                    if detectedEmotion != "🤔" {
                        navigateToHelpMe = true
                    }
                } label: {
                    Text("Help Me")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(
                    destination: YogaView(
                        emotion: detectedEmotion,
                        description: "I feel \(detectedEmotion). Show me the best yoga to uplift my mood."
                    )
                ) {
                    Text("Best Yoga")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            .padding(.horizontal)
            .disabled(detectedEmotion == "🤔")
        }
        .navigationDestination(isPresented: $navigateToHelpMe) {
                       ConversationalAIView(
                           emotion: detectedEmotion,
                           description: "I feel \(detectedEmotion). How can I feel better?"
                       )
                   }
        .onAppear{
            requestCameraPermission()
        }
        .onChange(of: detectedEmotion) { newEmotion in
            //            let moodValue = moodValue(for: newEmotion)
            //                       let newEntry = MoodEntry(
            //                           emoji: detectedEmotion,
            //                           moodValue: moodValue,
            //                           date: Date(),
            //                           notes: ""
            //                       )
            //                       vm.addMood(newEntry)
        }
    }
             
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - Text Input Section
    var textInputSection: some View {
        VStack(spacing: 15) {
            Text("Enter your thoughts:")
                .font(.headline)
            TextField("Type here...", text: $textInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: detectEmotionFromText) {
                Text("Analyze Emotion")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            if isLoading {
                      ProgressView()
                          .padding()
                  } else {
                      // Display the detected emoji
                      Text("Detected Emotion: \(detectedEmotion)")
                          .font(.title)
                          .bold()
                          .foregroundColor(.primary)
                          .padding(.top, 10)
            }
        }
//        .padding()
    }
    // MARK: - Face Input Section
    var faceInputSection: some View {
        VStack(spacing: 15) {
                 Text("Analyze your facial emotion:")
                     .font(.headline)

                 // Display the captured image or a placeholder
            if let capturedImage = capturedImage {
                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFill()
                            .cornerRadius(20)
                            .frame(height: 300)
                            .clipped()
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    } else {
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .cornerRadius(20)
                            .frame(height: 300)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("No Image Captured")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    // Capture or Re-capture Image Button
                    Button(action: {
                        if capturedImage != nil {

                            capturedImage = nil
                            isCameraPresented = true
                        } else {
                            isCameraPresented = true
                        }
                    }) {
                        Text(capturedImage == nil ? "Capture Emotion" : "Re-capture Emotion")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $isCameraPresented, onDismiss: {
                        if let image = capturedImage {
                            isLoading = true
//                             Analyze the image immediately after it's captured
//                            viewModel.analyzeEmotion(from: image) { detectedEmotion in
//                                DispatchQueue.main.async {
//                                    self.isLoading = false
//                                    self.detectedEmotion = detectedEmotion
//                                    print("Updated Detected Emotion: \(detectedEmotion)")  // Debug print
//                                }
//                            }
                        }
                    }){
                        CameraCaptureView(capturedImage: $capturedImage)
                    }
                    .padding(.horizontal)

                    // Show detected emotion or ProgressView
                    if isLoading {
                        ProgressView("Analyzing...")
                            .padding()
                    } else {
                        Text("Detected Emotion: \(detectedEmotion)") // This should now show emoji
                            .font(.title)
                            .bold()
                            .foregroundColor(.primary)
                            .padding(.top, 10)
                    }
             }
    }
    
    func moodValue(for emotion: String) {
        let content = "Please return a single Integer value between 0 and 4 to represent the emotion expressed as: \(emotion) for 😭 have value 0,😔 have value 1,😐 have value 2,🙂 have value 3,😄 have value 4."
        openAIService.fetchInput(for: content,token: 10) { value in
             DispatchQueue.main.async {
                 
             }
         }
    }
//    func detectEmotion() {
//        guard let image = capturedImage, let pixelBuffer = image.toCVPixelBuffer(),
//              let emotion = classifier?.predictEmotion(from: pixelBuffer) else {
//            predictedEmotion = "Error detecting emotion"
//            return
//        }
//        predictedEmotion = "Emotion: \(emotion)"
//    }


//       Function to handle emotion analysis
      private func startEmotionAnalysis(from image: UIImage) {
          // Set loading state to true while analyzing the emotion
//          isLoading = true
//          print("Captured Image: \(image)") // Debug: Print the captured image to ensure it's not nil
//
//          // Trigger emotion analysis via ViewModel
//          viewModel.analyzeEmotion(from: image) { emotion in
//              DispatchQueue.main.async {
//                  // Check if we received a valid emotion response
//                  if !emotion.isEmpty {
//                      print("Detected Emotion: \(emotion)") // Debug: Print the detected emotion
//                      self.detectedEmotion = emotion
//                  } else {
//                      print("No emotion detected, returning default.")
//                      self.detectedEmotion = "No Emotion Detected"
//                  }
//
//                  // Hide loading and update UI
//                  isLoading = false
//              }
//          }
      }

    func cropFace(from image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let faceDetectionRequest = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) ?? .up, options: [:])
        do {
            try handler.perform([faceDetectionRequest])
            if let results = faceDetectionRequest.results,
               let faceObservation = results.first {
                // Convert normalized coordinates to image coordinates
                let boundingBox = faceObservation.boundingBox
                let imageSize = ciImage.extent.size
                let x = boundingBox.origin.x * imageSize.width
                let y = (1 - boundingBox.origin.y - boundingBox.size.height) * imageSize.height
                let width = boundingBox.size.width * imageSize.width
                let height = boundingBox.size.height * imageSize.height
                let cropRect = CGRect(x: x, y: y, width: width, height: height)
                
                if let cgImage = image.cgImage, let croppedCGImage = cgImage.cropping(to: cropRect) {
                    return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
                }
            }
        } catch {
            print("Failed to perform face detection: \(error)")
        }
        return nil
    }

    
    func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    isCameraActive = granted
                    if !granted {
                        showPermissionDeniedAlert()
                    }
                }
            }
        } else if status == .denied || status == .restricted {
            showPermissionDeniedAlert()
        }
    }

    private func showPermissionDeniedAlert() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
        let alert = UIAlertController(
            title: "Camera Access Denied",
            message: "Please enable camera access in Settings to use this feature.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        })
        rootViewController.present(alert, animated: true)
    }
    
    

    // MARK: - Actions
    func detectEmotionFromText() {
         isLoading = true // Show loading indicator
        let content = "Please return a single emoji to represent the emotion expressed in the following text: \(textInput)"
        openAIService.fetchInput(for: content,token: 10) { emojiResponse in
             DispatchQueue.main.async {
                 if let emoji = emojiResponse {
                     self.detectedEmotion = emoji
                     UserDefaults.standard.set(emoji, forKey: "detectedEmotion")
                 } else {
                     print("No response")
                     self.detectedEmotion = "🤔" // Fallback emoji if no response
                 }
                 self.isLoading = false // Hide loading indicator
             }
         }
     }
}

struct EmotionDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EmotionDetectionView()
        }
    }
}
//struct YogaView: View {
//    let emotion: String
//    let description: String
//    
//    var body: some View {
//        VStack {
//            Text("Yoga for \(emotion)")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .padding()
//            
//            Spacer()
//        }
//        .navigationBarTitle("Best Yoga", displayMode: .inline)
//    }
//}

struct YogaPoseView: View {
    let poseName: String
    let steps: [String]
    let imageName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(poseName)
                .font(.headline)
                .padding(.bottom, 5)
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .cornerRadius(10)
            ForEach(steps, id: \.self) { step in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text(step)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

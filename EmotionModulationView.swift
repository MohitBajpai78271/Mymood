import SwiftUI
import AVFoundation
import Vision

struct EmotionModulationView: View {
    @State private var isSessionActive = false
    @State private var heartRate = 72
    @State private var breathingText = "Breathe In"
    @State private var breathingScale: CGFloat = 1.0
    @State private var cameraLayer = AVCaptureVideoPreviewLayer()
    @State private var sessionSummary = "Session not started."
    @State private var showSessionSummary = false
    @State private var isProcessingFrame = false
    
    let breathingCycleDuration: TimeInterval = 4.0 // Seconds
    
    var body: some View {
        ZStack {
            // Live Camera Preview
            CameraPreview(cameraLayer: $cameraLayer)
                .edgesIgnoringSafeArea(.all)
                .overlay(Color.black.opacity(0.4)) // Dim background for better readability
            
            VStack(spacing: 30) {
                // Title
                Text("Emotion Modulation")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                
                if isSessionActive {
                    // Real-Time Feedback
                    VStack(spacing: 20) {
                        Text("Heart Rate: \(heartRate) bpm")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                        
                        // Breathing Animation
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            .frame(width: 150, height: 150)
                            .scaleEffect(breathingScale)
                            .animation(.easeInOut(duration: breathingCycleDuration).repeatForever(), value: breathingScale)
                            .onAppear {
                                startBreathingAnimation()
                            }
                        
                        Text(breathingText)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                    }
                }
                
                Spacer()
                
                // Start/End Session Button
                Button(action: {
                    isSessionActive.toggle()
                    if isSessionActive {
                        startSession()
                    } else {
                        endSession()
                    }
                }) {
                    Text(isSessionActive ? "End Session" : "Begin Emotion Modulation")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: isSessionActive ? [Color.red, Color.orange] : [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(radius: 10)
                }
                .padding(.horizontal)
                
                // Session Summary
                if showSessionSummary {
                    VStack(spacing: 12) {
                        Text("Session Summary")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(sessionSummary)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            setupCamera()
        }
    }
    
    // MARK: - Methods
    func setupCamera() {
        let session = AVCaptureSession()
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        session.addInput(input)
        cameraLayer.session = session
        cameraLayer.videoGravity = .resizeAspectFill
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(CameraFrameHandler(onFrameProcessed: processFrame), queue: DispatchQueue(label: "videoFrameProcessingQueue"))
        session.addOutput(output)
        
        DispatchQueue.global(qos: .background).async {
            session.startRunning()
        }
    }
    
    func processFrame(buffer: CVPixelBuffer) {
        guard !isProcessingFrame else { return }
        isProcessingFrame = true
        
        // Use Vision or custom algorithms to analyze the frame for physiological data.
        analyzeFrame(buffer: buffer) { estimatedHeartRate in
            DispatchQueue.main.async {
                heartRate = estimatedHeartRate
                isProcessingFrame = false
            }
        }
    }
    
    func analyzeFrame(buffer: CVPixelBuffer, completion: @escaping (Int) -> Void) {
        // Placeholder for heart rate and breathing analysis.
        // Implement custom algorithms or use Vision APIs to analyze skin tone changes, etc.
        // Example: Use Vision's VNDetectFaceRectanglesRequest and process skin region.
        
        completion(Int.random(in: 60...90)) // Simulated heart rate for now.
    }
    
    func startSession() {
        breathingScale = 1.0
        heartRate = Int.random(in: 65...75)
        sessionSummary = "Session not started."
        showSessionSummary = false
    }
    
    func endSession() {
        breathingScale = 1.0
        sessionSummary = "Your heart rate was \(heartRate) bpm. Great job relaxing!"
        showSessionSummary = true
    }
    
    func startBreathingAnimation() {
        Timer.scheduledTimer(withTimeInterval: breathingCycleDuration, repeats: true) { timer in
            if isSessionActive {
                breathingScale = breathingScale == 1.0 ? 1.3 : 1.0
                breathingText = breathingScale == 1.3 ? "Breathe Out" : "Breathe In"
            } else {
                timer.invalidate()
            }
        }
    }
}

// Camera Frame Handler
class CameraFrameHandler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var onFrameProcessed: (CVPixelBuffer) -> Void
    
    init(onFrameProcessed: @escaping (CVPixelBuffer) -> Void) {
        self.onFrameProcessed = onFrameProcessed
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        onFrameProcessed(buffer)
    }
}

// Camera Preview View
struct CameraPreview: UIViewControllerRepresentable {
    @Binding var cameraLayer: AVCaptureVideoPreviewLayer
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.layer.addSublayer(cameraLayer)
        DispatchQueue.main.async {
            cameraLayer.frame = controller.view.bounds
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

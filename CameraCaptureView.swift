import SwiftUI
import AVFoundation

struct CameraCaptureView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    
    func makeUIViewController(context: Context) -> CameraCaptureViewController {
        let controller = CameraCaptureViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraCaptureViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CameraCaptureViewControllerDelegate {
        let parent: CameraCaptureView

        init(_ parent: CameraCaptureView) {
            self.parent = parent
        }

        func didCaptureImage(_ image: UIImage) {
            parent.capturedImage = image
        }
    }
}

protocol CameraCaptureViewControllerDelegate: AnyObject {
    func didCaptureImage(_ image: UIImage)
}

class CameraCaptureViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    weak var delegate: CameraCaptureViewControllerDelegate?

    private let captureSession = AVCaptureSession()
    private var capturePhotoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }

    private func setupCamera() {
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: frontCamera) else {
            print("Error setting up front camera.")
            return
        }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        if captureSession.canAddOutput(capturePhotoOutput) {
            captureSession.addOutput(capturePhotoOutput)
        }

        captureSession.commitConfiguration()

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }

    private func setupUI() {
        // Create a stylish circular capture button
        let captureButton = UIButton(type: .custom)
        captureButton.layer.cornerRadius = 37.5 // Half of 75 points for a circular shape
        captureButton.layer.masksToBounds = false
        captureButton.backgroundColor = UIColor.clear

        // Add a circular gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemPink.cgColor, UIColor.systemPurple.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 75, height: 75) // Adjusted for intermediate size
        gradientLayer.cornerRadius = 37.5

        // Add inner shadow effect
        captureButton.layer.shadowColor = UIColor.black.cgColor
        captureButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        captureButton.layer.shadowOpacity = 0.2
        captureButton.layer.shadowRadius = 10

        // Insert gradient layer and shadow
        captureButton.layer.insertSublayer(gradientLayer, at: 0)

        // Add a subtle border
        captureButton.layer.borderWidth = 3
        captureButton.layer.borderColor = UIColor.white.cgColor

        // Add action for capturing photo
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)

        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)

        // Position the button with AutoLayout
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            captureButton.widthAnchor.constraint(equalToConstant: 75), // Adjusted for intermediate size
            captureButton.heightAnchor.constraint(equalToConstant: 75) // Adjusted for intermediate size
        ])
    }




    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        capturePhotoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Error creating image from photo data.")
            return
        }

        // Pass captured image to delegate
        delegate?.didCaptureImage(image)

        // Close the camera view after capturing the photo
        dismiss(animated: true, completion: nil)
    }
}

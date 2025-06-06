import SwiftUI
import AVFoundation
import PhotosUI
import CoreMedia


// MARK: – CameraView

/// A SwiftUI view that presents a live camera preview.
/// On capture, it navigates to a confirmation screen (`CaptureConfirmationView`)
/// where the user can retake or confirm saving the photo.
struct CameraView: View {
    // MARK: – State Properties

    /// Triggers a photo capture when set to true.
    @State private var capturePhoto = false

    /// Holds the most recently captured UIImage, before confirmation.
    @State private var pendingImage: UIImage? = nil

    /// Controls whether to show the photo library picker.
    @State private var showPhotoLibrary = false

    /// Toggles between front and back camera.
    @State private var useFrontCamera = false

    /// Controls whether to display the capture confirmation screen.
    @State private var showConfirmation = false

    var body: some View {
        ZStack {
            // 1) Show live camera preview when there's no pending image
                        if pendingImage == nil {
                            // ┌──── Live preview + controls ─────────────────────────────┐
                            CameraPreview(
                                capturePhoto: $capturePhoto,
                                pendingImage: $pendingImage,
                                useFrontCamera: $useFrontCamera
                            )
                            .edgesIgnoringSafeArea(.all)
                            .background(Color.black)

                            VStack {
                                Spacer()
                                ZStack {
                                    Rectangle()
                                        .fill(Color.black.opacity(0.5))
                                        .edgesIgnoringSafeArea(.bottom)
                                        .frame(height: 100)

                                    HStack {
                                        // Photo library button
                                        Button(action: {
                                            showPhotoLibrary = true
                                        }) {
                                            Image(systemName: "photo.on.rectangle")
                                                .resizable()
                                                .frame(width: 40, height: 30)
                                                .foregroundColor(.white)
                                                .padding()
                                        }

                                        Spacer()

                                        // Capture button
                                        Button(action: {
                                            capturePhoto = true
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .strokeBorder(Color.white, lineWidth: 4)
                                                    .frame(width: 80, height: 80)
                                                Circle()
                                                    .fill(Color.white.opacity(0.2))
                                                    .frame(width: 60, height: 60)
                                            }
                                        }

                                        Spacer()

                                        // Flip camera button
                                        Button(action: {
                                            useFrontCamera.toggle()
                                        }) {
                                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.white)
                                                .padding()
                                        }
                                    }
                                    .padding(.horizontal, 30)
                                }
                            }
                            // └───────────────────────────────────────────────────────────┘
                        }
                        else {
                            // This branch shows only once pendingImage is non-nil,
                            // but we’ll immediately present the confirmation view via fullScreenCover
                            Color.black.edgesIgnoringSafeArea(.all)
                        }
                    }
                    // ────────────────────────────────────────────────────────────────
                    // These modifiers are now applied *outside* the `if/else`:
                    .onChange(of: pendingImage) { newImage in
                        // This will run whenever pendingImage changes—whether nil→non-nil or non-nil→nil
                        if newImage != nil {
                            showConfirmation = true
                        }
                        print("🔄 CameraView.onChange: pendingImage is now \(String(describing: newImage))")
                    }
                    .sheet(isPresented: $showPhotoLibrary) {
                        PhotoLibraryPicker(selectedImage: $pendingImage)
                            .edgesIgnoringSafeArea(.all)
                        
                    }
                    .fullScreenCover(isPresented: $showConfirmation) {
                        Group {
                            if let image = pendingImage {
                                CaptureConfirmationView(
                                    image: image.withoutApplyingOrientation(),
                                    onRetake: {
                                        pendingImage = nil
                                        showConfirmation = false
                                    },
                                    onConfirm: { confirmedImage in
                                        UIImageWriteToSavedPhotosAlbum(confirmedImage, nil, nil, nil)
                                        pendingImage = nil
                                        showConfirmation = false
                                    }
                                )
                                .edgesIgnoringSafeArea(.all)
                            } else {
                                EmptyView()
                            }
                        }
                    }
                }
            }



// MARK: – CameraPreview (UIViewRepresentable)

/// Bridges a UIKit UIView (`PreviewView`) into SwiftUI.
/// Binds `capturePhoto` and `useFrontCamera` and outputs the captured image into `pendingImage`.
struct CameraPreview: UIViewRepresentable {
    @Binding var capturePhoto: Bool
    @Binding var pendingImage: UIImage?
    @Binding var useFrontCamera: Bool

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView(frame: .zero)
        view.setBindings(
            capturePhoto: $capturePhoto,
            pendingImage: $pendingImage,
            useFrontCamera: $useFrontCamera
        )
        return view
    }
    func updateUIView(_ uiView: PreviewView, context: Context) {
        // Trigger capture if needed
        if capturePhoto {
            uiView.capturePhoto()
            DispatchQueue.main.async {
                capturePhoto = false
            }
        }
        // Switch camera when toggled
        uiView.switchCamera(toFront: useFrontCamera)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {}
}

// MARK: – PreviewView (UIKit UIView)

/// A UIView that manages an AVCaptureSession, preview layer, and photo capture.
/// Delivers the captured UIImage to SwiftUI via `pendingImageBinding`.
final class PreviewView: UIView, AVCapturePhotoCaptureDelegate {
    // MARK: – Properties

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let photoOutput = AVCapturePhotoOutput()
    private var currentInput: AVCaptureDeviceInput?

    // Bindings from SwiftUI
    private var capturePhotoBinding: Binding<Bool>?
    private var pendingImageBinding: Binding<UIImage?>?
    private var useFrontCameraBinding: Binding<Bool>?

    // Tracks current camera position
    private var isUsingFrontCamera = false

    // MARK: – Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        checkCameraAuthorization()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Attach SwiftUI bindings for capture, output image, and camera flip


    // MARK: – Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
        previewLayer?.connection?.videoOrientation = currentVideoOrientation()
    }

    // MARK: – Authorization & Session Setup

    /// Check camera permission and configure session if allowed
    private func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureCaptureSession(position: isUsingFrontCamera ? .front : .back)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.configureCaptureSession(position: self.isUsingFrontCamera ? .front : .back)
                    }
                } else {
                    print("Camera access denied by user.")
                }
            }

        case .denied, .restricted:
            print("Camera access denied or restricted.")

        @unknown default:
            print("Unknown camera authorization status.")
        }
    }

    /// Configure the AVCaptureSession: choose camera, add input/output, and show preview
    private func configureCaptureSession(position: AVCaptureDevice.Position) {
        // 1) Find camera device based on position
        guard let cameraDevice = findCameraDevice(position: position) else {
            print("Unable to find camera for position \(position).")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: cameraDevice)
            // Remove existing input if any
            if let current = currentInput {
                captureSession.removeInput(current)
            }
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                currentInput = input
            } else {
                print("Cannot add camera input to session.")
                return
            }
        } catch {
            print("Error creating camera input: \(error.localizedDescription)")
            return
        }

        // 2) Add photo output once

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
           
        }

        // 3) Set up preview layer once
        if previewLayer == nil {
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.connection?.videoOrientation = currentVideoOrientation()
            previewLayer.frame = bounds
            layer.insertSublayer(previewLayer, at: 0)
            self.previewLayer = previewLayer
        }

        // 4) Start session on background queue
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }

    /// Finds an AVCaptureDevice for the given position.
    private func findCameraDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        // On iPhone, try dual camera first for back
        if position == .back,
           let dual = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return dual
        }
        // Otherwise use wide-angle
        let type: AVCaptureDevice.DeviceType = .builtInWideAngleCamera
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [type],
            mediaType: .video,
            position: position
        )
        return discovery.devices.first
    }

    /// Returns the correct video orientation based on UIDevice orientation
    private func currentVideoOrientation() -> AVCaptureVideoOrientation {
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .portrait:            return .portrait
        case .portraitUpsideDown:  return .portraitUpsideDown
        case .landscapeLeft:       return .landscapeRight
        case .landscapeRight:      return .landscapeLeft
        default:                   return .portrait
        }
    }

    // MARK: – Photo Capture

    /// Trigger a still image capture
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()

        // 1️⃣ Decide on your maximum width/height in pixels.
        //     For example, if you want to cap at 4K, you could do 3840×2160.
        //     Here, we'll cap at 1920×1080 (Full HD). Adjust as needed.
        let maxWidth: Int32 = 1920
        let maxHeight: Int32 = 1080

        // 2️⃣ Construct a CMVideoDimensions struct and assign it:
        let maxDimensions = CMVideoDimensions(width: maxWidth, height: maxHeight)
        settings.maxPhotoDimensions = maxDimensions

        // 3️⃣ You can also choose a quality prioritization if desired:
        //    settings.photoQualityPrioritization = .quality  // or .speed, .balanced

        // 4️⃣ Finally, trigger the capture:
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: – Switch Camera

    /// Switch between front and back camera
    func switchCamera(toFront: Bool) {
        // Avoid redundant switch
        guard toFront != isUsingFrontCamera else { return }
        isUsingFrontCamera = toFront
        // Reconfigure session with new position
        captureSession.beginConfiguration()
        configureCaptureSession(position: toFront ? .front : .back)
        captureSession.commitConfiguration()
    }

    // MARK: – AVCapturePhotoCaptureDelegate

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error = error {
            print("❌ Photo capture error: \(error.localizedDescription)")
            return
        }
        guard let data = photo.fileDataRepresentation() else {
            print("❌ Photo buffer returned no data")
            return
        }
        print("✅ photoOutput didFinishProcessingPhoto: got data of length \(data.count)")

        // Create a UIImage from the data
        guard let rawImage = UIImage(data: data) else {
            print("❌ UIImage(data:) failed")
            return
        }
        print("✅ Created raw UIImage (size: \(rawImage.size), orientation: \(rawImage.imageOrientation))")

        // 1️⃣ Normalize orientation
        let fixedImage = rawImage
        print("✅ Fixed orientation; now imageOrientation = \(fixedImage.imageOrientation), size = \(fixedImage.size)")

        // 2️⃣ Pass it back to SwiftUI
        DispatchQueue.main.async {
            self.pendingImageBinding?.wrappedValue = fixedImage
            print("✅ pendingImageBinding set in PreviewView. It is now: \(String(describing: self.pendingImageBinding?.wrappedValue))")
        }
    }


    // MARK: – Binding Setup

    /// Attach SwiftUI bindings for capture, output image, and camera flip
    func setBindings(
        capturePhoto: Binding<Bool>,
        pendingImage: Binding<UIImage?>,
        useFrontCamera: Binding<Bool>
    ) {
        self.capturePhotoBinding = capturePhoto
        self.pendingImageBinding = pendingImage
        self.useFrontCameraBinding = useFrontCamera
        self.isUsingFrontCamera = useFrontCamera.wrappedValue
    }
}

// MARK: – PhotoLibraryPicker

/// A SwiftUI wrapper around PHPickerViewController to pick an image from the library.
struct PhotoLibraryPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images          // Only images
        config.selectionLimit = 1        // Single selection

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No update needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: PhotoLibraryPicker

        init(_ parent: PhotoLibraryPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true) {
                guard let firstResult = results.first else { return }
                if firstResult.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    firstResult.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                        DispatchQueue.main.async {
                            if let uiImage = object as? UIImage {
                                self.parent.selectedImage = uiImage
                            }
                        }
                    }
                }
            }
        }
    }
}


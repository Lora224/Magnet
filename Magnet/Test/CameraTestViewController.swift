//
//  CameraTestViewController.swift
//  Magnet
//
//  Created by Muze Lyu on 5/6/2025.
//

import UIKit
import AVFoundation

/// This UIViewController builds its entire UI programmatically (no Storyboards).
/// It requests camera permission, then shows a live back‐camera preview inside `cameraView`.
class CameraTestViewController: UIViewController {
    
    // MARK: – Subviews
    
    /// This is the container where the live camera preview will appear.
    /// We’ll pin it to the edges of the screen.
    private let cameraView: UIView = {
        let view = UIView()
        view.backgroundColor = .black     // In case the preview isn’t ready yet
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    // MARK: – AVFoundation Properties
    
    /// The session coordinates input (camera) → output (preview layer).
    private let captureSession = AVCaptureSession()
    
    /// The `AVCaptureVideoPreviewLayer` that will show “what the camera sees.”
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    /// The `AVCaptureDeviceInput` wrapping the back camera.
    private var cameraInput: AVCaptureDeviceInput?
    
    
    // MARK: – View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Camera Test"
        
        // 1. Build the UI hierarchy (everywhere in code)
        setupViews()
        
        // 2. Configure the capture session preset (use .photo for high resolution still-capable)
        captureSession.sessionPreset = .photo
        
        // 3. Check/request camera permission & then configure the session
        checkCameraAuthorization()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Whenever the view’s size changes (e.g. rotation), update the preview layer’s frame.
        videoPreviewLayer?.frame = cameraView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start the session if it isn’t already running
        if captureSession.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop the session to free up the camera
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    /// Handle device rotation so the preview stays oriented
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            if let connection = self.videoPreviewLayer?.connection {
                connection.videoOrientation = self.currentVideoOrientation()
                self.videoPreviewLayer?.frame = self.cameraView.bounds
            }
        })
    }
    
    

    // MARK: – Camera Permission & Session Configuration
    
    /// Checks the authorization status for video (camera). If `.notDetermined`, requests access.
    /// If authorized, calls `setupCaptureSession()`. Otherwise, shows a “permission denied” alert.
    private func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Already have permission → configure the session immediately
            setupCaptureSession()
            
        case .notDetermined:
            // First‐time: ask the user
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupCaptureSession()
                    } else {
                        self.showPermissionDeniedAlert()
                    }
                }
            }
            
        case .denied, .restricted:
            // User previously denied, or system restricted
            showPermissionDeniedAlert()
            
        @unknown default:
            // A future case we don’t know about yet
            showPermissionDeniedAlert()
        }
    }
    
    /// Presents an alert telling the user to go to Settings → Privacy → Camera.
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "Please allow camera access in Settings → Privacy → Camera.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    /// Finds the back‐facing camera, creates an AVCaptureDeviceInput, attaches it to `captureSession`,
    /// and inserts an AVCaptureVideoPreviewLayer into `cameraView`.
    private func setupCaptureSession() {
        // 1. Find the default back camera
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: .back) else {
            print("ERROR: No back camera available.")
            return
        }
        
        do {
            // 2. Wrap that camera in an AVCaptureDeviceInput
            let input = try AVCaptureDeviceInput(device: backCamera)
            cameraInput = input
            
            // 3. Add the input to our session
            guard captureSession.canAddInput(input) else {
                print("ERROR: Cannot add camera input to session.")
                return
            }
            captureSession.addInput(input)
            
            // 4. Create & configure the preview layer
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.connection?.videoOrientation = currentVideoOrientation()
            previewLayer.frame = cameraView.bounds
            
            // 5. Insert the preview layer as the bottom‐most layer of cameraView
            cameraView.layer.insertSublayer(previewLayer, at: 0)
            self.videoPreviewLayer = previewLayer
            
            // 6. Start the session on a background queue
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
        catch {
            print("ERROR: Unable to initialize back camera: \(error.localizedDescription)")
        }
    }
    
    /// Returns the proper `AVCaptureVideoOrientation` matching the device’s UI orientation.
    private func currentVideoOrientation() -> AVCaptureVideoOrientation {
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        switch statusBarOrientation {
        case .portrait:            return .portrait
        case .portraitUpsideDown:  return .portraitUpsideDown
        case .landscapeLeft:       return .landscapeRight
        case .landscapeRight:      return .landscapeLeft
        default:                   return .portrait
        }
    }
    // MARK: – Setup UI in Code

    /// Adds `cameraView` to the root view and pins it to all edges.
    private func setupViews() {
        view.addSubview(cameraView)
        
        NSLayoutConstraint.activate([
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // (Optional) If you want an overlay button to “snap” a photo, you could add it here:
        // let snapButton = makeSnapButton()
        // view.addSubview(snapButton)
        // …add constraints…
        // and then hook up snapButton.addTarget(self, action: #selector(snapButtonTapped), for: .touchUpInside)
    }

    
    // MARK: – (Optional) Photo Capture Example
    
    // If you want to add a “Snap” button and capture a still image, uncomment the code below and add a UIButton in `setupViews()`:
    //
    // private let photoOutput = AVCapturePhotoOutput()
    //
    // @objc private func snapButtonTapped() {
    //     let settings = AVCapturePhotoSettings()
    //     photoOutput.capturePhoto(with: settings, delegate: self)
    // }
    //
    // Then in setupCaptureSession(), after adding `input` to the session, do:
    //     if captureSession.canAddOutput(photoOutput) {
    //         captureSession.addOutput(photoOutput)
    //     }
    //
    // And add this extension:
    // extension CameraTestViewController: AVCapturePhotoCaptureDelegate {
    //     func photoOutput(_ output: AVCapturePhotoOutput,
    //                      didFinishProcessingPhoto photo: AVCapturePhoto,
    //                      error: Error?) {
    //         if let error = error {
    //             print("Photo capture error: \(error.localizedDescription)")
    //             return
    //         }
    //         guard let data = photo.fileDataRepresentation(),
    //               let image = UIImage(data: data) else {
    //             return
    //         }
    //         // Save to Photos for testing
    //         UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    //         print("Photo captured and saved to Photos.")
    //     }
    // }
    //
    // If you do enable photo capture, don’t forget to add `NSPhotoLibraryAddUsageDescription`
    // to Info.plist as well, since we’re saving to the Camera Roll.
}


import UIKit
import AVFoundation

class CameraTestViewController: UIViewController {
    // 用来展示摄像头预览的 UIView
    private let cameraView: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var cameraInput: AVCaptureDeviceInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        captureSession.sessionPreset = .photo
        
        // 先判断权限状态
        checkCameraAuthorization()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 确保 previewLayer 始终与 cameraView 大小同步
        videoPreviewLayer?.frame = cameraView.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 如果 previewLayer 还没有创建，就在这里创建，保证 cameraView.bounds 已经有值
        if videoPreviewLayer == nil {
            configurePreviewLayerIfPossible()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 启动 session 在后台线程
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 停止 session 释放摄像头
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            // 更新方向 & 尺寸
            if let connection = self.videoPreviewLayer?.connection {
                connection.videoOrientation = self.currentVideoOrientation()
                self.videoPreviewLayer?.frame = self.cameraView.bounds
            }
        })
    }
    
    // MARK: - UI 布局
    private func setupViews() {
        view.addSubview(cameraView)
        NSLayoutConstraint.activate([
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // MARK: - 权限 & Session 配置
    
    private func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // 已有权限，尝试配置摄像头
            configurePreviewLayerIfPossible()
            
        case .notDetermined:
            // 第一次请求权限
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.configurePreviewLayerIfPossible()
                    } else {
                        self.showPermissionDeniedAlert()
                    }
                }
            }
            
        case .denied, .restricted:
            // 用户拒绝过或受限
            showPermissionDeniedAlert()
            
        @unknown default:
            showPermissionDeniedAlert()
        }
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "需要访问相机权限",
            message: "请前往 设置 → 隐私 → 相机，允许访问后再试。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "打开设置", style: .default, handler: { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    /// 只有在确定有权限、且 cameraView.bounds 已经准备好之后调用才安全
    private func configurePreviewLayerIfPossible() {
        // 1. 如果已经有 previewLayer，不要重复创建
        if videoPreviewLayer != nil { return }
        
        // 2. 模拟器里没有摄像头时直接返回
        #if targetEnvironment(simulator)
        print("当前是模拟器，没有摄像头，跳过相机初始化")
        return
        #endif
        
        // 3. 查找后置摄像头
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: .back) else {
            print("ERROR: 找不到后置摄像头")
            return
        }
        
        // 4. 尝试生成输入对象
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            cameraInput = input
            
            // 5. 将输入添加到 session
            guard captureSession.canAddInput(input) else {
                print("ERROR: 无法将摄像头输入添加到 Session")
                return
            }
            captureSession.addInput(input)
        }
        catch {
            print("ERROR: 初始化摄像头输入失败：\(error.localizedDescription)")
            return
        }
        
        // 6. 在主线程中创建并插入 PreviewLayer
        DispatchQueue.main.async {
            let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.connection?.videoOrientation = self.currentVideoOrientation()
            previewLayer.frame = self.cameraView.bounds
            self.cameraView.layer.insertSublayer(previewLayer, at: 0)
            self.videoPreviewLayer = previewLayer
        }
    }
    
    private func currentVideoOrientation() -> AVCaptureVideoOrientation {
        let orientation = UIApplication.shared.statusBarOrientation
        switch orientation {
        case .portrait:            return .portrait
        case .portraitUpsideDown:  return .portraitUpsideDown
        case .landscapeLeft:       return .landscapeRight
        case .landscapeRight:      return .landscapeLeft
        default:                   return .portrait
        }
    }
}

import AVFoundation
import UIKit
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    @Published var isPreviewAvailable = false
    @Published var permissionGranted = false
    
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    private var photoCaptureCompletionBlock: ((UIImage?) -> Void)?
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return videoPreviewLayer
    }
    
    override init() {
        super.init()
        setupCaptureSession()
    }
    
    func requestPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    if granted {
                        self?.startSession()
                    }
                }
            }
        case .denied, .restricted:
            permissionGranted = false
        @unknown default:
            permissionGranted = false
        }
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("無法使用後鏡頭")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            photoOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            
            DispatchQueue.main.async {
                self.isPreviewAvailable = true
            }
            
        } catch {
            print("相機設定失敗：\(error.localizedDescription)")
        }
    }
    
    func startSession() {
        guard permissionGranted else { return }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        photoCaptureCompletionBlock = completion
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func preprocessImage(_ image: UIImage) -> UIImage {
        // 圖像預處理：裁切、增強對比度等
        guard let ciImage = CIImage(image: image) else { return image }
        
        let context = CIContext()
        
        // 增強對比度和清晰度
        let contrastFilter = CIFilter(name: "CIColorControls")!
        contrastFilter.setValue(ciImage, forKey: kCIInputImageKey)
        contrastFilter.setValue(1.2, forKey: kCIInputContrastKey) // 增加對比度
        contrastFilter.setValue(1.1, forKey: kCIInputSaturationKey) // 略微增加飽和度
        
        guard let contrastOutput = contrastFilter.outputImage else { return image }
        
        // 銳化處理
        let sharpenFilter = CIFilter(name: "CISharpenLuminance")!
        sharpenFilter.setValue(contrastOutput, forKey: kCIInputImageKey)
        sharpenFilter.setValue(0.4, forKey: kCIInputSharpnessKey)
        
        guard let finalOutput = sharpenFilter.outputImage,
              let cgImage = context.createCGImage(finalOutput, from: finalOutput.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("拍照失敗：\(error.localizedDescription)")
            photoCaptureCompletionBlock?(nil)
            return
        }
        
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {
            let processedImage = preprocessImage(image)
            photoCaptureCompletionBlock?(processedImage)
        } else {
            photoCaptureCompletionBlock?(nil)
        }
        
        photoCaptureCompletionBlock = nil
    }
}
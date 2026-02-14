import SwiftUI
import AVFoundation
import UIKit

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @EnvironmentObject private var visionManager: VisionManager
    
    @State private var showingImagePicker = false
    @State private var showingProcessingSheet = false
    @State private var capturedImages: [UIImage] = []
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if cameraManager.isPreviewAvailable {
                    CameraPreviewView(cameraManager: cameraManager)
                        .onAppear {
                            cameraManager.startSession()
                        }
                        .onDisappear {
                            cameraManager.stopSession()
                        }
                } else {
                    Color.black
                        .overlay(
                            Text("相機無法使用")
                                .foregroundColor(.white)
                                .font(.title2)
                        )
                }
                
                VStack {
                    Spacer()
                    
                    // 拍照控制區域
                    HStack(spacing: 50) {
                        // 相片庫按鈕
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        // 拍照按鈕
                        Button(action: {
                            capturePhoto()
                        }) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 2)
                                        .frame(width: 70, height: 70)
                                )
                        }
                        
                        // 已拍攝數量
                        Button(action: {
                            if !capturedImages.isEmpty {
                                showingProcessingSheet = true
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.5))
                                    .frame(width: 50, height: 50)
                                
                                Text("\(capturedImages.count)")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        }
                        .disabled(capturedImages.isEmpty)
                    }
                    .padding(.bottom, 50)
                }
                
                if isProcessing {
                    Color.black.opacity(0.7)
                        .overlay(
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                                
                                Text("正在處理圖片...")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding(.top)
                            }
                        )
                }
            }
            .navigationTitle("拍照識別")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(images: $capturedImages)
            }
            .sheet(isPresented: $showingProcessingSheet) {
                ProcessingView(images: capturedImages, 
                             onComplete: { images in
                    capturedImages = []
                    showingProcessingSheet = false
                })
            }
        }
        .onAppear {
            cameraManager.requestPermission()
        }
    }
    
    private func capturePhoto() {
        cameraManager.capturePhoto { image in
            if let image = image {
                capturedImages.append(image)
            }
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = view.frame
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = uiView.frame
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
            .environmentObject(VisionManager())
    }
}
//
//  CameraViewModel.swift
//  Edu Plus Admin
//
//  Created by Doniyorbek Ibrokhimov on 16/04/25.
//

import SwiftUI
import AVFoundation
import Combine
import PipecatClientIOS

class CameraViewModel: NSObject, ObservableObject, VideoRecorderDelegate {
    var streamContinuation: AsyncStream<Data>.Continuation?
    
    
    func streamVideo() -> AsyncStream<Data> {
        return AsyncStream { continuation in
            self.streamContinuation = continuation
        }
    }
    
    override init() {
        super.init()
        
        setUpCaptureSessionOutput()
        setUpCaptureSessionInput()
    }

    private let sessionQueue = DispatchQueue(label: "SessionQueue")
    
    // AVFoundation properties
    let captureSession = AVCaptureSession()
    private var lastFrame: CMSampleBuffer?
    
    @Published var currentImage: UIImage?
    
    // Recognition properties
    @Published var isLoading = false
    @Published var error: String?
    private var lastRecognitionTime: Date?
    private let recognitionInterval: TimeInterval = 1.5 // Process every 3 seconds
    
    // MARK: - Camera Setup
    
    private func setUpCaptureSessionOutput() {
        sessionQueue.async {
            self.captureSession.stopRunning()
            self.captureSession.beginConfiguration()
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [
                (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
            ]
            output.alwaysDiscardsLateVideoFrames = true
            let outputQueue = DispatchQueue(label: "VideoDataOutputQueue")
            output.setSampleBufferDelegate(self, queue: outputQueue)
            
            guard self.captureSession.canAddOutput(output) else {
                print("Failed to add capture session output.")
                return
            }
            self.captureSession.addOutput(output)
            self.captureSession.commitConfiguration()
        }
    }
    
    private func setUpCaptureSessionInput() {
        sessionQueue.async {
            guard let device = self.captureDevice(forPosition: .front) else {
                print("Failed to get capture device for camera position: \(AVCaptureDevice.Position.front)")
                return
            }
            do {
                self.captureSession.beginConfiguration()
                for input in self.captureSession.inputs {
                    self.captureSession.removeInput(input)
                }
                
                let input = try AVCaptureDeviceInput(device: device)
                guard self.captureSession.canAddInput(input) else {
                    print("Failed to add capture session input.")
                    return
                }
                self.captureSession.addInput(input)
                self.captureSession.commitConfiguration()
            } catch {
                print("Failed to create capture device input: \(error.localizedDescription)")
            }
        }
    }
    
    private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera, .builtInTelephotoCamera, .builtInTrueDepthCamera],
            mediaType: .video,
            position: position
        )
        return discoverySession.devices.first { $0.position == position }
    }
    
    // MARK: - Session Control
    
    func startSession() {
        sessionQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            self.captureSession.stopRunning()
        }
    }
}

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Store last frame
        lastFrame = sampleBuffer
        
        // Don't process every frame - check if enough time has passed since last recognition
//        let currentTime = Date()
//        if let lastTime = lastRecognitionTime, 
//           currentTime.timeIntervalSince(lastTime) < recognitionInterval {
//            return
//        }
        
        // Convert CMSampleBuffer to UIImage
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let imageData = createImageData(from: imageBuffer) else {
            print("Failed to convert frame to image data")
            return
        }
        
        // Update last recognition time
//        lastRecognitionTime = currentTime
        
        // Process image
        streamContinuation?.yield(imageData)
    }
    
    private func createImageData(from pixelBuffer: CVPixelBuffer) -> Data? {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let context = CIContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent, format: .RGBA8, colorSpace: colorSpace) else {
            return nil
        }
        
        let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
        let imageData = uiImage.jpegData(compressionQuality: 0.5)
        
//        DispatchQueue.main.async {
//            if let imageData {
//                self.currentImage = UIImage(data: imageData)
//            }
//        }

        return imageData
    }
}

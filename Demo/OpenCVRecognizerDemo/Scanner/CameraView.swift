//
//  CameraView.swift
//  OpenCVRecognizer
//
//  Created by Yanis Plumit on 05.07.2023.
//

import Foundation
import AVFoundation

class CameraView: UIView {
    
    // performed in background thread
    // call completion when you have done
    var processImage: ((_ getImage: () -> UIImage?, _ completion: @escaping () -> Void) -> Void)?
    private var isProcessing = false
    
    func start() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    func stop() {
        self.captureSession.stopRunning()
    }
    
    private let captureQueue = DispatchQueue(label: "camera.frame.processing.queue")
    private let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupCamera()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer?.frame = bounds
        
        
        if let connection = self.videoPreviewLayer?.connection, connection.isVideoOrientationSupported {
            connection.videoOrientation = {
                switch window?.windowScene?.interfaceOrientation {
                case .portrait: return .portrait
                case .portraitUpsideDown: return .portraitUpsideDown
                case .landscapeLeft: return .landscapeLeft
                case .landscapeRight: return .landscapeRight
                default: return .portrait
                }
            }()
            
        }
        if let connection = self.videoDataOutput.connection(with: AVMediaType.video), connection.isVideoOrientationSupported {
            connection.videoOrientation = {
                switch window?.windowScene?.interfaceOrientation {
                case .portrait: return .portrait
                case .portraitUpsideDown: return .portraitUpsideDown
                case .landscapeLeft: return .landscapeLeft
                case .landscapeRight: return .landscapeRight
                default: return .portrait
                }
            }()
            
        }
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
            mediaType: .video,
            position: .back).devices.first else {
                fatalError("No back camera device found, please make sure to run app in an iOS device and not a simulator")
        }
        
        guard let cameraInput = try? AVCaptureDeviceInput(device: device) else {
            fatalError("looks like you are forbid access to the camera")
        }
        
        self.captureSession.sessionPreset = .vga640x480
        self.captureSession.addInput(cameraInput)
        
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: captureQueue)
        if self.captureSession.canAddOutput(videoDataOutput) {
            self.captureSession.addOutput(videoDataOutput)
            
            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            self.layer.addSublayer(videoPreviewLayer)
            self.videoPreviewLayer = videoPreviewLayer
        }
    }
    
}

extension CameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let processImage = self.processImage else { return }
        guard !isProcessing else { return }
        isProcessing = true
        
        let getUIImage: () -> UIImage? = {
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
            CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
            let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
            let width = CVPixelBufferGetWidth(imageBuffer)
            let height = CVPixelBufferGetHeight(imageBuffer)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
            bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
            let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
            guard let quartzImage = context?.makeImage() else { return nil }
            CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
            let image = UIImage(cgImage: quartzImage)
            return image
        }
        self.processImage?(getUIImage, {[weak self] in
            self?.captureQueue.async {
                self?.isProcessing = false
            }
        } )
    }
    
}

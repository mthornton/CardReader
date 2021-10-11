//
//  PreviewView.swift
//  CardReader
//
//  Created by Michael Thornton on 10/7/21.
//

import UIKit
import AVFoundation
import VideoToolbox
import Vision


class PreviewView: UIView {
    
    private let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
        
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    private let outlineLayer = CAShapeLayer()
    
    private var device: AVCaptureDevice?
    
    
    typealias CapturedCGImage = (CGImage) -> Void
    var didCaptureCGImage: CapturedCGImage?
    
    
    public func setup() {
        
        setCameraInput()
        setCameraOutput()
        
        //preview layer shows the camera output
        previewLayer.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        previewLayer.videoGravity = .resizeAspectFill
        
        self.layer.addSublayer(previewLayer)
        
        //outline layer is where we draw boxes
        outlineLayer.frame = previewLayer.bounds
        previewLayer.insertSublayer(outlineLayer, at: 1)
    }



    public func startCameraFeed(torchOn: Bool = false) {
                
        captureSession.startRunning()
        
        if torchOn {
            self.turnTorchOn()
        }
    }
    
    
    
    public func stopCameraFeed() {
        captureSession.stopRunning()
        
        // just in case it was turned on
        self.turnTorchOff()
    }
    
    
    
    public func freezFrameWithImage(_ cgImage: CGImage) {
        previewLayer.contents = cgImage
    }
    
    
    
    public func drawBoundingBox(rect: VNRectangleObservation) {
        
        let outlinePath = UIBezierPath()
        
        outlineLayer.lineCap = .butt
        outlineLayer.lineJoin = .round
        outlineLayer.lineWidth = 5.0
        outlineLayer.strokeColor = UIColor.systemYellow.cgColor
        outlineLayer.fillColor = UIColor.systemYellow.withAlphaComponent(0.25).cgColor
        
        let bottomTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -previewLayer.frame.height)
        
        let topRight = VNImagePointForNormalizedPoint(rect.topRight, Int(previewLayer.frame.width), Int(previewLayer.frame.height))
        let topLeft = VNImagePointForNormalizedPoint(rect.topLeft, Int(previewLayer.frame.width), Int(previewLayer.frame.height))
        let bottomRight = VNImagePointForNormalizedPoint(rect.bottomRight, Int(previewLayer.frame.width), Int(previewLayer.frame.height))
        let bottomLeft = VNImagePointForNormalizedPoint(rect.bottomLeft, Int(previewLayer.frame.width), Int(previewLayer.frame.height))
        
        outlinePath.move(to: topLeft.applying(bottomTopTransform))
        
        outlinePath.addLine(to: topRight.applying(bottomTopTransform))
        outlinePath.addLine(to: bottomRight.applying(bottomTopTransform))
        outlinePath.addLine(to: bottomLeft.applying(bottomTopTransform))
        outlinePath.addLine(to: topLeft.applying(bottomTopTransform))
        outlinePath.addLine(to: topRight.applying(bottomTopTransform))
        
        outlineLayer.path = outlinePath.cgPath
        
    }
    
    
    
    public func turnTorchOn() {
        
        if let device = device {
            // turn on the flashlight
            if (device.hasTorch) {
                do {
                    try device.lockForConfiguration()
                    
                    if (device.torchMode == AVCaptureDevice.TorchMode.off) {
                        try device.setTorchModeOn(level: 1.0)
                    }
                }
                catch { }
            }
        }
    }

    
    
    public func turnTorchOff() {
        
        if let device = device {
            // turn on the flashlight
            if (device.hasTorch) {
                do {
                    try device.lockForConfiguration()
                    
                    if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                        device.torchMode = .off
                    }
                }
                catch { }
            }
        }
    }
    
    
    private func setCameraInput() {

        let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera]

        guard let device = AVCaptureDevice.DiscoverySession(deviceTypes : deviceTypes, mediaType: .video, position: .back).devices.first else {
            print("This device does not support required input device")
            //TODO: something in UX
            return
        }
        
        self.device = device
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(cameraInput)
        } catch {
            //TODO: SOMETHING IN UX
            print(error.localizedDescription)
        }
    }
    
    
    
    private func setCameraOutput() {
        
        videoDataOutput.videoSettings = [
            (kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)
        ] as [String : Any]
        
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        
        captureSession.addOutput(videoDataOutput)
        
        guard let connection = videoDataOutput.connection(with: .video) else {
            print("An error was encontered while unwrapping videoDataOutput connection.")
            return
        }
        
        connection.videoOrientation = .portrait
        
    }
}



extension PreviewView: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("Unable to get image from sample buffer.")
            return
        }
        
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(frame, options: nil, imageOut: &cgImage)
        
        if let cgImage = cgImage {
            self.didCaptureCGImage?(cgImage)
        }
        else {
            print("Failed to create image from buffer")
        }
    }
} // end extension

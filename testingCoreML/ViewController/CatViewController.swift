//
//  ViewController.swift
//  testingCoreML
//
//  Created by Тоха on 15.06.2022.
//

import UIKit
import AVFoundation
import Vision

protocol BaseController: AnyObject {
    var presenter: BasePresenter? { get set }
}

class CatViewController: UIViewController, BaseController {
    //MARK: - Properties
    weak var presenter: BasePresenter?
    private let mainView = UIView()
    private let mainCameraLayer = AVCaptureVideoPreviewLayer()
    private var session = AVCaptureSession()
    private let captureQueue = DispatchQueue(label: "captureQueue")
    private var visionRequests: [VNRequest] = []
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMainView()
//        configureCameraVision()
        testCamera()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutMainView()
        activateConstraints()
    }

    //MARK: - Configurations
    private func configureMainView() {
        mainView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainView)
    }
    
    private func testCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
            let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    print("adding input")
                    session.addInput(input)
                }
                let videoOut = AVCaptureVideoDataOutput()
                if session.canAddOutput(videoOut) {
                    print("adding output")
                    session.addOutput(videoOut)
                }
                
                mainCameraLayer.videoGravity = .resizeAspectFill
                mainCameraLayer.session = session
                mainCameraLayer.frame = mainView.frame
                mainView.layer.insertSublayer(mainCameraLayer, at: 0)
                
                session.startRunning()
                self.session = session
        } catch {
            fatalError("dsfsf")
        }
        }
    }
    
    private func configureCameraVision() {
        guard let camera = AVCaptureDevice.default(for: .video) else {
            let alertC = UIAlertController(title: "Ops", message: "Run on real device", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default)
            alertC.addAction(alertAction)
            return
        }
        
        mainCameraLayer.session = session
        mainView.layer.addSublayer(mainCameraLayer)
        
        let cameraIn = try? AVCaptureDeviceInput(device: camera)
        
        let videoOut = AVCaptureVideoDataOutput()
        videoOut.setSampleBufferDelegate(self, queue: captureQueue)
        videoOut.alwaysDiscardsLateVideoFrames = true
        videoOut.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        guard let cameraIn = cameraIn else {
            let alertC = UIAlertController(title: "Ops", message: "Something is wrong with camera", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default)
            alertC.addAction(alertAction)
            return
        }
        
        session.sessionPreset = .high
        session.addInput(cameraIn)
        session.addOutput(videoOut)
        
        let connection = videoOut.connection(with: .video)
        connection?.videoOrientation = .portrait
        session.startRunning()
    }
    
    //MARK: - Layout
    
    private func layoutMainView() {
        mainView.backgroundColor = .clear
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate(
            [
                mainView.topAnchor.constraint(equalTo: view.topAnchor),
                mainView.leftAnchor.constraint(equalTo: view.leftAnchor),
                mainView.rightAnchor.constraint(equalTo: view.rightAnchor),
                mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ]
        )
    }
    
    //MARK: - Action

}

//MARK: - Extensions
extension CatViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                    return
                }

                var requestOptions: [VNImageOption: Any] = [:]
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
                    requestOptions = [.cameraIntrinsics: cameraIntrinsicData]
                }

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: requestOptions)
                do {
                    try imageRequestHandler.perform(visionRequests)
                } catch {
                    print(error)
                }
    }
}

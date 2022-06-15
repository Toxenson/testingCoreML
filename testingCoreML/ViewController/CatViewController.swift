//
//  ViewController.swift
//  testingCoreML
//
//  Created by Тоха on 15.06.2022.
//

import UIKit
import AVFoundation

protocol BaseController: UIViewController {
    var animal: String? { get set }
}

class CatViewController: UIViewController, BaseController {
    //MARK: - Properties
    var presenter: BasePresenter?
    private let mainView = UIImageView()
    private let mainCameraLayer = AVCaptureVideoPreviewLayer()
    private var session = AVCaptureSession()
    private let captureQueue = DispatchQueue(label: "captureQueue")
    private let visionLabel = UILabel()
    var animal: String? {
        didSet {
            visionLabel.text = animal
        }
    }
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMainView()
        configureCameraVision()
        configureVisionLabel()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        activateConstraints()
        layoutMainView()
    }

    //MARK: - Configurations
    private func configureMainView() {
        mainView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainView)
    }
    
    private func configureVisionLabel() {
        visionLabel.translatesAutoresizingMaskIntoConstraints = false
        visionLabel.numberOfLines = 0
        visionLabel.textColor = .white
        visionLabel.textAlignment = .center
        visionLabel.font = .boldSystemFont(ofSize: 20)
        mainView.addSubview(visionLabel)
        
        visionLabel.text = "FUCK!!"
    }
    
    private func configureCameraVision() {
        guard let camera = AVCaptureDevice.default(for: .video) else {
            let alertC = UIAlertController(title: "Ops", message: "Run on real device", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default)
            alertC.addAction(alertAction)
            return
        }
        
        mainCameraLayer.videoGravity = .resizeAspectFill
        mainCameraLayer.frame = view.frame
        mainCameraLayer.session = session
        mainView.layer.addSublayer(mainCameraLayer)
        
        let cameraIn = try? AVCaptureDeviceInput(device: camera)
        
        let videoOut = AVCaptureVideoDataOutput()
        videoOut.setSampleBufferDelegate(presenter as? AVCaptureVideoDataOutputSampleBufferDelegate, queue: captureQueue)
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
        mainView.backgroundColor = .green
    }
    
    
    
    private func activateConstraints() {
        NSLayoutConstraint.activate(
            [
                mainView.topAnchor.constraint(equalTo: view.topAnchor),
                mainView.leftAnchor.constraint(equalTo: view.leftAnchor),
                mainView.rightAnchor.constraint(equalTo: view.rightAnchor),
                mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                visionLabel.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -view.safeAreaInsets.bottom),
                visionLabel.centerXAnchor.constraint(equalTo: mainView.centerXAnchor)
            ]
        )
    }
    
    //MARK: - Action

}

//MARK: - Extensions


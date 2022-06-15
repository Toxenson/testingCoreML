//
//  CatViewPresenter.swift
//  testingCoreML
//
//  Created by Тоха on 15.06.2022.
//

import Vision
import AVFoundation

protocol BasePresenter: AnyObject {
    var output: BaseController? { get set }
}

protocol CatViewPresenterOutput: AnyObject {
    
}

class CatViewPresenter: NSObject, BasePresenter {
    weak var output: BaseController? {
        didSet {
            configureModel()
        }
    }
    private var visionRequests: [VNRequest] = []
    
    private func configureModel() {
        guard let mlModel = try? VNCoreMLModel(for: Inceptionv3().model) else {
            return
        }
        
        let classificationRequest = VNCoreMLRequest(model: mlModel, completionHandler: handleClassification)
        classificationRequest.imageCropAndScaleOption = .centerCrop
        visionRequests = [classificationRequest]
    }
    
    private func handleClassification(request: VNRequest, error: Error?) {
        if let error = error {
            debugPrint(error.localizedDescription)
            return
        }
        
        guard let results = request.results as? [VNClassificationObservation] else {
            output?.animal = "No animals here"
            return
        }
        
        var resultString = "No cats here"
            results[0...3].forEach {
                    let identifer = $0.identifier.lowercased()
                    if identifer.range(of: "cat") != nil {
                    resultString = "It is a cat!"
                }
            }
            DispatchQueue.main.async {
                self.output?.animal = resultString
            }
    }
}

extension CatViewPresenter: AVCaptureVideoDataOutputSampleBufferDelegate {
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

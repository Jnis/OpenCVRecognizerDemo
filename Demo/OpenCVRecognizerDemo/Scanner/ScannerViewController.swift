//
//  ScannerViewController.swift
//  OpenCVRecognizer
//
//  Created by Yanis Plumit on 04.07.2023.
//

import Foundation

class ScannerViewController: UIViewController {
    
    let selfView = ScannerView(frame: .zero)
    
    override func loadView() {
        self.view = selfView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let models: [OCVAdapterImageModel] = [
            .init(image: UIImage(named: "car_moon")!, key: "car_moon"),
            .init(image: UIImage(named: "car_star")!, key: "car_star"),
            .init(image: UIImage(named: "car")!, key: "car"),
            .init(image: UIImage(named: "face_hat")!, key: "face_hat"),
            .init(image: UIImage(named: "face_rabbit")!, key: "face_rabbit"),
            .init(image: UIImage(named: "face")!, key: "face"),
            .init(image: UIImage(named: "hummer_nail")!, key: "hummer_nail"),
            .init(image: UIImage(named: "hummer")!, key: "hummer"),
        ]
        selfView.cameraView.processImageWith(processor: OCVProcessorAdapter(models: models),
                                             throttleInterval: 0.3,
                                             recognitionRepeats: 1,
                                             completion: {[weak self] results in
            self?.selfView.resultLabel.text = "=> " + results.items
                .map({ String(format: "\($0.key) (%i/%.2f%%)", $0.mistakes, $0.matchPercent * 100) })
                .joined(separator: "\n")
        },
                                             debugImage: {[weak self] debugImage in
            self?.selfView.debugImageView.image = debugImage
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selfView.cameraView.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        selfView.cameraView.stop()
    }
    
}

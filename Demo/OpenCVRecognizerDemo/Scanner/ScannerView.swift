//
//  ScannerView.swift
//  OpenCVRecognizer
//
//  Created by Yanis Plumit on 04.07.2023.
//

import Foundation

class ScannerView: UIView {
    let cameraView = CameraView()
    let resultLabel: UILabel = {
        let v = UILabel()
        v.textColor = .black
        v.backgroundColor = .white
        v.numberOfLines = 0
        return v
    }()
    let debugImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        self.addSubview(cameraView)
        self.addSubview(debugImageView)
        self.addSubview(resultLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resultLabel.frame = {
            var rect = CGRect.zero
            rect.origin.x = 20
            rect.size.width = bounds.width - rect.origin.x * 2
            rect.size.height = resultLabel.font.lineHeight * 4
            rect.origin.y = safeAreaInsets.top
            return rect
        }()
        cameraView.frame = bounds
        debugImageView.frame = {
            var rect = cameraView.frame
            rect.size.width = bounds.size.width * 0.3
            rect.origin.x = bounds.size.width - rect.size.width
            return rect
        }()
    }
}


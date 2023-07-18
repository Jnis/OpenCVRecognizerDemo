//
//  CameraView+Throttler.swift
//  OpenCVRecognizerDemo
//
//  Created by Yanis Plumit on 14.07.2023.
//

import Foundation

extension CameraView {
    
    private class ThrottleHelper {
        var lastProcessDate = Date()
        var lastRecognition: String?
        var lastRecognitionRepeats: Int = 0
    }
    
    // completions preformed in main thread
    func processImageWith(processor: OCVProcessorAdapter, throttleInterval: TimeInterval, recognitionRepeats: Int, completion: @escaping (OCVAdapterResults) -> Void, debugImage: @escaping (UIImage?) -> Void) {
        let helper = ThrottleHelper()
        
        self.processImage = { getImage, processImageCompletion in
            guard fabs(helper.lastProcessDate.timeIntervalSinceNow) > throttleInterval,
                  let image = getImage() else {
                processImageCompletion()
                return
            }
            helper.lastProcessDate = Date()
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                let results = processor.processImage(image, isDebug: {
#if DEBUG
                    return true
#else
                    return false
#endif
                }())
                DispatchQueue.main.async {
#if DEBUG
                    debugImage(results.debugImage)
#endif
                    let resultRecognition = results.items.first?.key
                    if recognitionRepeats > 0 {
                        if resultRecognition != nil && resultRecognition == helper.lastRecognition {
                            if helper.lastRecognitionRepeats >= recognitionRepeats {
                                completion(results)
                            } else {
                                helper.lastRecognitionRepeats += 1
                            }
                        } else {
                            helper.lastRecognitionRepeats = 1
                        }
                        helper.lastRecognition = resultRecognition
                    } else {
                        if resultRecognition != nil {
                            completion(results)
                        }
                    }
                    processImageCompletion()
                }
            }
        }
    }
}

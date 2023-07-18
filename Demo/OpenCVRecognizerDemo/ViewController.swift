//
//  ViewController.swift
//  OpenCVRecognizer
//
//  Created by Yanis Plumit on 04.07.2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }

    @IBAction func openScannerAction(_ sender: Any) {
        self.present(ScannerViewController(), animated: true)
    }
    
    
}


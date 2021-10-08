//
//  ViewController.swift
//  CardReader
//
//  Created by Michael Thornton on 10/7/21.
//

import UIKit




class ViewController: UIViewController {

    @IBOutlet weak var previewView: PreviewView!
    
    let scanner = CreditCardScanner()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewView.setup()
        
        previewView.didCaptureCGImage = scanner.readTextFromCGImage(_:)

    }

    
    override func viewDidAppear(_ animated: Bool) {
        
        previewView.startCameraFeed()
    }
    
} // end class



extension ViewController: CreditCardScannerDelegate {
    
    func didFindCardNumber(_ ccNum: String, withDate date: String, forName name: String) {
        
        previewView.stopCameraFeed()
        print("name = \(name)")
        print("cc = \(ccNum)")
        print("date = \(date)")
    }
    
} // end extension

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
    
    typealias CardDataFoundHandler = (String, String, String) -> Void
    var cardDataFound: CardDataFoundHandler?
    
    typealias CardDataFailed = () -> Void
    var cardDataNotFound: CardDataFailed?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //  set the callback for when data is found
        scanner.cardDataFound = didFindCardNumber(_:withDate:forName:)
        
        // get the preview view attached to the carera and outputting image to screen
        previewView.setup()
        
        // set function to call for each frame captured
        previewView.didCaptureCGImage = scanner.readTextFromCGImage(_:)

        self.perform(#selector(giveUpLookingForCCData), with: nil, afterDelay: 10.0)
    }


    
    override func viewDidAppear(_ animated: Bool) {
        
        // turn the preview on
        previewView.startCameraFeed(torchOn: false)
    }
    
    
    
    /***
     Called when cc data was found
     */
    func didFindCardNumber(_ ccNum: String, withDate date: String, forName name: String) {
        
        // stop the tiemout
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        // turn off the preview
        previewView.stopCameraFeed()
        
        // tell whatever wanted this data we have the data
        self.cardDataFound?(ccNum, date, name)
        
        // dismiss the UI
        self.dismiss(animated: true, completion: nil)
    }

    
    
    @objc func giveUpLookingForCCData() {

        // turn off the preview
        previewView.stopCameraFeed()
        
        // tell called we are giving up
        cardDataNotFound?()
        
        // dismiss the UI
        self.dismiss(animated: true, completion: nil)
    }
} // end class

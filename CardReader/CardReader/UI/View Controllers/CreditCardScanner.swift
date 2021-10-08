//
//  CreditCardScanner.swift
//  CardReader
//
//  Created by Michael Thornton on 10/7/21.
//

import Foundation
import Vision



protocol CreditCardScannerDelegate {
    func didFindCardNumber(_ ccNum: String, withDate date: String, forName name: String)
}



class CreditCardScanner {
    
    private var isLookingForCreditCard = false
    
    var delegate: CreditCardScannerDelegate?
    
    func readTextFromCGImage(_ cgImage: CGImage) {
        
        if isLookingForCreditCard { return }
        
        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest { request, error in
                        
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            var ccRecognizedText: VNRecognizedText?
            var dateRecognizedText: VNRecognizedText?            
            var nameRecognizedText: VNRecognizedText?
            
            for observation in observations {
                if let recognizedText = observation.topCandidates(1).first {
                    
                    //print("testing \(recognizedText.string)")
                    
                    //check for a CC
                    if CCValidator.validate(creditCardNumber: recognizedText.string) {
                        ccRecognizedText = recognizedText
                        //print("CC \(recognizedText.string) (\(recognizedText.confidence)")
                    }
                    
                    //check for a date
                    if CCValidator.validate(dateText: recognizedText.string) {
                        dateRecognizedText = recognizedText
                        //print("Date \(recognizedText.string) (\(recognizedText.confidence)")
                    }
                    
                    //check for name
                    if recognizedText.string.isName {
                        nameRecognizedText = recognizedText
                        //print("Name \(recognizedText.string) (\(recognizedText.confidence)")
                    }
                    
                    //if we have both, we are done
                    if let nameRecognizedText = nameRecognizedText, let ccRecognizedText = ccRecognizedText, let dateRecognizedText = dateRecognizedText {
                        
                        //print("found \(nameRecognizedText.string) = \(nameRecognizedText.confidence) :: \(ccRecognizedText.string) = \(ccRecognizedText.confidence) :: \(dateRecognizedText.string) = \(dateRecognizedText.confidence)")
                        
                        
                        self.delegate?.didFindCardNumber(ccRecognizedText.string, withDate: dateRecognizedText.string, forName: nameRecognizedText.string)
                    }
                }
            }
        }

        request.recognitionLevel = .accurate //.fast gave much worse results
        request.usesLanguageCorrection = false
        
        //TODO: possible future enhancement - find the CC in the image and reduce area to look at
        //request.regionOfInterest = ?
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Perform the text-recognition request.
                self.isLookingForCreditCard = true
                try requestHandler.perform([request])
                self.isLookingForCreditCard = false
            } catch {
                print("Unable to perform the requests: \(error).")
            }
        }


    }
    
}

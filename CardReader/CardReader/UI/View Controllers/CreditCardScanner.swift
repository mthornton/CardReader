//
//  CreditCardScanner.swift
//  CardReader
//
//  Created by Michael Thornton on 10/7/21.
//

import Foundation
import Vision




class CreditCardScanner {
    
    typealias CardDataFoundHandler = (String, String, String) -> Void
    
    var cardDataFound: CardDataFoundHandler?
    
    private var isLookingForCreditCard = false
    
    
    private func findCCTextInVNRequest(_ request: VNRequest) {
        
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
                    print("CC \(recognizedText.string)")
                }

                //check for a date
                if CCValidator.validate(dateText: recognizedText.string) {
                    dateRecognizedText = recognizedText
                    print("date \(recognizedText.string)")
                }

                //check for name
                if recognizedText.string.isName {
                    nameRecognizedText = recognizedText
                    print("name \(recognizedText.string)")
                }

                //if we have all three, we are done
                if let ccRecognizedText = ccRecognizedText, let dateRecognizedText = dateRecognizedText, let nameRecognizedText = nameRecognizedText {

                    // dates are a pain in the ass because they get read with extra data a lot
                    // so the validator return true if it find a date in the text
                    // it is typically the first or last 5 chars, so we will just check for that
                    // but if it is not we will return the whole string
                    var date = dateRecognizedText.string

                    if date.count > 5 {
                        if CCValidator.validate(dateText: String(date.suffix(5))) {
                            date = String(date.suffix(5))
                        }
                        else {
                            if CCValidator.validate(dateText: String(date.prefix(5))) {
                                date = String(date.prefix(5))
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.cardDataFound?(ccRecognizedText.string, date, nameRecognizedText.string)
                    }
                }
            }
        }
    }
    
    
    
    func readTextFromCGImage(_ cgImage: CGImage) {
                
        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest { request, error in

            if let _ = error {
                // ignore errors, next frame might be fine
                // let whomever is calling this functionality worry about timeouts
                return
            }
            
            self.findCCTextInVNRequest(request)
        }

        request.recognitionLevel = .accurate //.fast gave much worse results
        request.usesLanguageCorrection = false
        
        
        //TODO: possible future enhancement - find the CC in the image and reduce area to look at
        //request.regionOfInterest = ?
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                
                // keeping a flag marking when processing the text so we
                // don't bother with a new frame until last check is done
                if self.isLookingForCreditCard == false {
                    self.isLookingForCreditCard = true
                    
                    // process the image
                    try requestHandler.perform([request])
                    self.isLookingForCreditCard = false
                }
            } catch {
                print("Unable to perform the requests: \(error).")
            }
        }


    }
    
}

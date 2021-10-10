//
//  CreditCardCollectViewController.swift
//  CardReader
//
//  Created by Michael Thornton on 10/8/21.
//

import UIKit

class CreditCardCollectViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ccNumTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    
    @IBAction func buttonScan_touched(_ sender: Any) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            vc.cardDataFound = self.didFindCardNumber(_:withDate:forName:)
            vc.cardDataNotFound = self.didNotFindCardNumber
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }

    
    
    func didFindCardNumber(_ ccNum: String, withDate date: String, forName name: String) {
        
        nameTextField.text = name
        ccNumTextField.text = ccNum
        dateTextField.text = date
    }
    
    
    
    func didNotFindCardNumber() -> Void {
    
        // do somethign to let the user know it failed
    }
    
    
} // end class

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

        // Do any additional setup after loading the view.
    }
    

    @IBAction func buttonScan_touched(_ sender: Any) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }

}

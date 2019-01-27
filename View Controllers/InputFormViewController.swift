//
//  InputFormViewController.swift
//  CashMoney
//
//  Created by Cory Da Silva on 1/26/19.
//  Copyright © 2019 Cory Da Silva. All rights reserved.
//

import UIKit
import TextFieldEffects

class InputFormViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var ageTextField : HoshiTextField?
    @IBOutlet var incomeTextField : HoshiTextField?
    @IBOutlet var startingIncomeTextField : HoshiTextField?
    @IBOutlet var nextButton : UIButton!
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func pressReady(){
        mainDelegate.startingAmount = Float(startingIncomeTextField?.text ?? "0")
        mainDelegate.age = Int(ageTextField?.text ?? "0")
        mainDelegate.monthlyIncome = Float(incomeTextField?.text ?? "0")
        
        self.performSegue(withIdentifier: "arSegue", sender: self)
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        ageTextField!.delegate = self
        incomeTextField!.delegate = self
        startingIncomeTextField!.delegate = self
        nextButton.layer.cornerRadius = 7
        nextButton.clipsToBounds = true

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        
    }
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

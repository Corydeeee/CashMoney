//
//  HomeViewController.swift
//  CashMoney
//
//  Created by Cory Da Silva on 1/26/19.
//  Copyright © 2019 Cory Da Silva. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet var startedButton : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        startedButton.layer.cornerRadius = 7
        startedButton.clipsToBounds = true
        // Do any additional setup after loading the view.
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



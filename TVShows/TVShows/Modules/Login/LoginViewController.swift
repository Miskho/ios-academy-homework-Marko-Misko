//
//  LoginViewController.swift
//  TVShows
//
//  Created by Infinum on 05/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController {
    
    private var numberOfTaps = 0
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView! {
        didSet {
            myActivityIndicator.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
               self.myActivityIndicator.stopAnimating()
            }
        }
    }
    
    @IBOutlet weak var myButton: UIButton! {
        didSet {
            myButton.layer.cornerRadius = 20
            myButton.frame.size = CGSize(width: 120.0, height: 60.0)
            
            myButton.setImage(UIImage(named: "Plus"), for: .normal)
            myButton.setTitle("Increment!", for: .normal)
            myButton.sizeToFit()
        }
    }
    
    @IBOutlet weak var myLabel: UILabel!  {
        didSet {
            myLabel.text = "\(numberOfTaps)"
            myLabel.font = UIFont(name: "Verdana-BoldItalic", size: 45.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
    }
    
    @IBAction func buttonPressed() {
        print("It works!")
        numberOfTaps += 1
        myLabel.text = "\(numberOfTaps)"
        myActivityIndicator.isAnimating ? myActivityIndicator.stopAnimating() : myActivityIndicator.startAnimating()
    }
}

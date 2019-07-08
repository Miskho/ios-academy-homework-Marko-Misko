//
//  LoginViewController.swift
//  TVShows
//
//  Created by Infinum on 05/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController
{
    
    var tapCounter = 0
    
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
            myButton.backgroundColor = .green
            myButton.layer.cornerRadius = 20
            myButton.frame.size = CGSize(width: 120.0, height: 60.0)
            
            let icon = UIImage(named: "Plus") as UIImage?
            myButton.setImage(icon, for: .normal)
            myButton.setTitle("Increment!", for: .normal)
            myButton.sizeToFit()
        }
    }
    
    @IBOutlet weak var myLabel: UILabel!  {
        didSet {
            myLabel.text = "\(tapCounter)"
            myLabel.font = UIFont(name: "Verdana-BoldItalic", size: 45.0)
        }
    }
    
    @IBAction func touchUpInside(_ sender: Any) {
        print("It works!")
        tapCounter += 1
        myLabel.text = "\(tapCounter)"
        myActivityIndicator.isAnimating ? myActivityIndicator.stopAnimating() : myActivityIndicator.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .cyan
    }
}

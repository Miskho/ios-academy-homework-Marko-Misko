//
//  HomeViewController.swift
//  TVShows
//
//  Created by Infinum on 15/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit

final class HomeViewController: UIViewController {
    
    @IBOutlet public var userLabel: UILabel!
    
    var loginCredentials: LoginData?
    var loginUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLabel.text = loginCredentials?.token
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

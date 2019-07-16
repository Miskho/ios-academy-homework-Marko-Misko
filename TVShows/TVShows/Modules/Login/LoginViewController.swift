//
//  LoginViewController.swift
//  TVShows
//
//  Created by Infinum on 05/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit

final class LoginViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logInButtonPressed(_ sender: Any) {
        navigateToHomeView()
    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        navigateToHomeView()
    }
    
    private func navigateToHomeView() {
        // We need to instantiate the Storyboard in which our view controller that we want to go to lives
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
        
        // We need to instantiate the view controller that we want to go to
        let homeViewController = homeStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController

        // We need to push that view controller on top of the navigation stack
        navigationController?.pushViewController(homeViewController, animated: true)
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

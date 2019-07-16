//
//  LoginViewController.swift
//  TVShows
//
//  Created by Infinum on 05/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import CodableAlamofire

final class LoginViewController : UIViewController {
    
    @IBOutlet private weak var rememberMeButton: UIButton!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private var loggedUser: User?
    private var loginCredentials: LoginData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setDefaultMaskType(.black)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    @IBAction private func logInButtonPressed(_ sender: Any) {
        _loginUserWith(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
        _navigateToHomeView()
    }
    
    @IBAction private func createAccountButtonPressed(_ sender: Any) {
        _registerUserWith(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
        logInButtonPressed(sender)
    }
    
    @IBAction private func rememberMePressed() {
        rememberMeButton.isSelected.toggle()
    }
    
    
    private func _navigateToHomeView() {
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = homeStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        homeViewController.email = loggedUser?.email
        navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    private func _registerUserWith(email: String, password: String) {
        SVProgressHUD.show()
        
        if email.isEmpty || password.isEmpty {
            return
        }
        
        let parameters: [String: String] = [
            "email": email,
            "password": password
        ]
        
        Alamofire
            .request(
                "https://api.infinum.academy/api/users",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default)
            .validate()
            .responseDecodableObject(keyPath: "data", decoder: JSONDecoder()) { (response: DataResponse<User>) in
                
                SVProgressHUD.dismiss()
                
                switch response.result {
                case .success(let user):
                    print("Success: \(user)")
                    self.loggedUser = user
                case .failure(let error):
                    print("API failure: \(error)")
                }
        }
    }
    
    private func _loginUserWith(email: String, password: String) {
        SVProgressHUD.show()
        
        let parameters: [String: String] = [
            "email": email,
            "password": password
        ]
        
        Alamofire
            .request(
                "https://api.infinum.academy/api/users/sessions",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default)
            .validate()
            .responseDecodableObject(keyPath: "data", decoder: JSONDecoder()) { (response: DataResponse<LoginData>) in
                
                SVProgressHUD.dismiss()
                
                switch response.result {
                case .success(let loginData):
                    print("Success: \(loginData)")
                    self.loginCredentials = loginData
                case .failure(let error):
                    print("API failure: \(error)")
                }
        }
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

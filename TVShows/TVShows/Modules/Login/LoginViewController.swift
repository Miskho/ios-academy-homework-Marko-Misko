//
//  LoginViewController.swift
//  TVShows
//
//  Created by Infinum on 05/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire
import PromiseKit
import SVProgressHUD

final class LoginViewController : UIViewController {
    
    @IBOutlet private weak var rememberMeButton: UIButton!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private var loginCredentials: LoginData?
    private var loginUser: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setDefaultMaskType(.black)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    @IBAction private func logInButtonPressed(_ sender: Any) {
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty
            else {
                return
                
        }
        _logInUserWith(email: email, password: password)
        
    }
    
    @IBAction private func createAccountButtonPressed(_ sender: Any) {
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty
            else {
                return
        }
        _registerUserWith(email: email, password: password)
        
    }
    
    @IBAction private func rememberMePressed() {
        rememberMeButton.isSelected.toggle()
    }
    
    
    private func _navigateToHomeView() {
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = homeStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        
        homeViewController.loginCredentials = loginCredentials
        homeViewController.loginUser = loginUser
        
        navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    private func  _displayLoginFailedAlert() {
        let alertController = UIAlertController(title: "Could not log in with provided credentials", message: "Please register yourself or check if the email and password you have provided are valid ones.", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Ok", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

// Provides the same API functionalities using Promises from PromiseKit
extension LoginViewController {
    
    private func _registerUserWith(email: String, password: String) {
        SVProgressHUD.show()
        firstly { () -> Promise<User> in
            return _sendAlamofireHTTPRequestTo(
                "https://api.infinum.academy/api/users"
                , method: .post
                , email: email
                , password: password)
            }.then { [weak self] (user: User) -> Promise<LoginData> in
                guard let self = self else {
                    return Promise(error: NSError())
                }
                self.loginUser = user
                return self._sendAlamofireHTTPRequestTo(
                    "https://api.infinum.academy/api/users/sessions"
                    , method: .post
                    , email: email
                    , password: password)
            }.done { [weak self] in
                print("Success: \($0)")
                guard let self = self else { return }
                self._navigateToHomeView()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch {
                print("API failure: \($0)")
        }
    }
    
    private func _logInUserWith(email: String, password: String) {
        SVProgressHUD.show()
        firstly { () -> Promise<LoginData> in
            _sendAlamofireHTTPRequestTo(
                "https://api.infinum.academy/api/users/sessions"
                , method: .post
                , email: email
                , password: password)
            }
            .done { [weak self] in
                guard let self = self else { return }
                self.loginCredentials = $0
                print("Success: \($0)")
                self._navigateToHomeView()
            }
            .ensure {
                SVProgressHUD.dismiss()
            }.catch {
                print("API failure: \($0)")
        }
    }
    
    private func _sendAlamofireHTTPRequestTo<T: Codable>(_ url: String, method: HTTPMethod, email: String, password: String) -> Promise<T>{
        return Alamofire.request(
            url,
            method: method,
            parameters: [
                "email": email,
                "password": password
            ],
            encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(T.self, keyPath: "data")
    }
}

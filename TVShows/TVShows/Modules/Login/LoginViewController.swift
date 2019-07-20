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
        navigationController?.setNavigationBarHidden(true, animated: animated)
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
        _logInUserUsingPromisesWith(email: email, password: password)
        
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
        _registerUserUsingPromisesWith(email: email, password: password)
        
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
    
    private func _registerUserWith(email: String, password: String) {
        SVProgressHUD.show()
        
        Alamofire
            .request(
                "https://api.infinum.academy/api/users",
                method: .post,
                parameters: [
                    "email": email,
                    "password": password
                ],
                encoding: JSONEncoding.default)
            .validate()
            .responseDecodableObject(keyPath: "data", decoder: JSONDecoder()) { (response: DataResponse<User>) in
                
                SVProgressHUD.dismiss()
                
                switch response.result {
                case .success(let user):
                    print("Success: \(user)")
                    self.loginUser = user
                    self._logInUserWith(email: email, password: password)
                case .failure(let error):
                    print("API failure: \(error)")
                }
        }
    }
    
    
    private func _logInUserWith(email: String, password: String) {
        SVProgressHUD.show()
        
        Alamofire
            .request(
                "https://api.infinum.academy/api/users/sessions",
                method: .post,
                parameters: [
                    "email": email,
                    "password": password
                ],
                encoding: JSONEncoding.default)
            .validate()
            .responseDecodableObject(keyPath: "data", decoder: JSONDecoder()) { (response: DataResponse<LoginData>) in
                
                SVProgressHUD.dismiss()
                
                switch response.result {
                case .success(let loginData):
                    print("Success: \(loginData)")
                    self.loginCredentials = loginData
                    self._navigateToHomeView()
                case .failure(let error):
                    print("API failure: \(error)")
                }
        }
    }
    
}

// Provides the same API functionalities using Promises from PromiseKit
extension LoginViewController {
    
    private func _registerUserUsingPromisesWith(email: String, password: String) {
        SVProgressHUD.show()
        firstly { () -> Promise<User> in
            let registerUserHTTPRequestHeaderData = AvailableRequestsFromLoginViewController.registerUser
            return _sendAlamofireHTTPRequestTo(url: registerUserHTTPRequestHeaderData.1, method: registerUserHTTPRequestHeaderData.0
                , email: email, password: password)
            }.then { (user: User) -> Promise<LoginData> in
                self.loginUser = user
                let logInUserHTTPRequestHeaderData = AvailableRequestsFromLoginViewController.loginUser
                return self._sendAlamofireHTTPRequestTo(url: logInUserHTTPRequestHeaderData.1, method: logInUserHTTPRequestHeaderData.0
                    , email: email, password: password)
            }.done { user in
                print("Success: \(user)")
                self._navigateToHomeView()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch { error in
                print("API failure: \(error)")
        }
    }
    
    private func _logInUserUsingPromisesWith(email: String, password: String) {
        SVProgressHUD.show()
        let logInUserHTTPRequestHeaderData = AvailableRequestsFromLoginViewController.loginUser
        firstly { () -> Promise<LoginData> in
            _sendAlamofireHTTPRequestTo(url: logInUserHTTPRequestHeaderData.1, method: logInUserHTTPRequestHeaderData.0
                , email: email, password: password)
            }
            .done { loginData in
                self.loginCredentials = loginData
                print("Success: \(loginData)")
                self._navigateToHomeView()
            }
            .ensure {
                SVProgressHUD.dismiss()
            }.catch { error in
                print("API failure: \(error)")
        }
    }
    
    private func _sendAlamofireHTTPRequestTo<T: Codable>(url: String, method: HTTPMethod, email: String, password: String) -> Promise<T>{
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
    
    private enum AvailableRequestsFromLoginViewController {
        static let registerUser = (HTTPMethod.post, "https://api.infinum.academy/api/users")
        static let loginUser = (HTTPMethod.post, "https://api.infinum.academy/api/users/sessions")
    }
}

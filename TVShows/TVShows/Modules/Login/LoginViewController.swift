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
        let loginUserHTTPRequestHeaderData = AvailableRequestsFromLoginViewController.registerUser
        
        Alamofire
            .request(
                loginUserHTTPRequestHeaderData.url,
                method: loginUserHTTPRequestHeaderData.method,
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
        let registerUserHTTPRequestHeaderData = AvailableRequestsFromLoginViewController.registerUser
        
        Alamofire
            .request(
                registerUserHTTPRequestHeaderData.url,
                method: registerUserHTTPRequestHeaderData.method,
                parameters: [
                    "email": email,
                    "password": password
                ],
                encoding: JSONEncoding.default)
            .validate()
            .responseDecodableObject(keyPath: "data", decoder: JSONDecoder()) { [weak self] (response: DataResponse<LoginData>) in
                
                SVProgressHUD.dismiss()
                
                switch response.result {
                case .success(let loginData):
                    print("Success: \(loginData)")
                    self?.loginCredentials = loginData
                    self?._navigateToHomeView()
                case .failure(let error):
                    print("API failure: \(error)")
                    self?._displayLoginFailedAlert()
                }
        }
    }
    
    private func  _displayLoginFailedAlert() {
        let alertController = UIAlertController(title: "Could not log in with provided credentials", message: "Please register yourself or check if the email and password you have provided are valid ones.", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Ok", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private enum AvailableRequestsFromLoginViewController {
        static let registerUser = (method: HTTPMethod.post, url: "https://api.infinum.academy/api/users")
        static let loginUser = (method: HTTPMethod.post, url: "https://api.infinum.academy/api/users/sessions")
    }
    
}

// Provides the same API functionalities using Promises from PromiseKit
extension LoginViewController {
    
    private func _registerUserUsingPromisesWith(email: String, password: String) {
        SVProgressHUD.show()
        firstly { () -> Promise<User> in
            let registerUserHTTPRequestHeaderData = AvailableRequestsFromLoginViewController.registerUser
            return _sendAlamofireHTTPRequestTo(registerUserHTTPRequestHeaderData.url, method: registerUserHTTPRequestHeaderData.method
                , email: email, password: password)
            }.then { (user: User) -> Promise<LoginData> in
                self.loginUser = user
                let logInUserHTTPRequestHeaderData = AvailableRequestsFromLoginViewController.loginUser
                return self._sendAlamofireHTTPRequestTo(logInUserHTTPRequestHeaderData.url, method: logInUserHTTPRequestHeaderData.method
                    , email: email, password: password)
            }.done { user in
                print("Success: \(user)")
                self._navigateToHomeView()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch { [weak self] error in
                print("API failure: \(error)")
                self?._displayLoginFailedAlert()
        }
    }
    
    private func _logInUserUsingPromisesWith(email: String, password: String) {
        SVProgressHUD.show()
        let logInUserHTTPRequestHeaderData = AvailableRequestsFromLoginViewController.loginUser
        firstly { () -> Promise<LoginData> in
            _sendAlamofireHTTPRequestTo(logInUserHTTPRequestHeaderData.url, method: logInUserHTTPRequestHeaderData.method
                , email: email, password: password)
            }
            .done { loginData in
                self.loginCredentials = loginData
                print("Success: \(loginData)")
                self._navigateToHomeView()
            }
            .ensure {
                SVProgressHUD.dismiss()
            }.catch { [weak self] error in
                print("API failure: \(error)")
                self?._displayLoginFailedAlert()
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

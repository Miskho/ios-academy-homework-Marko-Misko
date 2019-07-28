//
//  NewEpisodeViewController.swift
//  TVShows
//
//  Created by Infinum on 23/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire
import PromiseKit
import SVProgressHUD

protocol NewEpisodeReloadTableViewDelegate: class {
    func newEpisodeAdded()
}

class NewEpisodeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var episodeTitleTextField: UITextField!
    @IBOutlet private weak var seasonNumberTextField: UITextField!
    @IBOutlet private weak var episodeNumberTextField: UITextField!
    @IBOutlet private weak var episodeDescriptionTextField: UITextField!
    @IBOutlet private weak var episodeImage: UIImageView!
    
    // MARK: - Properties
    private weak var newEpisodeDelegate: NewEpisodeReloadTableViewDelegate?
    private var loginCredentials: LoginData?
    private var show: TVShow?
    private var episodeTitle: String?
    private var seasonNumber: String?
    private var episodeNumber: String?
    private var episodeDescription: String?
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = "Add episode"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(didSelectCancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(didSelectAddShow)
        )
        
        let pink = UIColor(rgb: 0xFF758C)
        navigationItem.leftBarButtonItem?.tintColor = pink
        navigationItem.rightBarButtonItem?.tintColor = pink
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Public methods
    func configureBeforeNavigating(with show: TVShow, credentials: LoginData, delegate: NewEpisodeReloadTableViewDelegate) {
        loginCredentials = credentials
        self.show = show
        newEpisodeDelegate = delegate
    }
    
    // MARK: - Private methods
    @objc private func didSelectAddShow() {
        _registerNewEpisode()
    }
    
    @objc private func didSelectCancel() {
        _navigateToShowDetailsViewController()
    }
    
    private func _navigateToShowDetailsViewController() {        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func _registerNewEpisode() {
        let headers = ["Authorization": loginCredentials!.token]
        
        guard let episodeTitle = episodeTitleTextField.text,
            let seasonNumber = seasonNumberTextField.text,
            let episodeNumber = episodeNumberTextField.text,
            let episodeDescription = episodeDescriptionTextField.text,
            !episodeTitle.isEmpty,
            !seasonNumber.isEmpty,
            !episodeNumber.isEmpty,
            !episodeDescription.isEmpty
            else {
                _displaySimpleDisposableAlertUsing(UIAlertController(title: "Could not add new episode", message: "Please provide all fields below for registering new episode.", preferredStyle: .alert))
                return
        }
        
        Alamofire
            .request(
                "https://api.infinum.academy/api/episodes",
                method: .post,
                parameters: [
                    "showId": show!.id,
                    "mediaId": "X",
                    "title": episodeTitle,
                    "description": episodeDescription,
                    "episodeNumber": episodeNumber,
                    "season": seasonNumber
                ],
                encoding: JSONEncoding.default,
                headers: headers
            ).validate()
            .responseDecodable(Episode.self, keyPath: "data")
            .done { [weak self] _ in
                self?.newEpisodeDelegate?.newEpisodeAdded()
                self?._navigateToShowDetailsViewController()
            }.catch { [weak self] _ in
                self?._displaySimpleDisposableAlertUsing(UIAlertController(title: "Could not add new episode", message: "Please check the validity of provided data for registering new episode.", preferredStyle: .alert))
        }
        
    }
    
    private func _displaySimpleDisposableAlertUsing(_ alertController: UIAlertController) {
        let OKAction = UIAlertAction(title: "Ok", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: - UIColor extension for creating colors using hexadecimal notation
extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
}

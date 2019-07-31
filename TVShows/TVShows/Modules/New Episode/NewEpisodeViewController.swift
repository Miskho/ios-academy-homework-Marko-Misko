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
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = "Add episode"
        _configureNavigationBarAndItems()
    }
    
    // MARK: - Public methods
    func configureBeforeNavigating(with show: TVShow, credentials: LoginData, delegate: NewEpisodeReloadTableViewDelegate) {
        loginCredentials = credentials
        self.show = show
        newEpisodeDelegate = delegate
    }
    
    // MARK: - Private methods
    @objc private func didSelectAddShow() {
        _addNewEpisode()
    }
    
    @objc private func didSelectCancel() {
        _navigateToShowDetailsViewController()
    }
    
    private func _navigateToShowDetailsViewController() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func _configureNavigationBarAndItems() {
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
    }
    
    private func _addNewEpisode() {
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
        _sendRequestForRegisteringNewEpisode(named: episodeTitle,
                description: episodeDescription,
                number: episodeNumber,
                season: seasonNumber)
            .done { [weak self] _ in
                guard let self = self else { return }
                self.newEpisodeDelegate?.newEpisodeAdded()
                self._navigateToShowDetailsViewController()
            }.catch { [weak self] _ in
                self?._displaySimpleDisposableAlertUsing(UIAlertController(title: "Could not add new episode", message: "Please check the validity of provided data for registering new episode.", preferredStyle: .alert))
        }
    }
    
    private func _sendRequestForRegisteringNewEpisode(
                        named episodeTitle: String,
                        description episodeDescription: String,
                        number episodeNumber: String,
                        season seasonNumber: String) -> Promise<Episode> {
        let headers = ["Authorization": loginCredentials!.token]
        return Alamofire
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
                headers: headers)
            .validate()
            .responseDecodable(Episode.self, keyPath: "data")
    }
    
    private func _displaySimpleDisposableAlertUsing(_ alertController: UIAlertController) {
        let OKAction = UIAlertAction(title: "Ok", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

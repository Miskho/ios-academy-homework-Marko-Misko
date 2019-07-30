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

class NewEpisodeViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet private weak var episodeTitleTextField: UITextField!
    @IBOutlet private weak var seasonNumberTextField: UITextField!
    @IBOutlet private weak var episodeNumberTextField: UITextField!
    @IBOutlet private weak var episodeDescriptionTextField: UITextField!
    @IBOutlet private weak var episodeImage: UIImageView!
    @IBOutlet private weak var loadImageButton: UIButton!
    
    // MARK: - Properties
    private weak var newEpisodeDelegate: NewEpisodeReloadTableViewDelegate?
    private var loginCredentials: LoginData?
    private var show: TVShow?
    private let imagePicker = UIImagePickerController()
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        _configureNavigationBarAndItems()
    }
    
    // MARK: - IB Actions
    @IBAction func loadImageButtonTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
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
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func _configureNavigationBarAndItems() {
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
    }
    
    private func _addNewEpisode() {
        SVProgressHUD.show()
        
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
        let headers = ["Authorization": loginCredentials!.token]
        let image = episodeImage.image ?? UIImage.init()
        
        firstly {
            _uploadImageOnAPI(image, token: headers)
            }.then { [weak self] (request: UploadRequest) -> Promise<Media> in
                guard let self = self else { return Promise(error: NSError()) }
                return self._processUploadRequest(request)
            }.then { [weak self] (media: Media) -> Promise<Episode> in
                guard let self = self else { return Promise(error: NSError()) }
                return self._uploadEpisode(media: media, named: episodeTitle, description: episodeDescription, number: episodeNumber, season: seasonNumber, token: headers)
            }.done { [weak self] _ in
                guard let self = self else { return }
                self.newEpisodeDelegate?.newEpisodeAdded()
                self._navigateToShowDetailsViewController()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch { [weak self] _ in
                self?._displaySimpleDisposableAlertUsing(UIAlertController(title: "Could not add new episode", message: "Please check the validity of provided data for registering new episode.", preferredStyle: .alert))
        }
    }
    
    private func _uploadEpisode(media: Media,
                                named episodeTitle: String,
                                description episodeDescription: String,
                                number episodeNumber: String,
                                season seasonNumber: String,
                                token: [String : String]) -> Promise<Episode> {
        return Alamofire
            .request(
                "https://api.infinum.academy/api/episodes",
                method: .post,
                parameters: [
                    "showId": show!.id,
                    "mediaId": media.id,
                    "title": episodeTitle,
                    "description": episodeDescription,
                    "episodeNumber": episodeNumber,
                    "season": seasonNumber
                ],
                encoding: JSONEncoding.default,
                headers: token)
            .validate()
            .responseDecodable(Episode.self, keyPath: "data")
    }
    
    private func _uploadImageOnAPI(_ image: UIImage, token: [String : String]) -> Promise<UploadRequest> {
        return Promise<UploadRequest> { seal in
            Alamofire
                .upload(multipartFormData: { multipartFormData in
                    multipartFormData.append(image.pngData()!,
                                             withName: "file",
                                             fileName: "image.png",
                                             mimeType: "image/png")
                }, to: "https://api.infinum.academy/api/media",
                   method: .post,
                   headers: token) { result in
                    switch result {
                    case .success(let uploadRequest, _, _):
                        print(result)
                        seal.fulfill(uploadRequest)
                    case .failure(let encodingError):
                        seal.reject(encodingError)
                    }
            }
        }
    }
    
    private func _processUploadRequest(_ uploadRequest: UploadRequest) -> Promise<Media> {
        return Promise<Media> { seal in
            uploadRequest
                .responseDecodableObject(keyPath: "data") { (response:
                    DataResponse<Media>) in
                    switch response.result {
                    case .success(let media):
                        seal.fulfill(media)
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
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

// MARK: - UIImagePickerControllerDelegate Methods
extension NewEpisodeViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            _setupImageOverButton(pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func _setupImageOverButton(_ pickedImage: UIImage) {
        episodeImage.contentMode = .scaleAspectFit
        episodeImage.image = pickedImage
        let layer = CAShapeLayer()
        layer.frame = .zero
        loadImageButton.layer.mask = layer
    }
    
}

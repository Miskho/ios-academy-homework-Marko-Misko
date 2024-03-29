//
//  EpisodeDetailsViewController.swift
//  TVShows
//
//  Created by Infinum on 28/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire
import PromiseKit
import SVProgressHUD
import Kingfisher

class EpisodeDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var episodeNameLabel: UILabel!
    @IBOutlet private weak var episodeImage: UIImageView!
    @IBOutlet private weak var episodeAndSeasonNumberLabel: UILabel!
    @IBOutlet private weak var episodeDescriptionLabel: UILabel!
    
    // MARK: - Properties
    private var loginCredentials: LoginData?
    private var episode: Episode?
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupEpisodeDetailsViewController()
        _setupGradient()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Outlet actions
    @IBAction private func backToShowDetailsButtonPressed(_ sender: Any) {
        _navigateToShowDetailsViewController()
    }
    
    @IBAction private func commentsButtonPressed(_ sender: Any) {
        _navigateToCommentsViewController()
    }
    
    // MARK: - Public methods
    func configureBeforeNavigating(with episode: Episode, credentials: LoginData) {
        loginCredentials = credentials
        self.episode = episode
    }
    
    // MARK: - Private methods
    private func _setupGradient() {
        let gradient = CAGradientLayer()
        gradient.frame = episodeImage.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        gradient.locations = [0.8, 1]
        
        let gradImageView = UIImageView(image: gradient.createGradientImage())
        view.addSubview(gradImageView)
        gradImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gradImageView.leftAnchor.constraint(equalTo: episodeImage.leftAnchor),
            gradImageView.topAnchor.constraint(equalTo: episodeImage.topAnchor),
            gradImageView.rightAnchor.constraint(equalTo: episodeImage.rightAnchor),
            gradImageView.bottomAnchor.constraint(equalTo: episodeImage.bottomAnchor),
            ])
    }
    
    private func _setupEpisodeDetailsViewController() {
        SVProgressHUD.show()
        
        firstly { () -> Promise<Episode> in
            _fetchEpisodeDetails()
            }.done { [weak self] in
                self?.episode = $0
                self?._fillInEpisodeDetails()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch {
                print("API failure: \($0)")
        }
    }
    
    private func _fetchEpisodeDetails() -> Promise<Episode> {
        let headers = ["Authorization": loginCredentials!.token]
        return Alamofire
            .request(
                "https://api.infinum.academy/api/episodes/\(episode!.id)",
                method: .get,
                encoding: JSONEncoding.default,
                headers: headers
            ).validate()
            .responseDecodable(Episode.self, keyPath: "data")
    }
    
    private func _fillInEpisodeDetails() {
        
        let url = URL(string: "https://api.infinum.academy\(episode!.imageUrl)")
        let processor = DownsamplingImageProcessor(size: episodeImage.frame.size)
        episodeImage.kf.indicatorType = .activity
        episodeImage.kf.setImage(
            with: url,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        
        episodeNameLabel.text = episode!.title
        episodeAndSeasonNumberLabel.text = "S" + episode!.season + " Ep" + episode!.episodeNumber
        episodeDescriptionLabel.text = episode!.description
    }
    
    private func _navigateToShowDetailsViewController() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func _navigateToCommentsViewController() {
        let commentsStoryboard = UIStoryboard(name: "Comments", bundle: nil)
        let commentsViewController = commentsStoryboard.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        commentsViewController.configureBeforeNavigating(with: episode!, credentials: loginCredentials!)
        
        let navigationController = UINavigationController(rootViewController: commentsViewController)
        present(navigationController, animated: true)
    }
    
}

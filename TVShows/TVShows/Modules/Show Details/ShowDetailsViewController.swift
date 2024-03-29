//
//  ShowDetailsViewController.swift
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

class ShowDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var episodesTableView: UITableView!
    
    // MARK: - Properties
    private let refreshControl = UIRefreshControl()
    private var show: TVShow?
    private var loginCredentials: LoginData?
    private var showDetails: ShowDetails?
    private var episodes = [Episode]()
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupShowDetailsViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Outlet actions
    @IBAction private func backToHomeButtonPressed(_ sender: Any) {
        _navigateToHomeViewController()
    }
    
    @IBAction private func newEpisodeButtonPressed(_ sender: Any) {
        _navigateToNewEpisodeViewController()
    }
    
    @IBAction private func likeButtonPressed(_ sender: Any) {
        _updateLikesCount(increment: true)
    }
    
    @IBAction private func dislikeButtonPressed(_ sender: Any) {
        _updateLikesCount(increment: false)
    }
    
    private func _updateLikesCount(increment: Bool) {
        let headers = ["Authorization": loginCredentials!.token]
        let urlSufix = increment ? "like" : "dislike"
        Alamofire
            .request(
                "https://api.infinum.academy/api/shows/\(show!.id)/\(urlSufix)",
                method: .post,
                encoding: JSONEncoding.default,
                headers: headers
            ).validate()
            .responseDecodable(ShowDetailsLikeable.self)
            .done { [weak self] in
                if let detailsCell = self?.episodesTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ShowInfoTableViewCell {
                    detailsCell.setLikesCount(to: $0.likesCount)
                }
            }.catch {
                print("API failure: \($0)")
        }
    }
    
    // MARK: - Public methods
    func configureBeforeNavigating(with show: TVShow, credentials: LoginData) {
        loginCredentials = credentials
        self.show = show
    }
    
    // MARK: - Private methods
    private func _setupShowDetailsViewController() {
        SVProgressHUD.show()
        
        firstly { () -> Promise<ShowDetails> in
            _fetchShowDetails()
            }.then { [weak self] (showDetails: ShowDetails) -> Promise<[Episode]> in
                self?.showDetails = showDetails
                return self!._fetchEpisodes()
            }.done { [weak self]  in
                guard let self = self else { return }
                self.episodes = $0
                self._displayShowDetails()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch {
                print("API failure: \($0)")
        }
    }
    
    private func _fetchShowDetails() -> Promise<ShowDetails> {
        let headers = ["Authorization": loginCredentials!.token]
        return Alamofire
            .request(
                "https://api.infinum.academy/api/shows/\(show!.id)",
                method: .get,
                encoding: JSONEncoding.default,
                headers: headers
            ).validate()
            .responseDecodable(ShowDetails.self, keyPath: "data")
    }
    
    private func _fetchEpisodes() -> Promise<[Episode]> {
        let headers = ["Authorization": loginCredentials!.token]
        return Alamofire
            .request(
                "https://api.infinum.academy/api/shows/\(show!.id)/episodes",
                method: .get,
                encoding: JSONEncoding.default,
                headers: headers
            ).validate()
            .responseDecodable([Episode].self, keyPath: "data")
    }
    
    private func _displayShowDetails() {
        _setupTableView()
        
        episodesTableView.reloadData()
    }
    
    private func _setupTableView() {
        episodesTableView.estimatedRowHeight = 110
        episodesTableView.rowHeight = UITableView.automaticDimension
        episodesTableView.tableFooterView = UIView()
        episodesTableView.allowsSelection = true
        
        episodesTableView.delegate = self
        episodesTableView.dataSource = self
        
        if #available(iOS 10.0, *) {
            episodesTableView.refreshControl = refreshControl
        } else {
            episodesTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshEpisodesData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshEpisodesData(_ sender: Any) {
        _fetchEpisodes()
            .done { [weak self]  in
                guard let self = self else { return }
                self.episodes = $0
                self._displayShowDetails()
                self.refreshControl.endRefreshing()
            }.catch {
                print("API failure: \($0)")
        }
    }
    
    private func _navigateToNewEpisodeViewController() {
        let newEpisodeStoryboard = UIStoryboard(name: "NewEpisode", bundle: nil)
        let newEpisodeViewController = newEpisodeStoryboard.instantiateViewController(withIdentifier: "NewEpisodeViewController") as! NewEpisodeViewController
        newEpisodeViewController.configureBeforeNavigating(with: show!, credentials: loginCredentials!, delegate: self)
        
        let navigationController = UINavigationController(rootViewController:
            newEpisodeViewController)
        present(navigationController, animated: true)
    }
    
    private func _navigateToHomeViewController() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    private func _navigateToEpisodeDetailsViewController(with episode: Episode) {
        let episodeDetailsStoryboard = UIStoryboard(name: "EpisodeDetails", bundle: nil)
        let episodeDetailsViewController = episodeDetailsStoryboard.instantiateViewController(withIdentifier: "EpisodeDetailsViewController") as! EpisodeDetailsViewController
        episodeDetailsViewController.configureBeforeNavigating(with: episode, credentials: loginCredentials!)
        
        let navigationController = UINavigationController(rootViewController:
            episodeDetailsViewController)
        present(navigationController, animated: true)
    }
    
}


// MARK: - UITableView
extension ShowDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let selectedEpisodeCell = tableView.cellForRow(at: indexPath) as? EpisodeTableViewCell {
            selectedEpisodeCell.navigateToButtonsEpisode()
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.episodes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return [delete]
    }
}


extension ShowDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ShowInfoTableViewCell.self), for: indexPath) as! ShowInfoTableViewCell
            cell.configure(with: showDetails!, episodesCount: episodes.count)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EpisodeTableViewCell.self), for: indexPath) as! EpisodeTableViewCell
            cell.configure(with: episodes[indexPath.row - 1]) { [unowned self] in
                let selectedEpisode = self.episodes[indexPath.row - 1]
                self._navigateToEpisodeDetailsViewController(with: selectedEpisode)
            }
            
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension ShowDetailsViewController: NewEpisodeReloadTableViewDelegate {
    
    func newEpisodeAdded() {
        SVProgressHUD.show()
        
        firstly {
            return _fetchEpisodes()
            }.done { [weak self] in
                self?.episodes = $0
                self?.episodesTableView.reloadData()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch {
                print("API failure: \($0)")
        }
    }
    
}

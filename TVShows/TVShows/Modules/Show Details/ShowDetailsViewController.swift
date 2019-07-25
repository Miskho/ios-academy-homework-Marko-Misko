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
    
    @IBOutlet private weak var episodesTableView: UITableView!
    
    var show: TVShow?
    var loginCredentials: LoginData?
    private var showDetails: ShowDetails?
    private var episodes = [Episode]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        _setupShowDetailsViewController()
    }
    
    
    @IBAction func backToHomeButtonPressed(_ sender: Any) {
        _navigateToHomeViewController()
    }
    
    @IBAction func newEpisodeButtonPressed(_ sender: Any) {
        _navigateToNewEpisodeViewController()
    }
    
    
    private func _setupShowDetailsViewController() {
        SVProgressHUD.show()
        
        firstly { () -> Promise<ShowDetails> in
            _fetchShowDetails()
            }.then { [weak self] (showDetails: ShowDetails) -> Promise<[Episode]> in
                self?.showDetails = showDetails
                return self!._fetchEpisodes()
            }.done { [weak self]  in
                self?.episodes = $0
                self?._displayShowDetails()
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
        
        episodesTableView.delegate = self
        episodesTableView.dataSource = self
    }
    
    private func _navigateToNewEpisodeViewController() {
        let newEpisodeStoryboard = UIStoryboard(name: "NewEpisode", bundle: nil)
        let newEpisodeViewController = newEpisodeStoryboard.instantiateViewController(withIdentifier: "NewEpisodeViewController") as! NewEpisodeViewController
        newEpisodeViewController.loginCredentials = loginCredentials
        newEpisodeViewController.show = show
        
        let navigationController = UINavigationController(rootViewController:
            newEpisodeViewController)
        present(navigationController, animated: true)
    }
    
    private func _navigateToHomeViewController() {
        navigationController?.popViewController(animated: true)
    }
    
}


// MARK: - UITableView
extension ShowDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
            cell.configure(with: episodes[indexPath.row])
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension ShowDetailsViewController: NewEpisodeReloadTableViewDelegate {
    
    func newEpisodeAdded() {
        episodesTableView.reloadData()
    }
    
}
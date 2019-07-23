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
    
    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var showDescriptionLabel: UILabel!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var episodesTableView: UITableView!
    @IBOutlet weak var newEpisodeButton: UIButton!
    
    var show: TVShow?
    var loginCredentials: LoginData?
    var showDetails: ShowDetails?
    var episodes = [Episode]()
    
    
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
                "https://api.infinum.academy/api/shows/\(String(describing: show!.id))",
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
                "https://api.infinum.academy/api/shows/\(String(describing: show!.id))/episodes",
                method: .get,
                encoding: JSONEncoding.default,
                headers: headers
            ).validate()
            .responseDecodable([Episode].self, keyPath: "data")
    }
    
    private func _displayShowDetails() {
        showTitleLabel.text = show?.title
        showDescriptionLabel.text = showDetails?.description
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
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EpisodeTableViewCell.self), for: indexPath) as! EpisodeTableViewCell
        
        cell.configure(with: episodes[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

extension ShowDetailsViewController: NewEpisodeReloadTableViewDelegate {
    
    func newEpisodeAdded() {
        episodesTableView.reloadData()
    }
    
}

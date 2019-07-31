//
//  HomeViewController.swift
//  TVShows
//
//  Created by Infinum on 15/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire
import PromiseKit
import SVProgressHUD
import Kingfisher
import KeychainAccess

final class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    private let listIcon = UIImage(named: "ic-listview")
    private let gridIcon = UIImage(named: "ic-gridview")
    private var tvShows = [TVShow]()
    private var loginCredentials: LoginData?
    private var listLayoutFlag = true
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupTableView()
        _setupCollectionView()
        _displayTVShows()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _setupNavigationBarAndItems()
    }
    
    // MARK: - Public methods
    func configureBeforeNavigating(with credentials: LoginData) {
        loginCredentials = credentials
    }
    
    // MARK: - Private methods
    @objc private func logoutActionHandler() {
        _deleteUserFromPersistance()
        _navigateToLoginViewController()
    }
    
    @objc private func changeLayoutActionHandler() {
        listLayoutFlag.toggle()
        navigationItem.rightBarButtonItem?.image = listLayoutFlag ? gridIcon : listIcon
        tableView.isHidden = !listLayoutFlag
        collectionView.isHidden = listLayoutFlag
    }

    private func _setupNavigationBarAndItems() {
        let logoutItem = UIBarButtonItem.init(image: UIImage(named: "ic-logout"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(logoutActionHandler))
        navigationItem.leftBarButtonItem = logoutItem
        navigationItem.leftBarButtonItem?.tintColor = .darkGray
        
        let changeLayoutItem = UIBarButtonItem.init(image: UIImage(named: "ic-gridview"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(changeLayoutActionHandler))
        navigationItem.rightBarButtonItem = changeLayoutItem
        navigationItem.rightBarButtonItem?.tintColor = .darkGray

    }
    
    private func _deleteUserFromPersistance() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsConstants.Keys.rememberMePressed.rawValue)

        let keychain = Keychain(service: KeychainConstants.loginKeychain.rawValue)
        keychain[KeychainConstants.Keys.rememberedEmail.rawValue] = nil
        keychain[KeychainConstants.Keys.rememberedPassword.rawValue] = nil
    }
    
    private func _setupTableView() {
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func _setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    // Side effect: assigns the data fetched via API call to the property
    // tvShows, effectively causing the tableView to be reloaded
    private func _displayTVShows() {
        SVProgressHUD.show()
        
        firstly { () -> Promise<[TVShow]> in
            let headers = ["Authorization": loginCredentials!.token]
            return Alamofire
                .request(
                    "https://api.infinum.academy/api/shows",
                    method: .get,
                    encoding: JSONEncoding.default,
                    headers: headers
                ).validate()
                .responseDecodable([TVShow].self, keyPath: "data")
            }.done() { [weak self]  in
                guard let self = self else { return }
                print("Success: \($0)")
                self.tvShows = $0
                self.tableView.reloadData()
                self.collectionView.reloadData()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch {
                print("API failure: \($0)")
        }
    }
    
    private func _navigateToLoginViewController() {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        navigationController?.setViewControllers([loginViewController], animated: true)
    }
    
    private func _navigateToShowDetailsViewController(showing show: TVShow) {
        let showDetailsStoryboard = UIStoryboard(name: "ShowDetails", bundle: nil)
        let showDetailsViewController = showDetailsStoryboard.instantiateViewController(withIdentifier: "ShowDetailsViewController") as! ShowDetailsViewController
        showDetailsViewController.configureBeforeNavigating(with: show, credentials: loginCredentials!)
        
        navigationController?.pushViewController(showDetailsViewController, animated: true)
    }
    
}

// MARK: - UITableView
extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        _navigateToShowDetailsViewController(showing: tvShows[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.tvShows.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
     
        return [delete]
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tvShows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TVShowTableViewCell.self), for: indexPath) as! TVShowTableViewCell
        
        cell.configure(with: tvShows[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

// MARK: - UICollectionView
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        _navigateToShowDetailsViewController(showing: tvShows[indexPath.row])
    }
    
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tvShows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TVShowCollectionViewCell.self), for: indexPath) as! TVShowCollectionViewCell
        
        cell.configure(with: tvShows[indexPath.row])
        return cell
    }

}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: 1.5 * widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

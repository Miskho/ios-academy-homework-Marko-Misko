//
//  CommentsViewController.swift
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
import DZNEmptyDataSet

class CommentsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var commentsTableView: UITableView!
    @IBOutlet weak var newCommentTextField: UITextField!
    @IBOutlet weak var postButton: UIButton!
    
    // MARK: - Properties
    private var loginCredentials: LoginData?
    private var episode: Episode?
    private var comments = [Comment]()
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _setupCommentsViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "ic-navigate-back"),
            style: .plain,
            target: self,
            action: #selector(didSelectBack)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - IBActions
    @IBAction func postCommentButtonTapped(_ sender: Any) {
        _postNewComment()
    }
    
    // MARK: - Public methods
    func configureBeforeNavigating(with episode: Episode, credentials: LoginData) {
        loginCredentials = credentials
        self.episode = episode
    }
    
    // MARK: - Private methods
    @objc private func didSelectBack() {
        _navigateToEpisodeDetailsViewController()
    }
    
    private func _navigateToEpisodeDetailsViewController() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func _setupCommentsViewController() {
        SVProgressHUD.show()
        
        _fetchComments()
            .done { [weak self]  in
                self?.comments = $0
                self?._displayComments()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch {
                print("API failure: \($0)")
        }
    }
    
    private func _postNewComment() {
        guard
            let comment = newCommentTextField.text,
            let episodeId = episode?.id,
            !comment.isEmpty
            else {
                _displaySimpleDisposableAlertUsing(UIAlertController(title: "Could not add new comment", message: "Please fill in the comment text field for adding new comment.", preferredStyle: .alert))
                return
        }
        firstly {
            _sendRequestForPostingComment(comment, episodeId: episodeId)
            }.then { [weak self] _ -> Promise<[Comment]> in
                guard let self = self else {
                    return Promise(error: NSError())
                }
                return self._fetchComments()
            }.done { [weak self] in
                guard let self = self else { return }
                self.comments = $0
                self.commentsTableView.reloadData()
            }.catch {
                print("API error: \($0)")
        }
    }
    
    private func _displayComments() {
        _setupTableView()
        commentsTableView.reloadData()
    }
    
    private func _setupTableView() {
        commentsTableView.estimatedRowHeight = 110
        commentsTableView.rowHeight = UITableView.automaticDimension
        commentsTableView.tableFooterView = UIView()
        commentsTableView.allowsSelection = false
        
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.emptyDataSetSource = self
        commentsTableView.emptyDataSetDelegate = self
    }
    
    private func _sendRequestForPostingComment(_ comment: String, episodeId: String) -> Promise<Comment> {
        let headers = ["Authorization": loginCredentials!.token]
        return Alamofire
            .request(
                "https://api.infinum.academy/api/comments",
                method: .post,
                parameters: [
                    "text": comment,
                    "episodeId": episodeId
                ],
                encoding: JSONEncoding.default,
                headers: headers
            ).validate()
            .responseDecodable(Comment.self, keyPath: "data")
    }
    
    private func _fetchComments() -> Promise<[Comment]> {
        let headers = ["Authorization": loginCredentials!.token]
        return Alamofire
            .request(
                "https://api.infinum.academy/api/episodes/\(episode!.id)/comments",
                method: .get,
                encoding: JSONEncoding.default,
                headers: headers
            ).validate()
            .responseDecodable([Comment].self, keyPath: "data")
    }
    
    private func _displaySimpleDisposableAlertUsing(_ alertController: UIAlertController) {
        let OKAction = UIAlertAction(title: "Ok", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableView
extension CommentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.comments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return [delete]
    }
}


extension CommentsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CommentTableViewCell.self), for: indexPath) as! CommentTableViewCell
        cell.configure(with: comments[indexPath.row])
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension CommentsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    // Add description/subtitle on empty dataset
    func description(forEmptyDataSet _: UIScrollView!) -> NSAttributedString! {
        let str = "Sorry, we don't have any comments yet. \n Be first who will write review."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    // Add your image
    func image(forEmptyDataSet _: UIScrollView!) -> UIImage! {
        return UIImage(named: "img-placehoder-comments")
    }
    
}

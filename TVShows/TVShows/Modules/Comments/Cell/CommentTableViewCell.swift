//
//  CommentTableViewCell.swift
//  TVShows
//
//  Created by Infinum on 28/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var userImage: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var commentContentLabel: UILabel!

    // MARK: - UITableViewCell
    override func prepareForReuse() {
        super.prepareForReuse()
        userImage.image = nil
        usernameLabel.text = nil
        commentContentLabel.text = nil
    }
    
}

// MARK: - Configure
extension CommentTableViewCell {
    
    func configure(with comment: Comment) {
        userImage.image = UIImage(named: "img-placehoder-user\(Int.random(in: 1 ... 3))")
        usernameLabel.text = comment.userEmail
        commentContentLabel.text = comment.text
    }
    
}

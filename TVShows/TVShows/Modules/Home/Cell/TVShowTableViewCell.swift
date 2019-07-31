//
//  TVShowHomeTableViewCell.swift
//  TVShows
//
//  Created by Infinum on 21/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit

class TVShowTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: - UITableViewCell methods
   override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
}

// MARK: - Configure
extension TVShowTableViewCell {
    func configure(with show: TVShow) {
        titleLabel.text = show.title
    }
}


//
//  TVShowHomeTableViewCell.swift
//  TVShows
//
//  Created by Infinum on 21/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit

class TVShowTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = nil
    }
    
}

// MARK: - Configure
extension TVShowTableViewCell {
    func configure(with item: TVShow) {
        title.text = item.title
    }
}


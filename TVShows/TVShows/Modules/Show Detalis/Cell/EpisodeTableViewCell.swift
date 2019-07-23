//
//  EpisodeTableViewCell.swift
//  TVShows
//
//  Created by Infinum on 23/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit

class EpisodeTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = nil
    }
    
}

// MARK: - Configure
extension EpisodeTableViewCell {
    func configure(with episode: Episode) {
        title.text = episode.title
    }
}


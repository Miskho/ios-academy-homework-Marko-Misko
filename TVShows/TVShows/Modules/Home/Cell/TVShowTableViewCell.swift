//
//  TVShowHomeTableViewCell.swift
//  TVShows
//
//  Created by Infinum on 21/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit
import Kingfisher

class TVShowTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var showImage: UIImageView!

    // MARK: - UITableViewCell methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        showImage.image = nil
    }
    
}

// MARK: - Configure
extension TVShowTableViewCell {
    
    func configure(with show: TVShow) {
        titleLabel.text = show.title
        
        let url = URL(string: "https://api.infinum.academy" + show.imageUrl)
        let processor = DownsamplingImageProcessor(size: showImage.frame.size) >> RoundCornerImageProcessor(cornerRadius: 20)
        showImage.kf.indicatorType = .activity
        showImage.kf.setImage(
            with: url,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
    }
    
}

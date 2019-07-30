//
//  TVShowCollectionViewCell.swift
//  TVShows
//
//  Created by Infinum on 28/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit
import Kingfisher

class TVShowCollectionViewCell: UICollectionViewCell {
    
    
    // MARK: - Outlets
    @IBOutlet private weak var showImage: UIImageView!
    
    // MARK: - UITableViewCell methods
   override func prepareForReuse() {
        super.prepareForReuse()
        showImage.image = nil
    }
    
}

// MARK: - Configure
extension TVShowCollectionViewCell {
    
    func configure(with show: TVShow) {
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

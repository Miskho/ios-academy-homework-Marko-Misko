//
//  ShowInfoTableViewCell.swift
//  TVShows
//
//  Created by Infinum on 25/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit
import Kingfisher

class ShowInfoTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var showImage: UIImageView!
    @IBOutlet private weak var showTitleLabel: UILabel!
    @IBOutlet private weak var showDescriptionLabel: UILabel!
    @IBOutlet private weak var episodeCountLabel: UILabel!
    
    // MARK: - Properties
    private let gradient = CAGradientLayer()
    
    // MARK: - UITableViewCell
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = showImage.bounds
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = UITableViewCell.SelectionStyle.none
        
        gradient.frame = showImage.bounds
        gradient.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.1, 0.9, 1]
        showImage.layer.mask = gradient
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        showImage.image = nil
        showTitleLabel.text = nil
        showDescriptionLabel.text = nil
        episodeCountLabel.text = nil
    }
    
}

// MARK: - Configure
extension ShowInfoTableViewCell {
    
    func configure(with details: ShowDetails, episodesCount: Int) {
        
        let url = URL(string: "https://api.infinum.academy\(details.imageUrl)")
        let processor = DownsamplingImageProcessor(size: showImage.frame.size)
        showImage.kf.indicatorType = .activity
        showImage.kf.setImage(
            with: url,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        
        showTitleLabel.text = details.title
        showDescriptionLabel.text = details.description
        episodeCountLabel.text = String(episodesCount)
    }
    
}

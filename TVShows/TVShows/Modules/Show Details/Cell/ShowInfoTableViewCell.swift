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
    @IBOutlet private weak var likesCountLabel: UILabel!
    
    // MARK: - UITableViewCell
   override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = UITableViewCell.SelectionStyle.none
        let gradient = CAGradientLayer()
        gradient.frame = showImage.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        gradient.locations = [0.8, 1]

        let gradImageView = UIImageView(image: gradient.createGradientImage())
    
        addSubview(gradImageView)
        gradImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gradImageView.leftAnchor.constraint(equalTo: showImage.leftAnchor),
            gradImageView.topAnchor.constraint(equalTo: showImage.topAnchor),
            gradImageView.rightAnchor.constraint(equalTo: showImage.rightAnchor),
            gradImageView.bottomAnchor.constraint(equalTo: showImage.bottomAnchor),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        showImage.image = nil
        showTitleLabel.text = nil
        showDescriptionLabel.text = nil
        episodeCountLabel.text = nil
        likesCountLabel.text = nil
    }
    
    // MARK: - Public methods
    func setLikesCount(to likesCount: Int) {
        likesCountLabel.text = String(likesCount)
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
        likesCountLabel.text = String(details.likesCount)
    }
    
}

//
//  EpisodeTableViewCell.swift
//  TVShows
//
//  Created by Infinum on 23/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit

class EpisodeTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet private weak var seasonAndEpisodeLabel: UILabel!
    @IBOutlet private weak var episodeTitleLabel: UILabel!
    @IBOutlet private weak var episodeDetailsButton: UIButton!
    
    // MARK: - Properties
    private var episodeDetailsButtonAction : (() -> ())?
    
    // MARK: - UITableViewCell methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.episodeDetailsButton.addTarget(self, action: #selector(episodeDetailsButtonTapped(_:)), for: .touchUpInside)
    }
    
   override func prepareForReuse() {
        super.prepareForReuse()
        episodeTitleLabel.text = nil
        seasonAndEpisodeLabel.text = nil
    }
    
    // MARK: - IBActions
    @IBAction func episodeDetailsButtonTapped(_ sender: UIButton){
        episodeDetailsButtonAction?()
    }
    
}

// MARK: - Configure
extension EpisodeTableViewCell {
    
    func configure(with episode: Episode, action: (() -> ())? = nil) {
        seasonAndEpisodeLabel.text = "S" + episode.season + " Ep" + episode.episodeNumber
        episodeTitleLabel.text = !episode.title.isEmpty ? episode.title : " "
        episodeDetailsButtonAction = action
    }
    
}


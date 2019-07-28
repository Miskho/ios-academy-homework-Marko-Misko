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
    
    // MARK: - UITableViewCell methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        episodeTitleLabel.text = nil
        seasonAndEpisodeLabel.text = nil
    }
    
    // MARK: - IB Actions
    @IBAction func episodeDetailsPressed(_ sender: Any) {
        _navigateToEpisodeDetails()
    }
    
    private func _navigateToEpisodeDetails() {
        
    }
    
}

// MARK: - Configure
extension EpisodeTableViewCell {
    func configure(with episode: Episode) {
        seasonAndEpisodeLabel.text = "S" + episode.season + " Ep" + episode.episodeNumber
        episodeTitleLabel.text = !episode.title.isEmpty ? episode.title : " "
    }
}


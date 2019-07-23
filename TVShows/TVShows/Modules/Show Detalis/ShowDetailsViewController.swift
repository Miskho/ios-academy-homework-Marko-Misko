//
//  ShowDetailsViewController.swift
//  TVShows
//
//  Created by Infinum on 23/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit

class ShowDetailsViewController: UIViewController {
    
    @IBOutlet weak var showDescriptionLabel: UILabel!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var episodesTableView: UITableView!
    @IBOutlet weak var newEpisodeButton: UIButton!
    
    var showID: TVShow?
    var loginCredentials: LoginData?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _setupShowDetails()
    }
    
    private func _setupShowDetails() {

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

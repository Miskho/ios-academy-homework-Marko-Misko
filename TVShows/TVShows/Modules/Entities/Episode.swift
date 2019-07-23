//
//  Episode.swift
//  TVShows
//
//  Created by Infinum on 23/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import Foundation
import Alamofire

struct Episode: Codable {
    let id: String
    let title: String
    let description: String
    let imageUrl: String
    let episodeNumber: Int
    let season: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case imageUrl
        case episodeNumber
        case season
    }
}

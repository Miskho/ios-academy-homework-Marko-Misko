//
//  ShowDetails.swift
//  TVShows
//
//  Created by Infinum on 23/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import Foundation
import Alamofire

struct ShowDetails: Codable {
    let showId: String
    let title: String
    let description: String
    let episodeNumber: Int
    let season: Int
    let type: String
    let id: String
    let likesCount: Int
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case showId
        case title
        case description
        case episodeNumber
        case season
        case type
        case id = "_id"
        case likesCount
        case imageUrl
    }
}

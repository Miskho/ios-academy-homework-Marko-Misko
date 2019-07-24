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
    let type: String
    let title: String
    let description: String
    let id: String
    let likesCount: Int
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case title
        case description
        case id = "_id"
        case likesCount
        case imageUrl
    }
}

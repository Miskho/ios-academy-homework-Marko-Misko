//
//  Comment.swift
//  TVShows
//
//  Created by Infinum on 29/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import Foundation
import Alamofire

struct Comment: Codable {
    let text: String
    let episodeId: String
    let userId: String?
    let userEmail: String
    let type: String?
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case text
        case episodeId
        case userId
        case userEmail
        case type
        case id = "_id"
    }
}

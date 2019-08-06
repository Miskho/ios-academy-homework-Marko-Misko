//
//  Media.swift
//  TVShows
//
//  Created by Infinum on 30/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import Foundation
import Alamofire

struct Media: Codable {
    let path: String
    let type: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case path
        case type
        case id = "_id"
    }
}

//
//  User.swift
//  TVShows
//
//  Created by Infinum on 16/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import Foundation
import Alamofire

struct User: Codable {
    let email: String
    let type: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case type
        case id = "_id"
    }
}

struct RememberedUser: Codable {
    let email: String
    let password: String
}

struct LoginData: Codable {
    let token: String
}

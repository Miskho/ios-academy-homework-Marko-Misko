//
//  Constants.swift
//  TVShows
//
//  Created by Infinum on 27/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import Foundation

enum UserDefaultsConstants {
    
    enum Keys: String {
        case rememberMePressed
    }
}

enum KeychainConstants: String {
    case loginKeychain
    
    enum Keys: String {
        case rememberedEmail
        case rememberedPassword
    }
}

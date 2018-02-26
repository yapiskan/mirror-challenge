//
//  AuthToken.swift
//  mirror-challenge
//
//  Created by Ali Ersöz on 2/25/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation

import ObjectMapper

final class AuthToken: ImmutableMappable {
    var string: String
    
    required init(map: Map) throws {
        string = try map.value("access_token")
    }
    
    func mapping(map: Map) {
        string >>> map["access_token"]
    }
}


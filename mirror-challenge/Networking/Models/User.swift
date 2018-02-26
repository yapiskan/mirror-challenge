//
//  Book.swift
//  mirror-challenge
//
//  Created by Ali Ersöz on 2/25/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

final class User: Object, Mappable, Persistable {
    @objc dynamic var id = 0
    @objc dynamic var username = ""
    @objc dynamic var age = 0
    @objc dynamic var height = 0
    @objc dynamic var likesJavascript = false
    @objc dynamic var magicNumber = 0
    @objc dynamic var magicHash = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: Int, username: String) {
        self.init()
        self.id = id
        self.username = username
    }
 	
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        username <- map["username"]
        age <- map["age"]
        height <- map["height"]
        likesJavascript <- map["likes_javascript"]
        magicNumber <- map["magic_number"]
        magicHash <- map["magic_hash"]
    }
}


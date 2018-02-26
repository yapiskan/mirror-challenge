//
//  UserDefaults+Extension.swift
//  mirror-challenge
//
//  Created by Ali Ersöz on 2/25/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let userId = DefaultsKey<Int?>("userId")
    static let username = DefaultsKey<String>("username")
}

//
//  Utility.swift
//  mirror-challenge
//
//  Created by Ali Ersöz on 2/25/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

// TODO: we should convert static variables to instance variables so it can be injectable.
class Utility {
    class var accessToken: String? {
        get {
        	return KeychainWrapper.standard.string(forKey: Constants.accessToken)
        }
        set {
            if let at = newValue {
            	KeychainWrapper.standard.set(at, forKey: Constants.accessToken)
            }
            else {
        		KeychainWrapper.standard.removeObject(forKey: Constants.accessToken)
            }
        }
    }
}

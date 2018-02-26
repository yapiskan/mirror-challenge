//
//  App.swift
//  mirror-challenge
//
//  Created by Ali Ersöz on 2/25/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation

final class App {
    private var injector = Injector()
    var router: AppRouter
    
    init() {
        router = injector.container.resolve(AppRouter.self)!
        router.injector = injector
    }
}

final class AppCache {
    static let shared = AppCache()
    
    var user: User?
}

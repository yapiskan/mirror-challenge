//
//  Injector.swift
//  mirror-challenge
//
//  Created by Ali Ersöz on 2/25/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import Swinject

final class Injector {
    let container: Container = {
        let container = Container()
        
        // AppRouter
        container.register(AppRouter.self) { _ in AppRouter() }.inObjectScope(.container)
        
        // Api
        container.register(ApiClientProtocol.self) { _ in ApiClient() }
        
        // Api
        container.register(PersisterProtocol.self) { _ in RealmPersister() }
        
        // View Models
        container.register(AuthViewModelProtocol.self) { r in
            AuthViewModel(apiClient: r.resolve(ApiClientProtocol.self)!, persister: r.resolve(PersisterProtocol.self)!)
        }
        
        container.register(AccountViewModelProtocol.self) { (r) in
            AccountViewModel(apiClient: r.resolve(ApiClientProtocol.self)!, persister: r.resolve(PersisterProtocol.self)!)
        }
        
        // View Controllers
        container.register(AuthViewController.self) { r in
            var vc = AuthViewController(viewModel: r.resolve(AuthViewModelProtocol.self)!, router: r.resolve(AppRouter.self)!)
            
            return vc
        }
        
        container.register(AccountViewController.self) { (r) in
            var vc = AccountViewController(viewModel: r.resolve(AccountViewModelProtocol.self)!, router:
                r.resolve(AppRouter.self)!)
            return vc
        }
        
        container.register(EditAccountViewController.self) { (r, viewModel: AccountViewModelProtocol?) in
            let vm = viewModel ?? r.resolve(AccountViewModelProtocol.self)!
            var vc = EditAccountViewController(viewModel: vm, router: r.resolve(AppRouter.self)!)
            return vc
        }
        
        return container
    }()
}

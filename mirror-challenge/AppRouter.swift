//
//  AppDelegate.swift
//  mirror-challenge
//
//  Created by Ali Ersöz on 2/25/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import Swinject
import SwiftKeychainWrapper
import MBProgressHUD

final class AppRouter {
    var injector: Injector!
    private var navigationController: UINavigationController?
    private var _window: UIWindow?
    
	var window: UIWindow {
        if _window == nil {
            _window = UIWindow(frame: UIScreen.main.bounds)
            _window!.backgroundColor = UIColor.white
            _window!.rootViewController = entryViewController
            _window!.makeKeyAndVisible()
        }
        
		return _window!
	}
    
	var entryViewController: UINavigationController {
        if let _ = Utility.accessToken {
            navigationController = UINavigationController(rootViewController: injector.container.resolve(AccountViewController.self)!)
        }
        else {
            navigationController = UINavigationController(rootViewController: injector.container.resolve(AuthViewController.self)!)
        }
		
        return navigationController!
	}
    
    func routeToAuth() {
        navigationController = UINavigationController(rootViewController: resolveViewController(for: .auth))

        UIView.transition(with: self.window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.window.rootViewController = self.navigationController
        }, completion: nil)
    }
    
    func routeToHome() {
        navigationController = UINavigationController(rootViewController: resolveViewController(for: .account))
        
        UIView.transition(with: self.window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.window.rootViewController = self.navigationController
        }, completion: nil)
    }
	
    func navigate(screen: Screens) {
        let vc = resolveViewController(for: screen)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func alert(with title: String? = nil, message: String, actions: [(String, UIAlertActionStyle)] = [("OK", .default)], style: UIAlertControllerStyle = .alert, _ completion: ((Bool) -> ())? = nil) {
        let avc = UIAlertController(title: title, message: message, preferredStyle: style)
        for (i, action) in actions.enumerated() {
            avc.addAction(UIAlertAction(title: action.0, style: action.1, handler: { (action) in
                completion?(i == 0)
            }))
        }
        
        navigationController?.present(avc, animated: true, completion: nil)
    }
    
    func prompt(with title: String? = nil, message: String, placeholders:[String], actions: [(String, UIAlertActionStyle)], _ completion: ((Bool, [String?]?) -> ())? = nil) {
        let avc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for placeholder in placeholders {
            avc.addTextField { (tf) in
                tf.placeholder = placeholder
            }
        }
        
        for (i, action) in actions.enumerated() {
            avc.addAction(UIAlertAction(title: action.0, style: action.1, handler: { (action) in
                let info = avc.textFields?.map({ (tf) -> String? in
                    return tf.text
                })
                
                completion?(i == 0, info)
            }))
        }
    
        navigationController?.present(avc, animated: true, completion: nil)
    }
    
    func showHUD(message: String) {
        if let view = navigationController?.view {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.mode = .text
            hud.label.text = message
            hud.hide(animated: true, afterDelay: 2)
        }
    }
    
    private func resolveViewController(for screen: Screens) -> BaseViewController {
        switch screen {
        case .auth:
            return injector.container.resolve(AuthViewController.self)!
        case .account:
            let vc = injector.container.resolve(AccountViewController.self)!
            return vc
        case .editAccount:
            return injector.container.resolve(EditAccountViewController.self)!
        }
    }
}

enum Screens {
    case auth
    case account
    case editAccount
}

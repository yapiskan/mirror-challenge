//
//  AuthViewModel.swift
//  mirror-challenge
//
//  Created by Ali Ersöz on 2/25/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import SwiftyUserDefaults

protocol AuthViewModelProtocol {
    var user: User? {get set}
    
    func login(username: String, password: String, _ completion: @escaping (AuthResult) -> ())
    func signUp(username: String, password: String, _ completion: @escaping (AuthResult) -> ())
}

class AuthViewModel: AuthViewModelProtocol {
    private let apiClient: ApiClientProtocol
    private var persister: PersisterProtocol
    
    var user: User?
    var token: String?
    
    init(apiClient: ApiClientProtocol, persister: PersisterProtocol) {
        self.apiClient = apiClient
        self.persister = persister
    }
    
    func login(username: String, password: String, _ completion: @escaping (AuthResult) -> ()) {
        let error = AuthResult(username: username, password: password)
        if error != .success {
            completion(error)
            return
        }
        
        apiClient.login(username: username, password: password) { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let token):
                strongSelf.token = token.string
                Utility.accessToken = strongSelf.token!
                if let user: User = strongSelf.persister.first(isIncluded: { $0.username == username }) {
                    strongSelf.user = user
                    Defaults[.userId] = user.id
                	completion(.success)
                }
                else {
                    completion(.userNotFound)
                }
                
            case.failure(_):
                completion(.generic)
            }
        }
    }
    
    func signUp(username: String, password: String, _ completion: @escaping (AuthResult) -> ()) {
        let error = AuthResult(username: username, password: password)
        if error != .success {
            completion(error)
            return
        }
        
        apiClient.singUp(username: username, password: password) { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let user):
                strongSelf.user = user
                strongSelf.persister.save(object: user)
                Defaults[.userId] = user.id
                completion(.success)
            case.failure(_):
                completion(.generic)
            }
        }
    }
}

enum AuthResult: Error {
    case usernameEmpty
    case passwordEmpty
    case minPasswordLength
    case minUsernameLength
    case userNotFound
    case generic
    case success
    
    init(username: String, password: String) {
        if username.count == 0 { self = .usernameEmpty; return }
        if username.count < 3 { self = .minUsernameLength; return }
        if password.count == 0 { self = .passwordEmpty; return  }
        if password.count < 6 { self = .minPasswordLength; return }
        
        self = .success
    }
    
    var isSuccess: Bool {
        return self == .success
    }
    
    var errorMessage: String {
        switch self {
        case .usernameEmpty:
            return "Username is empty"
        case .passwordEmpty:
            return "Password is empty"
        case .minPasswordLength:
            return "Min password length is 6"
        case .minUsernameLength:
            return "Min username legth is 3"
        case .userNotFound:
            return "User not found"
        case .generic:
            return "Make sure username/password is correct"
        case .success:
            return ""
        }
    }
}

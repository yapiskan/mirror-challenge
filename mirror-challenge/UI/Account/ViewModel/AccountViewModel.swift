//
//  AccountViewModel.swift
//  mirror-challenge
//
//  Created by Ali Ersöz on 2/25/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import SwiftKeychainWrapper

protocol AccountViewModelProtocol {
    var user: User {get set}
    var onDataUpdate: (() -> ())? {get set}
    
    func startFetchingUser()
    func updateUser(height: Int, age: Int, likesJavascript: Bool, _ completion: (Bool) -> ())
    func convertToImperial(height: Int) -> String
    func logout()
}

class AccountViewModel: AccountViewModelProtocol {
    private let apiClient: ApiClientProtocol
    var persister: PersisterProtocol
    var user: User
    var onDataUpdate: (() -> ())?
    var timer: Timer?

    init(apiClient: ApiClientProtocol, persister: PersisterProtocol) {
        self.apiClient = apiClient
        self.persister = persister
        self.user = User()
        
        if let id = Defaults[.userId], let u: User = persister.get(id: id) {
            self.user = u
        }
    }
    
    func startFetchingUser() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [unowned self] (timer) in
            self.fetchUser()
        })
    }
    
    func logout() {
        timer?.invalidate()
        timer = nil
        Defaults[.userId] = nil
        Utility.accessToken = nil
    }
    
    private func fetchUser() {
        apiClient.fetchUser(id: user.id) { [weak self] (response) in
            guard let strongSelf = self else { return }
            
            debugPrint("fetch user response: \(response)")
            switch response {
            case .success(let user):
                strongSelf.user = user
                strongSelf.persister.save(object: user)
                strongSelf.onDataUpdate?()
            case .failure(let error):
                debugPrint("error: \(error)")
            }
        }
    }
    
    func updateUser(height: Int, age: Int, likesJavascript: Bool, _ completion: (Bool) -> ()) {
        apiClient.updateUser(id: user.id, height: height, age: age, likesJavascript: likesJavascript) { [weak self] (response) in
            guard let strongSelf = self else { return }
            
            debugPrint("fetch user response: \(response)")
            switch response {
            case .success(let user):
                strongSelf.user = user
                strongSelf.persister.save(object: user)
            case .failure(let error):
                debugPrint("error: \(error)")
            }
        }
    }
    
    func convertToImperial(height: Int) -> String {
        let measurement = Measurement(value: Double(height), unit: UnitLength.centimeters)
        let inches = Int(measurement.converted(to: .inches).value)
        let remainingInches = inches % 12
        let feet = inches / 12
        return "\(feet)' \(remainingInches)''"
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

//
//  ApiClient.swift
//  mirror-challenge
//
//  Created by Ali Ersöz on 2/23/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import SwiftKeychainWrapper

protocol ApiClientProtocol {
    func login(username: String, password: String, _ completion: @escaping (Result<AuthToken>) -> ())
    func singUp(username: String, password: String, _ completion: @escaping (Result<User>) -> ())
    func fetchUser(id: Int, _ completion: @escaping (Result<User>) -> ())
    func updateUser(id: Int, height: Int, age: Int, likesJavascript: Bool, _ completion: @escaping (Result<User>) -> ())
}

final class ApiClient: ApiClientProtocol {
    func login(username: String, password: String, _ completion: @escaping (Result<AuthToken>) -> ()) {
        let params = ["username": username, "password": password]
        Api.request(method: .post, path: "/auth", params: params).responseObject(completionHandler: { (response: DataResponse<AuthToken>) in
            completion(response.result)
        })
    }
    
    func singUp(username: String, password: String, _ completion: @escaping (Result<User>) -> ()) {
        let params = ["username": username, "password": password]
        Api.request(method: .post, path: "/users", params: params).responseObject(completionHandler: { (response:DataResponse<User>) in
            debugPrint("response: \(response)")
            completion(response.result)
        })
    }
    
    func fetchUser(id: Int, _ completion: @escaping (Result<User>) -> ()) {
        Api.authRequest(method: .get, path: "/users/\(id)").responseObject(completionHandler: { (response:DataResponse<User>) in
            debugPrint("response: \(response)")
            completion(response.result)
        })
    }
    
    func updateUser(id: Int, height: Int, age: Int, likesJavascript: Bool, _ completion: @escaping (Result<User>) -> ()) {
        Api.authRequest(method: .patch, path: "/users/\(id)").responseObject(completionHandler: { (response:DataResponse<User>) in
            debugPrint("response: \(response)")
            completion(response.result)
        })
    }
}

final class Api {
    static let basePopularPostsUrl = "https://mirror-ios-test.herokuapp.com"
    
    class func request(method: HTTPMethod, path: String, params: Parameters? = nil) -> DataRequest {
        let url: String = "\(basePopularPostsUrl)\(path)"
        return Alamofire.request(url, method: method, parameters: params, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: nil)
    }
    
    class func authRequest(method: HTTPMethod, path: String, params: Parameters? = nil) -> DataRequest {
        let url: String = "\(basePopularPostsUrl)\(path)"
        let token = Utility.accessToken
        let headers = ["Authorization": "JWT \(token ?? "")"]
        return Alamofire.request(url, method: method, parameters: params, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: headers)
    }
}

class APIError: Mappable {
    var message: String?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        message <- map["error"]
    }
    
    func getMessage() -> String? {
        return self.message
    }
}

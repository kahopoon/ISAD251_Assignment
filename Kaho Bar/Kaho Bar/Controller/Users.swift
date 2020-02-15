//
//  Users.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class Users {
    
    private let controllerPath:String
    
    public init() {
        self.controllerPath = "\(Constant.API_ENDPOINT)\(Constant.API_ROUTE)\(Constant.API_USER)"
    }
    
    public func login(email: String, password: String, completion: @escaping (_ user: User?) -> Void) {
        let requestParams = JSON(["password":password])
        let apiRequst = APIRequest(url: "\(self.controllerPath)/\(email)", method: .get, parameters: requestParams)
        APIManager.sharedInstance.request(apiRequst) { (responseJSON) in
            if let user = User(responseJSON) {
                completion(user)
            } else {
                completion(nil)
            }
            return
        }
    }
    
    public func login(currentUser: User, completion: @escaping (_ user: User?) -> Void) {
        let requestParams = JSON(["accessToken":currentUser.accessToken])
        let apiRequst = APIRequest(url: "\(self.controllerPath)/\(currentUser.email)", method: .get, parameters: requestParams)
        APIManager.sharedInstance.request(apiRequst) { (responseJSON) in
            if let user = User(responseJSON) {
                completion(user)
            } else {
                completion(nil)
            }
            return
        }
    }
    
    public func register(email: String, name: String, password: String, approvalCode:String?, completion: @escaping (_ user: User?) -> Void) {
        var requestParams = JSON(["email":email, "name":name, "password":password])
        if approvalCode != nil {
            requestParams["approvalCode"].stringValue = approvalCode!
        }
        let apiRequst = APIRequest(url: "\(self.controllerPath)", method: .post, parameters: requestParams)
        APIManager.sharedInstance.request(apiRequst) { (responseJSON) in
            if let user = User(responseJSON) {
                completion(user)
            } else {
                completion(nil)
            }
            return
        }
    }
    
    public func update(currentUser: User, newEmail: String, name: String, password: String, completion: @escaping (_ user: User?) -> Void) {
        let requestParams = JSON(["accessToken":currentUser.accessToken, "email":newEmail, "name":name, "password":password])
        let apiRequst = APIRequest(url: "\(self.controllerPath)/\(currentUser.email)", method: .put, parameters: requestParams)
        APIManager.sharedInstance.request(apiRequst) { (responseJSON) in
            if let user = User(responseJSON) {
                completion(user)
            } else {
                completion(nil)
            }
            return
        }
    }
    
    public func remove(currentUser: User, completion: @escaping (_ user: User?) -> Void) {
        let requestParams = JSON(["accessToken":currentUser.accessToken])
        let apiRequst = APIRequest(url: "\(self.controllerPath)/\(currentUser.email)", method: .delete, parameters: requestParams)
        APIManager.sharedInstance.request(apiRequst) { (responseJSON) in
            if let user = User(responseJSON) {
                completion(user)
            } else {
                completion(nil)
            }
            return
        }
    }

}

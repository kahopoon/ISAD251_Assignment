//
//  User.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import Foundation
import SwiftyJSON


public struct User {
    
    public let name:String
    public let email:String
    public let role:Role
    public let accessToken:String
    public let status:Status
    
    public let errorCode:String?
    public let errorDescription:String?
    
    public enum Role {
        case user
        case administrator
    }
    
    public enum Status {
        case active
        case inactive
    }
    
    public init?(_ json: JSON) {
        guard json != JSON.null else {
            return nil
        }
        self.name = json["name"].stringValue
        self.email = json["email"].stringValue
        self.accessToken = json["accessToken"].stringValue
        switch json["role"].stringValue {
        case "ADMIN":
            self.role = .administrator
        default:
            self.role = .user
        }
        switch json["status"].stringValue {
        case "ACTIVE":
            self.status = .active
        default:
            self.status = .inactive
        }
        
        self.errorCode = json["code"].string
        self.errorDescription = json["description"].string
    }

}

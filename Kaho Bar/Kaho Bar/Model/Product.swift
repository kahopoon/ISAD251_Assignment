//
//  Product.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import Foundation
import SwiftyJSON


public struct Product {
    
    public let id:String
    public let name:String
    public let type:ProductType
    public let description:String
    public let imagePath:String
    public let status:Status
    public let price:Double
    
    public let errorCode:String?
    public let errorDescription:String?
    
    public enum ProductType {
        case alcohol
        case nonAlcohol
        case snack
    }
    
    public enum Status {
        case active
        case inactive
    }
    
    public init?(_ json: JSON) {
        guard json != JSON.null else {
            return nil
        }
        self.id = json["productId"].stringValue
        self.name = json["name"].stringValue
        self.description = json["description"].stringValue
        self.imagePath = json["imagePath"].stringValue
        self.price = json["price"].doubleValue
        switch json["type"].stringValue {
        case "ALCOHOL":
            self.type = .alcohol
        case "NON_ALCOHOL":
            self.type = .nonAlcohol
        default:
            self.type = .snack
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

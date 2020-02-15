//
//  Order.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import Foundation
import SwiftyJSON


public struct Order {
    
    public let id:String
    public let totalPrice:Double
    public let createDatetime:String
    public let updateDatetime:String
    public let orderProducts:[OrderProduct]
    public let status:Status
    
    public let errorCode:String?
    public let errorDescription:String?
    
    public enum Status {
        case created
        case inProgress
        case cancelled
        case delivered
    }
    
    public init?(_ json: JSON) {
        guard json != JSON.null else {
            return nil
        }
        self.id = json["orderId"].stringValue
        self.totalPrice = json["totalPrice"].doubleValue
        self.createDatetime = json["createDatetime"].stringValue
        self.updateDatetime = json["updateDatetime"].stringValue
        switch json["status"].stringValue {
        case "CREATED":
            self.status = .created
        case "IN_PROGRESS":
            self.status = .inProgress
        case "DELIVERED":
            self.status = .delivered
        default:
            self.status = .cancelled
        }
        var products:[OrderProduct] = []
        for productJSON in json["orderProducts"].arrayValue {
            if let product = OrderProduct(productJSON) {
                products.append(product)
            }
        }
        self.orderProducts = products
        
        self.errorCode = json["code"].string
        self.errorDescription = json["description"].string
    }

}

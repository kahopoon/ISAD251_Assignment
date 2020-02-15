//
//  OrderProduct.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import Foundation
import SwiftyJSON

public class OrderProduct {
    
    public let id:String
    public var quantity:Int
    public var subTotalPrice:Double
    
    public var product:Product?
    
    public init?(_ json: JSON) {
        guard json != JSON.null else {
            return nil
        }
        self.id = json["productId"].stringValue
        self.quantity = json["quantity"].intValue
        self.subTotalPrice = json["subTotalPrice"].doubleValue
    }
    
    public init(id: String, quantity: Int, product: Product) {
        self.id = id
        self.quantity = quantity
        self.subTotalPrice = product.price * Double(quantity)
        self.product = product
    }

}

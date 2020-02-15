//
//  Orders.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class Orders {
    
    private let controllerPath:String
    
    public init() {
        self.controllerPath = "\(Constant.API_ENDPOINT)\(Constant.API_ROUTE)\(Constant.API_ORDER)"
    }

    public func get(currentUser: User, orderId: String, completion: @escaping (_ order: Order?) -> Void) {
        let requestParams = JSON(["accessToken":currentUser.accessToken])
        let apiRequst = APIRequest(url: "\(self.controllerPath)/\(orderId)", method: .get, parameters: requestParams)
        APIManager.sharedInstance.request(apiRequst) { (responseJSON) in
            if let order = Order(responseJSON) {
                completion(order)
            } else {
                completion(nil)
            }
            return
        }
    }
    
    public func get(currentUser: User, completion: @escaping (_ product: [Order]) -> Void) {
        let requestParams = JSON(["accessToken":currentUser.accessToken])
        let apiRequst = APIRequest(url: "\(self.controllerPath)", method: .get, parameters: requestParams)
        APIManager.sharedInstance.request(apiRequst) { (responseJSON) in
            var orders:[Order] = []
            for orderJSON in responseJSON.arrayValue {
                if let order = Order(orderJSON) {
                    orders.append(order)
                }
            }
            completion(orders.sorted(by: { $0.updateDatetime > $1.updateDatetime }))
            return
        }
    }
    
    public func create(currentUser: User, orderProducts:[OrderProduct], completion: @escaping (_ Order: Order?) -> Void) {

        var orderProductsDict:[[String:Any]] = []
        for orderProduct in orderProducts {
            var orderProductDict:[String:Any] = [:]
            orderProductDict["productId"] = orderProduct.id
            orderProductDict["quantity"] = orderProduct.quantity
            orderProductsDict.append(orderProductDict)
        }
        let requestParams = JSON(["accessToken":currentUser.accessToken,"orderProducts":JSON(orderProductsDict)])
        
        let apiRequst = APIRequest(url: "\(self.controllerPath)", method: .post, parameters: requestParams)
        APIManager.sharedInstance.request(apiRequst) { (responseJSON) in
            if let order = Order(responseJSON) {
                completion(order)
            } else {
                completion(nil)
            }
            return
        }
    }
 
    public func update(currentUser: User, orderId:String, orderStatus: Order.Status?, orderProducts:[OrderProduct], completion: @escaping (_ order: Order?) -> Void) {
        var orderProductsDict:[[String:Any]] = []
        for orderProduct in orderProducts {
            var orderProductDict:[String:Any] = [:]
            orderProductDict["productId"] = orderProduct.id
            orderProductDict["quantity"] = orderProduct.quantity
            orderProductsDict.append(orderProductDict)
        }
        var requestParams = JSON(["accessToken":currentUser.accessToken,"orderProducts":JSON(orderProductsDict)])
        if let status = orderStatus {
            switch status {
            case .delivered:
                requestParams["status"].stringValue = "DELIVERED"
            case .inProgress:
                requestParams["status"].stringValue = "IN_PROGRESS"
            case .cancelled:
                requestParams["status"].stringValue = "CANCELLED"
            default:
                requestParams["status"].stringValue = "CREATED"
            }
        }
        
        let apiRequst = APIRequest(url: "\(self.controllerPath)/\(orderId)", method: .put, parameters: requestParams)
        APIManager.sharedInstance.request(apiRequst) { (responseJSON) in
            if let order = Order(responseJSON) {
                completion(order)
            } else {
                completion(nil)
            }
            return
        }
    }

    public func remove(currentUser: User, orderId: String, completion: @escaping (_ order: Order?) -> Void) {
        let requestParams = JSON(["accessToken":currentUser.accessToken])
        let apiRequst = APIRequest(url: "\(self.controllerPath)/\(orderId)", method: .delete, parameters: requestParams)
        APIManager.sharedInstance.request(apiRequst) { (responseJSON) in
            if let order = Order(responseJSON) {
                completion(order)
            } else {
                completion(nil)
            }
            return
        }
    }

}

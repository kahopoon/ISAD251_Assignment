//
//  Products.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class Products {
    
    private let controllerPath:String
    
    public init() {
        self.controllerPath = "\(Constant.API_ENDPOINT)\(Constant.API_ROUTE)\(Constant.API_PRODUCT)"
    }

    public func get(currentUser: User, productId: String, completion: @escaping (_ product: Product?) -> Void) {
        let requestParams = JSON(["accessToken":currentUser.accessToken])
        let apiRequst = APIRequest(url: "\(self.controllerPath)/\(productId)", method: .get, parameters: requestParams)
        APIManager.sharedInstance.request(apiRequst) { (responseJSON) in
            if let product = Product(responseJSON) {
                completion(product)
            } else {
                completion(nil)
            }
            return
        }
    }
    
    public func get(currentUser: User, completion: @escaping (_ product: [Product]) -> Void) {
        let requestParams = JSON(["accessToken":currentUser.accessToken])
        let apiRequst = APIRequest(url: "\(self.controllerPath)", method: .get, parameters: requestParams)
        APIManager.sharedInstance.request(apiRequst) { (responseJSON) in
            var products:[Product] = []
            for productJSON in responseJSON.arrayValue {
                if let product = Product(productJSON) {
                    products.append(product)
                }
            }
            completion(products)
            return
        }
    }
    
    public func create(currentUser: User, name: String, type: Product.ProductType, description: String, imagePath:String, price: Double, completion: @escaping (_ product: Product?) -> Void) {
        var requestParams = JSON(["accessToken":currentUser.accessToken, "name":name, "description":description, "imagePath":imagePath, "price":"\(price)", "status":"ACTIVE"])
        switch type {
        case .alcohol:
            requestParams["type"].stringValue = "ALCOHOL"
        case .nonAlcohol:
            requestParams["type"].stringValue = "NON_ALCOHOL"
        default:
            requestParams["type"].stringValue = "SNACK"
        }
        let apiRequst = APIRequest(url: "\(self.controllerPath)/", method: .post, parameters: requestParams)
        APIManager.sharedInstance.request(apiRequst) { (responseJSON) in
            if let product = Product(responseJSON) {
                completion(product)
            } else {
                completion(nil)
            }
            return
        }
    }
 
    public func update(currentUser: User, productId:String, name: String?, type: Product.ProductType?, description: String?, imagePath:String?, price: Double?, completion: @escaping (_ product: Product?) -> Void) {
        var requestParams = JSON(["accessToken":currentUser.accessToken])
        
        if let updatedName = name, updatedName.count > 0 {
            requestParams["name"].stringValue = updatedName
        }
        if let updatedType = type {
            switch updatedType {
            case .alcohol:
                requestParams["type"].stringValue = "ALCOHOL"
            case .nonAlcohol:
                requestParams["type"].stringValue = "NON_ALCOHOL"
            default:
                requestParams["type"].stringValue = "SNACK"
            }
        }
        if let updatedDescription = description {
            requestParams["description"].stringValue = updatedDescription
        }
        if let updateImagePath = imagePath {
            requestParams["imagePath"].stringValue = updateImagePath
        }
        if let updatedPrice = price {
            requestParams["price"].stringValue = String(format: "%.02f", updatedPrice)
        }
        
        let apiRequst = APIRequest(url: "\(self.controllerPath)/\(productId)", method: .put, parameters: requestParams)
        APIManager.sharedInstance.request(apiRequst) { (responseJSON) in
            if let product = Product(responseJSON) {
                completion(product)
            } else {
                completion(nil)
            }
            return
        }
    }
    
    public func remove(currentUser: User, productId: String, completion: @escaping (_ product: Product?) -> Void) {
        let requestParams = JSON(["accessToken":currentUser.accessToken])
        let apiRequst = APIRequest(url: "\(self.controllerPath)/\(productId)", method: .delete, parameters: requestParams)
        APIManager.sharedInstance.request(apiRequst) { (responseJSON) in
            if let product = Product(responseJSON) {
                completion(product)
            } else {
                completion(nil)
            }
            return
        }
    }

}

//
//  CacheManager.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import Foundation

public class CacheManager {
    
    public static let sharedInstance = CacheManager()
    private init() {
    }
    
    public var currentUser:User?
    public var accessToken:String? {
        return self.currentUser?.accessToken
    }
    
    public var cartOrderProducts:[OrderProduct] = []
    public var cartUpdateOrderId:String?
    
    public var products:[Product] = []
    public var orders:[Order] = []

}

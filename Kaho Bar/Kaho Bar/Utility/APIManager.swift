//
//  APIManager.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class APIManager {
    
    public static let sharedInstance = APIManager()
    private init() {
        
    }
    
    public func request(_ request: APIRequest?, completion: @escaping(_ responseJSON: JSON) -> Void) {
        guard let apiRequest = request else {
            completion(JSON.null)
            return
        }
        AF.request(apiRequest.url, method: apiRequest.method, parameters: apiRequest.parameters, encoder: apiRequest.encoder).responseJSON { (response) in
            switch response.result {
            case let .success(value):
                let responseJSON = JSON(value)
                completion(responseJSON)
            case .failure(_):
                completion(JSON.null)
            }
            return
        }
    }

}

//
//  APIRequest.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public struct APIRequest {
    
    public let url:String
    public let method:HTTPMethod
    public let parameters:JSON?
    public let encoder:ParameterEncoder
    
    public init?(url: String?, method: HTTPMethod?, parameters: JSON?) {
        guard   let requestURL = url, !requestURL.isEmpty,
                let requestMethod = method else {
                return nil
        }
        self.url = requestURL
        self.method = requestMethod
        self.parameters = parameters
        switch requestMethod {
        case .get:
            self.encoder = URLEncodedFormParameterEncoder.default
        default:
            self.encoder = JSONParameterEncoder.default
        }
    }
    
}

//
//  GetCustomerDetailsService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 4/13/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GetCustomerDetailsService: RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.GET, "\(Configuration.serverUrl)\(Configuration.getCustomerDetailsUrl)", encoding: .JSON, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
}

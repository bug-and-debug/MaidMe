//
//  ChangePasswordService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 4/13/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChangePasswordService : RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.POST, "\(Configuration.serverUrl)\(Configuration.updateCustomerPasswordUrl)", parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getParams(currentPass: String, newPass: String) -> [String: AnyObject] {
        return [
            "current_password": currentPass,
            "new_password": newPass
        ]
    }
    
}
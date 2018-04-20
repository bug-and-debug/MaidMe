//
//  RegisterAPI.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/15/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RegisterService: RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.POST, "\(Configuration.serverUrl)\(Configuration.registerUrl)", parameters: parameters, encoding: .JSON) {
                response in
                completionHandler(response)
                
            }
    }
}

//
//  UpdateCustomerDetailsService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 4/13/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UpdateCustomerDetailsService : RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.POST, "\(Configuration.serverUrl)\(Configuration.updateCustomerDetailsUrl)", parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getParams(customer: Customer) -> [String: AnyObject] {
        return [
            "first_name": customer.firstName!,
            "last_name": customer.lastName!,
            "phone": customer.phone!,
            "default_area": (customer.defaultArea?.areaID == nil ? "" : customer.defaultArea!.areaID)
        ]
    }
    
}

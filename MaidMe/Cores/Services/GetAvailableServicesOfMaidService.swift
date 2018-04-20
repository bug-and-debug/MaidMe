//
//  GetAvailableServicesOfMaidService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 5/23/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GetAvailableServicesOfMaidService: RequestManager {
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.POST, "\(Configuration.serverUrl)\(Configuration.availableServicesOfMaidUrl)", parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getParams(maidID: String) -> [String: AnyObject] {
        return [
            "maid_id": maidID
        ]
    }
}

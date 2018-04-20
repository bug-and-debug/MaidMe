//
//  RemoveAddressService.swift
//  MaidMe
//
//  Created by Vo Minh Long on 1/10/17.
//  Copyright © 2017 SmartDev. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

class RemoveAddress: RequestManager{
    override func request(method: Alamofire.Method? = nil, _ URLString: URLStringConvertible? = nil, parameters: [String : AnyObject]?, encoding: ParameterEncoding? = nil, headers: [String : String]? = nil, completionHandler: Response<AnyObject, NSError> -> ()) {
        super.request(.POST, "\(Configuration.serverUrl)\(Configuration.removeAddressUrl)",parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
            response in
            completionHandler(response)
        }
    }
    func getRemoveAddressParams(addressRemove: Address?) -> [String:String] {
    return [
        "address_id" : (addressRemove?.addressID)!
        ]
    }
}

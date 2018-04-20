//
//  CancelABookingService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 4/20/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CancelABookingService : RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.POST, "\(Configuration.serverUrl)\(Configuration.cancelABookingUrl)", parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getParams(bookingID: String) -> [String: AnyObject] {
        return [
            "booking_id": bookingID
        ]
    }
}
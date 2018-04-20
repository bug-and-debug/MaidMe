//
//  RebookGetTimeOptionsService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 5/24/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RebookGetTimeOptionsService: RequestManager {
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.POST, "\(Configuration.serverUrl)\(Configuration.rebookingGetTimeOptionsUrl)", parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getParams(booking: Booking,addressID: String?) -> [String: AnyObject] {
        return [
            "maid_id": booking.workerID!,
            "service_id": booking.service!.serviceID,
            "address_id": (addressID == nil ? "" : addressID)!,
            "working_hours": booking.hours
        ]
    }
}

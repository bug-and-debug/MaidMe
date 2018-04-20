//
//  FetchAllUpcomingBookingsService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 4/14/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FetchAllUpcomingBookingsService: RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.POST, "\(Configuration.serverUrl)\(Configuration.fetchAllUpcomingBookingUrl)", parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
        }
    }
    func getParams() -> [String: AnyObject] {
        return [
            "from_date": NSDate().timeIntervalSince1970 * 1000
        ]
    }
    
    func getBookingList(list: JSON) -> [Booking] {
        var bookingList = [Booking]()
        
        for (_, dic) in list {
            let item = Booking(bookingDic: dic)
            if item.bookingID == nil {
                continue
            }
            
            bookingList.append(item)
        }
        
        return bookingList
    }
}

//
//  FetchBookingHistoryService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 5/13/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FetchBookingHistoryService : RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.POST, "\(Configuration.serverUrl)\(Configuration.bookingHistoryUrl)", parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getParams(count: Int, limit: Int) -> [String: AnyObject] {
        return [
            "load_time": count,
            "items_per_load": limit
        ]
    }
    
    func getBookingList(list: JSON) -> (total: Int, bookings: [Booking]) {
        var bookingList = [Booking]()
        
        let commentDic = list["bookings"]
        
        for (_, dic) in commentDic {
            let item = Booking(bookingDic: dic)
            if item.bookingID == nil {
                continue
            }
            
            bookingList.append(item)
        }
        
        return (list["total"].intValue, bookingList)
    }
}
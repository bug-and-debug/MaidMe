//
//  GetAllRatingsAndCommentsService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 5/11/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GetAllRatingsAndCommentsService : RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.POST, "\(Configuration.serverUrl)\(Configuration.getRatingsAndCommentsUrl)", parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getParams(maidID: String, fromDate: Double, limit: Int) -> [String: AnyObject] {
        return [
            "maid_id": maidID,
            "from_date": fromDate, //NSDate().timeIntervalSince1970 * 1000,//"\(fromDate)",
            "limit": limit
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
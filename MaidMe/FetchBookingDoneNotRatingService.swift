//
//  FetchBookingDoneNotRatingService.swift
//  MaidMe
//
//  Created by LuanVo on 5/5/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FetchBookingDoneNotRatingService: RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.GET, "\(Configuration.serverUrl)\(Configuration.getBookingDoneNotRatingUrl)", parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    
    func getBookingList(list: JSON) -> ([Rating]) {
        var bookingList = [Rating]()
        
        for (_, dic) in list {
            let item = Rating(ratingDic: dic)
            if item.ratingID == nil {
                continue
            }
            
            bookingList.append(item)
        }
        
        return bookingList
    }
}




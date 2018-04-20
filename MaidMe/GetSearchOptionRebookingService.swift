//
//  GetSearchOptionRebookingService.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 1/16/17.
//  Copyright © 2017 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GetSearchOptionRebookingService: RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
                          _ URLString: URLStringConvertible? = nil,
                            parameters: [String : AnyObject]?,
                            encoding: ParameterEncoding? = nil,
                            headers: [String : String]? = nil,
                            completionHandler: Response<AnyObject, NSError> -> ()) {
        super.request(.POST, "\(Configuration.serverUrl)/api/bookings/rebook/getOption", parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
            response in
            completionHandler(response)
        }
    }
    
    func getSearchOptionsForRebookingParams(booking: Booking) -> [String: String] {
        return ["booking_id" : booking.bookingID == nil ? "" : booking.bookingID!]
    }
    
    func getAddressList(list: JSON) -> [Address] {
        var addressList = [Address]()
        
        for (_, dic) in list["addresses"] {
            let item = Address(addressDic: dic)
            if item.addressID == nil {
                continue
            }
            
            addressList.append(item)
        }
        
        return addressList
    }
    
    func getServiceList(list: JSON ) -> [WorkingService] {
        var serviceList = [WorkingService]()
        for (_,dic) in list["services"] {
            let item = WorkingService(serviceDic: dic)
            if item.serviceID == nil {
                continue
            }
            serviceList.append(item)
        }
        return serviceList
        
    }
    
}
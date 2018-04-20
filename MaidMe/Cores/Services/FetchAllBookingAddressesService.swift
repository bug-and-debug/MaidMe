//
//  FetchAllBookingAddressesService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 4/6/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FetchAllBookingAddressesService: RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
		print(parameters)
            super.request(.GET, "\(Configuration.serverUrl)\(Configuration.fetchAllBookingAddressesUrl)", encoding: .JSON, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getAddressList(list: JSON) -> [Address] {
        var addressList = [Address]()
        
        for (_, dic) in list {
            let item = Address(addressDic: dic)
            if item.addressID == nil {
                continue
            }
            
            addressList.append(item)
        }
        
        return addressList
    }
}

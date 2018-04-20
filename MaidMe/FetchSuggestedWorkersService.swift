//
//  FetchSuggestedWorkersService.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 1/11/17.
//  Copyright © 2017 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class FetchSuggestedWorkerService: RequestManager {
    override func request(method: Alamofire.Method? = nil,
                          _ URLString: URLStringConvertible? = nil,
                            parameters: [String : AnyObject]?,
                            encoding: ParameterEncoding? = nil,
                            headers: [String : String]? = nil,
                            completionHandler: Response<AnyObject, NSError> -> ()) {
        super.request(.POST, "\(Configuration.serverUrl)\(Configuration.suggetedWorker)", parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
            response in
            completionHandler(response)
        }
    }

    func getSuggesstedWorkerList(list: JSON) -> [SuggesstedWorker] {
        var suggesetdWorkerList = [SuggesstedWorker]()
        
        for (_, dic) in list {
            let item = SuggesstedWorker(suggesstedWorkerDic: dic)
            if item.workerID == nil && item.firstName != nil {
                continue
            }
            
            suggesetdWorkerList.append(item)
        }
        
        return suggesetdWorkerList
    }
    
    func getSuggestionWorkerParams(address : Address) -> [String: AnyObject] {
        return [ "address" : [
            "building_name": address.buildingName ?? "",
            "apartment_no": address.apartmentNo ?? "",
            "floor_no": address.floorNo ?? "",
            "zip_po": address.zipPO ?? "",
            "area": address.area,
            "city": address.city ?? "",
            "emirate": address.emirate,
            "additional_details": address.additionalDetails ?? "",
            "country": "United Arab Emirates",
            "working_area_ref": address.workingArea_ref,
            
            ]]
    
    }

}

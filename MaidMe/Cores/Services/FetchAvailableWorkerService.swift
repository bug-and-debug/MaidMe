//
//  AvailableWorkerService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/11/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FetchAvailableWorkerService: RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
        super.request(.POST, "\(Configuration.serverUrl)\(Configuration.availableWorkerUrl)", parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
            response in
            completionHandler(response)
        }
    }
    
    func getWorkerList(list: JSON) -> [Worker] {
        var workerList = [Worker]()
        
        for (_, dic) in list {
            let item = Worker(workerDic: dic)
            if item.workerID == nil && item.firstName != nil {
                continue
            }
            
            workerList.append(item)
        }
        
        return workerList
    }
}

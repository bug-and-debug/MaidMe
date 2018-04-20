//
//  RemoveCardService.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 1/9/17.
//  Copyright © 2017 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class RemoveCardService: RequestManager {
    override func request(method: Alamofire.Method? = nil,
                          _ URLString: URLStringConvertible? = nil,
                            parameters: [String : AnyObject]?,
                            encoding: ParameterEncoding? = nil,
                            headers: [String : String]? = nil,
                            completionHandler: Response<AnyObject, NSError> -> ()) {
        super.request(.POST, "\(Configuration.serverUrl)\(Configuration.removeCardUrl)",parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
            response in
            completionHandler(response)
        }
    }
    
    
    
    func getRemoveCardParams(cardRemove: Card?) -> [String:String] {
        return [
            "id" : (cardRemove?.cardID)!,
            "card_id": (cardRemove?.cardPaymentID)!,
        ]
    }
}

//
//  DefaultsCardService.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 1/9/17.
//  Copyright © 2017 SmartDev. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON


class DefaultCardService: RequestManager {
    override func request(method: Alamofire.Method? = nil,
                          _ URLString: URLStringConvertible? = nil,
                            parameters: [String : AnyObject]?,
                            encoding: ParameterEncoding? = nil,
                            headers: [String : String]? = nil,
                            completionHandler: Response<AnyObject, NSError> -> ()) {
        super.request(.POST, "\(Configuration.serverUrl)\(Configuration.setDefaultCardUrl)",parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
            response in
            completionHandler(response)
        }
    }
    func getDefaultCardParams(card: Card?) -> [String:String] {
        return [
            "card_id": (card!.cardPaymentID)!,
        ]
    }
}


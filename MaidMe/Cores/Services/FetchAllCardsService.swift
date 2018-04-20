//
//  FetchAllCardsService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 4/1/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FetchAllCardsService: RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.GET, "\(Configuration.serverUrl)\(Configuration.fetchAllCardUrl)", encoding: .JSON, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getCardList(list: JSON) -> [Card] {
        var cardList = [Card]()
        
        for (_, dic) in list {
            let item = Card(cardDic: dic)
            if item.cardPaymentID == nil && item.cardID != nil {
                continue
            }
            
            cardList.append(item)
        }
        
        return cardList
    }
}


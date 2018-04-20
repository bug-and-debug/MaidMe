//
//  CreateNewTokenCardService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/29/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain
import StartSDK

class CreateNewTokenCardService: RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.POST, "\(Configuration.payfortUrl)", parameters: parameters, encoding: .JSON, headers: self.authenticatedHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getCardTokenParams(selectedCard: Card?, newCard: Card?) -> [String: String] {
        let card = (selectedCard == nil ? newCard : selectedCard)
        
        return [
            "number": card!.number!,
            "exp_month": "\(card!.expiryMonth)",
            "exp_year": "\(card!.expiryYear)",
            "cvc": card!.cvv!,
            "name": "",
        ]
    }
    
    func authenticatedHeader() -> [String: String] {
        var key = ""
        
        if let publicKey = SSKeychain.passwordForService(KeychainIdentifier.appService, account: KeychainIdentifier.payfortkey) {
            key = publicKey
        }
        
        /*if let data = key.dataUsingEncoding(NSUTF8StringEncoding) {
            encryptedKey = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        }*/
        
        let header = [
            Parameters.contentType: Parameters.jsonContentType,
            Parameters.authorization: Parameters.basic + key]
        
        return header
    }
    
    func startCard(card: Card) -> StartCard {
        return try! StartCard(cardholder: "maidme",
                              number: card.number!,
                              cvc: card.cvv!,
                              expirationMonth: card.expiryMonth,
                              expirationYear: card.expiryYear)
    }
    
    func getCardToken(card: StartCard, amount: NSNumber, completionHandler: (String?, NSError?) -> Void) {

        let start = Start(APIKey: PaymentKey.payfortApiKey)

        start.createTokenForCard(card, amount: amount.integerValue * 100, currency: "AED",
                                 successBlock: { (token) in
                                    completionHandler(token.tokenId, nil)
            },
                                 errorBlock: { (error) in
                                    completionHandler(nil, error)
            },cancelBlock: {})
        
    }
}

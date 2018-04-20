//
//  Card.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/3/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Card: Object {
    dynamic var cardPaymentID: String!
    dynamic var cardID: String!
	var brand: CardType?
	dynamic var brandInt: Int = 0
    dynamic var lastFourDigit: String!
    dynamic var number: String?
    dynamic var expiryMonth: Int = 0
    dynamic var expiryYear: Int = 0
    dynamic var ownerName: String!
    dynamic var cvv: String?
//    var cardLogo: UIImage?
	dynamic var cardLogoData: NSData?
    dynamic var country: String!
    dynamic var countryCode: String!
    dynamic var isDefault: Bool = true

	convenience init(type: CardType, last4: String, number: String, expiryMonth: Int, expiryYear: Int, ownerName: String, cvv: String, cardLogo: UIImage? = nil, country: String, countryCode: String, isDefault: Bool) {
		self.init()
		self.brand = type
        self.lastFourDigit = last4
        self.number = number
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.ownerName = ownerName
        self.cvv = cvv
//        self.cardLogo = cardLogo
        self.country = country
        self.countryCode = countryCode
        self.isDefault = false
		self.brandInt = self.brand!.rawValue
//		self.cardLogoData = UIImagePNGRepresentation(self.cardLogo!)
    }
    
    convenience init(cardDic: JSON) {
		self.init()
        self.cardPaymentID = cardDic["card_id"].string
        self.cardID = cardDic["id"].string
        self.brand = CardType.brand(cardDic["brand"].string)
        self.lastFourDigit = cardDic["last4"].string
        self.number = cardDic["description"].string
        self.expiryMonth = cardDic["exp_month"].intValue
        self.expiryYear = cardDic["exp_year"].intValue
        self.ownerName = cardDic["name"].string
        self.country = cardDic["country_name"].string
        self.countryCode = cardDic["country_code_name"].string
        self.isDefault = cardDic["default_card"].boolValue
//		self.cardLogoData = UIImagePNGRepresentation(self.cardLogo!)
    }
	
	override static func primaryKey() -> String? {
		return "cardID"
	}

}

extension Card {
    func getLastFourDigit() -> String {
		
		if number == nil {
			return "****"
		}
		
        let count = number!.characters.count
        var endingNumber = ""
        
        guard count >= 4 else {
            return endingNumber
        }
        
        for var i = count - 1; i >= count - 4; i -= 1 {
            let index = number!.startIndex.advancedBy(i)
            endingNumber = "\(number![index])" + endingNumber
        }
        
        return endingNumber
    }
}

enum CardType:Int {
    case Visa = 0
    case Master
    case Amex
    case Discover
    case Diners
    case JCB
    
    static func brand(rawValue: String?) -> CardType? {
        guard let code = rawValue else {
            return nil
        }
        
        switch(code) {
        case "visa": return .Visa
        case "mastercard": return .Master
        default: return nil
        }
    }
}

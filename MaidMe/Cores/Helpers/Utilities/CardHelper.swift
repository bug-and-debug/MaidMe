//
//  CardHelper.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/2/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit

class CardHelper: NSObject {
    class func getCardLogo(cardNumber: String, isSmall: Bool) -> UIImage? {
        let validator = CreditCardValidator()
        
        if !validator.validateString(cardNumber) {
            return nil
        }
        
        if let cardValidator = validator.typeFromString(cardNumber) {
            switch(cardValidator.type) {
            case .Visa:
                return UIImage(named: "visacard_small")
                
            case .Master:
                return UIImage(named: "mastercard_small")
                
            case .Amex:
                return UIImage(named: "card_amex_small")
                
            case .Diners:
                return UIImage(named: "card_diner_small")
                
            case .Discover:
                return UIImage(named: "card_discover_small")
                
            case .JCB:
                return UIImage(named: "card_jcb_small")
                
            default:
                break
            }
        }
        
        return nil
    }
    
    class func isValidCVV(cvv: String, cardNumber: String) -> Bool {
        var regrex: String = "^[0-9]{3}$"
        
        let validator = CreditCardValidator()
        
        if let cardValidator = validator.typeFromString(cardNumber) {
            if cardValidator.type == .Amex {
                regrex = "^[0-9]{4}$"
            }
        }
        
        return Validation.isValidRegex(cvv, expression: regrex)
    }
    
    class func isValidCardExpiryDate(expiryDate: NSDate) -> Bool {
        return !expiryDate.isLessThanCurrentMonth()
    }
    
    class func isValidExpiryDate(expiryMonth: Int, expiryYear: Int) -> Bool {
        let currentMonth = NSDate().getMonth()
        let currentYear = NSDate().getYear()
        
        if expiryYear > currentYear {
            return true
        }
            
        else if currentYear == expiryYear && expiryMonth >= currentMonth {
            return true
        }
        
        return false
    }
    
    class func showLastFourDigit(last4: String) -> String {
        var encodedNumber = ""
        
        for i in 0 ..< 12 {
            encodedNumber = encodedNumber + "*"
            
            if (i + 1) % 4 == 0 && i > 0 && i != 15 {
                encodedNumber += " "
            }
        }
        
        encodedNumber += last4
        
        return encodedNumber
    }
    
    class func hideCardNumber(number: String, numberOfHide: Int) -> String {
        let count = number.characters.count
        var encodedNumber = ""
        
        if count - numberOfHide <= 0 {
            return number
        }
        
        for i in 0 ..< count {
            if i < count - numberOfHide {
                encodedNumber = encodedNumber + "*"
            }
            else {
                let index = number.startIndex.advancedBy(i)
                encodedNumber = encodedNumber + "\(number[index])"
            }
            if (i + 1) % 4 == 0 && i > 0 && i != count - 1 {
                encodedNumber += " "
            }
        }
        
        return encodedNumber
    }
    
    class func reformatCardNumber(cardNumber: String?) -> String? {
        guard let number = cardNumber else {
            return cardNumber
        }
        
        let count = number.characters.count
        var encodedNumber = ""
        
        for i in 0 ..< count {
            let index = number.startIndex.advancedBy(i)
            encodedNumber = encodedNumber + "\(number[index])"
            
            if (i + 1) % 4 == 0 && i > 0 && i != count - 1 {
                encodedNumber += " "
            }
        }
        
        return encodedNumber
    }
    
    class func isValidData(newCard: Card) -> (isValid: Bool, title: String, message: String) {
        // Card owner name only allows characters.
      
        
        if !newCard.number!.isValidCreditCardNumber() {
            return (false, LocalizedStrings.invalidCardTitle, LocalizedStrings.invalidCardNumberMessage)
        }
        
        if !CardHelper.isValidExpiryDate(newCard.expiryMonth, expiryYear: newCard.expiryYear) { //isValidCardExpiryDate(newCard!.expiryDate) {
            return (false, LocalizedStrings.invalidCardTitle, LocalizedStrings.invalidCardExpiryDateMessage)
        }
        
        if !CardHelper.isValidCVV(newCard.cvv!, cardNumber: newCard.number!) {
            return (false, LocalizedStrings.invalidCardTitle, LocalizedStrings.invalidCardCVVMessage)
        }
        
        return (true, "", "")
    }
}


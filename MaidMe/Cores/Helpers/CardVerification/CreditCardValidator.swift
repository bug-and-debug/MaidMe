//
//  CreditCardValidator.swift
//
//  Created by Vitaliy Kuzmenko on 02/06/15.
//  Copyright (c) 2015. All rights reserved.
//

import Foundation

public class CreditCardValidator {
    
    public lazy var types: [CreditCardValidationType] = {
        var types = [CreditCardValidationType]()
        for object in CreditCardValidator.types {
            //types.append(CreditCardValidationType(dict: object))
            types.append(object)
        }
        return types
        }()
    
    public init() { }
    
    /**
    Get card type from string
    
    - parameter string: card number string
    
    - returns: CreditCardValidationType structure
    */
    public func typeFromString(string: String) -> CreditCardValidationType? {
        for type in types {
            let predicate = NSPredicate(format: "SELF MATCHES %@", type.regex)
            let numbersString = self.onlyNumbersFromString(string)
            if predicate.evaluateWithObject(numbersString) {
                return type
            }
        }
        return nil
    }
    
    /**
    Validate card number
    
    - parameter string: card number string
    
    - returns: true or false
    */
    public func validateString(string: String) -> Bool {
        let numbers = self.onlyNumbersFromString(string)
        if numbers.characters.count < 9 {
            return false
        }
        
        var reversedString = ""
        let range = Range<String.Index>(start: numbers.startIndex, end: numbers.endIndex)
        
        numbers.enumerateSubstringsInRange(range, options: [NSStringEnumerationOptions.Reverse, NSStringEnumerationOptions.ByComposedCharacterSequences]) { (substring, substringRange, enclosingRange, stop) -> () in
            reversedString += substring!
        }
        
        var oddSum = 0, evenSum = 0
        let reversedArray = reversedString.characters
        var i = 0
        
        for s in reversedArray {
            
            let digit = Int(String(s))!
            
            if i++ % 2 == 0 {
                evenSum += digit
            } else {
                oddSum += digit / 5 + (2 * digit) % 10
            }
        }
        return (oddSum + evenSum) % 10 == 0
    }
    
    /**
    Validate card number string for type
    
    - parameter string: card number string
    - parameter type:   CreditCardValidationType structure
    
    - returns: true or false
    */
    public func validateString(string: String, forType type: CreditCardValidationType) -> Bool {
        return typeFromString(string) == type
    }
    
    public func onlyNumbersFromString(string: String) -> String {
        let set = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let numbers = string.componentsSeparatedByCharactersInSet(set)
        return numbers.joinWithSeparator("")
    }
    
    // MARK: - Loading data

    public static let types = [
        CreditCardValidationType(type: .Amex, regex: "^3[47][0-9]{13}$"),
        CreditCardValidationType(type: .Visa, regex: "^4[0-9]{12}((?:[0-9]{3})?){2}$"),
        CreditCardValidationType(type: .Master, regex: "^5[1-5][0-9]{14}$"),
        CreditCardValidationType(type: .Maestro, regex: "^(5018|5020|5038|5893|6304|6759|6761|6762|6763)[0-9]{8,15}$"),
        CreditCardValidationType(type: .Diners, regex: "^3(?:0[0-5]|0[9]|[689][0-9])[0-9]{11}$"),
        CreditCardValidationType(type: .JCB, regex: "^(?:2131|1800|35\\d{3})\\d{11}$"),
        CreditCardValidationType(type: .Discover, regex: "^(65[0-9]{14}|64[4-9][0-9]{13}|6011[0-9]{12}|(622(?:12[6-9]|1[3-9][0-9]|[2-8][0-9][0-9]|9[01][0-9]|92[0-5])[0-9]{10}))(?:[0-9]{3})?$"),
        CreditCardValidationType(type: .UnionPay, regex: "^62[0-9]{14,17}$"),
    ]
}

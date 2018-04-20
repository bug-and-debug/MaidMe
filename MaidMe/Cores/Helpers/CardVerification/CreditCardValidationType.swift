//
//  CreditCardValidationType.swift
//
//  Created by Vitaliy Kuzmenko on 02/06/15.
//  Copyright (c) 2015. All rights reserved.
//

import Foundation

public func ==(lhs: CreditCardValidationType, rhs: CreditCardValidationType) -> Bool {
    return lhs.type == rhs.type
}

public struct CreditCardValidationType: Equatable {
    
    public var type: CreditCardType
    
    public var regex: String

    public init(type: CreditCardType, regex: String) {
        self.type = type
        self.regex = regex
    }
    
    public init(dict: [String: AnyObject]) {
        if let name = dict["type"] as? CreditCardType {
            self.type = name
        } else {
            self.type = .Unknown
        }
        
        if let regex = dict["regex"] as? String {
            self.regex = regex
        } else {
            self.regex = ""
        }
    }
}

public enum CreditCardType {
    case Visa
    case Master
    case Maestro
    case Amex
    case Discover
    case Diners
    case JCB
    case UnionPay
    case Unknown
}

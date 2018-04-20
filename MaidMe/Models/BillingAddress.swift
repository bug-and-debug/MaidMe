//
//  Country.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/2/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class BillingAddress: Object {
    dynamic var firstName: String!
    dynamic var lastName: String!
    dynamic var phoneNumber: String!
    dynamic var billingAddress: String!
    dynamic var country: String!
    dynamic var region: String?
    dynamic var city: String!
    dynamic var zipCode: Int = 0
    
    convenience init(firstName: String, lastName: String, phone: String, billingAddress: String, country: String, region: String?, city: String, zipCode: Int ) {
		self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phone
        self.billingAddress = billingAddress
        self.country = country
        self.region = region
        self.city = city
        self.zipCode = zipCode
    }
	
	override static func primaryKey() -> String? {
		return "firstName"
	}

}

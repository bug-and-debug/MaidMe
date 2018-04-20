//
//  Customer.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 4/13/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Customer: Object {
    dynamic var customerID: String!
    dynamic var phone: String?
    dynamic var email: String?
    dynamic var defaultArea: WorkingArea?
    dynamic var firstName: String?
    dynamic var lastName: String?
    
    convenience init(customerID: String!, phone: String?, email: String?, defaultArea: WorkingArea?, firstName: String?, lastName: String?) {
		self.init()
        self.customerID = customerID
        self.phone = phone
        self.email = email
        self.defaultArea = defaultArea
        self.firstName = firstName
        self.lastName = lastName
    }
    
    convenience init(customerDic: JSON) {
		self.init()
        self.customerID = customerDic["_id"].string
        self.phone = customerDic["phone"].string
        self.email = customerDic["email"].string
        self.defaultArea = WorkingArea(areaDic: customerDic["default_area"])
        self.firstName = customerDic["first_name"].string
        self.lastName = customerDic["last_name"].string
    }
	
	override static func primaryKey() -> String? {
		return "customerID"
	}

}


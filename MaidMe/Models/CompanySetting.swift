//
//  CompanySetting.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 4/20/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class CompanySetting: Object {
    dynamic var compID: String!
    dynamic var minCancelTime: Int = 0
    dynamic var minPeriodWorkingHour: Int = 0
    dynamic var preMinTimeForBooking: Int = 0
    dynamic var periodTimeBetweenTwoBooking: Int = 0
    dynamic var refundFee: Double = 0
    
    convenience init(companyDic: JSON) {
		self.init()
        self.compID = companyDic["_id"].string
		if companyDic["min_cancel_time"] != nil {
			self.minCancelTime = companyDic["min_cancel_time"].int!
		}
		
		if companyDic["min_period_working_hour"] != nil {
			self.minPeriodWorkingHour = companyDic["min_period_working_hour"].int!
		}
		
		if companyDic["pre_min_time_for_booking"] != nil {
			self.preMinTimeForBooking = companyDic["pre_min_time_for_booking"].int!
		}
		
		if companyDic["period_of_time_two_booking"] != nil {
			self.periodTimeBetweenTwoBooking = companyDic["period_of_time_two_booking"].int!
		}
		if companyDic["refund_fee"] != nil {
			self.refundFee = companyDic["refund_fee"].double!
		}
		
    }
	
	override static func primaryKey() -> String? {
		return "compID"
	}

}

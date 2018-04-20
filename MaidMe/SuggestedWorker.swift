//
//  SuggestedWorker.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 1/11/17.
//  Copyright © 2017 SmartDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class SuggesstedWorker: Object {
    dynamic var workerID: String!
    dynamic var availableTime: Double = 0
    dynamic var lastName: String?
    dynamic var firstName: String?
    dynamic var price: Float = 0
    dynamic var price_per_hour: Float = 0
    dynamic var materialPrice: Float = 0
    dynamic var rateAverage: Float = 0
    dynamic var phone: String?
    dynamic var avartar: String?
    dynamic var serviceType: WorkingService?
    dynamic var hour : Int = 0
    
    convenience init(suggesstedWorkerDic: JSON) {
		self.init()
        self.workerID = suggesstedWorkerDic["_id"].string
        self.availableTime = suggesstedWorkerDic["available_time"].doubleValue
        self.lastName = suggesstedWorkerDic["last_name"].string
        self.firstName = suggesstedWorkerDic["first_name"].string
        self.price = suggesstedWorkerDic["price"].float!
        self.price_per_hour = suggesstedWorkerDic["price_per_hour"].float!
        self.materialPrice = (suggesstedWorkerDic["material_price"].float == nil ? 0 : suggesstedWorkerDic["material_price"].floatValue)
        self.rateAverage = suggesstedWorkerDic["rate_average"].float!
        self.phone = suggesstedWorkerDic["phone"].string
        self.avartar = suggesstedWorkerDic["avatar"].string ?? ""
        self.serviceType = WorkingService(serviceDic: suggesstedWorkerDic["service_type"])
        self.hour = suggesstedWorkerDic["hours"].int!
        
    }
	
	override static func primaryKey() -> String? {
		return "workerID"
	}

}

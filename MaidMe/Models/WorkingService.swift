//
//  WorkingService.swift
//  MaidMe
//
//  Created by Romecon on 3/7/16.
//  Copyright © 2016 SmartDev. All rights reserved.
// avatar

import UIKit
import SwiftyJSON
import RealmSwift

class WorkingService: Object {
    dynamic var serviceID: String!
    dynamic var serviceDescription: String?
    dynamic var name: String?
    var status: WorkingAreaStatus?
    dynamic var avatar: String?
	dynamic var statusInt = 0
    

	convenience init(serviceID: String!, serviceDescription: String?, name: String?, status: WorkingAreaStatus?) {
		self.init()
        self.serviceID = serviceID
        self.serviceDescription = serviceDescription
        self.name = name
        self.status = status
		self.statusInt = (self.status?.rawValue)!
    }
	
    convenience init(serviceDic: JSON) {
		self.init()
        self.serviceID = serviceDic["_id"].string
        self.serviceDescription = serviceDic["description"].string
        self.name = serviceDic["name"].string
        self.avatar = serviceDic["avatar"].string
        self.status = WorkingAreaStatus.status(serviceDic["status"].intValue)
		self.statusInt = (self.status?.rawValue)!
    }
	
	override static func primaryKey() -> String? {
		return "serviceID"
	}

}

extension WorkingService {
    class func getService(serviceName: String?, list: [WorkingService]) -> WorkingService? {
        guard let workingService = serviceName else {
            return nil
        }
        
        guard list.count > 0 else {
            return nil
        }
        
        for item in list {
            let itemName = item.name!
            if workingService.lowercaseString == itemName.lowercaseString {
                return item
            }
        }
        
        return nil
    }
}

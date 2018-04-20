//
//  Address.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 4/4/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Address: Object {
    dynamic var addressID: String?
    dynamic var buildingName: String!
    dynamic var apartmentNo: String!
    dynamic var floorNo: String?
    dynamic var streetNo: String?
    dynamic var streetName: String?
    dynamic var zipPO: String?
    dynamic var area: String!
    dynamic var emirate: String!
    dynamic var city: String!
    dynamic var additionalDetails: String?
    dynamic var country: String!
    dynamic var isDefault: Bool = true
	dynamic var workingArea_ref : String?
    dynamic var latitude: Float = 0
    dynamic var longitude: Float = 0
	
	convenience init(buildingName: String, apartmentNo: String, floorNo: String?, streetNo: String?, streetName: String?, zipPO: String?, area: String, city: String, additionalDetails: String?, country: String) {
		self.init()
        self.buildingName = buildingName
        self.apartmentNo = apartmentNo
        self.floorNo = floorNo
        self.streetNo = streetNo
        self.streetName = streetName
        self.zipPO = zipPO
        self.area = area
        self.city = city
        self.additionalDetails = additionalDetails
        self.country = country
    }
    
    convenience init(addressDic: JSON) {
		self.init()
        self.buildingName = addressDic["address"]["building_name"].string
        self.apartmentNo = addressDic["address"]["apartment_no"].string
        self.floorNo = addressDic["address"]["floor_no"].string
        self.streetNo = addressDic["address"]["street_no"].string
        self.streetName = addressDic["address"]["street_name"].string
        self.zipPO = addressDic["address"]["zip_po"].string
        self.area = addressDic["address"]["area"].string
        self.emirate = addressDic["address"]["emirate"].string
        self.city = addressDic["address"]["city"].string
        self.additionalDetails = addressDic["address"]["additional_details"].string
        self.country = addressDic["address"]["country"].string
        self.workingArea_ref = addressDic["address"]["working_area_ref"].string
        self.addressID = addressDic["_id"].string
        self.isDefault = addressDic["is_default"].boolValue
		if addressDic["address"]["latitude"] != nil {
			self.latitude = addressDic["address"]["latitude"].float!
		}
		
		if addressDic["address"]["longitude"] != nil {
			self.longitude = addressDic["address"]["longitude"].float!
		}
    }
    
    convenience init(dic: JSON) {
		self.init()
        self.buildingName = dic["building_name"].string
        self.apartmentNo = dic["apartment_no"].string
        self.floorNo = dic["floor_no"].string
        self.streetNo = dic["street_no"].string
        self.streetName = dic["street_name"].string
        self.zipPO = dic["zip_po"].string
        self.area = dic["area"].string
        self.emirate = dic["emirate"].string
        self.city = dic["city"].string
        self.additionalDetails = dic["additional_details"].string
        self.country = dic["country"].string
        self.workingArea_ref = dic["working_area_ref"].string
		if dic["latitude"] != nil {
			self.latitude = dic["latitude"].float!
		}
		
		if dic["longitude"] != nil {
			self.longitude = dic["longitude"].float!
		}
    }
	
	override static func primaryKey() -> String? {
		return "addressID"
	}

}

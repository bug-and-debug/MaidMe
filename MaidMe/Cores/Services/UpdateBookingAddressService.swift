//
//  UpdateBookingAddressService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 4/6/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UpdateBookingAddressService: RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.POST, "\(Configuration.serverUrl)\(Configuration.updateBookingAddressUrl)", parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getParams(address: Address,areaID: String?,isDefault: Bool?) -> [String: AnyObject] {
        return [
            "address_id": (address.addressID == nil ? "" : address.addressID!),
            "building_name": address.buildingName,
            "apartment_no": address.apartmentNo,
            "floor_no": (address.floorNo == nil ? "" : address.floorNo!),
            "street_no": (address.streetNo == nil ? "" : address.streetNo!),
            "street_name": (address.streetName == nil ? "" : address.streetName!),
            "zip_po": (address.zipPO == nil ? "" : address.zipPO!),
            "area": address.area,
            "emirate" : address.emirate,
            "city": address.city,
            "additional_details": (address.additionalDetails == nil ? "" : address.additionalDetails!),
            "country": address.country,
            "working_area_ref" : areaID!,
            "is_default" : isDefault!,
            "longitude": address.longitude,
            "latitude": address.latitude
        ]
    }
    func getParams1(address: Address) -> [String: AnyObject] {
        return [
            "address_id": (address.addressID == nil ? "" : address.addressID!),
            "building_name": address.buildingName,
            "apartment_no": address.apartmentNo,
            "floor_no": (address.floorNo == nil ? "" : address.floorNo!),
            "street_no": (address.streetNo == nil ? "" : address.streetNo!),
            "street_name": (address.streetName == nil ? "" : address.streetName!),
            "zip_po": (address.zipPO == nil ? "" : address.zipPO!),
            "area": address.area,
            "emirate" : address.emirate,
            "city": address.city,
            "additional_details": (address.additionalDetails == nil ? "" : address.additionalDetails!),
            "country": address.country,
          //  "working_area_ref" : (area?.areaID)!,
//            "is_default" : false,
//          
        ]
    }
}

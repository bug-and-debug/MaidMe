//
//  LockABookingService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/31/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LockABookingService: RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.POST, "\(Configuration.serverUrl)\(Configuration.lockABookingUrl)", parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getLockABookingParams(bookingInfo: Booking, address: Address, isIncludeMaterial: Bool) -> [String: AnyObject] {
        let addressq: [String: AnyObject] = [
            "building_name": address.buildingName,
            "apartment_no": address.apartmentNo,
            "floor_no": (address.floorNo == nil ? "" : address.floorNo!),
            "street_no": (address.streetNo == nil ? "" : address.streetNo!),
            "street_name": (address.streetName == nil ? "" : address.streetName!),
            "zip_po": (address.zipPO == nil ? "" : "\(address.zipPO!)"),
            "area": address.area,
            "emirate": address.emirate,
            "city": address.city,
            "additional_details": (address.additionalDetails == nil ? "" : address.additionalDetails!),
            "country": address.country
        ]
		
        var materialPrice: Float = 0.0
        
        if isIncludeMaterial {
            materialPrice = (bookingInfo.materialPrice == 0.0 ? 0.0 : bookingInfo.materialPrice)
        }
        
        let params: [String: AnyObject] = [
            "maid_id": bookingInfo.workerID!,
            "service_type_ref": bookingInfo.service!.serviceID,
            "working_area_ref": address.workingArea_ref!,
            "time_of_service": (bookingInfo.time?.timeIntervalSince1970)! * 1000,
            "working_hours": bookingInfo.hours,
            "price": Float(bookingInfo.price + materialPrice),
            "asap": false,
            "address": addressq,
            "material_price": materialPrice
        ]
        
        return params
    }
}

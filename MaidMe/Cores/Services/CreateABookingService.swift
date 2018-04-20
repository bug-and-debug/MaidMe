//
//  CreateABookingService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 4/4/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CreateABookingService: RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
            super.request(.POST, "\(Configuration.serverUrl)\(Configuration.createABookingUrl)", parameters: parameters, encoding: .JSON, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getCreateABookingParams(cardID: String, address: Address, booking: Booking) -> [String: AnyObject] {
        
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
        
        return [
            "booking_id":booking.bookingID!,
            "maid_id": booking.workerID!,
            "service_type_ref": (booking.service?.serviceID)!,
            "working_area_ref": address.workingArea_ref!,
            "time_of_service": (booking.time?.timeIntervalSince1970)! * 1000,
            "working_hours": booking.hours,
            "asap": false,
            "address": addressq,
            "price": (booking.price == 0 ? 0 : booking.price) + (booking.materialPrice == 0 ? 0 : booking.materialPrice),
            "material_price": (booking.materialPrice == 0 ? 0 : booking.materialPrice),
            "card_id": cardID,
            "booking_code": (booking.bookingCode == nil ? "" : booking.bookingCode!)
        ]
    }
    
    func getBookingCode(result: JSON?) -> String? {
        guard let result = result else {
            return nil
        }
        
        return result["booking"]["booking_code"].string
    }
}


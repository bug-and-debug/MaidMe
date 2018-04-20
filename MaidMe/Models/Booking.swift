//
//  Booking.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/16/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Booking: Object, NSCopying {
    dynamic var bookingID: String?
    dynamic var workerName: String?
    dynamic var workerID: String?
    dynamic var time: NSDate?
    dynamic var service: WorkingService?
    dynamic var hours: Int = 0
    dynamic var price: Float = 0
    dynamic var materialPrice: Float = 0
    dynamic var address: Address?
    dynamic var payerCard: Card?
    dynamic var maid: Worker?
    dynamic var bookingCode: String?
    var companySetting: CompanySetting?
    dynamic var timeOfRating: NSDate?
    dynamic var comment: String?
    dynamic var rating: Float = 0
    dynamic var workingAreaRef: WorkingArea?
    var status: BookingStatus?
    dynamic var avartar: String?
    dynamic var bookingStatus: Int = 0
    dynamic var isRebookable: Bool = false
    
    convenience init(bookingID: String?, workerName: String?, workerID: String?, time: NSDate?, service: WorkingService?, workingAreaRef: WorkingArea?, hours: Int?, price: Float?, materialPrice: Float?, payerCard: Card?, avartar: String?,maid: Worker?) {
		self.init()
        self.bookingID = bookingID
        self.workerName = workerName
        self.workerID = workerID
        self.time = time
        self.service = service
        self.workingAreaRef = workingAreaRef
		if hours != nil {
			self.hours = hours!
		}
		
		if price != nil {
			self.price = price!
		}
		
		if payerCard != nil {
			self.payerCard = payerCard
		}
		
		if materialPrice != nil {
			self.materialPrice = materialPrice!
		}
		
		if avartar != nil {
			self.avartar = avartar
		}
		
		if maid != nil {
			self.maid = maid
		}
		
    }
    
    convenience init(bookingDic: JSON) {
		self.init()
        self.bookingID = bookingDic["_id"].string
        self.time = DateTimeHelper.getDateFromString(bookingDic["time_of_service"].string, format: DateFormater.twentyFourhoursFormat)
        self.service = WorkingService(serviceDic: bookingDic["service_type_ref"])
        self.hours = bookingDic["working_hours"].int!
        self.price = bookingDic["price"].float!
//        self.materialPrice = bookingDic["material_price"].float!
        self.address = Address(dic: bookingDic["address"])
        self.maid = Worker(workerDic: bookingDic["maid"])
        self.bookingCode = bookingDic["booking_code"].string
        self.companySetting = CompanySetting(companyDic: bookingDic["company_ref"])
        self.timeOfRating = DateTimeHelper.getDateFromString(bookingDic["time_of_rating"].string, format: DateFormater.twentyFourhoursFormat)
        self.comment = bookingDic["comment"].string
        self.rating = bookingDic["maid"]["rate_average"].float!
        self.workingAreaRef = WorkingArea(areaDic: bookingDic["working_area_ref"])
        self.status = BookingStatus(rawValue: bookingDic["status"].intValue)
        self.bookingStatus = bookingDic["status"].int!
		if  bookingDic["is_rebookable"].bool != nil {
			self.isRebookable = bookingDic["is_rebookable"].bool!	
		}
		
	}
	
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Booking(bookingID: bookingID, workerName: workerName, workerID: workerID, time: time, service: service, workingAreaRef: workingAreaRef, hours: hours, price: price, materialPrice: materialPrice, payerCard: payerCard, avartar: avartar,maid: maid)
        return copy
    }
	
	override static func primaryKey() -> String? {
		return "bookingID"
	}

}

enum BookingStatus: Int {
    case Locked = 0
    case Booked
    case Done
    case CanceledRefundFree
    case CanceledRefundCharged
    case CanceledNoRefund
    case Paid
    
    static func status(rawValue: Int) -> BookingStatus {
        switch(rawValue) {
        case 0: return .Locked
        case 1: return .Booked
        case 2: return .Done
        case 3: return .CanceledRefundFree
        case 4: return .CanceledRefundCharged
        case 5: return .CanceledNoRefund
        case 6: return .Paid
        default: return .Booked
        }
    }
    
    static func getRawString(status: BookingStatus) -> String {
        switch(status) {
        case .Locked: return "LOCKED"
        case .Booked: return "BOOKED"
        case .Paid,
             .Done: return "DONE"
        case .CanceledRefundFree,
             .CanceledRefundCharged,
             .CanceledNoRefund: return "CANCELED"
        }
    }
    
    static func getColorCode(status: BookingStatus) -> UIColor {
        switch(status) {
        case .Locked: return UIColor.blueColor()
        case .Booked: return UIColor.purpleColor()
        case .Done: return UIColor.greenColor()
        case .CanceledRefundFree,
        .CanceledRefundCharged,
        .CanceledNoRefund: return UIColor.redColor()
        case .Paid: return UIColor.orangeColor()
        }
    }
}



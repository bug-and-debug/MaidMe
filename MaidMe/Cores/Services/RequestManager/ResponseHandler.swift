//
//  ResponseHandler.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 2/15/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ResponseHandler: NSObject {
    class func responseHandling(response: Response<AnyObject, NSError>) -> ResponseObject {
        var messageCode: MessageCode?
        
        switch response.result {
        case .Success(let value):
            return ResponseObject(response: JSON(value))
            
        case .Failure(let error):
            messageCode = MessageCode.code(error.code)
            return ResponseObject(messageCode: messageCode, messageInfo: (messageCode == .CannotConnectServer ? LocalizedStrings.connectToServerFailedMessage : nil))
        }
    }
    
    class func payfortResponseHandling(response: Response<AnyObject, NSError>) -> (error: MessageCode?, tokenID: String?){
        switch response.result {
        case .Success(let value):
            let error = JSON(value)["error"]
            
            if error != nil {
                return (error: .InvalidCardPayfort, tokenID: nil)
            }
            
            return (error: nil, tokenID: JSON(value)["id"].stringValue)
            
        case .Failure(let error):
            print("Error:", error)
            var message = MessageCode.code(error.code)
            if message == nil {
                message = .ErrorCreatingCardPayfort
            }
            
            return (error: message, tokenID: nil)
        }
    }
}

class ResponseObject {
    var status: Int?
    var messageCode: MessageCode?
    var messageInfo: String?
    var body: JSON?
    
    init(status: Int? = nil,
        messageCode: MessageCode?,
        messageInfo: String?,
        body: JSON? = nil) {
            self.status = status
            self.messageCode = messageCode
            self.messageInfo = messageInfo
            self.body = body
    }
    
    init(response: JSON) {
        //print("Response: ", response)
        self.status = response["status"].intValue
        
        if let message = response["messageInfo"].string {
            self.messageInfo = message
        }
        else {
            self.messageInfo = LocalizedStrings.connectionFailedMessage
        }
        
        self.messageCode = MessageCode.code(response["messageCode"].intValue)
        self.body = response["body"]
    }
}

enum MessageCode {
    case Success
    case ExistedAccount
    case NotAvailableAccount
    case InvalidEmailPass
    case AddressExisted
    case AddressNotFound
    case RepeatedPassword
    case NoServiceForArea
    case InternalServerError
    case PermissionDenied
    case ValidationError
    case Timeout
    case CannotConnectServer
    case InvalidCardPayfort
    case ErrorCreatingCardPayfort
    case Unauthorize
    case MaidNotFound
    case InactivateMaid
    case BookingNotFound
    case BookingTimeout
    case BookingConflict
    case InvalidWorkingHours
    case BookingTimeInvalid
    case CannotCharge
    case PaymentParamsInvalid
    case CanGetTermsAndCondition
    case ServiceTypeNotFound
    case PasswordWasReset
    
    static func code(rawValue: Int?) -> MessageCode? {
        guard let code = rawValue else {
            return nil
        }
        
        switch(code) {
            case 200: return .Success
            case 30001: return .ExistedAccount
            case 30002: return .NotAvailableAccount
            case 30003: return .InvalidEmailPass
            case 30004: return .AddressExisted
            case 30005: return .AddressNotFound
            case 30006: return .RepeatedPassword
            case 90003: return .ServiceTypeNotFound
            case 90006: return .NoServiceForArea
            case 150001: return .InternalServerError
            case 150002: return .PermissionDenied
            case 150003: return .ValidationError
            case -1001: return .Timeout
            case -1004: return .CannotConnectServer
            case 100002: return .MaidNotFound
            case 100004: return .InactivateMaid
            case 110001: return .Unauthorize
            case 110006: return .CannotCharge
            case 110007: return .PaymentParamsInvalid
            case 120001: return .BookingNotFound
            case 120002: return .BookingTimeout
            case 120003: return .BookingConflict
            case 120007: return .InvalidWorkingHours
            case 120006: return .BookingTimeInvalid
            case 160001: return .CanGetTermsAndCondition
             case 30008: return .PasswordWasReset
            default: return nil
        }
    }
}
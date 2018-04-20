//
//  RequestManager.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 2/15/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SSKeychain

class RequestManager: NSObject {
    //static let sharedInstance = RequestManager()
    
    var alamofireManager : Alamofire.Manager?
    
    func request1(method: Alamofire.Method,
                  _ URLString: URLStringConvertible,
                    parameters: [String: AnyObject]? = nil,
                    encoding: ParameterEncoding = .URL,
                    headers: [String: String]? = nil,
                    completionHandler: Response<AnyObject, NSError> -> ()) {
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        
        self.alamofireManager = Alamofire.Manager(configuration: configuration)
        self.alamofireManager!.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers)
            .responseJSON{ (response: Response) -> Void in
                completionHandler(response)
        }
    }
    
    func request(method: Alamofire.Method? = nil,
                 _ URLString: URLStringConvertible? = nil,
                   parameters: [String : AnyObject]? = nil,
                   encoding: ParameterEncoding? = nil,
                   headers: [String : String]? = nil,
                   completionHandler: Response<AnyObject, NSError> -> ()) {
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        
        self.alamofireManager = Alamofire.Manager(configuration: configuration)
        self.alamofireManager!.request(method!, URLString!, parameters: parameters, encoding: encoding!, headers: headers)
            .responseJSON{ (response: Response) -> Void in
                completionHandler(response)
        }
    }
    
    /**
     Get authenticated header for the request
     
     - returns: header
     */
    func getAuthenticateHeader() -> [String: String] {
        var customerID = ""
        var tokenID = ""
        
        if let token = SSKeychain.passwordForService(KeychainIdentifier.appService, account: KeychainIdentifier.tokenID) {
            tokenID = token
        }
        if let customer = SSKeychain.passwordForService(KeychainIdentifier.appService, account: KeychainIdentifier.customerID) {
            customerID = customer
        }
        var info: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist") {
            info = NSDictionary(contentsOfFile: path)
        }
        
        var appVersion = ""
        if let dict = info {
            let version = dict["CFBundleShortVersionString"] as! String
            let build = dict["CFBundleVersion"] as! String
            appVersion = "\(version),\(build)"
        }
        
        let header = [
            Parameters.contentType: Parameters.jsonContentType,
            Parameters.customerID: customerID,
            Parameters.accessToken: tokenID,
            Parameters.appVersion: appVersion
        ]
        
        print(header)
        return header
    }
    
    static func getAuthenticateHeader() -> [String: String] {
        var customerID = ""
        var tokenID = ""
        
        if let token = SSKeychain.passwordForService(KeychainIdentifier.appService, account: KeychainIdentifier.tokenID) {
            tokenID = token
        }
        if let customer = SSKeychain.passwordForService(KeychainIdentifier.appService, account: KeychainIdentifier.customerID) {
            customerID = customer
        }

        var info: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist") {
            info = NSDictionary(contentsOfFile: path)
        }
        
        var appVersion = ""
        if let dict = info {
            let version = dict["CFBundleShortVersionString"] as! String
            let build = dict["CFBundleVersion"] as! String
            appVersion = "\(version) \(build)"
        }
        
        let header = [
            Parameters.contentType: Parameters.jsonContentType,
            Parameters.customerID: customerID,
            Parameters.accessToken: tokenID,
            Parameters.appVersion: appVersion
        ]

        print(header)
        return header
    }
}

enum RequestType {
    case Register
    case Login
    case FetchWorkingArea
    case FetchServiceTypes
    case FetchAvailableWorker
    case CreateCardToken
    case CreateCustomerCard
    case LockABooking
    case FetchAllCard
    case CreateABooking
    case AddNewBookingAddress
    case UpdateBookingAddress
    case FetchAllBookingAddresses
    case FetchCustomerDetails
    case UpdateCustomerDetails
    case ChangePassword
    case FetchAllUpcomingBookings
    case CancelBooking
    case ClearLockedBooking
    case FetchBookingDoneNotRating
    case GetRatingsAndComments
    case FetchBookingHistory
    case GiveARatingComment
    case FetchTermsConditions
    case ForgotPassword
    case RebookAMaid
    case GetMinPeriodWorkingHour
    
    case DefaultCard
    case RemoveCards
    case RemoveAddress
    
    case FetchSugesstedWorker
    case GetSearchOptionRebooking
}

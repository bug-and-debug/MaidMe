//
//  RequestHelper.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 2/15/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import ReachabilitySwift
import SwiftyJSON
import SSKeychain

class RequestHelper: NSObject {
    
    // MARK: - Check Internet connection
    
    class func isInternetConnectionFailed() -> Bool {
        do {
            let readchability: Reachability = try Reachability.reachabilityForInternetConnection()
            let internetStatus = readchability.currentReachabilityStatus
            
            if internetStatus != .NotReachable {
                return false
            }
            else {
                return true
            }
        }
        catch _ {
            return false
        }
    }
    
    class func showNoInternetConnectionAlert(viewController: UIViewController) {
        let alert = UIAlertController(title: LocalizedStrings.noInternetConnectionTitle, message: LocalizedStrings.noInternetConnectionMessage, preferredStyle: .Alert)
        let action = UIAlertAction(title: LocalizedStrings.okButton, style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addAction(action)
        
        dispatch_async(dispatch_get_main_queue(), {
            viewController.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    class func saveLoginSuccessData(result: JSON?) {
        // Get the customer_id and token_id
        guard let body = result else {
            return
        }
		
        let customerID = body[APIKeys.customerID]
        let userTokenId = body[APIKeys.tokenID]
        
        if customerID != nil {
            SSKeychain.setPassword(customerID.stringValue, forService: KeychainIdentifier.appService, account: KeychainIdentifier.customerID)
        }
        
        if userTokenId != nil {
            SSKeychain.setPassword(userTokenId.stringValue, forService: KeychainIdentifier.appService, account: KeychainIdentifier.tokenID)
        }
        
        SessionManager.sharedInstance.isLoggedIn = true
    }
}

//
//  SessionManager.swift
//  Edgar
//
//  Created by Romecon on 2/1/16.
//  Copyright © 2016 smartlink. All rights reserved.
//

import UIKit
import SSKeychain

class SessionManager: NSObject {
    static let sharedInstance = SessionManager()
    var isLoggedIn: Bool = false
    var defaultAreaCustomer: String = ""
    
    func deleteLoginToken() {
        SSKeychain.deletePasswordForService(KeychainIdentifier.appService, account:  KeychainIdentifier.customerID)
        SSKeychain.deletePasswordForService(KeychainIdentifier.appService, account:  KeychainIdentifier.tokenID)
    }
}

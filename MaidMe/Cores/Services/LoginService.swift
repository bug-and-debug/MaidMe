//
//  LoginService.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/15/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain

class LoginService: RequestManager {
    
    override func request(method: Alamofire.Method? = nil,
        _ URLString: URLStringConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: Response<AnyObject, NSError> -> ()) {
			print(parameters)
		
            super.request(.POST, "\(Configuration.serverUrl)\(Configuration.loginUrl)", parameters: parameters, encoding: .JSON) {
                response in
				
				SSKeychain.setPassword(parameters!["password"] as! String, forService: KeychainIdentifier.appService, account: parameters!["email"] as! String)
				SSKeychain.setPassword(parameters!["email"] as! String, forService: KeychainIdentifier.appService, account: KeychainIdentifier.userName)
				if parameters!["decryptedPass"] != nil {
					SSKeychain.setPassword(parameters!["decryptedPass"] as! String, forService: KeychainIdentifier.appService, account: KeychainIdentifier.password)
				}
				

				
				completionHandler(response)
				
            }
    }
}

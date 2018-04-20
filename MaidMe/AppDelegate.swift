//
//  AppDelegate.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 2/15/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SSKeychain
import GooglePlaces
import SVProgressHUD
import RealmSwift
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    //aaaa
    var window: UIWindow?
    let notificationManager = NotificationManager()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        window?.backgroundColor = UIColor.whiteColor()
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor.grayColor(),
            NSFontAttributeName: UIFont(name: CustomFont.quicksanRegular, size: 16)!
        ]
        
        UINavigationBar.appearance().titleTextAttributes = navBarAttributesDictionary
        UITabBar.appearance().tintColor = UIColor(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.grayColor()
		
		// Configure SVProgressHUD
		SVProgressHUD.setDefaultStyle(.Custom)
		SVProgressHUD.setDefaultMaskType(.Black)
		SVProgressHUD.setRingNoTextRadius(14)
		SVProgressHUD.setForegroundColor(UIColor(red:0.27, green:0.68, blue:0.75, alpha:1.00))
		SVProgressHUD.setBackgroundColor(UIColor.whiteColor())
		SVProgressHUD.setBackgroundLayerColor(UIColor(white: 0, alpha: 0.25))
		// Store Payfort public key into keychain
        SSKeychain.setPassword(PaymentKey.payfort, forService: KeychainIdentifier.appService, account: KeychainIdentifier.payfortkey)

		Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
		let realm = try! Realm()
		debugPrint("Path to realm file: " + realm.configuration.fileURL!.absoluteString!)

        //GooglePlaces search address
        GMSPlacesClient.provideAPIKey(GooglePlacesSearchAddress.key)

        #if DEVELOPMENT
        enableDevelopmentMode(true)
        #else
        enableDevelopmentMode(false)
        #endif
        
        Fabric.with([Crashlytics.self])
        CheckMobiConfigurations.setup()
        notificationManager.setupNotificationSettings()

        return true
    }


    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        notificationManager.application(application, didReceiveLocalNotification: notification)
    }
    
    func enableDevelopmentMode(flag: Bool) {
        if flag {
            Configuration.serverUrl = Configuration.serverDevUrl
            Configuration.payfortUrl = Configuration.payfortDevUrl
            PaymentKey.payfort = PaymentKey.payfortDev
            PaymentKey.payfortApiKey = PaymentKey.payfortApiKeyDev
        }
        else {
            Configuration.serverUrl = Configuration.serverProductionUrl
            Configuration.payfortUrl = Configuration.payfortProductionUrl
            PaymentKey.payfort = PaymentKey.payfortProduction
            PaymentKey.payfortApiKey = PaymentKey.payfortApiKeyLive
        }
    }

}


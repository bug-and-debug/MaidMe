//
//  NotificationManager.swift
//  MaidMe
//
//  Created by Mohammad Alatrash on 6/3/17.
//  Copyright © 2017 SmartDev. All rights reserved.
//

import Foundation

class NotificationManager: NSObject {
    
    func setupNotificationSettings() {
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
    }

    class func createReminderNotification(name: String, fireDate: NSDate) {
        let notification = UILocalNotification()
        notification.alertBody = "\(name), \(LocalizedStrings.arrivingTimeMessage)"
        notification.fireDate = fireDate
        notification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}

extension NotificationManager: UIApplicationDelegate {

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        let rootViewController = UIApplication.sharedApplication().windows.first?.rootViewController
        let tabBarController = (rootViewController as? UINavigationController)?.viewControllers.first?.presentedViewController as? UITabBarController
        print(rootViewController)
        tabBarController?.selectedIndex = 2
    }
}

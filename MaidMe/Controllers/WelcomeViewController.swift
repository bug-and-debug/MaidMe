//
//  WelcomeViewController.swift
//  MaidMe
//
//  Created by Vo Minh Long on 12/27/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit

class WelcomeViewController: BaseViewController {
    @IBOutlet weak var createNewButton: UIButton!
    @IBOutlet weak var alreadyUserButton: UIButton!
    var navController: UINavigationController?
    var currentViewController: AnyObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        createNewButton.layer.cornerRadius = 5
        alreadyUserButton.layer.cornerRadius = 5
    }
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        disableBackToPreviousScreen(true)
        //hidden navigationbar
        self.navigationController?.navigationBar.hidden = true
        self.tabBarController?.tabBar.hidden = true
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    @IBAction func login(sender: AnyObject) {
        if !SessionManager.sharedInstance.isLoggedIn {
            return
        }
        
//        SessionManager.sharedInstance.deleteLoginToken()
        
        let storyboard = self.storyboard
        
        if let loginScreen = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIDs.login) as? LoginTableViewController {
            loginScreen.isAutoLogin = false
            navController?.pushViewController(loginScreen, animated: true)
            self.navigationController?.interactivePopGestureRecognizer?.enabled = false
            SessionManager.sharedInstance.isLoggedIn = false
        }
    }
    @IBAction func createNew(sender: AnyObject) {
        let storyboard = self.storyboard
        
        guard let registerScreen = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIDs.register) as? RegisterViewController else {
            return
        }
        
        guard let _ = currentViewController as? RegisterViewController else {
            navController?.pushViewController(registerScreen, animated: true)
            return
        }
    }

}

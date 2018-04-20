//
//  BaseViewController.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 2/15/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class BaseViewController: UIViewController {
    
    var alert: UIAlertController!
    var loadingIndicator: UIActivityIndicatorView!
    var isShownAlert: Bool = false
    var navTitleView = AddressTitleView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLoadingIndicator()
        customBackButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        // End editing
        dismissKeyboard()
    }
    
    // MARK: - Loading View
    
    func createLoadingIndicator() {
        self.loadingIndicator = UIActivityIndicatorView()
        setDefaultUIForLoadingIndicator()
    }
    
    func setDefaultUIForLoadingIndicator() {
        self.loadingIndicator.activityIndicatorViewStyle = .WhiteLarge
        self.loadingIndicator.color = UIColor.blackColor()
        self.view.addSubview(self.loadingIndicator)
        
        let viewBounds = self.view.bounds
        self.loadingIndicator.center = CGPointMake(CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds))
    }
    
    func setLoadingUI(type: UIActivityIndicatorViewStyle, color: UIColor? = nil) {
        loadingIndicator.activityIndicatorViewStyle = type
        if let color = color {
            loadingIndicator.color = color
        }
    }
    
    func setRequestLoadingViewCenter(button: UIButton) {
        let x = CGRectGetWidth(button.frame) - 10
        var y: CGFloat = 100
        if let superView = button.superview?.superview {
            y = CGRectGetMinY(superView.frame) + CGRectGetMaxY(button.frame) - 25
        }
        setLoadingViewCenter(x, y: y)
    }
    
    func setRequestLoadingViewCenter1(view: UIView) {
        var x = CGRectGetWidth(view.frame) - 10
        var y: CGFloat = 100
        if let superView = view.superview {
            x = view.center.x
            y = CGRectGetMinY(superView.frame) / 2 + view.center.y
        }
        
        setLoadingViewCenter(x, y: y)
    }
    
    func setLoadingViewCenter(x: CGFloat, y: CGFloat) {
        self.loadingIndicator.center = CGPointMake(x, y)
    }
    
    func startLoadingView() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
			if !SVProgressHUD.isVisible() {
				SVProgressHUD.show()
			}
            self.view.userInteractionEnabled = false
            self.navigationController?.navigationBar.userInteractionEnabled = false
            self.tabBarController?.tabBar.userInteractionEnabled = false
            self.disableBackToPreviousScreen(true)
        }
    }
    
    func stopLoadingView() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
			SVProgressHUD.dismiss()
//            self.loadingIndicator.stopAnimating()
            self.view.userInteractionEnabled = true
            self.tabBarController?.tabBar.userInteractionEnabled = true
            self.navigationController?.navigationBar.userInteractionEnabled = true
            self.disableBackToPreviousScreen(false)
        }
    }
    
    func setUserInteraction(isEnable: Bool) {
        self.view.userInteractionEnabled = isEnable
    }
    
    func disableBackToPreviousScreen(isDisable: Bool) {
        // Disable/Enable wipe back to previous screen
        disableWipeBack(isDisable)
        
        self.navigationItem.backBarButtonItem?.enabled = !isDisable
    }
    
    func disableWipeBack(isDisable: Bool) {
        if let navController = self.navigationController {
            if (navController.respondsToSelector(Selector("interactivePopGestureRecognizer"))) {
                navController.interactivePopGestureRecognizer?.enabled = !isDisable
            }
        }
    }
    func setupMenuAddressButton() {
        let titleView = UIView()
        titleView.frame = CGRectMake(0, 0, self.view.frame.width/(2), 40)
        titleView.backgroundColor = UIColor.clearColor()
        navTitleView.frame = titleView.frame
        titleView.addSubview(navTitleView)
        self.navigationItem.titleView = titleView
        
    }
    func cutString(string: String) -> String{
        if string.characters.count > 22 {
            let subString = string[string.startIndex.advancedBy(0)...string.startIndex.advancedBy(22)]
            return subString + ".."
        } else {
            return string
        }
    }
    
    func customBackButton() {
        // Uncomment the following code to set custom back image
        /*self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back_arrow")
         self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back_arrow")*/
        
        // Remove the default back title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func handleAPIResponse() {
        // Hide the loading indicator
		// Removed. Might need to enable it again.
//        stopLoadingView()
    }
    func handleResponseError(messageCode: MessageCode?, title: String, message: String?, requestType: RequestType) {
        print("Show alert")
        if messageCode == nil {
            dispatch_async(dispatch_get_main_queue(), {
                self.showAlertView(LocalizedStrings.connectionFailedTitle, message: LocalizedStrings.connectionFailedMessage, requestType: requestType)
            })
        }
            
        else if messageCode == .Timeout {
            // Show alert with two button
            dispatch_async(dispatch_get_main_queue(), {
                self.showTimeOutAlert(LocalizedStrings.timeoutTitle, message: LocalizedStrings.timeoutMessage, requestType: requestType)
            })
        }else if messageCode == .PasswordWasReset {
            if !SessionManager.sharedInstance.isLoggedIn {
                return
            }
            SessionManager.sharedInstance.deleteLoginToken()
            let storyboard = self.storyboard
            if let welcomeScreen = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIDs.welcom) as? WelcomeViewController {
                //loginScreen.isAutoLogin = false
                self.navigationController?.pushViewController(welcomeScreen, animated: true)
                SessionManager.sharedInstance.isLoggedIn = false
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                var alertTitle = title
                
                if messageCode == .CannotCharge {
                    alertTitle = LocalizedStrings.paymentFailedTitle
                }
                
                if let messageInfo = message {
                    self.showAlertView(alertTitle, message: messageInfo, requestType: requestType)
                }
                else {
                    self.showAlertView(title, message: LocalizedStrings.connectionFailedMessage, requestType: requestType)
                }
            })
        }
    }
    func handleAlertViewAction(requestType: RequestType?) {}
    func handleTryAgainTimeoutAction(requestType: RequestType) {}
    func handleTimeoutOKAction(requestType: RequestType) {}
    
    func showTimeOutAlert(title: String, message: String, requestType: RequestType) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: LocalizedStrings.okButton, style: .Default){ (action) -> Void in
            // Resend the sign up request
            self.handleTimeoutOKAction(requestType)
            self.isShownAlert = false
        }
        
        let tryAgainAction = UIAlertAction(title: LocalizedStrings.tryAgainButton, style: .Default) { (action) -> Void in
            // Resend the sign up request
            self.handleTryAgainTimeoutAction(requestType)
            self.isShownAlert = false
        }
        
        alert.addAction(okAction)
        alert.addAction(tryAgainAction)
        
        presentAlertView(self.alert)
    }
    // MARK: - UIAlertView
    func presentAlertView(alert: UIAlertController) {
        
        dispatch_async(dispatch_get_main_queue(), {
            if self.isShownAlert {
                //self.alert.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            else {
                self.presentViewController(self.alert, animated: true, completion: nil)
            }
            self.isShownAlert = true
        })
    }
    
    func showAlertView(title: String?, message: String, requestType: RequestType?) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: LocalizedStrings.okButton, style: UIAlertActionStyle.Default) { (action) -> Void in
            self.handleAlertViewAction(requestType)
        }
        
        alert.addAction(action)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(self.alert, animated: true, completion: nil)
        })
    }
    
    // MARK: - Handle UIAlertViewAction
    
}

extension BaseViewController: UITextFieldDelegate {
    
    /**
     Close keyboard when touch on empty area.
     
     - parameter touches:
     - parameter event:
     */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissKeyboard()
    }
}

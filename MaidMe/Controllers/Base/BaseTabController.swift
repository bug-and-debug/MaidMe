//
//  BaseTabController.swift
//  MaidMe
//
//  Created by Vo Minh Long on 12/14/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class BaseTabController: UITabBarController {
    var alert: UIAlertController!
    var loadingIndicator: UIActivityIndicatorView!
    var isShownAlert: Bool = false
    var rightMenuButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLoadingIndicator()
        customBackButton()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            self.disableBackToPreviousScreen(true)
        }
    }
    
    func stopLoadingView() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.dismiss()
            self.view.userInteractionEnabled = true
            self.navigationController?.navigationBar.userInteractionEnabled = true
            self.disableBackToPreviousScreen(false)
        }
    }
    
    func setUserInteraction(isEnable: Bool) {
        self.view.userInteractionEnabled = isEnable
    }
    
    // MARK: - Textfield Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - UI
    func customBackButton() {
        // Uncomment the following code to set custom back image
        /*self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back_arrow")
         self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back_arrow")*/
        
        // Remove the default back title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    func hideBackbutton(isHidden: Bool) {
        // Disable/Enable wipe back to previous screen
        disableWipeBack(isHidden)
        
        // Hide back button
        self.navigationItem.hidesBackButton = isHidden
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
    
 
    func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 44.0, 44.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context!, color.CGColor)
        CGContextFillRect(context!, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    // MARK: - Handle response
    
    func handleAPIResponse() {
        // Hide the loading indicator
        stopLoadingView()
    }
    
    func handleResponseError(messageCode: MessageCode?, title: String, message: String?, requestType: RequestType) {
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
            self.isShownAlert = false
        }
        
        alert.addAction(action)
        
        presentAlertView(self.alert)
    }
    
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
    
    // MARK: - Handle UIAlertViewAction
    
    func handleAlertViewAction(requestType: RequestType?) {}
    func handleTryAgainTimeoutAction(requestType: RequestType) {}
    func handleTimeoutOKAction(requestType: RequestType) {}
    
}


extension BaseTabController: UITextFieldDelegate {
    
    /**
     Close keyboard when touch on empty area.
     
     - parameter touches:
     - parameter event:
     */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

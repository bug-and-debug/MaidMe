//
//  ChangePasswordTableViewController.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 12/7/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain

class ChangePasswordTableViewController: BaseTableViewController {
    
    @IBOutlet weak var currentPassTextField: UITextField!
    @IBOutlet weak var newPassTextField: UITextField!
    @IBOutlet weak var repeatedPassTextField: UITextField!
    @IBOutlet weak var savePassButton: UIButton!
    
    
    
    let changeCustomerPassAPI = ChangePasswordService()
    var messageCode: MessageCode?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.customBackButton()
        self.navigationController?.navigationBar.hidden = false
        self.navigationItem.title = "CHANGE PASSWORD"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        addTapGestureDismissKeyboard(self.view)
    }
    
    private func setupVC(){
        title = "Change Password"
        newPassTextField.delegate = self
    }
    
    func resetPasswordFields() {
        currentPassTextField.text = ""
        newPassTextField.text = ""
        repeatedPassTextField.text = ""
    }
    func sendRequest(parameters: [String: AnyObject]?,
                     request: RequestManager,
                     requestType: RequestType,
                     isSetLoadingView: Bool, button: UIButton?) {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
            return
        }
        // Set loading view center
       
        self.startLoadingView()
        request.request(parameters: parameters) {
            [weak self] response in
            if let strongSelf = self {
                strongSelf.handleAPIResponse()
                strongSelf.handleResponse(response, requestType: requestType)
            }
        }
    }
    func changePasswordRequest() {
        let currentPass = StringHelper.encryptStringsha256(currentPassTextField.text!)
        let newPass = StringHelper.encryptStringsha256(newPassTextField.text!)
        let params = changeCustomerPassAPI.getParams(currentPass, newPass: newPass)
        sendRequest(params, request: changeCustomerPassAPI, requestType: .ChangePassword, isSetLoadingView: true, button: savePassButton)
    }
    func handleResponse(response: Response<AnyObject, NSError>, requestType: RequestType) {
        if requestType == .ChangePassword {
            //            resetPasswordFields()
        }
        let result = ResponseHandler.responseHandling(response)
        if result.messageCode != MessageCode.Success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            if let error = result.messageCode {
                messageCode = error
            }
            return
        }
        // Show success alert
        self.showAlertSuccess()
    }
    
    func showAlertSuccess(){
        let alert = UIAlertController(title: LocalizedStrings.updateSuccessTitle, message: LocalizedStrings.updateSuccessMessage, preferredStyle: .Alert)
        let action = UIAlertAction(title: LocalizedStrings.okButton, style: .Default) { (action) in
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
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    private func checkFullFillRequiredFields(button: UIButton, fields: [UITextField]) {
        let isFullFilled = Validation.isFullFillRequiredFields(fields)
        
        ValidationUI.changeRequiredFieldsUI(isFullFilled, button: button)
    }
    private func isValidPasswordData() -> (isValid: Bool, title: String, message: String) {
        if !Validation.isValidLength(currentPassTextField.text!, minLength: 6, maxLength: 45) || !Validation.isValidLength(newPassTextField.text!, minLength: 6, maxLength: 45) {
            return (false, LocalizedStrings.invalidPasswordTitle, LocalizedStrings.invalidPasswordMessage)
        }
        if !Validation.matchedStrings(newPassTextField.text!, stringTwo: repeatedPassTextField.text!) {
            return (false, LocalizedStrings.notMatchedPasswordTitle, LocalizedStrings.notMatchedPasswordMessage)
        }
        return (true, "", "")
    }
    
    func keyboardWasShow(notification: NSNotification){
        let info = notification.userInfo
        let keyboardFrame : CGRect = (info![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        UIView.animateWithDuration(0.2) {
            self.savePassButton.frame.origin.y -= (keyboardFrame.origin.y + 20)
        }
    }
    //MARK: - Action
    @IBAction func onTextFieldEditingChangedAction(sender: AnyObject) {
        checkFullFillRequiredFields(savePassButton, fields: [currentPassTextField,newPassTextField,repeatedPassTextField])
    }
    @IBAction func onSaveChangePasswordAction(sender: AnyObject) {
        let validationResult = isValidPasswordData()
        dismissKeyboard()
        if !validationResult.isValid {
            // Show invalid alert
            showAlertView(validationResult.title, message: validationResult.message, requestType: nil)
            resetPasswordFields()
            return
        }
        changePasswordRequest()
    }
    
    //MARK: tableview delegate
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 6 {
            if self.view.frame.size.height > 450 {
                return (self.view.frame.size.height - 325)
            } else {
                return 150
            }
            
        } else {
            return 45
        }
    }
    
}

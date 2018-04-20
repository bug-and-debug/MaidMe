//
//  RegisterTableViewController.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 2/15/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain

protocol RegisterTableViewControllerDelegate  {
    func didDismissRegisterTableViewController()
}

class RegisterTableViewController: BaseTableViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var rememberCheckBox: UIButton!
    
    let registerAPI = RegisterService()
    let workingAreaAPI = FetchWorkingAreaService()
    
    var selectedArea: String?
    var messageCode: MessageCode?
    let paddingLeft: CGFloat = 17.0
    let textFontSize: CGFloat = 16.0
    var defaultAreaList = [WorkingArea]()
    var isAgreeWithTC: Bool = false
    var delegate: RegisterTableViewControllerDelegate?
    var selectedWorkingArea: WorkingArea?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.enabled = false
        registerButton.alpha = 0.5
        // Uncomment to show default areas in drop down list
        //createFakeDataForDefaultArea()
        self.hideBackbutton(false)
        self.navigationItem.title = "NEW USER"
        
        // Set place holder font
    //    StringHelper.setPlaceHolderFont([firstNameTextField, lastNameTextField, passwordTextField,emailTextField, phoneNumberTextField], font: CustomFont.quicksanRegular, fontsize: textFontSize)
        // disable login button
      
        // Uncomment to show default areas in drop down list
        // Fetch list of working areas
        //sendFetchWorkingAreaRequest()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        phoneNumberTextField.keyboardType = UIKeyboardType.PhonePad
        emailTextField.keyboardType = UIKeyboardType.EmailAddress
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.didDismissRegisterTableViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("Deinit the view")
    }
    
    // MARK: - IBActions
    
    @IBAction func termButton(sender: AnyObject) {
        let storyboard = self.storyboard
        guard let TermsAndConditionsVC = storyboard?.instantiateViewControllerWithIdentifier("TermsAndConditionsVC") as? TermsAndConditions else{
            return
        }
        TermsAndConditionsVC.isMoveFromRegister = true
        self.navigationController?.pushViewController(TermsAndConditionsVC, animated: true)

    }
    @IBAction func onTextFieldEditingChangedAction(sender: AnyObject) {
        checkFullFillRequiredFields()
    }
    
    private func checkFullFillRequiredFields() {
        let isFullFilled = Validation.isFullFillRequiredFields([firstNameTextField, lastNameTextField, emailTextField,passwordTextField, phoneNumberTextField])
        let isValid = isFullFilled && isAgreeWithTC
        
        ValidationUI.changeRequiredFieldsUI(isValid, button: registerButton)
    }
    
    @IBAction func onRememberMeAction(sender: AnyObject) {
        isAgreeWithTC = !isAgreeWithTC
        
        if isAgreeWithTC {
            rememberCheckBox.setImage(UIImage(named: ImageResources.checkedBox), forState: UIControlState.Normal)
            //return
        }
        else {
            rememberCheckBox.setImage(UIImage(named: ImageResources.uncheckBox), forState: UIControlState.Normal)
        }
        
        checkFullFillRequiredFields()
    }
    
    @IBAction func onRegisterAction(sender: AnyObject) {
        dismissKeyboard()
        
        let validationResult = isValidData()
        
        if !validationResult.isValid {
            // Show invalid alert
            showAlertView(validationResult.title, message: validationResult.message, requestType: nil)
            return
        }
        
        performSegueWithIdentifier(SegueIdentifiers.verifyPhoneSegue, sender: self)
    }
    
    // MARK: - Unwind segue
    
    @IBAction func backFromTermsAndConditions(segue: UIStoryboardSegue) {}
    
    // MARK: - Textfield delegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == phoneNumberTextField {
            // Reformat the number
            textField.text = StringHelper.reformatPhoneNumber(textField.text!)
        }
    }
    
    // MARK: - Validation
    
    private func isValidData() -> (isValid: Bool, title: String, message: String) {
        if !Validation.isValidLength(firstNameTextField.text!, minLength: 0, maxLength: 45) || !Validation.isValidLength(lastNameTextField.text!, minLength: 0, maxLength: 45) {
            return (false, LocalizedStrings.inValidNameTitle, LocalizedStrings.inValidNameMessage)
        }
        if !Validation.isValidRegex(emailTextField.text!, expression: ValidationExpression.email) {
            return (false, LocalizedStrings.invalidEmailTitle, LocalizedStrings.invalidEmailMessage)
        }
        
        // Uncomment to show default areas in drop down list and validate this info
        /*if !Validation.isInTheList(selectedArea!, list: defaultAreaList) {
            return (false, LocalizedStrings.invalidAreaTitle, LocalizedStrings.invalidAreaMessage)
        }*/
        
        let phone = StringHelper.getPhoneNumber(phoneNumberTextField.text!)
        if !Validation.isValidPhoneNumber(phone) {
            return (false, LocalizedStrings.inValidPhoneNumberTitle, LocalizedStrings.inValidPhoneNumberMessage)
        }
        
        if !Validation.isValidLength(passwordTextField.text!, minLength: 6, maxLength: 45) {
            return (false, LocalizedStrings.invalidPasswordTitle, LocalizedStrings.invalidPasswordMessage)
        }
        
        return (true, "", "")
    }
    
    // MARK: - API Request
    func saveRegisterAccount() {
        let userName = emailTextField.text
        let pass = passwordTextField.text
        let phoneNumber = phoneNumberTextField.text!
        if let customerName : String = firstNameTextField.text! + " " + lastNameTextField.text! {
              SSKeychain.setPassword(customerName, forService: KeychainIdentifier.appService, account: KeychainIdentifier.customerName)
        }
        SSKeychain.setPassword(userName, forService: KeychainIdentifier.appService, account: KeychainIdentifier.userName)
        SSKeychain.setPassword(pass, forService: KeychainIdentifier.appService, account: KeychainIdentifier.password)
        SSKeychain.setPassword(phoneNumber, forService: KeychainIdentifier.appService, account: KeychainIdentifier.phoneNumber)
        
    }
    func sendRegisterRequest() {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
            return
        }
        
        // Set loading view center
        setLoadingUI(.White, color: UIColor.whiteColor())
        setRequestLoadingViewCenter()
        
        guard let parameters = getParams() else {
            showAlertView(LocalizedStrings.internalErrorTitle, message: LocalizedStrings.internalErrorMessage, requestType: nil)
            return
        }
        
        startLoadingView()
        
        registerAPI.request(parameters: parameters) {
            [weak self] (response) in
            
            if let strongSelf = self {
                strongSelf.handleResponse(response)
                strongSelf.handleAPIResponse()
            }
        }
    }
    
    func sendFetchWorkingAreaRequest() {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
            setUserInteraction(false)
            return
        }
        
        startLoadingView()
        
        workingAreaAPI.request {
            [weak self] (response) in
            
            dispatch_async(dispatch_get_main_queue(), {
                if let strongSelf = self {
                    strongSelf.handleWorkingAreasListResponse(response)
                    strongSelf.handleAPIResponse()
                }
            })
        }
    }
    
    private func setRequestLoadingViewCenter() {
        let x = CGRectGetWidth(registerButton.frame) - 10
        var y: CGFloat = 100
        if let superView = registerButton.superview?.superview {
            y = CGRectGetMinY(superView.frame) + CGRectGetMaxY(registerButton.frame) - 21
        }
        setLoadingViewCenter(x, y: y)
    }
    
    private func getParams() -> [String: String]? {
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let email = emailTextField.text!
        let phone = StringHelper.getPhoneNumber(phoneNumberTextField.text!)
        let pass = StringHelper.encryptStringsha256(passwordTextField.text!) // Encrypt password
        

        
        return ["first_name": firstName,
            "last_name": lastName,
            "email": email,
            "phone": phone,
            "password": pass]
    }
    
    func handleResponse(response: Response<AnyObject, NSError>) {
        let result = ResponseHandler.responseHandling(response)
        
        if result.messageCode != MessageCode.Success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.registerFailedTitle, message: result.messageInfo, requestType: .Register)
            
            if let error = result.messageCode {
                messageCode = error
            }
            
            return
        }
        
        // Register successful
        RequestHelper.saveLoginSuccessData(result.body)
        saveRegisterAccount()
        self.performSegueWithIdentifier(SegueIdentifiers.registerSuccess, sender: self)
    }
    
    func handleWorkingAreasListResponse(response: Response<AnyObject, NSError>) {
        let result = ResponseHandler.responseHandling(response)
        
        if result.messageCode != MessageCode.Success || result.body == nil {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.connectionFailedTitle, message: result.messageInfo, requestType: .FetchWorkingArea)
            
            if let error = result.messageCode {
                messageCode = error
            }
            
            return
        }
        
        setUserInteraction(true)
        
        var list = [String]()
        var listArea = [WorkingArea]()
        
        for (_, dic) in result.body! {
            let item = WorkingArea(areaDic: dic)
            if item.areaID == nil && item.emirate != nil && item.area != nil {
                continue
            }
            
            listArea.append(item)
            list.append("\(item.emirate!) - \(item.area!)")
        }
    }
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(requestType: RequestType) {
        if requestType == .Register {
            self.sendRegisterRequest()
        }
        else if requestType == .FetchWorkingArea {
            self.sendFetchWorkingAreaRequest()
        }
    }
    
    override func handleAlertViewAction(requestType: RequestType?) {
        if requestType == .FetchWorkingArea {
            setUserInteraction(false)
        }
    }
    
    override func handleTimeoutOKAction(requestType: RequestType) {
        if requestType == .FetchWorkingArea {
            setUserInteraction(false)
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.registerSuccess {
            guard let destination = segue.destinationViewController as? CustomersAddressController else {
                return
            }
            
            destination.isMovedFromLogin = true
        }
        
        if segue.identifier == SegueIdentifiers.showWorkingAreaList {
            guard let destination = segue.destinationViewController as? UINavigationController else {
                return
            }
            guard let destinationVC = destination.viewControllers[0] as? WorkingAreaTableViewController else {
                return
            }
            
            destinationVC.delegate = self
        }
        
        if segue.identifier == SegueIdentifiers.verifyPhoneSegue {
            let navigation = segue.destinationViewController as? UINavigationController
            guard let verificationController = navigation?.viewControllers.first as? PhoneVerificationViewController else { return }

            let phone = StringHelper.getPhoneNumber(phoneNumberTextField.text!)
            verificationController.phoneNumber = phone
            verificationController.didVerifyPhoneSuccessfully = { [weak self] controller in
                guard let `self` = self else { return }
                self.sendRegisterRequest()
                controller.dismissViewControllerAnimated(true, completion: nil)
                
            }

            verificationController.didCancelPhoneVerification = { controller in
                controller.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }
    }
}

extension RegisterTableViewController: EdropdownListsDelegate {
    func didSelectItem(selectedItem: String, index: Int) {
        selectedArea = selectedItem
        checkFullFillRequiredFields()
    }
    
    func didSelectItemFromList(selectedItem: String) {
        phoneNumberTextField.becomeFirstResponder()
    }
    
    func getWorkingAreaIDFromArea(area: String?, list: [WorkingArea]) -> String? {
        guard let workingArea = area else {
            return nil
        }
        
        guard list.count > 0 else {
            return nil
        }
        
        for item in list {
            let itemName = item.emirate! + " - " + item.area!
            if workingArea.lowercaseString == itemName.lowercaseString {
                return item.areaID
            }
        }
        
        return nil
    }
}

extension RegisterTableViewController: WorkingAreaTableViewControllerDelegate {
    func didSelectArea(selectedArea: WorkingArea?) {
        self.selectedWorkingArea = selectedArea
        
        if selectedArea?.emirate != nil && selectedArea?.area != nil {
            if selectedArea?.emirate != "" && selectedArea?.area != "" {
              //  defaultAreaTextField.text = selectedArea!.emirate! + " - " + selectedArea!.area!
                checkFullFillRequiredFields()
            }
        }
    }
}

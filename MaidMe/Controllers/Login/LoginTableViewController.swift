//
//  LoginTableViewController.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 2/16/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain
import RealmSwift

class LoginTableViewController: BaseTableViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var rememberCheckBox: UIButton!
    
    let loginAPI = LoginService()
    var messageCode: MessageCode?
    var isSaveChecked: Bool = true
    var isAutoLogin: Bool = true
	let fetchAllAddresses = FetchAllBookingAddressesService()
    var addressList = [Address]()
    var selectedAddress: Address?
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
        setLoadingUI(.White, color: UIColor.whiteColor())
        passwordTextField.secureTextEntry = true
		customerSelectedAddress = nil
        // Set place holder font
        StringHelper.setPlaceHolderFont([emailTextField, passwordTextField], font: CustomFont.quicksanRegular, fontsize: 16.0)
        self.navigationController?.title = "LOGIN"
        // Enable wipe back to previous screen
        self.hideBackbutton(false)
        // check remember me
        if isSaveChecked {
            if let password = SSKeychain.passwordForService(KeychainIdentifier.appService, account: KeychainIdentifier.password) {
                passwordTextField.text = password
                if password == "" {
                    emailTextField.text = ""
                } else {
                    if let account = SSKeychain.passwordForService(KeychainIdentifier.appService, account: KeychainIdentifier.userName) {
                        emailTextField.text = account
                    }
                }
            }
    }
        // disable login button
        if emailTextField.text != ""  && passwordTextField.text != ""{
            loginButton.enabled = true
            loginButton.alpha = 1.0
            
        }
        tableView.scrollEnabled = false
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.hideBackbutton(true)
        emailTextField.keyboardType = UIKeyboardType.EmailAddress
        self.navigationController?.navigationBar.hidden = false

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Auto login if account has been save
          //  loginAuto()
        
    }
	
    // MARK: UI
    
    func loginAuto() {
        var userName: String?
        var pass: String?
        
        if let account = SSKeychain.passwordForService(KeychainIdentifier.appService, account: KeychainIdentifier.userName) {
            userName = account
        }
        if let password = SSKeychain.passwordForService(KeychainIdentifier.appService, account: KeychainIdentifier.password) {
            pass = password
        }
        
        if userName != nil && pass != nil {
            emailTextField.text = userName!
            passwordTextField.text = pass!
            
            checkFullFillRequiredFields()
            
            if isAutoLogin {
                onLoginAction(self)
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let height = screenSize.size.height
        let section = indexPath.section
        let row = indexPath.row
        if section == 0 && row == 4{
            return (height - 44.0*6)
        }
        return 44.0
    }
    // MARK: - IBActions
    
    @IBAction func onTextFieldEditingChangedAction(sender: AnyObject) {
        checkFullFillRequiredFields()
    }
    
    private func checkFullFillRequiredFields() {
        let isFullFilled = Validation.isFullFillRequiredFields([emailTextField, passwordTextField])
        ValidationUI.changeRequiredFieldsUI(isFullFilled, button: loginButton)
    }
    
    @IBAction func onLoginAction(sender: AnyObject) {
        dismissKeyboard()
        
        let validationResult = isValidData()
        
        if !validationResult.isValid {
            // Show invalid alert
            showAlertView(validationResult.title, message: validationResult.message, requestType: nil)
            return
        }
        
        // Send request to server.
        sendLoginRequest()
    }
    
    @IBAction func onRememberMeAction(sender: AnyObject) {
        isSaveChecked = !isSaveChecked
        
        if isSaveChecked {
            rememberCheckBox.setImage(UIImage(named: ImageResources.checkedBox), forState: UIControlState.Normal)
            return
        }
        
        rememberCheckBox.setImage(UIImage(named: ImageResources.uncheckBox), forState: UIControlState.Normal)
    }
    
    
    func saveLoginAccount() {
        var pass = passwordTextField.text
        
        if !isSaveChecked {
            pass = ""
        }
		
        SSKeychain.setPassword(pass, forService: KeychainIdentifier.appService, account: KeychainIdentifier.userName)
    }
    
    // MARK: - Unwind segue
    
    @IBAction func backFromForgotPassword(segue: UIStoryboardSegue) {}
    
    // MARK: - Validation
    
    private func isValidData() -> (isValid: Bool, title: String, message: String) {
        if !Validation.isValidRegex(emailTextField.text!, expression: ValidationExpression.email) {
            return (false, LocalizedStrings.invalidEmailTitle, LocalizedStrings.invalidEmailMessage)
        }
        
        if !Validation.isValidLength(passwordTextField.text!, minLength: 6, maxLength: 45) {
            return (false, LocalizedStrings.invalidPasswordTitle, LocalizedStrings.invalidPasswordMessage)
        }
        
        return (true, "", "")
    }
    
    // MARK: - API Request
    
    func fetchAllBookingAddressesRequest() {
        sendRequest(nil, request: fetchAllAddresses, requestType: .FetchAllBookingAddresses, isSetLoadingView: false)
    }
    func handleFetchAllBookingAddressesResponse(result: ResponseObject, requestType: RequestType) {
        guard let list = result.body else {
            return
        }
		
		
		var fetchedAddresses = fetchAllAddresses.getAddressList(list)
		var newService = false
		if addressList.count != fetchedAddresses.count {
			newService = true
		}else{
			for eachAddress in addressList {
				let results = fetchedAddresses.filter { $0.addressID == eachAddress.addressID }
				if results.count == 0 {
					newService = true
					break
				}
			}
		}
		
		if newService {
			// Cache service list
			addressList = fetchedAddresses
			let realm = try! Realm()
			try! realm.write {
				realm.add(fetchedAddresses, update: true)
			}
			self.tableView.reloadData()
		}
		
        for address in addressList {
            if (address.isDefault == true) {
                self.navTitleView.buildingNameLabel.text = address.buildingName
                selectedAddress = address
            }
        }
        if addressList.count == 0 {
        self.performSegueWithIdentifier(SegueIdentifiers.showDetailBookingAddress, sender: self)
        }
        else{
            //push availabel service
            self.performSegueWithIdentifier(SegueIdentifiers.loginSuccess, sender: self)
        }
    }
    func sendRequest(parameters: [String: AnyObject]?,
                     request: RequestManager,
                     requestType: RequestType,
                     isSetLoadingView: Bool) {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
            return
        }
        
        
        request.request(parameters: parameters) {
            [weak self] response in
            
            if let strongSelf = self {
                strongSelf.handleAPIResponse()
                strongSelf.handleResponse(response, requestType: requestType)
            }
        }
    }
    func handleResponse(response: Response<AnyObject, NSError>, requestType: RequestType) {
        let result = ResponseHandler.responseHandling(response)
        
        if result.messageCode != MessageCode.Success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            
            if let error = result.messageCode {
                messageCode = error
            }
            return
        }
            
        
        
        if requestType == .FetchAllBookingAddresses {
            handleFetchAllBookingAddressesResponse(result, requestType: .FetchAllBookingAddresses)
        }
        
    }
   
    func sendLoginRequest() {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
            return
        }
        
        // Set loading view center
        setRequestLoadingViewCenter(loginButton)
        
        let parameters = getParams()
        startLoadingView()
        
        loginAPI.request(parameters: parameters) {
            [weak self] response in
            
            if let strongSelf = self {
                strongSelf.handleResponse(response)
                strongSelf.handleAPIResponse()
            }
        }
    }
    
    func getParams() -> [String: String] {
        let email = emailTextField.text!
        let pass = StringHelper.encryptStringsha256(passwordTextField.text!) // Encrypt password
        
        return ["email": email,
            "password": pass,
		"decryptedPass":passwordTextField.text!]
    }
    
    func handleResponse(response: Response<AnyObject, NSError>) {
        let result = ResponseHandler.responseHandling(response)
        print(response)
        if result.messageCode != MessageCode.Success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.loginFailedTitle, message: result.messageInfo, requestType: .Login)
            
            if let error = result.messageCode {
                messageCode = error
            }
            return
        }
        
        // Login successful
        RequestHelper.saveLoginSuccessData(result.body)
		fetchAllBookingAddressesRequest()
    }
    
    
    
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(requestType: RequestType) {
        if requestType == .Login {
            self.sendLoginRequest()
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.loginSuccess {
            guard let destination = segue.destinationViewController as? AvailabelServicesViewController else {
                return
            }
            
            destination.isMovedFromLogin = true
        }
        if segue.identifier == SegueIdentifiers.showDetailBookingAddress {
            guard let destination = segue.destinationViewController as? CustomersAddressController else {
                return
            }
            
            destination.isMovedFromLogin = true
        }
        if segue.identifier == SegueIdentifiers.showRegister {
            guard let destination = segue.destinationViewController as? RegisterTableViewController else {
                return
            }
            
            destination.delegate = self
        }
        if segue.identifier == SegueIdentifiers.forgotPassword {
            guard let destination = segue.destinationViewController as? UINavigationController else {
                return
            }
            guard let destinationVC = destination.viewControllers[0] as? ForgotPassword else {
                return
            }
            
            destinationVC.delegate = self
        }
    }
}

extension LoginTableViewController: RegisterTableViewControllerDelegate {
    func didDismissRegisterTableViewController() {
        isAutoLogin = false
    }
}

//
//  PersonalDetailsTableViewController.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 4/12/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain

class PersonalDetailsTableViewController: BaseTableViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var phoneNumberTextField: UITextField!
  
    @IBOutlet weak var saveInfoButton: UIButton!
    
  
    
    let paddingLeft: CGFloat = 15.0
    var selectedArea: String?
    var selectedWorkingArea: WorkingArea?
    var messageCode: MessageCode?
    var defaultAreaList = [WorkingArea]()
    var customer: Customer!
    
    let workingAreaAPI = FetchWorkingAreaService()
    let getCustomerDetailsAPI = GetCustomerDetailsService()
    let updateCustomerDetailAPI = UpdateCustomerDetailsService()

    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCustomerDetailsRequest()
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = "PROFILE"
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.hideBackbutton(false)
        self.customBackButton()
        removeSeparatorLine()
        phoneNumberTextField.keyboardType = UIKeyboardType.PhonePad
        self.navigationController?.navigationBar.hidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI
    
    func removeSeparatorLine() {
        let cell1 = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        
        guard let tableCell1 = cell1 else {
            return
        }
        
        self.tableView.removeSeparatorLine([tableCell1])
    }
    

    
    private func setUpAreaDropdownList(areaDropdownList: EDropdownLists) {
        areaDropdownList.delegate = self
        areaDropdownList.superView = self.tableView
        areaDropdownList.placeHolder = ""//LocalizedStrings.defaultArea
        areaDropdownList.dropdownMaxHeight(250)
        let bgColor = UIColor(red: 246.0 / 255.0, green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1)
        areaDropdownList.dropdownColor(bgColor, textFieldBgColor: UIColor.clearColor(), textFieldTextColor: UIColor.blackColor(), selectedColor: UIColor(red: 255.0 / 255.0, green: 198.0 / 255.0, blue: 227.0 / 255.0, alpha: 1.0), textColor: UIColor.lightGrayColor())
        
        if let superView = areaDropdownList.superview?.superview {
            let width = CGRectGetWidth(self.view.frame) - paddingLeft * 2
            let yLocation = CGRectGetMinY(superView.frame) + CGRectGetMaxY(areaDropdownList.frame) + 6
            areaDropdownList.updateListTableFrame(yLocation, width: width)
        }
        
        areaDropdownList.dropdownTextField.leftView = nil
    }
    
    // MARK: - IBActions
    
    @IBAction func onTextFieldEditingChangedAction(sender: AnyObject) {
        guard let textField = sender as? UITextField else {
            return
        }
        
        let buttonPosition = textField.convertPoint(CGPointZero, toView: self.tableView)
        
        guard let indexPath =  self.tableView.indexPathForRowAtPoint(buttonPosition) else {
            return
        }
        
        if indexPath.section == 0 {
            checkFullFillRequiredFields(saveInfoButton, fields: [firstNameTextField, lastNameTextField, emailTextField, phoneNumberTextField])
        }
    }
    
    // MARK: - Textfield delegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == phoneNumberTextField {
            // Reformat the number
            textField.text = StringHelper.reformatPhoneNumber(textField.text!)
        }
    }
    
    // MARK: - Validation
    
    private func isValidInfoData() -> (isValid: Bool, title: String, message: String) {
        if !Validation.isValidLength(firstNameTextField.text!, minLength: 0, maxLength: 45) || !Validation.isValidLength(lastNameTextField.text!, minLength: 0, maxLength: 45) {
            return (false, LocalizedStrings.inValidNameTitle, LocalizedStrings.inValidNameMessage)
        }
        
        if !Validation.isValidRegex(emailTextField.text!, expression: ValidationExpression.email) {
            return (false, LocalizedStrings.invalidEmailTitle, LocalizedStrings.invalidEmailMessage)
        }
        
        let phone = StringHelper.getPhoneNumber(phoneNumberTextField.text!)
        if !Validation.isValidPhoneNumber(phone) {
            return (false, LocalizedStrings.inValidPhoneNumberTitle, LocalizedStrings.inValidPhoneNumberMessage)
        }
        

        
        return (true, "", "")
    }
    
    // MARK: - IBActions
    
    @IBAction func onSaveInfoAction(sender: AnyObject) {
        if firstNameTextField.text == "" || lastNameTextField.text == "" || emailTextField.text == "" || phoneNumberTextField.text == ""{
            showAlertView(LocalizedStrings.updateSuccessTitle, message: LocalizedStrings.asteriskRequiredField, requestType: nil)
            return
        }
        let validationResult = isValidInfoData()
        dismissKeyboard()
        
        if !validationResult.isValid {
            // Show invalid alert
            showAlertView(validationResult.title, message: validationResult.message, requestType: nil)
            return
        }
        
        updateCustomerDetailsRequest()
    }
    
    private func checkFullFillRequiredFields(button: UIButton, fields: [UITextField]) {
        let isFullFilled = Validation.isFullFillRequiredFields(fields)
        
        ValidationUI.changeRequiredFieldsUI(isFullFilled, button: button)
    }
    
    // MARK: - API
    
    func fetchDefaultAreaRequest() {
        sendRequest(nil, request: workingAreaAPI, requestType: .FetchWorkingArea, isSetLoadingView: false, button: nil)
    }
    
    func fetchCustomerDetailsRequest() {
        sendRequest(nil, request: getCustomerDetailsAPI, requestType: .FetchCustomerDetails, isSetLoadingView: false, button: nil)
    }
    
    func updateCustomerDetailsRequest() {
        customer.firstName = firstNameTextField.text
        customer.lastName = lastNameTextField.text
        customer.phone = StringHelper.getPhoneNumber(phoneNumberTextField.text!)
        
        let params = updateCustomerDetailAPI.getParams(customer)
        sendRequest(params, request: updateCustomerDetailAPI, requestType: .UpdateCustomerDetails, isSetLoadingView: true, button: saveInfoButton)
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
            if isSetLoadingView {
                setLoadingUI(.White, color: UIColor.whiteColor())
                self.setRequestLoadingViewCenter(button!)
            }
            self.startLoadingView()
            
            request.request(parameters: parameters) {
                [weak self] response in
                
                if let strongSelf = self {
                    strongSelf.handleAPIResponse()
                    strongSelf.handleResponse(response, requestType: requestType)
                }
            }
    }
    func saveCustomerInfo() {
        let phoneNumber = customer.phone
        if let customerName: String = customer.firstName! + " " + customer.lastName! {
            SSKeychain.setPassword(customerName, forService: KeychainIdentifier.appService, account: KeychainIdentifier.customerName)
        }
        SSKeychain.setPassword(phoneNumber, forService: KeychainIdentifier.appService, account: KeychainIdentifier.phoneNumber)
        customer.defaultArea = selectedWorkingArea
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
        
        if requestType == .FetchWorkingArea {
            handleFetchWorkingAreaResponse(result, requestType: .FetchWorkingArea)
        }
        else if requestType == .FetchCustomerDetails {
            handleFetchCustomerDetailsResponse(result, requestType: .FetchCustomerDetails)
        }
        else if requestType == .UpdateCustomerDetails {
            // Show success alert
             saveCustomerInfo()
            showAlertView(LocalizedStrings.updateSuccessTitle, message: LocalizedStrings.updateProfileSuccess, requestType: nil)

        }
    }
    override func handleAlertViewAction(requestType: RequestType?) {
            self.navigationController?.popToRootViewControllerAnimated(true)
    }
    func handleFetchWorkingAreaResponse(result: ResponseObject, requestType: RequestType) {
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
        
        defaultAreaList = listArea

    }
    
    func handleFetchCustomerDetailsResponse(result: ResponseObject, requestType: RequestType) {
        guard let body = result.body else {
            return
        }
        
        customer = Customer(customerDic: body)
        
        firstNameTextField.text = customer.firstName
        lastNameTextField.text = customer.lastName
        emailTextField.text = customer.email
        phoneNumberTextField.text = StringHelper.reformatPhoneNumber(customer.phone == nil ? "" : customer.phone!)
        
        checkFullFillRequiredFields(saveInfoButton, fields: [firstNameTextField, lastNameTextField, emailTextField, phoneNumberTextField])
        
        // Fetch working area.
        fetchDefaultAreaRequest()
    }
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(requestType: RequestType) {
        if requestType == .FetchWorkingArea {
            self.fetchDefaultAreaRequest()
        }
        else if requestType == .FetchCustomerDetails {
            self.fetchCustomerDetailsRequest()
        }
        else if requestType == .UpdateCustomerDetails {
            self.updateCustomerDetailsRequest()
        }
}
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 8 {
            if self.view.frame.size.height > 460 {
                return (self.view.frame.size.height - 380)
            } else {
                return 150
            }
        } else {
            return 42
        }
        
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.showWorkingAreaList {
            guard let destination = segue.destinationViewController as? UINavigationController else {
                return
            }
            guard let destinationVC = destination.viewControllers[0] as? WorkingAreaTableViewController else {
                return
            }
            destinationVC.delegate = self
        }
    }
}

// MARK: - EdropdownListsDelegate

extension PersonalDetailsTableViewController: EdropdownListsDelegate {
    func didSelectItem(selectedItem: String, index: Int) {
        selectedArea = selectedItem
        checkFullFillRequiredFields(saveInfoButton, fields: [firstNameTextField, lastNameTextField, emailTextField, phoneNumberTextField])
    }
    
    func didSelectItemFromList(selectedItem: String) {
//        areaDropdownList.dropdownTextField.endEditing(true)
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

extension PersonalDetailsTableViewController: WorkingAreaTableViewControllerDelegate {
    func didSelectArea(selectedArea: WorkingArea?) {
        self.selectedWorkingArea = selectedArea
        
        if selectedArea?.emirate != nil && selectedArea?.area != nil {
            if selectedArea?.emirate != "" && selectedArea?.area != "" {
               
                checkFullFillRequiredFields(saveInfoButton, fields: [firstNameTextField, lastNameTextField, emailTextField, phoneNumberTextField])
            }
        }
    }
}

//
//  RebookingViewController.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 5/23/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import SSKeychain

protocol RebookingViewControllerDelegate {
    func didDismissRebooking(isRebook: Bool, params: Booking,hour: Int,selectedService: WorkingService,bookingAdress: Address,addresList:[Address])
}

class RebookingViewController: BaseViewController {
    
    @IBOutlet weak var hourView: SelectValueView!
    @IBOutlet weak var serviceDropDownList: EDropdownList!
    @IBOutlet weak var addressDropList: EDropdownList!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    
    let fetchServiceTypeAPI = GetAvailableServicesOfMaidService()
    let getMinPeriodWorkingHourAPI = GetMinPeriodWorkingHourService()
    var isFindWorker: Bool!
    var serviceList = [WorkingService]()
    var delegate: RebookingViewControllerDelegate?
    var booking: Booking!
    var customerAddressList = [Address]()
    var selectedService: WorkingService?
    var rebookingAddress : Address?
    
    var addressBookingAvailableList = [Address]()
    
    let fetchAllAddresses = FetchAllBookingAddressesService()
    var searcOptionRebookParams : [String: String]?
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        showRebookingInfo()
        getMinPeriodWorkingHourRequest()
        fetchAllBookingAddressesRequest()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupDropdown()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func selectService(){
        serviceDropDownList.delegate = self
        addressDropList.delegate = nil
        addressDropList.hideDropdownList(true)
    }
    
    func selectAddress(){
        addressDropList.delegate = self
        serviceDropDownList.delegate = nil
        serviceDropDownList.hideDropdownList(true)
    }
    func setupDropdown(){
        setupDropDownList(serviceDropDownList)
        setupDropDownList(addressDropList)
        serviceDropDownList.dropdownButton.addTarget(self, action: #selector(selectService), forControlEvents: .TouchUpInside)
        addressDropList.dropdownButton.addTarget(self, action: #selector(selectAddress), forControlEvents: .TouchUpInside)
        var listAddressString = [String]()
        var listServiceString = [String]()
        for address in addressBookingAvailableList {
            listAddressString.append(address.buildingName)
        }
        for service in serviceList {
            listServiceString.append(service.name!)
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.reloadServiceList(listServiceString)
            self.reloadAddressList(listAddressString)
        })
    }
    // MARK: - IBActions
    
    @IBAction func onFindAction(sender: AnyObject) {
        isFindWorker = true
        self.dismissViewControllerAnimated(true, completion: nil)
        delegate?.didDismissRebooking(isFindWorker, params: getParams(), hour: hourView.currentValue, selectedService: selectedService!,bookingAdress: rebookingAddress!,addresList: customerAddressList)
    }
    
    @IBAction func onCancelAction(sender: AnyObject) {
        isFindWorker = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Data & UI
    func setupDropDownList(dropList : EDropdownList) {
        let dropDownTextColor = UIColor(red: 85.0 / 255.0, green: 85.0 / 255.0, blue: 85.0 / 255.0, alpha: 1.0)
        
        dropList.fontSize = 19.0
        dropList.dropdownMaxHeight(200)
        dropList.dropdownColor(UIColor.whiteColor(), buttonBgColor: UIColor.clearColor(), buttonTextColor: dropDownTextColor, selectedColor: UIColor(red: 255.0 / 255.0, green: 198.0 / 255.0, blue: 227.0 / 255.0, alpha: 1.0), textColor: UIColor.lightGrayColor())
        dropList.downArrow = ImageResources.arrowDown
        dropList.upArrow = ImageResources.arrowUp
        
        let minX = CGRectGetWidth(self.view.frame) * 0.04
        if let _ = dropList.superview {
            let width = CGRectGetWidth(self.view.frame) - CGRectGetMinX(dropList.frame) - 13.0 - minX
            let yLocation = CGRectGetMaxY(dropList.frame)
            dropList.updateListTableFrame(yLocation, width: width)
        }
    }
    
    func showRebookingInfo() {
        workerNameLabel.text = "Rebook " + booking.workerName!
    }
    
    // MARK: - API
    
    
    func getMinPeriodWorkingHourRequest() {
        let params = fetchServiceTypeAPI.getParams(booking.workerID!)
        sendRequest(params, request: getMinPeriodWorkingHourAPI, requestType: .GetMinPeriodWorkingHour, isSetLoadingView: false, view: nil)
    }
    
    func sendRequest(parameters: [String: AnyObject]?,
                     request: RequestManager,
                     requestType: RequestType,
                     isSetLoadingView: Bool, view: UIView?) {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
            return
        }
        
        // Set loading view center
        if isSetLoadingView && view != nil {
            self.setRequestLoadingViewCenter1(view!)
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
    
    func handleResponse(response: Response<AnyObject, NSError>, requestType: RequestType) {
        let result = ResponseHandler.responseHandling(response)
        
        if result.messageCode != MessageCode.Success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            ValidationUI.changeRequiredFieldsUI(false, button: findButton)
            return
        }
		
		self.stopLoadingView()
        setUserInteraction(true)
        
        if requestType == .GetMinPeriodWorkingHour {
            handleGetMinPeriodWorkingHour(result, requestType: .GetMinPeriodWorkingHour)
        } else if requestType == .FetchAllBookingAddresses {
            handleFetchAllBookingAddressesResponse(result, requestType: .FetchAllBookingAddresses)
        }
    }
    
    //Fetch all address
    func fetchAllBookingAddressesRequest() {
        sendRequest(nil, request: fetchAllAddresses, requestType: .FetchAllBookingAddresses, isSetLoadingView: true, view: nil)
    }
    func handleFetchAllBookingAddressesResponse(result: ResponseObject, requestType: RequestType) {
        
        guard let list = result.body else {
            return
        }
		
        customerAddressList = fetchAllAddresses.getAddressList(list)
		
    }
    
    
    func handleGetMinPeriodWorkingHour(result: ResponseObject, requestType: RequestType) {
        guard let body = result.body else {
            return
        }
        
        let mins = (body["min_period_working_hour"].int == nil ? 0 : body["min_period_working_hour"].int!)
        let minHour = ceil(Double(mins) / Double(60))
        
        // Update the min value of hour view.
        hourView.minValue = Int(minHour)
    }
   
    func reloadServiceList(listServiceString: [String]) {
        if listServiceString.count == 0 {
            ValidationUI.changeRequiredFieldsUI(false, button: findButton)
            serviceDropDownList.disableSelecting(true)
        }
        else {
            ValidationUI.changeRequiredFieldsUI(true, button: findButton)
            serviceDropDownList.disableSelecting(false)
        }
        
        serviceDropDownList.reloadList(listServiceString)
        if serviceList.count > 0 {
            // Set the default selected value
            let defaultIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            serviceDropDownList.listTable.selectRowAtIndexPath(defaultIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
            selectedService = serviceList[0]
            serviceDropDownList.placeHolder = serviceDropDownList.valueList[0]
        }
    }
    func reloadAddressList(listAddressString: [String]) {
        if listAddressString.count == 0 {
            ValidationUI.changeRequiredFieldsUI(false, button: findButton)
            addressDropList.disableSelecting(true)
        }
        else {
            ValidationUI.changeRequiredFieldsUI(true, button: findButton)
            addressDropList.disableSelecting(false)
        }
        
        addressDropList.reloadList(listAddressString)
        
        if addressBookingAvailableList.count > 0 {
            // Set the default selected value
            let defaultIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            addressDropList.listTable.selectRowAtIndexPath(defaultIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
            rebookingAddress = addressBookingAvailableList[0]
            addressDropList.placeHolder = cutString(addressDropList.valueList[0])
        }
    }
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(requestType: RequestType) {
        
        if requestType == .GetMinPeriodWorkingHour {
            getMinPeriodWorkingHourRequest()
        }
    }
    
    func getParams() -> Booking {
        return Booking(bookingID: nil, workerName: nil, workerID: booking.workerID, time: nil, service: selectedService!, workingAreaRef: booking.workingAreaRef, hours: hourView.currentValue, price: nil, materialPrice: nil, payerCard: nil,avartar: nil,maid: nil)
    }
}


// MARK: - EdropdownListDelegate

extension RebookingViewController: EdropdownListDelegate {
    func didSelectItem(selectedItem: String, index: Int) {
        if addressDropList.delegate != nil {
            rebookingAddress = addressBookingAvailableList[index]
        }
        if serviceDropDownList.delegate != nil {
            selectedService = serviceList[index]
        }
    }
}

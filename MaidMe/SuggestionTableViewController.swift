//
//  SuggestionTableViewController.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 1/11/17.
//  Copyright © 2017 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain
import RealmSwift

var isReloadSuggestion : Bool?
class SuggestionTableViewController: BaseTableViewController {
    
    @IBOutlet weak var noResultLabel: UILabel!
    
    
    var suggestionWorkerAPI = FetchSuggestedWorkerService()
    let fetchAllAddresses = FetchAllBookingAddressesService()
    let getCustomerDetailsAPI = GetCustomerDetailsService()
    var addressList = [Address]()
    
    var selectedAddress: Address?
    var messageCode : MessageCode?
    var sugesstionWorkerParams : [String : AnyObject]?
    var suggestedWorkers : [SuggesstedWorker]?
    var selectedIndex : Int?
    var ratingList = [Rating]()
    var customer: Customer!
    var timesShowRatingAndComment = 0
    var indexItemBookingList = 0
    var isPopView: Bool?
    var isObserver: Bool?
    var refreshItemControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isPopView = false
		
		let realm = try! Realm()
		let cachedAddresses = realm.objects(Address.self)
		if cachedAddresses.count > 0 {
			addressList = Array(cachedAddresses)
		}
		
        fetchAllBookingAddressesRequest()
        fetchCustomerDetailsRequest()
        setupRefreshControl()
        refreshItemControl.addTarget(self, action: #selector(SuggestionTableViewController.Refresh), forControlEvents: UIControlEvents.ValueChanged)
		
		if let cachedAddressName: String = NSUserDefaults.standardUserDefaults().stringForKey("cachedAddressName"){
			self.navTitleView.buildingNameLabel.text = cachedAddressName
		}
    }
    func Refresh(){
        sendFetchSuggestionWorkerRequest()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.hideTableEmptyCell()
        setNoResultLabelFrame()
        setDefaultUIForLoadingIndicator()
        setupMenuAddressButton()
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBar.hidden = false
        self.navTitleView.showListAddressButton.addTarget(self, action: #selector(showAddressMenu), forControlEvents: .TouchUpInside)
        let topView = UIView()
        topView.backgroundColor = UIColor(red: 91/255, green: 194/255, blue: 209/255, alpha: 1)
        topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1)
        self.tabBarController?.tabBar.addSubview(topView)
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        isPopView = true
        isObserver = false
        isReloadSuggestion = false
    }
    override func viewDidAppear(animated: Bool) {
        if customerSelectedAddress != nil && customerSelectedAddress?.addressID != selectedAddress?.addressID  {
           
            selectedAddress = customerSelectedAddress
            if let buildingName = selectedAddress?.buildingName {
                self.navTitleView.buildingNameLabel.text = cutString(buildingName)
            }
            if isPopView != false{
                sendFetchSuggestionWorkerRequest()
            }
        }
		
        if isReloadSuggestion == true {
            updateSuggestion()
        }
     
    }
    
    // MARK: - UI
    
    func setupRefreshControl() {
        refreshItemControl = UIRefreshControl()
        refreshItemControl.backgroundColor = UIColor(red: 173.0 / 255.0, green: 185.0 / 255.0, blue: 202.0 / 255.0, alpha: 0.3)
        refreshItemControl.tintColor = UIColor.lightGrayColor()
        tableView.addSubview(refreshItemControl)
    }
    func stopRefreshing() {
        if refreshItemControl.refreshing {
            refreshItemControl.endRefreshing()
        }
    }

    override func setDefaultUIForLoadingIndicator() {
        self.loadingIndicator.activityIndicatorViewStyle = .WhiteLarge
        self.loadingIndicator.color = UIColor.blackColor()
        if let window = UIApplication.sharedApplication().keyWindow {
            self.loadingIndicator.center = window.center
            window.addSubview(self.loadingIndicator)
        }
    }
    func updateSuggestion(){
        isObserver = true
        isPopView = false
        fetchAllBookingAddressesRequest()
    }
    
    func showAddressMenu() {
        if addressList.count > 1{
        let storyboard = self.storyboard
        guard let addressMenu = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIDs.customerAddressMenu) as? AddressMenu else {
            return
        }
        addressMenu.suggestedWorkerVC = self
        addressMenu.addressList = self.addressList
        addressMenu.navController = self.navigationController
        addressMenu.currentViewController = self
        addressMenu.view.backgroundColor = .clearColor()
        addressMenu.modalPresentationStyle = .OverCurrentContext
        self.presentViewController(addressMenu, animated: true, completion: nil)
        }
    }

    
    func selectAddressFromAddressMenu(address : Address) {
        self.selectedAddress = address
        if let buildingName: String = selectedAddress?.buildingName! {
                self.navTitleView.buildingNameLabel.text = cutString(buildingName)
        }
        self.selectedAddress = address
        sugesstionWorkerParams = suggestionWorkerAPI.getSuggestionWorkerParams(address)
        sendFetchSuggestionWorkerRequest()
    }
    
    func setNoResultLabelFrame() {
    noResultLabel.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height - 44)
    }
    func sendFetchSuggestionWorkerRequest () {
        sugesstionWorkerParams = suggestionWorkerAPI.getSuggestionWorkerParams((selectedAddress)!)
        sendRequest(sugesstionWorkerParams, request: suggestionWorkerAPI, requestType: .FetchSugesstedWorker, isSetLoadingView: true, button: nil)
    }
    func fetchCustomerDetailsRequest() {
        sendRequest(nil, request: getCustomerDetailsAPI, requestType: .FetchCustomerDetails, isSetLoadingView: false, button: nil)
    }
    func fetchAllBookingAddressesRequest() {
        sendRequest(nil, request: fetchAllAddresses, requestType: .FetchAllBookingAddresses, isSetLoadingView: false,button: nil)
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

		self.startLoadingView()

        request.request(parameters: parameters) {
            [weak self] response in

            if let strongSelf = self {
//                strongSelf.handleAPIResponse()
                strongSelf.handleResponse(response, requestType: requestType)
            }
        }
    }
 
    


    func handleResponse(response: Response<AnyObject, NSError>, requestType: RequestType) {
        let result = ResponseHandler.responseHandling(response)
        //end refresh
        stopRefreshing()
		if suggestedWorkers?.count > 0 || (requestType == .FetchAllBookingAddresses && addressList.count == 0){
			stopLoadingView()
		}
        if result.messageCode != MessageCode.Success {
            // Show alert
            print("ERROR")
            print("msssage info \(result.messageInfo)")
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            if let error = result.messageCode {
                messageCode = error
            }
            return
        }
        if requestType == .FetchAllBookingAddresses {
            handleFetchAllBookingAddressesResponse(result, requestType: .FetchAllBookingAddresses)
        }
        else if  requestType == .FetchSugesstedWorker {
            handleFetchSuggestedWorkersResponse(result, requestType: .FetchSugesstedWorker)
        } else if requestType == .FetchCustomerDetails {
            handleFetchCustomerDetailsResponse(result, requestType: .FetchCustomerDetails)
        }
		
    }
    
    func handleFetchSuggestedWorkersResponse(result: ResponseObject, requestType: RequestType) {
        setUserInteraction(true)
        suggestedWorkers = suggestionWorkerAPI.getSuggesstedWorkerList(result.body!)
		stopLoadingView()
        if suggestedWorkers == nil || suggestedWorkers?.count == 0 {
            showNoResultLabel(true)
        }
        else {
            showNoResultLabel(false)
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    func handleFetchCustomerDetailsResponse(result: ResponseObject, requestType: RequestType) {
        guard let body = result.body else {
            return
        }
        
        customer = Customer(customerDic: body)
        saveCustomerInfo()
        
    }
    func saveCustomerInfo() {
        let phoneNumber = customer.phone
        let userName = customer.email
        if let customerName: String = customer.firstName! + " " + customer.lastName! {
            SSKeychain.setPassword(customerName, forService: KeychainIdentifier.appService, account: KeychainIdentifier.customerName)
        }
        SSKeychain.setPassword(phoneNumber, forService: KeychainIdentifier.appService, account: KeychainIdentifier.phoneNumber)
        SSKeychain.setPassword(userName, forService: KeychainIdentifier.appService, account: KeychainIdentifier.userName)
    }
    func handleFetchAllBookingAddressesResponse(result: ResponseObject, requestType: RequestType) {
        guard let list = result.body else {
            return
        }
        addressList = fetchAllAddresses.getAddressList(list)
        if addressList.count == 1{
            self.navTitleView.dropDownImage.image = UIImage(named: "")
        } else {
            self.navTitleView.dropDownImage.image = UIImage(named: "dropIcon")
        }
       
        for address in addressList {
            if (address.isDefault == true) {
                self.selectedAddress = address
            }
        }
        
        if let buildingNAME: String = selectedAddress?.buildingName{
            self.navTitleView.buildingNameLabel.text = cutString(buildingNAME)
        }
        sendFetchSuggestionWorkerRequest()
    }
    func showNoResultLabel(flag: Bool) {
        if flag {
            tableView.addSubview(noResultLabel)
            return
        }
        noResultLabel.removeFromSuperview()
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if suggestedWorkers?.count == 0 {
            return tableView.frame.size.height - 40
        }
        return super.tableView(self.tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let suggestedWorkers = suggestedWorkers else {
            return 0
        }
        return (suggestedWorkers.count)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellID = "suggestedWorkerCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as? SuggestedWorkerCell
        cell?.backgroundColor = UIColor.whiteColor()
        if cell == nil {
            cell = SuggestedWorkerCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellID)
        }
        if suggestedWorkers != nil {
            cell?.showWorkerInfo(suggestedWorkers![indexPath.row])
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
        self.tabBarController?.tabBar.hidden = true
        self.performSegueWithIdentifier(SegueIdentifiers.showScheduleDetail, sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.showScheduleDetail {
            guard let destination = segue.destinationViewController as? ScheduleAndDetail else {
                return
            }
            guard let selectedIndex = selectedIndex else {
                return
            }
            guard let suggestedWorkers = suggestedWorkers else {
                return
            }
            let suggestedWorker = suggestedWorkers[selectedIndex]
            
            let avatar = suggestedWorker.avartar
            let workerName = suggestedWorker.firstName! + " " + suggestedWorker.lastName!
            
            let bookingPrice = suggestedWorker.price
            let bookingMaterialPrice = suggestedWorker.materialPrice
            let workerID = suggestedWorker.workerID
            let time = suggestedWorker.availableTime
            destination.tabbarDelegate = self
            destination.booking = Booking(bookingID: nil, workerName: workerName, workerID: workerID, time: NSDate(timeIntervalSince1970: time / 1000), service: suggestedWorker.serviceType, workingAreaRef: nil, hours: suggestedWorker.hour, price: bookingPrice, materialPrice: bookingMaterialPrice, payerCard: nil, avartar: avatar,maid: Worker(suggestedWorker: suggestedWorker) )
            destination.address = selectedAddress!
            destination.navController = self.navigationController
            destination.currentViewController = self
        }
        if segue.identifier == SegueIdentifiers.giveCommentAndRating {
            guard let commentAndRatingVC = segue.destinationViewController as? GiveRatingTableViewController else {
                return
            }
            commentAndRatingVC.listBookingDoneWithoutRating2 = ratingList
            commentAndRatingVC.timesShow = timesShowRatingAndComment
            commentAndRatingVC.indexItemShow = indexItemBookingList
            commentAndRatingVC.delegate = self
        }
    }
}
extension SuggestionTableViewController: showTabbarDelegate,UITabBarDelegate {
    func showTabar(visable: Bool) {
        self.tabBarController?.tabBar.hidden = visable
    }
}
extension SuggestionTableViewController: GiveRatingTableViewControllerDelegate {
    func didDismissRatingAndCommentBooking(isSubmitted: Bool) {
        if isSubmitted {
            timesShowRatingAndComment = timesShowRatingAndComment - 1
            indexItemBookingList = indexItemBookingList + 1
//            prepareToRatingAndComment()
        }
        else {
        }
    }
}

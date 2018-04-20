//
//  SearchResultsViewController.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 12/8/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SWTableViewCell
import Alamofire
import EasyTipView

var isReloadSearchResult: Bool?
class SearchResultsViewController: BaseTableViewController {
    
    
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var menuHomeButton: UIButton!
    
    var selectedIndex: Int?
    var availableWorkerParams: [String: AnyObject]?
    var availableWorkers: [Worker]?
    var messageCode: MessageCode?
    let availableWorkerAPI = FetchAvailableWorkerService()
    let rebookAPI = RebookGetTimeOptionsService()
    var isRebook: Bool?
    var rebookParams: [String: AnyObject]?
    var workService: WorkingService?
    var serviceList = [WorkingService]()
    var booking: Booking?
    var hour : Int?
    var searchTime:Double?
    var asap : Bool?
    var selectedAddress: Address?
     var isMoveFromSearchDetails : Bool?
    var isMoveFromRebook : Bool?
    var addressList = [Address]()
    var customer: Customer?
	var tipView : EasyTipView?
	
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customBackButton()
        guard let _ = isRebook else {
            sendFetchAvailableWorkerRequest()
            return
        }
        // Rebook a maid
        rebookParams = rebookAPI.getParams(booking!, addressID: selectedAddress!.addressID)
        rebookAMaidRequest()
		
	}
	
	override func scrollViewDidScroll(scrollView: UIScrollView) {
		tipView?.dismiss()
	}
	
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if addressList.count == 1{
            self.navTitleView.dropDownImage.image = UIImage(named: "")
        } else {
            self.navTitleView.dropDownImage.image = UIImage(named: "dropIcon")
        }
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        setupView()
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isReloadSearchResult == true && isMoveFromSearchDetails != true && isMoveFromRebook != true {
            updateAddressObeserver()
        }
        }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        isReloadSearchResult = false
        isMoveFromRebook = false
        isMoveFromSearchDetails = false
            }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
    }
    func updateAddressObeserver() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func setupView() {
        setNoResultLabelFrame()
        setupTableView()
        setupMenuAddressButton()
        setDefaultUIForLoadingIndicator()
        self.navTitleView.showListAddressButton.addTarget(self, action: #selector(handlerCustomerAddressMenu), forControlEvents: .TouchUpInside)
        if let buildingName: String = selectedAddress?.buildingName! {
            self.navTitleView.buildingNameLabel.text = cutString(buildingName)        }
        tableView.hideTableEmptyCell()
        self.hideBackbutton(false)
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.translucent = false
         self.view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    
    }
    
    // MARK: - UI
    func setNoResultLabelFrame() {
//        noResultLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(noResultLabel.frame))
        noResultLabel.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height - 44)
    }
    func setupTableView(){
        self.tableView.separatorStyle = .None
    }
    override func setDefaultUIForLoadingIndicator() {
        self.loadingIndicator.activityIndicatorViewStyle = .WhiteLarge
        self.loadingIndicator.color = UIColor.blackColor()
        if let window = UIApplication.sharedApplication().keyWindow {
            self.loadingIndicator.center = window.center
            window.addSubview(self.loadingIndicator)
        }
    }
    // MARK: - API
    
    func sendFetchAvailableWorkerRequest() {
        print("Available params: ", availableWorkerParams)
        sendRequest(availableWorkerParams, request: availableWorkerAPI, requestType: .FetchAvailableWorker, isSetLoadingView: true, view: nil)
    }
    
    func rebookAMaidRequest() {
        print("Rebook params: ", rebookParams)
        sendRequest(rebookParams, request: rebookAPI, requestType: .RebookAMaid, isSetLoadingView: true, view: nil)
        
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
            if let error = result.messageCode {
                messageCode = error
            }
            if let _ = availableWorkers {
                availableWorkers = nil
                tableView.reloadData()
            }
            showNoResultLabel(true)
            return
        }
        setUserInteraction(true)
        if requestType == .FetchAvailableWorker || requestType == .RebookAMaid {
            handleFetchAvailableWorkersResponse(result, requestType: .FetchAvailableWorker, response: response)
        }
    }
    
	func handleFetchAvailableWorkersResponse(result: ResponseObject, requestType: RequestType, response: Response<AnyObject, NSError>) {
        setUserInteraction(true)
        availableWorkers = availableWorkerAPI.getWorkerList(result.body!)
		var isSuggested = 0
		if response.data != nil {
			let jsonData: NSData = response.data!
			let jsonDict = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) as! NSDictionary
			if jsonDict.allKeys.count > 0 {
				isSuggested = jsonDict["messageInfo"]!["isSuggested"] as! Int
			}
		}

		if isSuggested == 1 {
			var preferences = EasyTipView.Preferences()
			preferences.drawing.font = UIFont.systemFontOfSize(13)
			preferences.drawing.foregroundColor = UIColor.whiteColor()
			preferences.drawing.backgroundColor = UIColor(red:0.27, green:0.68, blue:0.75, alpha:1.00)
			preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.Top
			EasyTipView.globalPreferences = preferences
			tipView = EasyTipView(text: "We couldn't find available options for the selected time, but here is what we recommend.", preferences: preferences)
			tipView?.show(animated: true, forView: self.navigationItem.titleView!, withinSuperview: self.navigationController?.view)
		}
		
        if availableWorkers == nil || availableWorkers?.count == 0 {
            showNoResultLabel(true)
        }
        else {
            showNoResultLabel(false)
        }

        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    func showNoResultLabel(flag: Bool) {
        if flag {
            tableView.addSubview(noResultLabel)
            return
        }
        
        noResultLabel.removeFromSuperview()
    }
	
	
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(requestType: RequestType) {
        if requestType == .FetchAvailableWorker {
            self.sendFetchAvailableWorkerRequest()
        }
    }
    override func handleAlertViewAction(requestType: RequestType?) {
        if requestType == .FetchAvailableWorker {
            setUserInteraction(true)
        }
    }
    override func handleTimeoutOKAction(requestType: RequestType) {
        if requestType == .FetchAvailableWorker {
            setUserInteraction(true)
        }
    }
    // MARK : - Home Menu
    @IBAction func handlerCustomerAddressMenu(sender: AnyObject) {
        self.showCustomerAddressMenu()
    }
    func showCustomerAddressMenu() {
        if addressList.count > 1 {
        let storyboard = self.storyboard
        guard let addressMenu = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIDs.customerAddressMenu) as? AddressMenu else {
            return
        }
        addressMenu.searchResultsVC = self
        addressMenu.addressList = self.addressList
        addressMenu.navController = self.navigationController
        addressMenu.currentViewController = self
        addressMenu.view.backgroundColor = .clearColor()
        addressMenu.modalPresentationStyle = .OverCurrentContext
            self.presentViewController(addressMenu, animated: false, completion: nil)
        }

    }
    func fetchSearchResultsWithAreaId(areaId: String,address: Address?){
        if let buildingName: String = address?.buildingName! {
            self.navTitleView.buildingNameLabel.text = cutString(buildingName)
        }
        self.selectedAddress = address
        if isRebook != true {
            availableWorkerParams = ["service_id": getServiceIDFromService(self.workService?.name, list: self.serviceList), "asap": asap!, "date_time": self.searchTime!, "area_id": areaId, "hours": self.hour!]
            sendFetchAvailableWorkerRequest()
            self.tableView.reloadData()
        } else {
            print("REBOOKING")
            booking =  Booking(bookingID: nil, workerName: nil, workerID: booking!.workerID, time: nil, service: workService, workingAreaRef: nil, hours: hour, price: nil, materialPrice: nil, payerCard: nil,avartar: nil,maid: nil)
            rebookParams = rebookAPI.getParams(booking!, addressID: address?.addressID)
            rebookAMaidRequest()
        }
    }
    
    // MARK: - Table view data source
     override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if availableWorkers?.count == 0 {
            return self.tableView.frame.size.height - 44
        }
        
        return super.tableView(self.tableView, heightForRowAtIndexPath: indexPath)
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let availableWorkers = availableWorkers else {
            return 0
        }
        return availableWorkers.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchResultsCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? SearchResultsCell
            cell?.backgroundColor = UIColor.whiteColor()
        if cell == nil {
            cell = SearchResultsCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        if availableWorkers != nil {
            if let workService = workService, let hour = hour {
                cell!.showWorkerInfo(availableWorkers![indexPath.row], service: workService, hour: hour)
            }
        }
        // NOTE DEMO: Uncomment to roll back
//        cell!.setRightUtilityButtons(self.rightButtons() as [AnyObject], withButtonWidth: 80.0)
//        cell!.delegate = self
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
        self.tabBarController?.tabBar.hidden = true
        performSegueWithIdentifier(SegueIdentifiers.showScheduleDetail, sender: indexPath.row)
    }
    // MARK: - Utilities button
    func rightButtons() -> NSMutableArray {
        let leftUtilityButtons = NSMutableArray()
        leftUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 91.0 / 255.0, green: 194.0 / 255.0, blue: 209.0 / 255.0, alpha: 1.0), icon: UIImage(named: ImageResources.feedback))
        return leftUtilityButtons
    }
    // MARK: - Unwind segue
    @IBAction func backFromPayment(segue: UIStoryboardSegue) {}
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.showScheduleDetail {
            guard let destination = segue.destinationViewController as? ScheduleAndDetail else {
                return
            }
            guard let selectedIndex = selectedIndex else {
                return
            }
            guard let availableWorkers = availableWorkers else {
                return
            }
            let worker = availableWorkers[selectedIndex]
            self.booking?.avartar = worker.avartar
            self.booking?.workerName = worker.firstName! + " " + worker.lastName!
            self.booking?.price = worker.price
            self.booking?.materialPrice = worker.materialPrice
            self.booking?.workerID = worker.workerID
            self.booking?.maid = worker
            
            if worker.availableTime != 0{
                self.booking?.time = NSDate(timeIntervalSince1970: worker.availableTime / 1000)
            }
            destination.booking = self.booking
            destination.tabbarDelegate = self
            destination.address = selectedAddress!
            destination.navController = self.navigationController
            destination.currentViewController = self
        }
        else if segue.identifier == SegueIdentifiers.showWorkerProfile {
            guard let destination = segue.destinationViewController as? MaidProfileTableViewController else {
                return
            }
            guard let selectedIndex = selectedIndex else {
                return
            }
            guard let availableWorkers = availableWorkers else {
                return
            }
            let worker = availableWorkers[selectedIndex]
            destination.maid = worker
        }
    }
}
extension SearchResultsViewController: SWTableViewCellDelegate {
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        switch (index) {
        case 0:
            cell.hideUtilityButtonsAnimated(true)
            let index = self.tableView.indexPathForCell(cell)
            selectedIndex = index?.row
            self.performSegueWithIdentifier(SegueIdentifiers.showWorkerProfile, sender: self)
            break
        default:
            break
        }
    }
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell) -> Bool {
        return true
    }
}
extension SearchResultsViewController: showTabbarDelegate,UITabBarDelegate {
    func showTabar(visable: Bool) {
        self.tabBarController?.tabBar.hidden = visable
    }
}


//
//  upcomingBookingViewController.swift
//  MaidMe
//
//  Created by Vo Minh Long on 12/14/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SWTableViewCell
import Alamofire
import SwiftyJSON
import RealmSwift

class UpcomingBookingViewController: BaseTableViewController {
    //  var refreshItemControl: UIRefreshControl!
    
    var isShowBookingDetail = false
    var selectedIndex: NSIndexPath!
    var listCount = 10
    var isCanceled: Bool = true
    var selectedCell: UpcomingCell?
    var messageCode: MessageCode?
    var upCommingBooking = [Booking]()
    var bookingHistory = [Booking]()
    
    let fetchUpcomingBookings = FetchAllUpcomingBookingsService()
    let cancelBooking = CancelABookingService()
    let bookingHistoryAPI = FetchBookingHistoryService()
    
    var countTime: Int = 0
    var maxLoadedItems = 10
    var totalBookingHistory = 0
    var totalupComingBookingHistory = 0
    var refreshItemControl: UIRefreshControl!
    var selectedBooking: Int?
    var selectedService: String?
    var serviceList = [WorkingService]()
    var isPopView: Bool?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        refreshItemControl.addTarget(self, action: #selector(UpcomingBookingViewController.Refresh), forControlEvents: UIControlEvents.ValueChanged)
		
		let realm = try! Realm()
		let cachedBookings = realm.objects(Booking.self).filter("time >= %@", NSDate())
		if cachedBookings.count != 0 {
			upCommingBooking = Array(cachedBookings)
			totalupComingBookingHistory = upCommingBooking.count
			print(cachedBookings)
			self.tableView.reloadData()
		}
		fetchUpcomingBookingsRequest()
		
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        self.tableView.separatorStyle = .None
        isPopView = false
        
    }
    func Refresh(){
        fetchUpcomingBookingsRequest()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.hideBackbutton(true)
        tableView.hideTableEmptyCell()
        self.view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBar.hidden = false
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        isPopView = true
        
    }
    override func viewDidAppear(animated: Bool) {
        if isPopView == true {
            fetchUpcomingBookingsRequest()
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
    
    func refreshResult() {
        // Remove all current search results
        //bookingHistory.removeAll()
        countTime = 0
        selectedIndex = nil
        isShowBookingDetail = false
    }
    override func setDefaultUIForLoadingIndicator() {
        self.loadingIndicator.activityIndicatorViewStyle = .WhiteLarge
        self.loadingIndicator.color = UIColor.blackColor()
        if let window = UIApplication.sharedApplication().keyWindow {
            self.loadingIndicator.center = window.center
            window.addSubview(self.loadingIndicator)
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && upCommingBooking.count == 0 {
            return 1
        }
        else {
            if isShowBookingDetail {
                if totalupComingBookingHistory > upCommingBooking.count {
                    return upCommingBooking.count + 1  // 1 for load more and 1 for detail cell
                }
                return upCommingBooking.count
            }
            
            if totalupComingBookingHistory > upCommingBooking.count {
                return upCommingBooking.count  // 1 for load more and 1 for detail cell
            }
            return upCommingBooking.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if upCommingBooking.count == 0 {
            let noUpcomingCell = "noUpcommingBookingCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(noUpcomingCell, forIndexPath: indexPath)
            self.tableView.removeSeparatorLine([cell])
            return cell
        }
        else{
            let upcomingCell = "UpcomingCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(upcomingCell, forIndexPath: indexPath) as! UpcomingCell
            cell.showDetails(upCommingBooking[indexPath.row])
            self.tableView.removeSeparatorLine([cell])
            return cell
        }
     //load more
        let row = indexPath.row
        if (row == upCommingBooking.count && !isShowBookingDetail) || (row == upCommingBooking.count + 1 && isShowBookingDetail) {
            let cell = loadMoreCell()
            return cell
        }
    }
    
    func loadMoreCell() -> UITableViewCell {
        var cell: UITableViewCell?
        let loadMoreId = "LoadMoreCell"
        cell = tableView.dequeueReusableCellWithIdentifier(loadMoreId)
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: loadMoreId)
        }
        // Remove the last separator line.
        cell?.removeSeparatorLine()
        if (upCommingBooking.count == 0) || upCommingBooking.count == totalupComingBookingHistory {
            cell!.hidden = true
        }
        else {
            countTime += 1
            // getbookingHistoryRequest()
            
            for subView in (cell?.contentView.subviews)! {
                if subView.isKindOfClass(UIActivityIndicatorView.self) {
                    (subView as! UIActivityIndicatorView).startAnimating()
                }
            }
        }
        
        return cell!
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if upCommingBooking.count > 0 {
            return 260
        }
        return tableView.frame.size.height - 40
    }
    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            return
        }
        guard let _ = tableView.cellForRowAtIndexPath(indexPath) as? UpcomingCell else {
            return
        }
    }
    
    
    
    //MARK: - IBAction
    @IBAction func call(sender: AnyObject) {
        
        guard let callButton = sender as? UIButton else {
            return
        }
        
        let buttonPosition = callButton.convertPoint(CGPointZero, toView: self.tableView)
        
        guard let indexPath =  self.tableView.indexPathForRowAtPoint(buttonPosition) else {
            return
        }
        selectedBooking = indexPath.row
        selectedIndex = indexPath
        let booking = upCommingBooking[selectedIndex.row]
        showCallAlert(booking.maid?.phone)
    }
    func showCallAlert(phoneNumber: String?) {
        guard let phoneNumber = phoneNumber else {
            let alert = UIAlertController(title: nil, message: LocalizedStrings.noPhoneNumberMessage, preferredStyle: .Alert)
            let action = UIAlertAction(title: LocalizedStrings.okButton, style: UIAlertActionStyle.Default, handler: nil)
            
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        self.callNumber(phoneNumber)
    }
    
    private func callNumber(phoneNumber:String) {
        let number = StringHelper.addPlusSign(phoneNumber)
        
        if let phoneCallURL:NSURL = NSURL(string: "telprompt://\(number)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL)
            }
        }
    }
    
    // MARK: - API
    
    func fetchUpcomingBookingsRequest() {
        
        let params = fetchUpcomingBookings.getParams()
        print("up coming Booking params: ", params)
        sendRequest(params, request: fetchUpcomingBookings, requestType: .FetchAllUpcomingBookings, isSetLoadingView: false, view: nil)
        
    }
    func cancelABookingRequest() {
        let params = cancelBooking.getParams(upCommingBooking[selectedIndex.row].bookingID!)
        print("Cancel booking params: ", params)
        setDefaultUIForLoadingIndicator()
        sendRequest(params, request: cancelBooking, requestType: .CancelBooking, isSetLoadingView: false, view: (selectedCell?.contentView == nil ? nil : selectedCell!.contentView))
    }
    func sendRequest(parameters: [String: AnyObject]?,
                     request: RequestManager,
                     requestType: RequestType,
                     isSetLoadingView: Bool, view: UIView?) {
        
        
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
            stopRefreshing()
            return
        }
        
        // Set loading view center
        if isSetLoadingView && view != nil {
            self.setRequestLoadingViewCenter1(view!)
        }
		
		if upCommingBooking.count == 0 {
			self.startLoadingView()	
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
        // End refresh control
        stopRefreshing()
        if result.messageCode != MessageCode.Success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            
            if let error = result.messageCode {
                messageCode = error
            }
            return
        }
        setUserInteraction(true)
        if requestType == .FetchAllUpcomingBookings {
            handleFetchUpcomingBookingsResponse(result, requestType: .FetchAllUpcomingBookings)
        }
        if requestType == .CancelBooking {
            handleCancelBookingsResponse(result, requestType: .CancelBooking)
        }

    }
    
    func handleFetchUpcomingBookingsResponse(result: ResponseObject, requestType: RequestType) {
        //setUserInteraction(true)
        guard let list = result.body else {
            return
        }
        let bookingList = fetchUpcomingBookings.getBookingList(list)
		totalupComingBookingHistory = bookingList.count
		
		//        for booking in result.bookings {
		//            bookingHistory.append(booking)
		//        }
		
		var newBooking = false
		if upCommingBooking.count != bookingList.count {
			newBooking = true
		}else{
			for eachBooking in bookingList {
				let results = bookingList.filter { $0.bookingID == eachBooking.bookingID }
				if results.count == 0 {
					newBooking = true
					break
				}
			}
		}
		
		if newBooking {
			// Cache service list
			upCommingBooking = bookingList
			let realm = try! Realm()
			try! realm.write {
				realm.add(bookingList, update: true)
			}
			self.tableView.reloadData()
		}
		
		if upCommingBooking.count == 0 {
			// If no upcoming bookings, switch to past bookings
			(self.parentViewController as! CustomTabbarViewController).segmented.selectedSegmentIndex = 1
			(self.parentViewController as! CustomTabbarViewController).selectedSegment()
		}
    }
    
    func handleCancelBookingsResponse(result: ResponseObject, requestType: RequestType) {
        let refundAmount = result.body == nil ? 0 : result.body!["charge"]["refunded_amount"].float
        let message = LocalizedStrings.cancelSuccessMessage + LocalizedStrings.currency + " \(refundAmount == nil ? 0 : refundAmount!) " 
                showAlertView(LocalizedStrings.cancelSuccessTitle, message: message, requestType: nil)
        // Cancel on the UI
        cancelBooking(selectedCell)
    
    }
    
        
    //MARK: - IBAction
    @IBAction func cancel(sender: AnyObject) {
        getSelectedCell(sender)
        guard let cancelButton = sender as? UIButton else {
            return
        }
        
        let buttonPosition = cancelButton.convertPoint(CGPointZero, toView: self.tableView)
        
        guard let indexPath =  self.tableView.indexPathForRowAtPoint(buttonPosition) else {
            return
        }
        selectedBooking = indexPath.row
        selectedIndex = indexPath
        self.performSegueWithIdentifier(SegueIdentifiers.showCancelBooking, sender: self)
        
    }
    //MARK: - Unwind segue
    func getSelectedCell(sender: AnyObject) {
        guard let cancelButton = sender as? UIButton else {
            return
        }
        
        let buttonPosition = cancelButton.convertPoint(CGPointZero, toView: self.tableView)
        
        guard let indexPath =  self.tableView.indexPathForRowAtPoint(buttonPosition) else {
            return
        }
        
        guard let upcomingCell = self.tableView.cellForRowAtIndexPath(indexPath) as? UpcomingCell else {
            return
        }
        selectedCell = upcomingCell
    }
    func cancelBooking(upcomingCell: UpcomingCell?) {
        let currentCell = selectedIndex.row
        upCommingBooking.removeAtIndex(currentCell)
        self.tableView.reloadData()
         NSNotificationCenter.defaultCenter().postNotificationName("updateBookinghistory", object: nil)
        // Hide this session if there is no more upcomming booking
        if upCommingBooking.count <= 0 {
            tableView.beginUpdates()
            tableView.reloadData()
            tableView.endUpdates()
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.showCancelBooking {
            
            guard let destination = segue.destinationViewController as? CancelBookingViewController else {
                return
            }
            guard let selectedIndex = selectedIndex else {
                return
            }
            destination.delegate = self
            destination.upcomingVC = self
            destination.booking = upCommingBooking[selectedIndex.row]
        }
        
    }
}
extension UpcomingBookingViewController: CancelBookingViewControllerDelegate {
    func didDismissCancelBooking(isCanceled: Bool) {
        // Cancel bookings
        if isCanceled {
            cancelABookingRequest()
        }
    }
}


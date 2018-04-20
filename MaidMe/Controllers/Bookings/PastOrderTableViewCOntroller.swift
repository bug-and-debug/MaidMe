//
//  PastOrderTableViewCOntroller.swift
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

class PastOrderTableViewCOntroller: BaseTableViewController {
    
    var isShowBookingDetail = false
    var selectedIndex: NSIndexPath!
    var listCount = 20
    var isCanceled: Bool = false
    
    var messageCode: MessageCode?
    var upCommingBooking = [Booking]()
    var bookingHistory = [Booking]()
    
    let cancelBooking = CancelABookingService()
    let bookingHistoryAPI = FetchBookingHistoryService()
    let getSearchOptionAPI = GetSearchOptionRebookingService()

    
    var countTime: Int = 0
    var maxLoadedItems = 10
    var totalBookingHistory = 0
    var refreshItemControl: UIRefreshControl!
    var selectedBooking: Int?
    var selectedService: String?
    var serviceListForRebook = [WorkingService]()
    var addressListForRebook = [Address]()
    var isShow: Bool?// = false
    var searcOptionRebookParams : [String: String]?
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		
		let realm = try! Realm()
		let cachedBookings = realm.objects(Booking.self)
		if cachedBookings.count == 0 {
			getbookingHistoryRequest()
		}else {
			bookingHistory = Array(cachedBookings)
			totalBookingHistory = bookingHistory.count
			print(cachedBookings)
			getbookingHistoryRequest()
			self.tableView.reloadData()
		}
		
        //isShow = false
        // Disable go back to previous screen
        self.hideBackbutton(true)
        setupRefreshControl()
		
        refreshItemControl.addTarget(self, action: #selector(PastOrderTableViewCOntroller.Refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        self.tableView.separatorStyle = .None
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        
    }
    func Refresh(){
        refreshResult()
        getbookingHistoryRequest()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.hideTableEmptyCell()
          NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(getbookingHistoryRequest), name: "updateBookinghistory", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

    func setupTableView(){
        self.tableView.separatorStyle = .None
        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && bookingHistory.count == 0{
            return 1
        }
        else {
            if isShowBookingDetail {
                if totalBookingHistory > bookingHistory.count {
                    return bookingHistory.count + 1  // 1 for load more and 1 for detail cell
                }
                return bookingHistory.count
            }
            
            if totalBookingHistory > bookingHistory.count {
                return bookingHistory.count  // 1 for load more and 1 for detail cell
            }
            return bookingHistory.count
        }
        
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if bookingHistory.count > 0 {
            return 260
        }
        return tableView.frame.size.height - 40
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if bookingHistory.count == 0 {
            let noBookingCell = "nobookinghistory"
            let cell = tableView.dequeueReusableCellWithIdentifier(noBookingCell, forIndexPath: indexPath)
            self.tableView.removeSeparatorLine([cell])
            return cell
            
        } else {
        let pastBookingCell = "PastBookingCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(pastBookingCell, forIndexPath: indexPath) as! PastBookingCell
        let index = cell.showArrow(selectedIndex, indexPath: indexPath, isShowBookingDetail: isShowBookingDetail)
        if bookingHistory.count > index {
            cell.showDetails(bookingHistory[index])
        }
        self.tableView.removeSeparatorLine([cell])
            return cell
        }
    }
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let position = scrollView.panGestureRecognizer.translationInView(scrollView.superview)
        //detect scroll down to load more
//        if position.y < 0{
//            countTime = countTime + 1
//            getbookingHistoryRequest()
//        }
        }

    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            return
        }
        guard let _ = tableView.cellForRowAtIndexPath(indexPath) as? PastBookingCell else {
            return
        }
    }
    
    // MARK: - API
    func getSearchOptionRebooking(booking: Booking) {
        searcOptionRebookParams = getSearchOptionAPI.getSearchOptionsForRebookingParams(booking)
        sendRequest(searcOptionRebookParams, request: getSearchOptionAPI, requestType: .GetSearchOptionRebooking, isSetLoadingView: false, view: nil)
    }

    func getbookingHistoryRequest() {
        let params = bookingHistoryAPI.getParams(countTime, limit: maxLoadedItems)
        print("Booking history params: ", params)
        sendRequest(params, request: bookingHistoryAPI, requestType: .FetchBookingHistory, isSetLoadingView: false, view: nil)
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
        
        messageCode = nil
        
        // Set loading view center
        if isSetLoadingView && view != nil {
            self.setRequestLoadingViewCenter1(view!)
        }
        if (isSetLoadingView == true && bookingHistory.count == 0) ||  requestType == .GetSearchOptionRebooking{
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
        //end refresh
        stopRefreshing()
        if result.messageCode != MessageCode.Success {
            if requestType == .GetSearchOptionRebooking {
                if let messageInfo = result.messageInfo {
                    self.showAlertView(LocalizedStrings.internalErrorTitle, message: messageInfo, requestType: nil)
                }
                return
            }
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            
            if let error = result.messageCode {
                messageCode = error
            }
            
            return
        }
        
        setUserInteraction(true)
        
        if requestType == .FetchBookingHistory {
            handleBookingHistoryResponse(result, requestType: .FetchBookingHistory)
        } else if requestType == .GetSearchOptionRebooking {
            handlerGetSearchOptions(result, requestType: .GetSearchOptionRebooking)
        }
    }
    func handlerGetSearchOptions(result: ResponseObject, requestType: RequestType) {
        guard let body = result.body else {
            return
        }
        addressListForRebook = getSearchOptionAPI.getAddressList(body)
        serviceListForRebook = getSearchOptionAPI.getServiceList(body)
        self.performSegueWithIdentifier(SegueIdentifiers.rebooking, sender: self)
    }
    
    func handleBookingHistoryResponse(result: ResponseObject, requestType: RequestType) {
//        if countTime == 0 {
//            bookingHistory.removeAll()
//        }
        
        guard let list = result.body else {
            return
        }
      //  print("booking history\(list)")
        let result = bookingHistoryAPI.getBookingList(list)
        totalBookingHistory = result.total
        
//        for booking in result.bookings {
//            bookingHistory.append(booking)
//        }
		
		var newBooking = false
		if bookingHistory.count != result.bookings.count {
			newBooking = true
		}else{
			for eachBooking in result.bookings {
				let results = result.bookings.filter { $0.bookingID == eachBooking.bookingID }
				if results.count == 0 {
					newBooking = true
					break
				}
			}
		}
		
		if newBooking {
			// Cache service list
			bookingHistory = result.bookings
			let realm = try! Realm()
			try! realm.write {
				realm.add(result.bookings, update: true)
			}
			self.tableView.reloadData()
		}

		
        if result.bookings.count > 0 {
            self.tableView.reloadData()
          //  maxLoadedItems = bookingHistory.count
        }
		
		
		
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.tableView.reloadData()
    }
    
    // MARK: - IBAction
    @IBAction func Rebook(sender: AnyObject) {
        guard let rebookButton = sender as? UIButton else {
            return
        }
        
        let buttonPosition = rebookButton.convertPoint(CGPointZero, toView: self.tableView)
        
        guard let indexPath =  self.tableView.indexPathForRowAtPoint(buttonPosition) else {
            return
        }
        selectedBooking = indexPath.row
        selectedIndex = indexPath
        if let selectedBooking = selectedBooking {
            getSearchOptionRebooking(bookingHistory[selectedBooking])
        }
		
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SegueIdentifiers.rebooking {
            guard let destination = segue.destinationViewController as? RebookingViewController else {
                return
            }
            
            guard let selectedIndex = selectedBooking else {
                return
            }
            destination.delegate = self
            let booking = bookingHistory[selectedIndex]
            destination.rebookingAddress = booking.address!
            destination.addressBookingAvailableList = self.addressListForRebook
            destination.serviceList = self.serviceListForRebook
            destination.booking = Booking(bookingID: booking.bookingID, workerName: booking.maid!.firstName! + " " + booking.maid!.lastName!, workerID: booking.maid!.workerID, time: nil, service: nil, workingAreaRef: booking.workingAreaRef, hours: nil, price: nil, materialPrice: nil, payerCard: nil, avartar: nil,maid: nil)
        }
    }
}

extension PastOrderTableViewCOntroller: RebookingViewControllerDelegate {
 func didDismissRebooking(isRebook: Bool, params: Booking,hour: Int,selectedService: WorkingService,bookingAdress: Address,addresList:[Address]){
        if isRebook {
            // Move to available worker for searching
            guard let searchResultVC = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIDs.searchResults) as? SearchResultsViewController else {
                return
            }
            
            searchResultVC.isRebook = true
            searchResultVC.booking = params
            searchResultVC.hour = hour
            searchResultVC.isMoveFromRebook = true
            searchResultVC.selectedAddress = bookingAdress
            searchResultVC.workService = selectedService
            searchResultVC.addressList = addresList
            
            self.navigationController?.pushViewController(searchResultVC, animated: true)
        }
    }
}


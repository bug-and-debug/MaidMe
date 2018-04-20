//
//  MaidProfileTableViewController.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 2/26/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire

class MaidProfileTableViewController: BaseTableViewController {
    
    var maid: Worker!
    var getRatingsAndCommentsAPI = GetAllRatingsAndCommentsService()
    var totalReviews = 0
    var bookingList = [Booking]()
    var nextTime: Double = 0
    var maxLoadedItems = 5
    var headerRows = 2
    var isFirstLoading = true
    
    var refreshItemControl: UIRefreshControl!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable go back to previous screen
        self.hideBackbutton(false)
        setupRefreshControl()
        
        // Get ratings and comments of this maid
        nextTime = NSDate().timeIntervalSince1970 * 1000
        getRatingsAndCommentsRequest(nextTime)
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.hideTableEmptyCell()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        bookingList.removeAll()
        nextTime = 0
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if totalReviews > bookingList.count {//maxLoadedItems {
            return headerRows + bookingList.count + 1 // 1 is for load more cell
        }
        
        return headerRows + bookingList.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 96.0
        }
        if indexPath.row == 1 {
            return 74.0
        }
        if indexPath.row == headerRows + bookingList.count {
            return 44.0
        }
        
        let string = bookingList[indexPath.row - headerRows].comment
        let newHeight = StringHelper.getTextHeight(string == nil ? "" : string!, width: CGRectGetWidth(self.tableView.frame) - 15 * 4, fontSize: 16.0) // 15 is the text and frame padding
        
        return 190.0 + newHeight - 54 // 54 is the design height for textview
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let nameIdentifier = "profileNameCell"
        let reviewIdentifier = "profileReviewCell"
        let commentIdentifier = "profileReviewDetailCell"
        
        // Show load more
        let row = indexPath.row
        
        if (row == headerRows + bookingList.count - 1) && bookingList.count > 0 {
            if let time = bookingList[indexPath.row - headerRows].timeOfRating {
                nextTime = time.timeIntervalSince1970 * 1000 + Double(NSTimeZone.localTimeZone().secondsFromGMT * 1000)
            }
        }
        
        if (row == headerRows + bookingList.count) {
            let cell = loadMoreCell()
            return cell
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(nameIdentifier, forIndexPath: indexPath) as! ProfileNameCell
            self.tableView.removeSeparatorLineInset([cell])
            cell.showMaidDetails(maid)
            return cell
        }
        
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(reviewIdentifier, forIndexPath: indexPath) as! ProfileReviewCell
            self.tableView.removeSeparatorLineInset([cell])
            cell.showTotalReview(totalReviews)
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(commentIdentifier, forIndexPath: indexPath) as! ProfileReviewDetailCell
        self.tableView.removeSeparatorLine([cell])
        cell.showDetail(bookingList[indexPath.row - headerRows])
        return cell
    }

    func loadMoreCell() -> UITableViewCell {
        var cell: UITableViewCell?
        let loadMoreId = "LoadMoreCell"
        cell = tableView.dequeueReusableCellWithIdentifier(loadMoreId)
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: loadMoreId)
        }
        
        // Remove the last separator line.
        cell!.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, cell!.bounds.size.width)
        
        if (bookingList.count == 0) || bookingList.count == totalReviews {
            cell!.hidden = true
        }
        else {
            isFirstLoading = false
            getRatingsAndCommentsRequest(nextTime)
            
            for subView in (cell?.contentView.subviews)! {
                if subView.isKindOfClass(UIActivityIndicatorView.self) {
                    (subView as! UIActivityIndicatorView).startAnimating()
                }
            }
        }
        
        return cell!
    }

    // MARK: API

    func getRatingsAndCommentsRequest(fromDate: Double) {
        let params = getRatingsAndCommentsAPI.getParams(maid.workerID, fromDate: fromDate, limit: maxLoadedItems)
        print("Rating comment params: ", params)
        sendRequest(params, request: getRatingsAndCommentsAPI, requestType: .GetRatingsAndComments, isSetLoadingView: true, view: nil)
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
        
        // End refresh control
        stopRefreshing()
        
        if result.messageCode != MessageCode.Success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            return
        }
        
        if requestType == .GetRatingsAndComments {
            handleFetchUpcomingBookingsResponse(result, requestType: .GetRatingsAndComments)
        }
    }
    
    func handleFetchUpcomingBookingsResponse(result: ResponseObject, requestType: RequestType) {
        setUserInteraction(true)
        
        guard let list = result.body else {
            return
        }
        
        let result = getRatingsAndCommentsAPI.getBookingList(list)
        
        if isFirstLoading {
            totalReviews = result.total
        }
        
        for booking in result.bookings {
            bookingList.append(booking)
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(requestType: RequestType) {
        if requestType == .GetRatingsAndComments {
            self.getRatingsAndCommentsRequest(nextTime)
        }
    }

    // MARK: - Scroll view Delegate
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if refreshItemControl.refreshing {
            refreshResult()
            isFirstLoading = true
            getRatingsAndCommentsRequest(NSDate().timeIntervalSince1970 * 1000)
        }
    }

}
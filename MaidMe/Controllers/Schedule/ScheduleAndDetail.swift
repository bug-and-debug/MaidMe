//
//  ScheduleAndDetail.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/1/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain

class ScheduleAndDetail: BaseTableViewController {
    
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var ratingView: RatingStars!
    @IBOutlet weak var totalHour: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var descriptionServiceLabel: UILabel!
    
    
    var tabbarDelegate : showTabbarDelegate?
    var navController : UINavigationController?
    var currentViewController: AnyObject?
    
    @IBOutlet weak var addMaterialButton: UIButton!
    
    var addMaterial = false
    var address = Address()
    var booking: Booking?
    var addressList = [Address]()

    
    let lockABooking = LockABookingService()
    let clearLockedBooking = ClearALockedBookingService()
    var messageCode: MessageCode?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.hideTableEmptyCell()
       showSegueData()
        }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = true
            }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.hidden = true
        
        if booking!.bookingID != nil {
            clearLockedBookingRequest()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UI
    
    func showSegueData() {

//        if let description = self.booking?.service?.serviceDescription,let buildingName = self.address.buildingName {
//            
//            descriptionServiceLabel.text = description
//        }
        descriptionServiceLabel.text = self.booking?.service?.serviceDescription
        addressLabel.text = self.address.buildingName
        serviceLabel.text = booking?.service?.name
        workerNameLabel.text = booking!.workerName
        timeLabel.text = booking!.time?.getDayMonthAndHour()
        ratingView.setRatingLevel((booking!.maid?.rateAverage)!)
        let hours = Int(booking!.hours == 0 ? 0 : booking!.hours)
        if hours == 1 {
            totalHour.text = "\(hours) hour"
        } else {
            totalHour.text = "\(hours) hours"
        }
        caculTotalPrince()
        if let serviceImageString:String = booking?.service?.avatar {
            self.loadImageFromURL(serviceImageString, imageLoad: self.serviceImage)
        }
    }
    func caculTotalPrince(){
        let materialPrice = (booking!.materialPrice == 0 ? 0 : booking!.materialPrice)
       

        if addMaterial == true {
            totalPriceLabel.text = showPrice((booking!.price == 0 ? 0 : booking!.price) + materialPrice)
        } else {
            totalPriceLabel.text = showPrice(booking!.price == 0 ? 0 : booking!.price)
        }

    }
    func updateAddressList() {
        // Check the new current address is included in the list or not
        if address.addressID == nil {
            return
        }
        var isExisted = false
        for address in addressList {
            if address.addressID == self.address.addressID {
                isExisted = true
                break
            }
        }
        if !isExisted {
            addressList.insert(address, atIndex: 0)
        }
    }
    
    
    func showPrice(price: Float) -> String {
        return LocalizedStrings.currency + " " + String.localizedStringWithFormat("%.2f", price)
    }
    // MARK: - IBActions

    
    @IBAction func onNextAction(sender: AnyObject) {
        
        lockABookingRequest()
        
    }
    
    @IBAction func addMaterialAction(sender: AnyObject) {
        addMaterial = !addMaterial
        if (addMaterial == true) {
            addMaterialButton.setImage(UIImage(named: ImageResources.checkedBox), forState: .Normal)
        } else {
            addMaterialButton.setImage(UIImage(named: ImageResources.uncheckBox), forState: .Normal)
        }
        caculTotalPrince()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        tabbarDelegate?.showTabar(false)
    }
    
    
    func showPaymentVC() {
        let storyboard = self.storyboard
        
        guard let paymentVC = storyboard?.instantiateViewControllerWithIdentifier("PaymentVC") as? PaymentViewController else {
            return
        }
       
        paymentVC.bookingInfo = booking
        paymentVC.address = self.address
        if !addMaterial {
            paymentVC.bookingInfo.materialPrice = 0.0
        }
        guard let _ = currentViewController as? PaymentViewController else {
            self.navController?.pushViewController(paymentVC, animated: true)
            return
        }
    }
    
    // MARK: - API
    func lockABookingRequest() {
        let parameters = lockABooking.getLockABookingParams(booking!, address: address, isIncludeMaterial: addMaterial)
        print("Booking param:", parameters)
        sendRequest(parameters, request: lockABooking, requestType: .LockABooking, isSetLoadingView: true)
    }
    
    func clearLockedBookingRequest() {
        guard let bookingID = booking!.bookingID else {
            return
        }
        
        let parameters = clearLockedBooking.getParams(bookingID)
        sendRequest(parameters, request: clearLockedBooking, requestType: .ClearLockedBooking, isSetLoadingView: false)
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
            print("sendRequets")
            // Set loading view center
            if isSetLoadingView {
                setLoadingUI(.White, color: UIColor.whiteColor())
                self.setRequestLoadingViewCenter(payButton)
            }
            else {
                setDefaultUIForLoadingIndicator()
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
        
        if requestType == .ClearLockedBooking && result.messageCode != .Success {
            return
        }
        if result.messageCode != .Success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            
            if let error = result.messageCode {
                messageCode = error
            }
            
            return
        }
        
        if requestType == .LockABooking {
            handleLockABookingResponse(result, requestType: .LockABooking)
        }
        else if requestType == .ClearLockedBooking {
            booking!.bookingID = nil
        }
    }
    
    func handleLockABookingResponse(result: ResponseObject, requestType: RequestType) {
        if let bookingID = result.body?["_id"] {
            booking!.bookingID = bookingID.stringValue
            tabbarDelegate?.showTabar(false)
            self.dismissViewControllerAnimated(true, completion: nil)
            self.showPaymentVC()
        }
        else {
            // Handle error when booking ID is nil
            showAlertView(LocalizedStrings.internalErrorTitle, message: LocalizedStrings.internalErrorMessage, requestType: .LockABooking)
            return
        }
        
    }
    
        // MARK: - Handle UIAlertViewAction
    override func handleTryAgainTimeoutAction(requestType: RequestType) {
        if requestType == .LockABooking {
            self.lockABookingRequest()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 5 {
            if self.view.frame.size.height > 648 {
                return (self.view.frame.size.height - 568)
            } else {
                return 80
            }
        }
        return 70
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == SegueIdentifiers.showBookingAddress {
            guard let destination = segue.destinationViewController as? BookingAddressTableViewController else {
                return
            }
            
            destination.addressList = addressList
            destination.currentAddress = (address.addressID == nil ? nil : address)
            
            if address.addressID == nil {
                print("Default address nil")
            }
        }
    }
}

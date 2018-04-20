//
//  CancelBookingViewController.swift
//  MaidMe
//
//  Created by Romecon on 3/16/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit

protocol CancelBookingViewControllerDelegate {
    func didDismissCancelBooking(isCanceled: Bool)
}

class CancelBookingViewController: UIViewController {

    @IBOutlet weak var cancelWithRefundView: UIView!
    @IBOutlet var cancelWithoutRefundView: UIView!
    @IBOutlet weak var refundLabel: UITextView!
    
    var delegate: CancelBookingViewControllerDelegate?
    var isCanceled: Bool = false
    var booking: Booking!
    var cancelType: CancelType!
    var upcomingVC  : UpcomingBookingViewController?
    // MARK: - Life cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(booking.companySetting)
        showSuitableCancelUI(booking.time!, cancelTime: 120, isPressedButton: false)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UI
    
    func showSuitableCancelUI(bookingTime: NSDate, cancelTime: Int, isPressedButton: Bool) {
        // If current < cancel time: show cancel without charge UI
        // If current in range (cancel time, booking time): show cancel with refund UI
        // If current time > booking time: show cancel without refund UI
        let localBookingTime = bookingTime.toLocalTime(DateFormater.twelvehoursFormat)
        let bookingTimeInterval = localBookingTime.timeIntervalSince1970
        let minTime = bookingTimeInterval - Double(cancelTime * 60)
        let allowedCancelTime = NSDate(timeIntervalSince1970: minTime)
        let currentTime = NSDate()
        
        if currentTime.compare(allowedCancelTime) == NSComparisonResult.OrderedAscending {
            if isPressedButton && cancelType == .RefundAll {
                // Dismiss view controller
                self.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            
            cancelType = .RefundAll
            cancelUI(false)
        }
        else {
            if currentTime.compare(localBookingTime) == NSComparisonResult.OrderedAscending {
                if isPressedButton && cancelType == .ChargeFee {
                    // Dismiss view controller
                    self.dismissViewControllerAnimated(true, completion: nil)
                    return
                }
                
                if isPressedButton && cancelType == .RefundAll {
                    updateCancelUI(true)
                }
                else {
                    cancelUI(true)
                }
                
                cancelType = .ChargeFee
            }
            else {
                if isPressedButton && cancelType == .NoRefund {
                    // Dismiss view controller
                    self.dismissViewControllerAnimated(true, completion: nil)
                    return
                }
                
                cancelType = .NoRefund
                showCancelWithouRefundView()
            }
        }
        
        

    }
    
    func cancelUI(isRefund: Bool) {
        showCancelWithRefundView()
        
        if isRefund {
            let fee = (booking.companySetting?.refundFee == 0 ? 0.0 : booking.companySetting!.refundFee)
            let feeFloor = floor(fee)
            
            if fee - feeFloor == 0 {
                refundLabel.text = "*\(Int(fee))\(LocalizedStrings.refundFeeMessage)"
            }
            else {
                refundLabel.text = "*\(String.localizedStringWithFormat("%.2f", fee))\(LocalizedStrings.refundFeeMessage)"
            }
        }
        else {
            refundLabel.text = LocalizedStrings.noRefundFeeMessage
        }
    }
    
    func updateCancelUI(isRefund: Bool) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.refundLabel.frame.origin.x = -CGRectGetWidth(self.cancelWithRefundView.frame)
            }) { Void in
                self.refundLabel.frame.origin.x = CGRectGetWidth(self.cancelWithRefundView.frame)
                self.cancelUI(isRefund)
                
                UIView.animateWithDuration(0.2) {
                    self.refundLabel.frame.origin.x = (CGRectGetWidth(self.cancelWithRefundView.frame) - CGRectGetWidth(self.refundLabel.frame)) / 2
                }
        }
    }
    
    func showCancelWithouRefundView() {
        let width = CGRectGetWidth(self.view.frame) * 0.9
        let height = CGRectGetHeight(cancelWithoutRefundView.frame)
        cancelWithRefundView.hidden = true
        cancelWithoutRefundView.frame = CGRectMake((CGRectGetWidth(self.view.frame) - width) / 2, (CGRectGetHeight(self.view.frame) - height) / 2, width, height)
        self.view.addSubview(cancelWithoutRefundView)
    }
    
    func showCancelWithRefundView() {
        cancelWithoutRefundView.removeFromSuperview()
        cancelWithRefundView.hidden = false
    }
    
    // MARK: - IBActions
    
    @IBAction func onAgreeCancelAction(sender: AnyObject) {
        isCanceled = true
        delegate?.didDismissCancelBooking(isCanceled)
        showSuitableCancelUI(booking.time!, cancelTime: 120, isPressedButton: true)
       
            }
    
    @IBAction func onDisagreeCancelAction(sender: AnyObject) {
        isCanceled = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "" {
            guard let destination = segue.destinationViewController as? UpcomingBookingViewController else {
                return
            }
            
            destination.isCanceled = true
        }
    }
}

enum CancelType {
    case RefundAll
    case ChargeFee
    case NoRefund
}

//
//  SelectExprixeDateView.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 1/6/17.
//  Copyright © 2017 SmartDev. All rights reserved.
//

import UIKit

protocol SelectExpiryDateDelegate{
    func showExpiryDate(expiryDate: NSDate)
}

class SelectExprixeDateView: BaseViewController {
    
    @IBOutlet weak var datePicker: MAKMonthPicker!
    @IBOutlet weak var bottomView: UIView!
    var expiryDate: NSDate?
    var delegate: SelectExpiryDateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.yearRange = NSRange(location: NSDate().getCurrentYear(), length: 100)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlerDismiss)))
        datePicker.monthPickerDelegate = self
    
    }
    
    func setupDatePicker() {
        
        datePicker.format = [MAKMonthPickerFormat.Month, MAKMonthPickerFormat.Year]
        datePicker.monthFormat = "%n"
        datePicker.date = NSDate(timeIntervalSinceNow: -ktTimeInMonth)
        datePicker.yearRange = NSMakeRange(2000, 10000)
    }
    
    func datePickerChanged(date: NSDate, dateFormat: String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        expiryDate = date
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        self.view.alpha = 0
        self.bottomView.frame = CGRectMake(0, self.view.frame.height, self.view.frame.width, 250)
        UIView.animateWithDuration(0.3) {
            self.view.alpha = 1
            self.bottomView.frame = CGRectMake(0, self.view.frame.height - 250, self.view.frame.width, 250)
        }
    }
    
    func handlerDismiss() {
        UIView.animateWithDuration(0.3) {
            self.bottomView.frame = CGRectMake(0, self.view.frame.height, self.view.frame.width, 250)
            self.view.alpha = 0
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    @IBAction func selectExpiryDateAction(sender: AnyObject?){
        
        if expiryDate != nil {
            delegate?.showExpiryDate(expiryDate!)
        } else {
            expiryDate = NSDate()
            delegate?.showExpiryDate(expiryDate!)
        }
        handlerDismiss()
    }
    
    
    
}

extension SelectExprixeDateView: MAKMonthPickerDelegate {
    
    func monthPickerDidChangeDate(picker: MAKMonthPicker) {
        if picker.restorationIdentifier == "expirydatePicker" {
            datePickerChanged(picker.date, dateFormat: DateFormater.monthYearFormat)
        }
    }
}


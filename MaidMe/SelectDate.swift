//
//  TestVC.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 12/24/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit

protocol SelectDateDelegate {
    func selectedDate(dateSelected: NSDate)
}

class TestVC: UIViewController {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var dateSelected: NSDate?
    var delegate: SelectDateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlerDismiss)))
//        setUpDateTimePicker()
        // Do any additional setup after loading the view.
		
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    func setUpDateTimePicker() {
        let nextRoundedTime = NSDate().getNextOneRoundedHourTime()
        datePicker.minimumDate = nextRoundedTime
        datePicker.maximumDate = nextRoundedTime.getNext7Days()
        // Set default day
        datePicker.setDate(nextRoundedTime, animated: false)
        datePickerChanged(nextRoundedTime, dateFormat: DateFormater.twelvehoursFormat)
    }
    func datePickerChanged(date: NSDate, dateFormat: String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        self.dateSelected = date
//        let beforeDate = date.dateByAddingTimeInterval(2 * 60 * 60)
    }
    
    @IBAction func dismiss() {
    }
    
    @IBAction func datePickerAction(sender: AnyObject) {
        if sender.restorationIdentifier == "datePicker" {
            datePickerChanged(datePicker.date, dateFormat: DateFormater.twelvehoursFormat)
        }
    }
    @IBAction func selectDateAction(sender: AnyObject) {
        delegate?.selectedDate(dateSelected!)
        handlerDismiss()
    }
    
}


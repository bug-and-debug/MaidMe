//
//  SelectValueView.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 2/23/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit

protocol UpdateHourDelegate {
    func updateHour(currentHour: Int)
}

class SelectValueView: UIView {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!

   
    
    var minValue: Int = 1 {
        didSet {
            setHour(minValue)
        }
    }
    
    let maxValue = 8
    var currentValue = 1
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSBundle.mainBundle().loadNibNamed(StoryboardIDs.selectValueView, owner: self, options: nil)
        
        self.view.frame = self.bounds
        self.addSubview(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NSBundle.mainBundle().loadNibNamed(StoryboardIDs.selectValueView, owner: self, options: nil)
        
        self.view.frame = self.bounds
        self.addSubview(view)
    }
    
    @IBAction func onDownAction(sender: AnyObject) {
        if currentValue <= minValue {
            return
        }
        
        setHour(currentValue - 1)
        /*currentValue -= 1
         hourLabel.text = StringHelper.getHourString(currentValue)
         
         if currentValue == minValue {
         ValidationUI.changeRequiredFieldsUI(false, button: downButton)
         }
         
         if currentValue == maxValue - 1 {
         ValidationUI.changeRequiredFieldsUI(true, button: upButton)
         }*/
        //        searchVC.updateHoursLabel(currentValue)
    }
    
    @IBAction func onUpAction(sender: AnyObject) {
        if currentValue >= maxValue {
            return
        }
        
        setHour(currentValue + 1)
        /*currentValue += 1
         hourLabel.text = StringHelper.getHourString(currentValue)
         
         if currentValue == minValue + 1 {
         ValidationUI.changeRequiredFieldsUI(true, button: downButton)
         }
         
         if currentValue == maxValue {
         ValidationUI.changeRequiredFieldsUI(false, button: upButton)
         }*/
        
        //        searchVC.updateHoursLabel(currentValue)
    }
    
    
    func setHour(hour: Int) {
        currentValue = hour
        
        if hour <= minValue {
            currentValue = minValue
        }
        
        if hour >= maxValue {
            currentValue = maxValue
        }
        
        hourLabel.text = StringHelper.getHourString(currentValue)
        
        if currentValue == minValue {
            ValidationUI.changeRequiredFieldsUI(false, button: downButton)
        }
        else {
            ValidationUI.changeRequiredFieldsUI(true, button: downButton)
        }
        if currentValue == maxValue {
            ValidationUI.changeRequiredFieldsUI(false, button: upButton)
        }
        else {
            ValidationUI.changeRequiredFieldsUI(true, button: upButton)
        }
    }
}

//
//  DateCollectionViewCell.swift
//  DateTimePicker
//
//  Created by Huong Do on 9/26/16.
//  Copyright © 2016 ichigo. All rights reserved.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    var dayLabel: UILabel! // rgb(128,138,147)
    var numberLabel: UILabel!
    var darkColor = UIColor(red: 0, green: 22.0/255.0, blue: 39.0/255.0, alpha: 1)
    var highlightColor = UIColor(red: 0/255.0, green: 199.0/255.0, blue: 194.0/255.0, alpha: 1)
    
    override init(frame: CGRect) {
        
        dayLabel = UILabel(frame: CGRect(x: 5, y: 15, width: frame.width - 10, height: 20))
        dayLabel.font = UIFont.systemFontOfSize(10)
        dayLabel.textAlignment = .Center
    
        numberLabel = UILabel(frame: CGRect(x: 5, y: 30, width: frame.width - 10, height: 40))
        numberLabel.font = UIFont.systemFontOfSize(25)
        numberLabel.textAlignment = .Center
        
        super.init(frame: frame)
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(numberLabel)
        contentView.backgroundColor = UIColor.whiteColor()
        contentView.layer.cornerRadius = 3
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var selected: Bool {
        didSet {
            dayLabel.textColor = selected == true ? UIColor.whiteColor() : darkColor.colorWithAlphaComponent(0.5)
            numberLabel.textColor = selected == true ? UIColor.whiteColor() : darkColor
            contentView.backgroundColor = selected == true ? highlightColor : UIColor.whiteColor()
            contentView.layer.borderWidth = selected == true ? 0 : 1
        }
    }
    
    func populateItem(date: NSDate, highlightColor: UIColor, darkColor: UIColor) {
        self.highlightColor = highlightColor
        self.darkColor = darkColor
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
		if NSCalendar.currentCalendar().isDateInToday(date) {
			dayLabel.text = "Today".uppercaseString
		}else if NSCalendar.currentCalendar().isDateInTomorrow(date) {
			dayLabel.text = "Tomorrow".uppercaseString
		}else{
			dayLabel.text = dateFormatter.stringFromDate(date).uppercaseString
		}
        dayLabel.textColor = selected == true ? UIColor.whiteColor() : darkColor.colorWithAlphaComponent(0.5)
        
        let numberFormatter = NSDateFormatter()
        numberFormatter.dateFormat = "d"
        numberLabel.text = numberFormatter.stringFromDate(date)
        numberLabel.textColor = selected == true ? UIColor.whiteColor() : darkColor
        
        contentView.layer.borderColor = darkColor.colorWithAlphaComponent(0.2).CGColor
        contentView.backgroundColor = selected == true ? highlightColor : UIColor.whiteColor()
    }
    
}

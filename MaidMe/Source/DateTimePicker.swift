//
//  DateTimePicker.swift
//  DateTimePicker
//
//  Created by Huong Do on 9/16/16.
//  Copyright © 2016 ichigo. All rights reserved.
//

import UIKit


@objc public class DateTimePicker: UIView {
    
    let contentHeight: CGFloat = 270
    
    // public vars
    public var backgroundViewColor: UIColor = UIColor.clearColor() {
        didSet {
            backgroundColor = backgroundViewColor
        }
    }
    
    public var highlightColor = UIColor(red: 0/255.0, green: 199.0/255.0, blue: 194.0/255.0, alpha: 1) {
        didSet {
            todayButton.setTitleColor(highlightColor, forState: .Normal)
            colonLabel.textColor = highlightColor
        }
    }
    
    public var darkColor = UIColor(red: 0, green: 22.0/255.0, blue: 39.0/255.0, alpha: 1)
    
    public var daysBackgroundColor = UIColor(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, alpha: 1)
    
    var didLayoutAtOnce = false
    public override func layoutSubviews() {
        super.layoutSubviews()
        // For the first time view will be layouted manually before show
        // For next times we need relayout it because of screen rotation etc.
        if !didLayoutAtOnce {
            didLayoutAtOnce = true
        } else {
            self.configureView()
        }
    }
    
    public var selectedDate = NSDate() {
        didSet {
            resetDateTitle()
        }
    }
	
	public var timeInterval = 1 {
		     didSet {
			            resetDateTitle()
			        }
		}
    
    public var dateFormat = "HH:mm dd/MM/YYYY" {
        didSet {
            resetDateTitle()
        }
    }
    
    public var todayButtonTitle = "Today" {
        didSet {
            todayButton.setTitle(todayButtonTitle, forState: .Normal)
            let size = todayButton.sizeThatFits(CGSize(width: 0, height: 44.0)).width + 10.0
            todayButton.frame = CGRect(x: contentView.frame.width - size, y: 0, width: size, height: 44)
        }
    }
    public var doneButtonTitle = "DONE" {
        didSet {
            doneButton.setTitle(doneButtonTitle, forState: .Normal)
        }
    }
    public var completionHandler: ((NSDate)->Void)?
    
    // private vars
    internal var hourTableView: UITableView!
    internal var minuteTableView: UITableView!
    internal var dayCollectionView: UICollectionView!
    
    private var contentView: UIView!
    private var dateTitleLabel: UILabel!
    private var todayButton: UIButton!
    private var doneButton: UIButton!
    private var colonLabel: UILabel!
    
    private var minimumDate: NSDate!
    private var maximumDate: NSDate!
	
    internal var calendar: NSCalendar = NSCalendar.currentCalendar()
    internal var dates: [NSDate]! = []
    internal var components: NSDateComponents!
    
	internal var shadow : UIView!
    @objc class func show(selected: NSDate? = nil, minimumDate: NSDate? = nil, maximumDate: NSDate? = nil) -> DateTimePicker {
		
		var defaultDate = NSDate()
		let calendar = NSCalendar.currentCalendar()
		let comp = calendar.components([.Hour], fromDate: defaultDate)
		let hour = comp.hour
		if hour >= 18 {
			// If it's later than 18:00
			defaultDate = calendar.dateByAddingUnit(.Day,value: 1,toDate: defaultDate,options: [])!
			defaultDate = defaultDate.setTo8AM()
		}
		
        let dateTimePicker = DateTimePicker()
        dateTimePicker.selectedDate = selected ?? defaultDate
        dateTimePicker.minimumDate = minimumDate ?? NSDate(timeIntervalSinceNow: -3600 * 24 * 365 * 20)
        dateTimePicker.maximumDate = maximumDate ?? NSDate(timeIntervalSinceNow: 3600 * 24 * 365 * 20)
        assert(dateTimePicker.minimumDate.compare(dateTimePicker.maximumDate) == .OrderedAscending, "Minimum date should be earlier than maximum date")
//        assert(dateTimePicker.minimumDate.compare(dateTimePicker.selectedDate) != .OrderedDescending || dateTimePicker.minimumDate.compare(dateTimePicker.selectedDate) == .OrderedSame, "Selected date should be later or equal to minimum date")
        assert(dateTimePicker.selectedDate.compare(dateTimePicker.maximumDate) != .OrderedDescending, "Selected date should be earlier or equal to maximum date")
        
        dateTimePicker.configureView()
        UIApplication.sharedApplication().keyWindow?.addSubview(dateTimePicker)
        
        return dateTimePicker
    }
	
	
	func dismissCalendar() {
		self.dismissView()
	}
    
    private func configureView() {
        if self.contentView != nil {
            self.contentView.removeFromSuperview()
        }
        let screenSize = UIScreen.mainScreen().bounds.size
		
		shadow = UIView(frame: UIScreen.mainScreen().bounds)
		shadow.backgroundColor = UIColor.blackColor()
		shadow.alpha = 0.0
		shadow.userInteractionEnabled = true
		self.addSubview(shadow)
		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissCalendar))
		tap.numberOfTapsRequired = 1
		shadow.addGestureRecognizer(tap)
		UIView.animateWithDuration(0.3) {
			self.shadow.alpha = 0.5
		}
		
		
        self.frame = CGRect(x: 0,
                            y: 0,
                            width: screenSize.width,
                            height: screenSize.height)
        
        // content view
        contentView = UIView(frame: CGRect(x: 0,
                                           y: frame.height,
                                           width: frame.width,
                                           height: contentHeight))
        contentView.layer.shadowColor = UIColor(white: 0, alpha: 0.3).CGColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: -2.0)
        contentView.layer.shadowRadius = 1.5
        contentView.layer.shadowOpacity = 0.5
        contentView.backgroundColor = UIColor.whiteColor()
        contentView.hidden = true
        addSubview(contentView)
        
        // title view
        let titleView = UIView(frame: CGRect(origin: CGPoint.zero,
                                             size: CGSize(width: contentView.frame.width, height: 44)))
        titleView.backgroundColor = UIColor.whiteColor()
        contentView.addSubview(titleView)
        
        dateTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 0))
        dateTitleLabel.font = UIFont.systemFontOfSize(17)
        dateTitleLabel.textColor = darkColor
        dateTitleLabel.textAlignment = .Center
		
		// Hide the title label
		dateTitleLabel.hidden = true
		
        resetDateTitle()
        titleView.addSubview(dateTitleLabel)
        
        todayButton = UIButton(type: .System)
        todayButton.setTitle(todayButtonTitle, forState: .Normal)
        todayButton.setTitleColor(highlightColor, forState: .Normal)
        todayButton.addTarget(self, action: #selector(DateTimePicker.setToday), forControlEvents: .TouchUpInside)
        todayButton.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
        todayButton.hidden = self.minimumDate.compare(NSDate()) == .OrderedDescending || self.maximumDate.compare(NSDate()) == .OrderedAscending
        let size = todayButton.sizeThatFits(CGSize(width: 0, height: 44.0)).width + 10.0
        todayButton.frame = CGRect(x: contentView.frame.width - size, y: 0, width: size, height: 44)
		
		// Hide the today button
		todayButton.hidden = true
        titleView.addSubview(todayButton)
        
        // day collection view
        let layout = StepCollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: 75, height: 80)
        
        dayCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: 100), collectionViewLayout: layout)
        dayCollectionView.backgroundColor = daysBackgroundColor
        dayCollectionView.showsHorizontalScrollIndicator = false
        dayCollectionView.registerClass(DateCollectionViewCell.self, forCellWithReuseIdentifier: "dateCell")
        dayCollectionView.dataSource = self
        dayCollectionView.delegate = self
        
        let inset = (dayCollectionView.frame.width - 75) / 2
        dayCollectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        contentView.addSubview(dayCollectionView)
        
        // top & bottom borders on day collection view
        let borderTopView = UIView(frame: CGRect(x: 0, y: 0, width: titleView.frame.width, height: 1))
        borderTopView.backgroundColor = darkColor.colorWithAlphaComponent(0.2)
        contentView.addSubview(borderTopView)
        
        let borderBottomView = UIView(frame: CGRect(x: 0, y: dayCollectionView.frame.origin.y + dayCollectionView.frame.height, width: titleView.frame.width, height: 1))
        borderBottomView.backgroundColor = darkColor.colorWithAlphaComponent(0.2)
        contentView.addSubview(borderBottomView)
        
        // done button
        doneButton = UIButton(type: .System)
        doneButton.frame = CGRect(x: 10, y: contentView.frame.height - 10 - 44, width: contentView.frame.width - 20, height: 44)
        doneButton.setTitle(doneButtonTitle, forState: .Normal)
        doneButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        doneButton.backgroundColor = darkColor.colorWithAlphaComponent(0.5)
        doneButton.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
        doneButton.layer.cornerRadius = 3
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(DateTimePicker.dismissView), forControlEvents: .TouchUpInside)
        contentView.addSubview(doneButton)
        
        // hour table view
        hourTableView = UITableView(frame: CGRect(x: contentView.frame.width / 2 - 60,
                                                  y: borderBottomView.frame.origin.y + 2,
                                                  width: 60,
                                                  height: doneButton.frame.origin.y - borderBottomView.frame.origin.y - 10))
        hourTableView.rowHeight = 36
        hourTableView.contentInset = UIEdgeInsetsMake(hourTableView.frame.height / 2, 0, hourTableView.frame.height / 2, 0)
        hourTableView.showsVerticalScrollIndicator = false
        hourTableView.separatorStyle = .None
        hourTableView.delegate = self
        hourTableView.dataSource = self
        contentView.addSubview(hourTableView)
        
        // minute table view
        minuteTableView = UITableView(frame: CGRect(x: contentView.frame.width / 2,
                                                    y: borderBottomView.frame.origin.y + 2,
                                                    width: 60,
                                                    height: doneButton.frame.origin.y - borderBottomView.frame.origin.y - 10))
        minuteTableView.rowHeight = 36
        minuteTableView.contentInset = UIEdgeInsetsMake(minuteTableView.frame.height / 2, 0, minuteTableView.frame.height / 2, 0)
        minuteTableView.showsVerticalScrollIndicator = false
        minuteTableView.separatorStyle = .None
        minuteTableView.delegate = self
        minuteTableView.dataSource = self
        contentView.addSubview(minuteTableView)
        
        // colon
        colonLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 36))
        colonLabel.center = CGPoint(x: contentView.frame.width / 2,
                                    y: (doneButton.frame.origin.y - borderBottomView.frame.origin.y - 10) / 2 + borderBottomView.frame.origin.y)
        colonLabel.text = ":"
        colonLabel.font = UIFont.boldSystemFontOfSize( 18)
        colonLabel.textColor = highlightColor
        colonLabel.textAlignment = .Center
        contentView.addSubview(colonLabel)
        
        // time separators
        let separatorTopView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 1))
        separatorTopView.backgroundColor = darkColor.colorWithAlphaComponent(0.2)
        separatorTopView.center = CGPoint(x: contentView.frame.width / 2, y: borderBottomView.frame.origin.y + 36)
        contentView.addSubview(separatorTopView)
        
        let separatorBottomView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 1))
        separatorBottomView.backgroundColor = darkColor.colorWithAlphaComponent(0.2)
        separatorBottomView.center = CGPoint(x: contentView.frame.width / 2, y: separatorTopView.frame.origin.y + 36)
        contentView.addSubview(separatorBottomView)
        
        // fill date
        fillDates(minimumDate, toDate: maximumDate)
        updateCollectionView(to: selectedDate)
		
		components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: selectedDate)
		var hour = components.hour
		if hour < 7 || hour > 18 {
			hour = 7
			components.hour = hour
			selectedDate = calendar.dateFromComponents(components)!
		}
		
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        for i in 0..<dates.count {
            let date = dates[i]
            if formatter.stringFromDate(date) == formatter.stringFromDate(selectedDate) {
                dayCollectionView.selectItemAtIndexPath(NSIndexPath(forRow: i, inSection: 0), animated: true, scrollPosition: .CenteredHorizontally)
                break
            }
        }
		
		
        contentView.hidden = false
        
        resetTime()
        
        // animate to show contentView
        UIView.animateWithDuration( 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .CurveEaseIn, animations: {
            self.contentView.frame = CGRect(x: 0,
                                            y: self.frame.height - self.contentHeight,
                                            width: self.frame.width,
                                            height: self.contentHeight)
        }, completion: nil)
    }
    
    func setToday() {
        selectedDate = NSDate()
        resetTime()
    }
    
    func resetTime() {
        components = calendar.components([.Day, .Month, .Year, .Hour, .Minute], fromDate: selectedDate)
		
		
		var hour = components.hour
		if hour < 7 || hour > 18 {
			hour = 7
			components.hour = hour
		}
		
		let componentsNow = calendar.components(.Hour, fromDate: NSDate())
		let hours = [7,8,9,10,11,12,13,14,15,16,17,18]
		var delta = 100000
		var idx=0
		for i in 0...hours.count-1 {
			if abs(hours[i]-componentsNow.hour) <= delta {
				delta = abs(hours[i]-componentsNow.hour)
				idx = i
			}
		}
        if idx+1 < hours.count {
            idx = idx+1
        }else{
            idx = hours[hours.count-1]
        }
        if hour > 0 {
            hourTableView.selectRowAtIndexPath(NSIndexPath(forRow: idx, inSection: 0), animated: false, scrollPosition: .Middle)
            self.tableView(hourTableView, didSelectRowAtIndexPath: NSIndexPath(forRow: idx, inSection: 0))
        }
		
		let minute = components.minute
        if minute >= 0 {
//            let expectedRow = minute == 0 ? 120 : minute + 60 // workaround for issue when minute = 0
            minuteTableView.selectRowAtIndexPath( NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .Middle)
            self.tableView(minuteTableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        }
		
		
		updateCollectionView(to: selectedDate)
		
    }
    
    private func resetDateTitle() {
        guard dateTitleLabel != nil else {
            return
        }
        let formatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        dateTitleLabel.text = formatter.stringFromDate(selectedDate)
        dateTitleLabel.sizeToFit()
        dateTitleLabel.center = CGPoint(x: contentView.frame.width / 2, y: 22)
    }
    
    func fillDates(fromDate: NSDate, toDate: NSDate) {
        
        var dates: [NSDate] = []
        let days = NSDateComponents()
        
        var dayCount = 0
        repeat {
            days.day = dayCount
            dayCount += 1
            guard let date = calendar.dateByAddingComponents(days, toDate: fromDate, options: .MatchFirst) else {
                break;
            }
            if date.compare(toDate) == .OrderedDescending {
                break
            }
            dates.append(date)
        } while (true)
        
        self.dates = dates
        dayCollectionView.reloadData()
        
        if let index = self.dates.indexOf(selectedDate) {
            dayCollectionView.selectItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true, scrollPosition: .CenteredHorizontally)
        }
    }
    
    func updateCollectionView(to currentDate: NSDate) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        for i in 0..<dates.count {
            let date = dates[i]
            if formatter.stringFromDate(date) == formatter.stringFromDate(currentDate) {
                let indexPath = NSIndexPath(forRow: i, inSection: 0)
                dayCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
				
				let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
				dispatch_after(delayTime, dispatch_get_main_queue(), {
					self.dayCollectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .CenteredHorizontally)
				})

                
                break
            }
        }
	}
	
    func dismissView() {
		
		if self.selectedDate.compare(NSDate()) == .OrderedAscending {
			let alert = UIAlertView()
			alert.title = "Ooops!"
			alert.message = "You cannot select a date in the past!"
			alert.addButtonWithTitle("OK")
			alert.show()
			self.resetTime()
			return
		}
		
		UIView.animateWithDuration(0.3) {
			self.shadow.alpha = 0.0
		}
		self.completionHandler?(self.selectedDate)
        UIView.animateWithDuration(0.3, animations: {
            // animate to show contentView
            self.contentView.frame = CGRect(x: 0,
                                            y: self.frame.height,
                                            width: self.frame.width,
                                            height: self.contentHeight)
        }) { (completed) in
            self.removeFromSuperview()
        }
    }
}

extension DateTimePicker: UITableViewDataSource, UITableViewDelegate {
	
	public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == hourTableView {
            // need triple of origin storage to scroll infinitely
            return 12 * 3
        }
        // need triple of origin storage to scroll infinitely
        return 2 * 3
    }
	
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("timeCell") ?? UITableViewCell(style: .Default, reuseIdentifier: "timeCell")
        
        cell.selectedBackgroundView = UIView()
        cell.textLabel?.textAlignment = tableView == hourTableView ? .Right : .Left
        cell.textLabel?.font = UIFont.boldSystemFontOfSize( 18)
        cell.textLabel?.textColor = darkColor.colorWithAlphaComponent(0.4)
        cell.textLabel?.highlightedTextColor = highlightColor
        // add module operation to set value same
		
		
		if tableView == hourTableView {
			let hours = [7,8,9,10,11,12,13,14,15,16,17,18]
			cell.textLabel?.text = String(format: "%02i", hours[indexPath.row % hours.count]  )
		}else{
			let minutes = [0, 30]
			cell.textLabel?.text = String(format: "%02i", minutes[indexPath.row % minutes.count]  )
		}
		
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .Middle)
        if tableView == hourTableView {
			let hours = [7,8,9,10,11,12,13,14,15,16,17,18]
            components.hour = hours[indexPath.row % hours.count]
        } else if tableView == minuteTableView {
			let minutes = [0, 30]
            components.minute = minutes[indexPath.row % minutes.count]
        }
        
		if let selected = calendar.dateFromComponents(components){
            selectedDate = selected
        }
    }
    
    // for infinite scrolling, use modulo operation.
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        guard scrollView != dayCollectionView else {
            return
        }
        let totalHeight = scrollView.contentSize.height
        let visibleHeight = totalHeight / 3.0
        if scrollView.contentOffset.y < visibleHeight || scrollView.contentOffset.y > visibleHeight + visibleHeight {
            let positionValueLoss = scrollView.contentOffset.y - CGFloat(Int(scrollView.contentOffset.y))
            let heightValueLoss = visibleHeight - CGFloat(Int(visibleHeight))
            let modifiedPotisionY = CGFloat(Int( scrollView.contentOffset.y ) % Int( visibleHeight ) + Int( visibleHeight )) - positionValueLoss - heightValueLoss
            scrollView.contentOffset.y = modifiedPotisionY
        }
    }
}


extension DateTimePicker: UICollectionViewDataSource, UICollectionViewDelegate {
    public func numberOfSectionsInCollectionView(_: UICollectionView) -> Int {
        return 1
    }
	
	public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("dateCell", forIndexPath: indexPath) as! DateCollectionViewCell
        
        let date = dates[indexPath.item]
        cell.populateItem(date, highlightColor: highlightColor, darkColor: darkColor)
        
        return cell
    }
	
	public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
	
        //workaround to center to every cell including ones near margins
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            let offset = CGPoint(x: cell.center.x - collectionView.frame.width / 2, y: 0)
            collectionView.setContentOffset(offset, animated: true)
        }
        
        // update selected dates
        let date = dates[indexPath.item]
        let dayComponent = calendar.components([.Day, .Month, .Year], fromDate: date)
        components.day = dayComponent.day
        components.month = dayComponent.month
        components.year = dayComponent.year
        if let selected = calendar.dateFromComponents(components){
            selectedDate = selected
        }
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        alignScrollView(scrollView)
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            alignScrollView(scrollView)
        }
    }
    
    func alignScrollView(scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            let centerPoint = CGPoint(x: collectionView.center.x + collectionView.contentOffset.x, y: 50);
			if let indexPath = collectionView.indexPathForItemAtPoint(centerPoint){
                // automatically select this item and center it to the screen
                // set animated = false to avoid unwanted effects
                collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .Top)
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                    let offset = CGPoint(x: cell.center.x - collectionView.frame.width / 2, y: 0)
                    collectionView.setContentOffset(offset, animated: false)
                }
                
                // update selected date
                let date = dates[indexPath.item]
                let dayComponent = calendar.components([.Day, .Month, .Year], fromDate: date)
                components.day = dayComponent.day
                components.month = dayComponent.month
                components.year = dayComponent.year
                if let selected = calendar.dateFromComponents(components){
                    selectedDate = selected
                }
            }
        } else if let tableView = scrollView as? UITableView {
            let relativeOffset = CGPoint(x: 0, y: tableView.contentOffset.y + tableView.contentInset.top )
            // change row from var to let.
            let row = round(relativeOffset.y / tableView.rowHeight)
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: Int(row), inSection: 0), animated: true, scrollPosition: .Middle)
            
            // add 24 to hour and 60 to minute, because datasource now has buffer at top and bottom.
            if tableView == hourTableView {
				let hours = [7,8,9,10,11,12,13,14,15,16,17,18]
                components.hour = hours[Int(row) % hours.count]
            } else if tableView == minuteTableView {
				let minutes = [0, 30]
                components.minute = minutes[Int(row) % minutes.count]
            }
            
            if let selected = calendar.dateFromComponents(components){
                selectedDate = selected
            }
        }
    }
}

extension NSDate {
	
	func setTo8AM() -> NSDate {
		let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
		let components = calendar.components(([.Day, .Month, .Year, .Hour]), fromDate: self)
		components.hour = 10
		return calendar.dateFromComponents(components)!
	}
	
}

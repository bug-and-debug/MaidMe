//
//  DateTimeHelper.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 2/24/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit

class DateTimeHelper: NSObject {
    
    class func getDateFromString(dateString: String?, format: String) -> NSDate? {
        guard let _ = dateString else {
            return nil
        }
        
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = format
        
        return dateFormater.dateFromString(dateString!)
    }
    
    class func getStringFromDate(date: NSDate, format: String) -> String {
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = format
        
        return dateFormater.stringFromDate(date)
    }
    
    class func getExpiryDateString(month: Int, year: Int) -> String {
        let date = DateTimeHelper.getDateFromString("\(month) / \(year)", format: DateFormater.monthYearFormat)
        return date!.getStringFromDate(DateFormater.monthYearFormat)!
    }
    
    /**
     Get time between input value and current time
     
     - parameter time:
     
     - returns:
     */
    class func getTimeDistance(time: Int64) -> Int64 {
        // Get current time
        let currentTime = Int64(NSDate().timeIntervalSince1970)
        let distance = currentTime - time / 1000
        
        return distance
    }
    
    /**
     Convert time to NSDateComponents for easy getting it in year, month, day...
     
     - parameter time:
     
     - returns:
     */
    class func convertTime(time: Int64) -> NSDateComponents {
        // The time interval
        let theTimeInterval: NSTimeInterval = NSTimeInterval(time)
        
        // Get the system calendar
        let sysCalendar = NSCalendar.currentCalendar()
        
        // Create the NSDates
        let date1 = NSDate()
        let date2 = NSDate(timeInterval: theTimeInterval, sinceDate: date1)
        
        // Get conversion to months, days, hours, minutes
        let unitFlags: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Second]
        let conversionInfo: NSDateComponents = sysCalendar.components(unitFlags, fromDate: date1, toDate: date2, options: NSCalendarOptions.MatchStrictly)
        
        return conversionInfo
    }
    
    /**
     Get the time in string
     
     - parameter conversionInfo:
     
     - returns:
     */
    class func getDisplayTime(conversionInfo: NSDateComponents) -> String {
        if conversionInfo.year != 0 {
            return "\(conversionInfo.year) \(getPluralForm(conversionInfo.year, string: "year")) ago"
        }
        else if conversionInfo.month != 0 {
            return "\(conversionInfo.month) \(getPluralForm(conversionInfo.month, string: "month")) ago"
        }
        else if conversionInfo.day != 0 {
            return "\(conversionInfo.day) \(getPluralForm(conversionInfo.day, string: "day")) ago"
        }
        else if conversionInfo.hour != 0 {
            return "\(conversionInfo.hour) \(getPluralForm(conversionInfo.hour, string: "hour")) ago"
        }
        else if conversionInfo.minute != 0 {
            return "\(conversionInfo.minute) \(getPluralForm(conversionInfo.minute, string: "min")) ago"
        }
        else if conversionInfo.second != 0 {
            return "\(conversionInfo.second) \(getPluralForm(conversionInfo.second, string: "sec")) ago"
        }
        
        return ""
    }
    
    class func getPluralForm(value: Int, string: String) -> String {
        if value > 1 {
            return string + "s"
        }
        return string
    }
    
    class func getCreatedTimeDistance(time: Int64?) -> String {
        guard let createdTime = time else {
            return ""
        }
        
        let distance = getTimeDistance(createdTime)
        let conversion = convertTime(distance)
        return getDisplayTime(conversion)
    }
}

extension NSDate {
    func isLessThanCurrentTime() -> Bool {
        let currentTime = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: currentTime)
        comp.hour += 1
        let time = calendar.dateFromComponents(comp)
        
        guard let comparedTime = time else {
            return false
        }
        
        if self.compare(comparedTime) == NSComparisonResult.OrderedAscending {
            return true
        }
        
        return false
    }
    
    func isLessThanCurrentMonth() -> Bool {
        let currentTime = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let currentComp = calendar.components([.Year, .Month], fromDate: currentTime)
        let comparedComp = calendar.components([.Year, .Month], fromDate: self)
        
        if comparedComp.year > currentComp.year {
            return false
        }
            
        else if comparedComp.year == currentComp.year && comparedComp.month >= currentComp.month {
            return false
        }
        
        return true
    }
    
    func getDayOfWeek() -> String {
        let calendar = NSCalendar.currentCalendar()
        let oneDayFromNow = calendar.dateByAddingUnit(.Day, value: 1, toDate: NSDate(), options: [])
        
        let compDate = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: self)
        let compToday = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
        let compTomorrow = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: oneDayFromNow!)
        if compDate.year == compToday.year && compDate.month == compToday.month && compDate.day == compToday.day {
            return LocalizedStrings.availableTime
        } else if compDate.year == compTomorrow.year && compDate.month == compTomorrow.month && compDate.day == compTomorrow.day {
            return LocalizedStrings.availableTomorrow
        } else {
            let dateFormater = NSDateFormatter()
            dateFormater.dateFormat = "EEEE"
            return dateFormater.stringFromDate(self)
        }
        
    }
    func getDayMonthAndHour() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, HH:mma"
        dateFormatter.AMSymbol = "am"
        dateFormatter.PMSymbol = "pm"
        return dateFormatter.stringFromDate(self)
    }
    
    func getCurrentYear() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Year, .Month, .Day], fromDate: NSDate())
        
        return comp.year
    }
    
    func getYear() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Year, .Month, .Day], fromDate: self)
        
        return comp.year
    }
    
    func getMonth() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Year, .Month, .Day], fromDate: self)
        
        return comp.month
    }
    
    func GMTTimeStamp() -> Double {
        let timeZoneOffset: NSTimeInterval = NSTimeInterval(NSTimeZone.localTimeZone().secondsFromGMT)
        let gmtTimeInterval = self.timeIntervalSinceReferenceDate - timeZoneOffset
        let gmtDate = NSDate(timeIntervalSinceReferenceDate: gmtTimeInterval)
        
        return gmtDate.timeIntervalSince1970
    }
    
    func getStringFromDate(format: String) -> String? {
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = format
        
        return dateFormater.stringFromDate(self)
    }
    
    func roundDownSecond() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: self)
        comp.second = 0
        
        return calendar.dateFromComponents(comp)!
    }
    
    func getNext30Days() -> NSDate {
        let date = self.roundDownSecond()
        
        let time30Days = Double(30 * 24 * 60 * 60)
        let timeInterval = date.timeIntervalSince1970
        
        return NSDate(timeIntervalSince1970: timeInterval + time30Days)
    }
    
    func getNext7Days() -> NSDate {
        let date = self.roundDownSecond()
        
        let time30Days = Double(7 * 24 * 60 * 60)
        let timeInterval = date.timeIntervalSince1970
        
        return NSDate(timeIntervalSince1970: timeInterval + time30Days)
    }
    
    func getNextRoundedTime() -> NSDate {
        let date = self.roundDownSecond()
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: date)
        
        if comp.minute > 0 && comp.minute < 30 {
            return NSDate(timeIntervalSince1970: date.timeIntervalSince1970 + Double((30 - comp.minute) * 60))
        }
        if comp.minute > 30 && comp.minute < 60 {
            return NSDate(timeIntervalSince1970: date.timeIntervalSince1970 + Double((60 - comp.minute) * 60))
        }
        
        return self
    }
    
    func getNextOneRoundedHourTime() -> NSDate {
        let roundedTime = self.getNextRoundedTime()
        let nextOneRounedTime = roundedTime.timeIntervalSince1970 + 60 * 60
        
        return NSDate(timeIntervalSince1970: nextOneRounedTime)
    }
    
    func getHourOfToday() -> String {
        let calendar = NSCalendar.currentCalendar()
        let compDate = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: self)
        let compToday = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
        
        if compDate.year == compToday.year && compDate.month == compToday.month && compDate.day == compToday.day {
            return LocalizedStrings.availableTime + self.getHourAndMin()
        }
        
        return DateTimeHelper.getStringFromDate(self, format: DateFormater.twelvehoursFormat)
    }
    
    func getHourAndMin() -> String {
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = DateFormater.timeFormat
        
        return dateFormater.stringFromDate(self)
    }
    
    func toLocalTime(format: String) -> NSDate {
        let dateString = DateTimeHelper.getStringFromDate(self, format: format)
        
        let df = NSDateFormatter()
        df.dateFormat = format
        
        //Create the date assuming the given string is in GMT
        df.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let date = df.dateFromString(dateString)
        
        return date!
    }
}

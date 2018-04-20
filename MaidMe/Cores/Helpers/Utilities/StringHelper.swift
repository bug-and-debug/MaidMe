//
//  StringHelper.swift
//  Edgar
//
//  Created by Mai Nguyen Thi Quynh on 12/25/15.
//  Copyright © 2015 SmartDev. All rights reserved.
//

import UIKit
import CryptoSwift
import PhoneNumberKit

class StringHelper: NSObject {

    /**
     Get the real size of string
     
     - parameter string: input string
     
     - returns: width and height of the string
     */
    class func stringSize(string: String) -> (swidth: CGFloat, sheight: CGFloat) {
        let button = UIButton(type: UIButtonType.Custom)
        button.setTitle(string, forState: UIControlState.Normal)
        button.sizeToFit()
        
        return (CGRectGetWidth(button.frame), CGRectGetHeight(button.frame))
    }
    
    /**
     Trim all white spaces exist in the string
     
     - parameter text:
     
     - returns: no white space string
     */
    class func trimWhiteSpace(text: String) -> String {
        let words = text.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let nospacestring = words.joinWithSeparator("")
        
        return nospacestring
    }
    
    /**
     Lucy: Trim all white space at the begining and the end the text
     
     - parameter text:
     
     - returns:
     */
    class func trimBeginningWhiteSpace(text: String) -> String {
        let trimedString = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return trimedString
    }
    
    
    // MARK: - Phone number
    
    /**
    Trim the first 0 number appears in the phone number
    
    - parameter phoneNumber:
    
    - returns:
    */
    class func trimExtraZeroNumber(phoneNumber: String) -> String {
        if phoneNumber.hasPrefix("0") {
            return phoneNumber.substringFromIndex(phoneNumber.startIndex.advancedBy(1))
        }
        return phoneNumber
    }
    
    /**
     Create phone number from country dialing code and number
     
     - parameter code:   country dialing code
     - parameter number: phonenumber
     
     - returns: 
     */
    class func createPhoneNumber(code: String, number: String) -> String {
        var phoneNumber = trimWhiteSpace(number)
        phoneNumber = trimExtraZeroNumber(phoneNumber)
        return code + phoneNumber
    }
    
    class func reformatPhoneNumber(number: String) -> String {
        do {
            let phoneNumber = try PhoneNumber(rawNumber: number)
            return phoneNumber.toInternational()
        }
        catch {
            return number
        }
    }
    
    class func getPhoneNumber(number: String) -> String {
        do {
            let phoneNumber = try PhoneNumber(rawNumber: number)
            return phoneNumber.toE164()
        }
        catch {
            return number
        }
    }
    
    class func getHourString(hour: Int) -> String {
        if hour <= 1 {
            return "\(hour) " + LocalizedStrings.hour
        }
        
        return "\(hour) " + LocalizedStrings.hours
    }
    
    // MARK: - SHA
    
    class func encryptString(string: String) -> String {
        if let data: NSData = string.dataUsingEncoding(NSUTF8StringEncoding) {
            let hash = data.sha256()
            
            if let base64 = hash?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength) {
                return base64
            }
        }
        
        return string.sha256()
    }
    
    class func encryptStringsha256(string: String) -> String {
        let hashString: String = string.sha256()
        
        if let data: NSData = hashString.dataUsingEncoding(NSUTF8StringEncoding) {
            var base64: String = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            base64 = base64.stringByReplacingOccurrencesOfString("\r\n", withString: "")
            
            return base64
        }
        
        return ""
    }
    
    class func setPlaceHolderFont(fields: [UITextField], font: String, fontsize: CGFloat) {
        let font = UIFont(name: font, size: fontsize)!
        let attributes = [
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSFontAttributeName : font]
        
        for field in fields {
            field.attributedPlaceholder = NSAttributedString(string: field.placeholder!,
                attributes:attributes)
        }
    }
    
    class func getAddress(strings: [String?]) -> String {
        var address = ""
        
        for string in strings {
            guard var string = string else {
                continue
            }
            
            string = trimBeginningWhiteSpace(string)
            
            if string == "" {
                continue
            }
            
            if address == "" {
                address = string
                continue
            }
            
            address = address + ", " + string
        }
        
        return address
    }
    
    class func getTextViewHeight(textView: UITextView) -> CGFloat {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        return CGRectGetHeight(newFrame)
    }
    
    class func resizeTextView(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
    }
    
    class func getTextHeight(text: String, width: CGFloat, fontSize: CGFloat) -> CGFloat {
        let textView = UITextView(frame: CGRectMake(0, 0, width, 49))
        
        textView.text = text
        textView.font = UIFont(name: CustomFont.quicksanRegular, size: fontSize)
        
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        return CGRectGetHeight(newFrame)
    }
    
    class func addPlusSign(phoneNumber: String) -> String {
        var string = trimWhiteSpace(phoneNumber)
        
        if !string.hasPrefix("+") {
            string = "+" + string
        }
        
        return string
    }
 }

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start: start, end: end)]
    }
}

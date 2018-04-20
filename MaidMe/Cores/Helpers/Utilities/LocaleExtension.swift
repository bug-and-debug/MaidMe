//
//  LocaleExtension.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/29/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit

extension NSLocale {
    class func locales(country : String) -> String {
        let localesName : String = ""
        for localeCode in NSLocale.ISOCountryCodes() {
            let countryName = NSLocale.systemLocale().displayNameForKey(NSLocaleCountryCode, value: localeCode)!
            if country.lowercaseString == countryName.lowercaseString {
                return localeCode
            }
        }
        return localesName
    }
}

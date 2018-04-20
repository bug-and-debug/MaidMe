//
//  TableCellExtension.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/17/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    func removeSeparatorLineInset() {
        // Remove seperator inset
        if (self.respondsToSelector(Selector("setSeparatorInset:"))) {
            self.separatorInset = UIEdgeInsetsZero
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if (self.respondsToSelector(Selector("setPreservesSuperviewLayoutMargins:"))) {
            self.preservesSuperviewLayoutMargins = false
        }
        
        // Explictly set your cell's layout margins
        if (self.respondsToSelector(Selector("setLayoutMargins:"))) {
            self.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    func removeSeparatorLine() {
        //self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.frame), 0, 0)
        self.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, self.bounds.size.width)
    }
    
    func showSeparatorLine() {
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
}

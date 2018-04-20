//
//  TableViewHelper.swift
//  Edgar
//
//  Created by Mai Nguyen Thi Quynh on 12/29/15.
//  Copyright © 2015 smartdev. All rights reserved.
//

import UIKit

extension UITableView {
    /**
     Remove the separator lines.
     
     - parameter tableView: target table view
     */
    func removeSeparatorLines() {
        self.separatorStyle = UITableViewCellSeparatorStyle.None
        self.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
        self.bounces = false
    }
    
    /**
     Hide empty cells of the table.
     
     - parameter tableView: target table view
     */
    func hideTableEmptyCell() {
        let backgroundView = UIView(frame: CGRectZero)
        self.tableFooterView = backgroundView
    }
    
    /**
     Remove the separator line's inset
     
     - parameter cell:
     */
    func removeSeparatorLineInset(cells: [UITableViewCell]) {
        // Remove seperator inset
        for cell in cells {
            cell.removeSeparatorLineInset()
        }
    }

    func removeSeparatorLine(cells: [UITableViewCell]) {
        for cell in cells {
            cell.removeSeparatorLine()
        }
    }
    
    func showSeparatorLine(cells:[UITableViewCell]) {
        for cell in cells {
            cell.showSeparatorLine()
        }
    }
}

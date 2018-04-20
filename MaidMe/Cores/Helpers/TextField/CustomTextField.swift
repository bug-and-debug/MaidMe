//
//  CustomTextField.swift
//  Edgar
//
//  Created by Mai Nguyen Thi Quynh on 1/6/16.
//  Copyright © 2016 smartlink. All rights reserved.
//

import UIKit

protocol CustomTextFieldDelegate {
    func onDeleteBackward(textField: CustomTextField)
}

class CustomTextField: UITextField {

    var customDelegate: CustomTextFieldDelegate?

    override func deleteBackward() {
        super.deleteBackward()
        customDelegate?.onDeleteBackward(self)
    }
    
    /**
     Disable paste action on the textfield
     
     - parameter action:
     - parameter sender:
     
     - returns: 
     */
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        super.canPerformAction(action, withSender: sender)

        return false
    }
}

//
//  ClipView.swift
//  MaidMe
//
//  Created by Romecon on 3/13/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit

class ClipView: UIView {
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let child = super.hitTest(point, withEvent: event)
        
        if child == self && self.subviews.count > 0 {
            return self.subviews[0]
        }
        return child
    }
}

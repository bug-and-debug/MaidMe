//
//  BorderView.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/2/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit

@IBDesignable class BorderView: UIView {

    var shapeLayer: CAShapeLayer!
    
    @IBInspectable var borderRadius: Float {
        get {
            return Float(layer.cornerRadius)
        }
        set {
            layer.masksToBounds = newValue > 0
            layer.cornerRadius = CGFloat(newValue)
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return CGFloat(layer.borderWidth)
        }
        set {
            layer.borderWidth = CGFloat(newValue)
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.lightGrayColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return CGFloat(layer.cornerRadius)
        }
        set {
            layer.masksToBounds = newValue > 0
            layer.cornerRadius = CGFloat(newValue)
        }
    }
    
    @IBInspectable var dashPattern: Int = 0
    @IBInspectable var spacePattern: Int = 0
    
    @IBInspectable var borderType: BorderType = .Solid {
        didSet {
            drawDashedBorder()
        }
    }
    
    func drawDashedBorder() {
        if (shapeLayer != nil) {
            shapeLayer.removeFromSuperlayer()
        }
   
        let lineColor = borderColor
        let frame = self.bounds
    
        shapeLayer = CAShapeLayer()
    
        //creating a path
        let path = CGPathCreateMutable()
    
        //drawing a border around a view
        CGPathMoveToPoint(path, nil, 0, frame.size.height - cornerRadius)
        CGPathAddLineToPoint(path, nil, 0, cornerRadius)
        CGPathAddArc(path, nil, cornerRadius, cornerRadius, cornerRadius, CGFloat(M_PI), CGFloat(-M_PI_2), false)
        CGPathAddLineToPoint(path, nil, frame.size.width - cornerRadius, 0)
        CGPathAddArc(path, nil, frame.size.width - cornerRadius, cornerRadius, cornerRadius, CGFloat(-M_PI_2), 0, false)
        CGPathAddLineToPoint(path, nil, frame.size.width, frame.size.height - cornerRadius);
        CGPathAddArc(path, nil, frame.size.width - cornerRadius, frame.size.height - cornerRadius, cornerRadius, 0, CGFloat(M_PI_2), false)
        CGPathAddLineToPoint(path, nil, cornerRadius, frame.size.height);
        CGPathAddArc(path, nil, cornerRadius, frame.size.height - cornerRadius, cornerRadius, CGFloat(M_PI_2), CGFloat(M_PI), false)
    
        //path is set as the _shapeLayer object's path
        shapeLayer.path = path
    
        shapeLayer.backgroundColor = UIColor.clearColor().CGColor// [[UIColor clearColor] CGColor];
        shapeLayer.frame = frame
        shapeLayer.masksToBounds = false
        shapeLayer.setValue(NSNumber(bool: false), forKey: "isCircle")
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = lineColor.CGColor
        shapeLayer.lineWidth = borderWidth
        shapeLayer.lineDashPattern = borderType == .Dashed ? [dashPattern, spacePattern] : nil
        shapeLayer.lineCap = kCALineCapRound
    
        //_shapeLayer is added as a sublayer of the view
        self.layer.addSublayer(shapeLayer)
        self.layer.cornerRadius = cornerRadius
    }

}

enum BorderType: Int {
    case Dashed = 0
    case Solid
}

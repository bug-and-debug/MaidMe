//
//  AddressTitleView.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 1/3/17.
//  Copyright © 2017 SmartDev. All rights reserved.
//


import UIKit

class AddressTitleView: UIView {
    
    
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var dropDownImage : UIImageView!
    @IBOutlet weak var buildingNameLabel: UILabel!
    @IBOutlet weak var showListAddressButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSBundle.mainBundle().loadNibNamed("AddressTitleView", owner: self, options: nil)
        
        self.view.frame = self.bounds
        self.addSubview(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NSBundle.mainBundle().loadNibNamed("AddressTitleView", owner: self, options: nil)
        
        self.view.frame = self.bounds
        self.addSubview(view)
    }
    
}

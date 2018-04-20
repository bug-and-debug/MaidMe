//
//  BookingAddressCell.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 4/7/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SSKeychain
import SWTableViewCell
class CurrentAddressCell: UITableViewCell {
    
    @IBOutlet weak var addressLabel: UILabel!
   // @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
   // @IBOutlet weak var editCurentAddressBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setContent(address: Address) {
        addressLabel.text = StringHelper.getAddress([address.buildingName,address.emirate, address.country])
        }
    
}

class AddressCell: SWTableViewCell {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var buildingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setContent(address: Address) {
        addressLabel.text = StringHelper.getAddress([address.buildingName, address.emirate, address.country])
        buildingLabel.text = StringHelper.getAddress([address.buildingName])

    }
}

class NewAddressCell: UITableViewCell {
    
    @IBOutlet weak var addPlaceButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
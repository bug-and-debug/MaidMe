//
//  CardDetailCell.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/2/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SWTableViewCell

class DefaultCardCell: SWTableViewCell {
    
    @IBOutlet weak var endCardNumber: UILabel!
    @IBOutlet weak var defaultCardLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

class  AddNewCardCell: UITableViewCell{
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

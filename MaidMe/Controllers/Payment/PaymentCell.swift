//
//  PaymentCell.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/3/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit

class PaymentHeaderCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yourCardsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
 
    func setTitle(string: String) {
        titleLabel.text = string
    }
}

class CardViewCell: UITableViewCell {
    
    @IBOutlet weak var cardView: CardView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCardInfo(card: Card) {
        cardView.showCardInfo(card)
    }
}

class CardSumaryCell: UITableViewCell {
    
    @IBOutlet weak var cardLogoImageView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var changeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func showCardSumaryInfo(card: Card) {
        if card.brand == CardType.Master {
            cardLogoImageView.image = UIImage(named: ImageResources.mastercardSmall)
        }
        else if card.brand == CardType.Visa {
            cardLogoImageView.image = UIImage(named: ImageResources.visacardSmall)
        }
        
        numberLabel.text = CardHelper.showLastFourDigit(card.lastFourDigit)//hideCardNumber(card.number, numberOfHide: 4)
    }
}

class PaymentInfoCell: UITableViewCell {
   
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var cardLogo: UIImageView!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setFontSize()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func showPaymentInfo(card: Card) {
        
        numberTextField.text = CardHelper.reformatCardNumber(card.number)
		if card.cardLogoData != nil {
			cardLogo.image = UIImage(data: card.cardLogoData!)
		}
		
        if card.expiryMonth != 0 && card.expiryYear != 0 {
        expiryDateTextField.text = DateTimeHelper.getExpiryDateString(card.expiryMonth, year: card.expiryYear)
            //card.expiryDate?.getStringFromDate(DateFormater.monthYearFormat)
        }
        cvvTextField.text = card.cvv
    }
    
    func setFontSize() {
        StringHelper.setPlaceHolderFont([numberTextField, expiryDateTextField, cvvTextField], font: CustomFont.quicksanRegular, fontsize: 16.0)
    }
    
    func resetCardInfor() {

        numberTextField.text = ""
        cardLogo.image = nil
        expiryDateTextField.text = ""
        cvvTextField.text = ""
    }
}

class CountryCell: UITableViewCell {
    
    @IBOutlet weak var countryTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func resetCountry() {
        countryTextField.text = LocalizedStrings.defaultCountry
    }
}

class BillingAddressSumaryCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func showBillingAddressInfo(address: BillingAddress) {
        nameLabel.text = address.firstName + " " + address.lastName
        addressLabel.text = address.billingAddress
        cityLabel.text = address.city
        countryLabel.text = address.country
        regionLabel.text = address.region
    }
}

class BillingAddressCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class StoredPaymentSettingCell: UITableViewCell {
    
    @IBOutlet weak var checkbox: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateButtonImage(isSelected: Bool) {
        if !isSelected {
            checkbox.setImage(UIImage(named: ImageResources.uncheckBox), forState: UIControlState.Normal)
           
        } else {
            checkbox.setImage(UIImage(named: ImageResources.checkedBox), forState: UIControlState.Normal)
        }
    }
}

class TotalPaymentCell: UITableViewCell {
    
    @IBOutlet weak var totalValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setPrice(price: Float) {
        totalValueLabel.text = LocalizedStrings.currency + " " + String.localizedStringWithFormat("%.2f", price)
    }
}

class PayActionCell: UITableViewCell {
    
    @IBOutlet weak var payButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func changeButtonUI(isValid: Bool) {
        ValidationUI.changeRequiredFieldsUI(isValid, button: payButton)
    }
}

let ktTimeInMonth: NSTimeInterval = 60 * 60 * 24 * 31

class DatePickerCell: UITableViewCell {
    
    @IBOutlet weak var datePicker: MAKMonthPicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        datePicker.yearRange = NSRange(location: NSDate().getCurrentYear(), length: 100)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupPicker() {
        datePicker.format = [MAKMonthPickerFormat.Month, MAKMonthPickerFormat.Year]
        datePicker.monthFormat = "%n"
        datePicker.date = NSDate(timeIntervalSinceNow: -ktTimeInMonth)
        datePicker.yearRange = NSMakeRange(2000, 10000)
        //datePicker.monthPickerDelegate = self
    }
    
    func resetDatePicker() {
        datePicker.setDate(NSDate(), animated: true)
    }
}

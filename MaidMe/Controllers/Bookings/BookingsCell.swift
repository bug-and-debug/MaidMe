//
//  BookingsCell.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 3/11/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SWTableViewCell
import Alamofire

func loadImageFromURL(imageString: String,imageLoad: UIImageView) {
    imageLoad.image = nil
    let urlString: String = "\(Configuration.maidImagesPath)\(imageString)"
    imageLoad.sd_setImageWithURL(NSURL(string: urlString), completed: { (image, error, cacheType, url) in
        imageLoad.image = image
    })
}

class PastBookingCell: UITableViewCell {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var backgroundCardView: UIView!
   
    @IBOutlet weak var imageWorker: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var ratingStarView: RatingStars!
    
    @IBOutlet weak var bookingCodeLabel: UILabel!
    @IBOutlet weak var rebookingButton: UIButton!
    @IBOutlet weak var workedTimeLabel: UILabel!
    
    @IBOutlet weak var statusCancelLabel: UILabel!
  //  @IBOutlet weak var bookingAddressLabel: UILabel!
    @IBOutlet weak var descriptionServiceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         setupCell()
        }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setupCell(){
        backgroundCardView.backgroundColor = UIColor.whiteColor()
        contentView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        self.removeSeparatorLineInset()
        backgroundCardView.clipsToBounds = false
        backgroundCardView.layer.shadowOpacity = 0.15
        imageWorker.layer.borderWidth = 1
        imageWorker.layer.cornerRadius = (imageWorker.frame.width)/2
        imageWorker.layer.borderColor = UIColor.grayColor().CGColor
        clipsToBounds = true
        rebookingButton.layer.cornerRadius = 5
        backgroundColor = UIColor.whiteColor()
    }
    
    func showDetails(booking: Booking) {
		if booking.maid != nil {
			let name = booking.maid!.firstName! + " " + booking.maid!.lastName!
			workerNameLabel.text = name
		}
        let serviceName = booking.service?.name == nil ? "" : booking.service!.name!
        serviceLabel.text = serviceName.uppercaseString
        let date = booking.time!.toLocalTime(DateFormater.twelvehoursFormat)
        timeLabel.text = DateTimeHelper.getStringFromDate(date, format: "MMM dd yyyy, HH:mma")
        priceLabel.text = LocalizedStrings.currency + " " + String.localizedStringWithFormat("%.2f", (booking.price == 0 ? 0 : booking.price))
        ratingStarView.setRatingLevel(booking.rating == 0 ? 0 : booking.rating)
        if booking.bookingStatus == 2 {
            bookingCodeLabel.text = "Ref. \(booking.bookingCode == nil ? "" : booking.bookingCode!)"
            statusCancelLabel.text = ""
        }
        else{
//            var text:NSString = "Ref. \(booking.bookingCode == nil ? "" : booking.bookingCode!) CANCELED"
//            var myMutableString = NSMutableAttributedString()
//            myMutableString = NSMutableAttributedString(string: text as String, attributes: [NSFontAttributeName:UIFont(name: "SFUIDisplay-Regular", size: 12.0)!])
//  myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: NSRange(location:11,length:9))
            if booking.bookingStatus == 3 || booking.bookingStatus == 4 || booking.bookingStatus == 5 {
                bookingCodeLabel.text = "Ref. \(booking.bookingCode == nil ? "" : booking.bookingCode!)"
                statusCancelLabel.text = "CANCELED"
                
            }
        }
        workedTimeLabel.text = StringHelper.getHourString(booking.hours == 0 ? 0 : booking.hours)
        addressLabel.text = booking.address?.buildingName//(booking.workingAreaRef?.emirate == nil ? "" : booking.workingAreaRef?.emirate)
        //load avatar
        if booking.maid!.avartar! == ""{
            imageWorker.image = UIImage(named: "noun")
        }
        else{
        let avartarURL: String = "\(booking.maid!.avartar!)"
            loadImageFromURL(avartarURL, imageLoad: imageWorker)
        }
       
        if booking.isRebookable == true {
            rebookingButton.enabled = true
            rebookingButton.alpha = 1
        }
        if booking.isRebookable == false {
            rebookingButton.enabled = false
            rebookingButton.alpha = 0.5
        }
    }
    
    func showArrow(selectedIndex: NSIndexPath?, indexPath: NSIndexPath, isShowBookingDetail: Bool) -> Int {
        var index = indexPath.row
        
        if let selectedIndex = selectedIndex {
            if indexPath.row > selectedIndex.row && isShowBookingDetail {
                index -= 1
            }
            
            
        }
        return index
    }
}
class UpcomingCell: UITableViewCell{
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var imageWorker: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var ratingStarView: RatingStars!
    
    @IBOutlet weak var addressLabel: UILabel!
 
    @IBOutlet weak var workedTimeLabel: UILabel!
    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet weak var bookingCodeLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var bookingViews = [UIView]()
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func setupCell(){
        backgroundCardView.backgroundColor = UIColor.whiteColor()
        contentView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        self.removeSeparatorLineInset()
        backgroundCardView.clipsToBounds = false
        backgroundCardView.layer.shadowOpacity = 0.25
        cancelButton.layer.cornerRadius = 5
        callButton.layer.cornerRadius = 5
        imageWorker.layer.borderWidth = 1
        imageWorker.layer.cornerRadius = (imageWorker.frame.width)/2
        imageWorker.layer.borderColor = UIColor.grayColor().CGColor
    }
    func showArrow(selectedIndex: NSIndexPath?, indexPath: NSIndexPath, isShowBookingDetail: Bool) -> Int {
        var index = indexPath.row
        
        if let selectedIndex = selectedIndex {
            if indexPath.row > selectedIndex.row && isShowBookingDetail {
                index -= 1
            }
        }
        return index
    }
    func showDetails(booking: Booking) {
        
        let name = booking.maid!.firstName! + " " + booking.maid!.lastName!
        workerNameLabel.text = name
        let serveseName = booking.service?.name == nil ? "" : booking.service!.name!
        serviceLabel.text = serveseName.uppercaseString
        let date = booking.time!.toLocalTime(DateFormater.twelvehoursFormat)
        timeLabel.text = DateTimeHelper.getStringFromDate(date, format: "MMM dd yyyy, HH:mma")
        //time service
        workedTimeLabel.text = StringHelper.getHourString(booking.hours == 0 ? 0 : booking.hours)
        priceLabel.text = LocalizedStrings.currency + " " + String.localizedStringWithFormat("%.2f", (booking.price == 0 ? 0 : booking.price))
        ratingStarView.setRatingLevel(booking.rating == 0 ? 0 : booking.rating)
        bookingCodeLabel.text = "Ref. \(booking.bookingCode == nil ? "" : booking.bookingCode!)"
        addressLabel.text = booking.address?.buildingName//(booking.workingAreaRef?.emirate == nil ? "" : booking.workingAreaRef?.emirate)
        
        //load avatar
        if booking.maid!.avartar! == ""{
            imageWorker.image = UIImage(named: "noun")
        }
        else{
            let avartarURL: String = "\(booking.maid!.avartar!)"
            loadImageFromURL(avartarURL, imageLoad: imageWorker)
        }

    }
    func cancelABooking(index: Int) {
        let bookingView = bookingViews[index]
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            // Remove the subview from parent view.
            bookingView.alpha = 0.0
        }) { (flag) -> Void in
            bookingView.removeFromSuperview()
            self.bookingViews.removeAtIndex(index)
            
        }
    }
    
}


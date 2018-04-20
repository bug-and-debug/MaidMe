//
//  AvailabelServiceCell.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 12/23/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class AvailabelServiceCell: UITableViewCell {
    
    
    @IBOutlet weak var detailService: UILabel!
    @IBOutlet weak var imageName: UIImageView!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var backgroundCardView : UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundCardView.backgroundColor = UIColor.whiteColor()
        contentView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        self.removeSeparatorLineInset()
        backgroundCardView.clipsToBounds = false
        backgroundCardView.layer.shadowOpacity = 0.25
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}

var imageCache = [String: UIImage]()
extension UITableViewCell {
    func cropImage(imageCrop: UIImage) -> UIImage {
        let imageView = UIImageView(image: imageCrop)
        let crop = CGRectMake(0, imageView.frame.height/2, imageView.frame.width, imageView.frame.height/2)
        let cgImage = CGImageCreateWithImageInRect(imageCrop.CGImage!, crop)
        let image: UIImage = UIImage(CGImage: cgImage!)
        return image
    }
    func loadImageFromURLwithCache(imageString: String,imageLoad: UIImageView) {
        imageLoad.image = nil
        
        let urlString: String = "http:\(imageString)"
		imageLoad.sd_setImageWithURL(NSURL(string: urlString), completed: { (image, error, cacheType, url) in
			if image != nil {
				imageLoad.image = self.cropImage(image)
			}
		})
	}
}

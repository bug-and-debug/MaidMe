//
//  CustomTabbarViewController.swift
//  MaidMe
//
//  Created by Vo Minh Long on 1/6/17.
//  Copyright © 2017 SmartDev. All rights reserved.
//

import UIKit

class CustomTabbarViewController: BaseViewController {
    
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var containerPast: UIView!
    @IBOutlet weak var containerUpComing: UIView!
    
    var embeddedViewController: PastOrderTableViewCOntroller!
    override func viewDidLoad() {
        super.viewDidLoad()
        //  let segAttributes: NSDictionary = [
        //            NSForegroundColorAttributeName: UIColor(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)]
        
        let segAttributes: NSDictionary = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont(name: "Quicksand", size: 15)!
        ]
        self.segmented.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], forState: UIControlState.Normal)
        containerPast.alpha = 0
        containerUpComing.alpha = 0
        self.segmented.layer.cornerRadius = 0.1
        self.segmented.layer.borderColor = UIColor.whiteColor().CGColor
        selectedSegment()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = true
		self.navigationItem.hidesBackButton = true
        self.customBackButton()
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showUpcoming), name: "showUpComming", object: nil)
    }
    func showUpcoming(){
        segmented.selectedSegmentIndex = 0
        selectedSegment()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func selectedSegment(){
        let array = segmented.subviews
        if segmented.selectedSegmentIndex == 0{
            let segAttributes: NSDictionary = [
                NSForegroundColorAttributeName: UIColor.blackColor(),
                NSFontAttributeName: UIFont(name: "Quicksand", size: 15)!
            ]
            self.segmented.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], forState: UIControlState.Normal)
            
            UIView.animateWithDuration(0.5, animations: {
                self.containerUpComing.alpha = 1
                self.containerPast.alpha = 0
                
                array[0].tintColor = UIColor.whiteColor()//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                array[1].tintColor = UIColor.whiteColor()//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                let segAttributes: NSDictionary = [
                    NSForegroundColorAttributeName: UIColor(red: 61/255, green: 185/255, blue: 216/255, alpha: 1),
                    NSFontAttributeName: UIFont(name: "Quicksand", size: 15)!
                ]
                self.segmented.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], forState: UIControlState.Selected)
                
                
            })
        }
        else{
            let segAttributes: NSDictionary = [
                NSForegroundColorAttributeName: UIColor.blackColor(),
                NSFontAttributeName: UIFont(name: "Quicksand", size: 15)!
            ]
            self.segmented.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], forState: UIControlState.Normal)
            
            UIView.animateWithDuration(0.5, animations: {
                self.containerUpComing.alpha = 0
                self.containerPast.alpha = 1
                array[1].tintColor = UIColor.whiteColor()//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                array[0].tintColor = UIColor.whiteColor()//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                let segAttributes: NSDictionary = [
                    NSForegroundColorAttributeName: UIColor(red: 61/255, green: 185/255, blue: 216/255, alpha: 1),
                    NSFontAttributeName: UIFont(name: "Quicksand", size: 15)!
                ]
                self.segmented.subviews[1]
                self.segmented.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], forState: UIControlState.Selected)
                
            })
        }

        
    }
    @IBAction func showComponent(sender: UISegmentedControl) {
        let array = segmented.subviews
        if sender.selectedSegmentIndex == 0{
            UIView.animateWithDuration(0.5, animations: {
                self.containerUpComing.alpha = 1
                self.containerPast.alpha = 0
                array[0].tintColor = UIColor.whiteColor()//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                array[1].tintColor = UIColor.whiteColor()//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                let segAttributes: NSDictionary = [
                    NSForegroundColorAttributeName: UIColor(red: 61/255, green: 185/255, blue: 216/255, alpha: 1),
                    NSFontAttributeName: UIFont(name: "Quicksand", size: 15)!
                ]
                
                self.segmented.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], forState: UIControlState.Selected)
                
            })
        }
        else{
            UIView.animateWithDuration(0.5, animations: {
                self.containerUpComing.alpha = 0
                self.containerPast.alpha = 1
                array[1].tintColor = UIColor.whiteColor()//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                array[0].tintColor = UIColor.whiteColor()//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                let segAttributes: NSDictionary = [
                    NSForegroundColorAttributeName: UIColor(red: 61/255, green: 185/255, blue: 216/255, alpha: 1),
                    NSFontAttributeName: UIFont(name: "Quicksand", size: 15)!
                ]
                self.segmented.subviews[1]
                self.segmented.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], forState: UIControlState.Selected)
                let storyboard = self.storyboard
                guard let PastVC = storyboard?.instantiateViewControllerWithIdentifier("PastVC") as? PastOrderTableViewCOntroller else {
                    return
                }
                PastVC.tableView.beginUpdates()
                PastVC.tableView.reloadData()
                PastVC.tableView.endUpdates()
                
            })
        }
    }
    
}

//
//  TermsAndConditions.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 5/18/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON



class TermsAndConditions: BaseTableViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var termsTextView: UITextView!
    
    @IBOutlet weak var termsTextViewBottomLayout: NSLayoutConstraint!
    let fetchTermsConditions = GetTermsAndConditionsService()
    let createTokenCard = CreateNewTokenCardService()
    var isMovedFromLogin: Bool = false
    var isMoveFromRegister: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTermsAndConditionsRequest()
		
		if let cachedTS :String = NSUserDefaults.standardUserDefaults().stringForKey("TCCache") {
			do {
				let string = "<span style=\"font-family: SFUIDisplay-Regular; font-size: 15\">\(cachedTS)</span>"
				let attributedString = try NSAttributedString(data: string.dataUsingEncoding(NSUnicodeStringEncoding)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSNumber(integer: Int(NSUTF8StringEncoding))], documentAttributes: nil)
				termsTextView.attributedText = attributedString
				self.tableView.reloadData()
				
			} catch _ {
				print("Error on parsing")
			}
		}
		
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.customBackButton()
        if isMoveFromRegister {
            termsTextViewBottomLayout.constant = 15
        }
        tableView.alwaysBounceVertical = false
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        self.navigationController?.navigationBar.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGRectGetHeight(self.tableView.frame)
    }

    // MARK: - API
    
    func fetchTermsAndConditionsRequest() {
        sendRequest(nil, request: fetchTermsConditions, requestType: .FetchTermsConditions, isSetLoadingView: true, view: nil)
    }
    
    func sendRequest(parameters: [String: AnyObject]?,
        request: RequestManager,
        requestType: RequestType,
        isSetLoadingView: Bool, view: UIView?) {
            // Check for internet connection
            if RequestHelper.isInternetConnectionFailed() && NSUserDefaults.standardUserDefaults().valueForKey("TCCache") == nil{
                RequestHelper.showNoInternetConnectionAlert(self)
                return
            }
            
            // Set loading view center
            if isSetLoadingView && view != nil {
                self.setRequestLoadingViewCenter1(view!)
            }
			if NSUserDefaults.standardUserDefaults().valueForKey("TCCache") == nil {
				self.startLoadingView()
			}
		
            
            request.request(parameters: parameters) {
                [weak self] response in
                
                if let strongSelf = self {
                    strongSelf.handleAPIResponse()
                    strongSelf.handleResponse(response, requestType: requestType)
                }
            }
    }
    
    func handleResponse(response: Response<AnyObject, NSError>, requestType: RequestType) {
        let result = ResponseHandler.responseHandling(response)
        
        if result.messageCode != MessageCode.Success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            
            return
        }
        
        setUserInteraction(true)
        
        if requestType == .FetchTermsConditions {
            handleFetchTCResponse(result, requestType: .FetchTermsConditions)
        }
    }
    
    func handleFetchTCResponse(result: ResponseObject, requestType: RequestType) {
        guard let list = result.body else {
            return
        }
		
		NSUserDefaults.standardUserDefaults().setValue(list.stringValue, forKey: "TCCache")
		
        do {
            let string = "<span style=\"font-family: SFUIDisplay-Regular; font-size: 15\">\(list.stringValue)</span>"
            let attributedString = try NSAttributedString(data: string.dataUsingEncoding(NSUnicodeStringEncoding)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSNumber(integer: Int(NSUTF8StringEncoding))], documentAttributes: nil)
            termsTextView.attributedText = attributedString
            self.tableView.reloadData()
            
        } catch _ {
            print("Error on parsing")
        }
    }
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(requestType: RequestType) {
        if requestType == .FetchTermsConditions {
            self.fetchTermsAndConditionsRequest()
        }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

//
//  ListCardTableViewController.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 1/6/17.
//  Copyright © 2017 SmartDev. All rights reserved.
//

import UIKit
import SWTableViewCell
import Alamofire
import SwiftyJSON
import SSKeychain

class PaymentMethodsTableViewController: BaseTableViewController {
    
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var customerEmailLabel: UILabel!
    @IBOutlet weak var customerPhoneLabel: UILabel!
    
    var listCard = [Card]()
    var removeCardAPI = RemoveCardService()
    var defaultCardAPI = DefaultCardService()
    var messageCode: MessageCode?
    let fetchAllCardAPI = FetchAllCardsService()
    var isMoveFromViewPersonal: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllCardsRequest()
        showCustomerInfor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
        self.tabBarController?.tabBar.hidden = false
    }
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if isMoveFromViewPersonal != true {
            fetchAllCardsRequest()
            showCustomerInfor()
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        isMoveFromViewPersonal = false
    }
    
    func showCustomerInfor(){
        let email = SSKeychain.passwordForService(KeychainIdentifier.appService, account: KeychainIdentifier.userName)
        let phoneNumber = SSKeychain.passwordForService(KeychainIdentifier.appService, account: KeychainIdentifier.phoneNumber)
        let customerName = SSKeychain.passwordForService(KeychainIdentifier.appService, account: KeychainIdentifier.customerName)
        customerEmailLabel.text = email
        customerPhoneLabel.text = StringHelper.reformatPhoneNumber(phoneNumber == nil ? "" : phoneNumber)
        customerNameLabel.text = customerName
    }

    func rightButtons() -> NSMutableArray{
        let leftUtilityButtons = NSMutableArray()
        leftUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red:  91.0/255,green: 194.0/255,blue: 209.0/255.0,alpha: 1.0), icon: UIImage(named: "default_button"))
        leftUtilityButtons.sw_addUtilityButtonWithColor(UIColor.lightGrayColor(), icon: UIImage(named: "deletee_button" ))
        return leftUtilityButtons
    }
    
    @IBAction func backAction(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func removeCardRequest(cardRemove: Card?) {
        let params = removeCardAPI.getRemoveCardParams(cardRemove)
        sendRequest(params, request: removeCardAPI, requestType: .RemoveCards, isSetLoadingView: true, button: nil)
        
    }
    func defaultCardRequest(card: Card) {
        let params = defaultCardAPI.getDefaultCardParams(card)
        sendRequest(params, request: defaultCardAPI, requestType: .DefaultCard, isSetLoadingView: true, button: nil)
    }
    func fetchAllCardsRequest() {
        sendRequest(nil, request: fetchAllCardAPI, requestType: .FetchAllCard, isSetLoadingView: false,button: nil)
    }

    func sendRequest(parameters: [String: AnyObject]?,
                     request: RequestManager,
                     requestType: RequestType,
                     isSetLoadingView: Bool, button: UIButton?) {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
            return
        }
        self.startLoadingView()
        
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
            
            if let error = result.messageCode {
                messageCode = error
            }
            
            return
        }
        if requestType == .DefaultCard {
            fetchAllCardsRequest()
        } else if requestType == .FetchAllCard {
            handleCardListResponse(result.body)
        }
    }
     func handleCardListResponse(responseBody: JSON?) {
        guard let list = responseBody else {
            return
        }
        
        listCard = fetchAllCardAPI.getCardList(list)
        self.tableView.reloadData()
      
    }
    
    @IBAction func editPersonalAction(sender: AnyObject) {
        let storyboard = self.storyboard
        guard let personalVC = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIDs.personalDetails) else {
            return
        }
        self.navigationController?.pushViewController(personalVC, animated: true)
        
    }
    func showAddNewCardVC(){
        let storyboard = self.storyboard
        guard let addNewCardVC = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIDs.addNewCardVC) else {
            return
        }
        self.navigationController?.pushViewController(addNewCardVC,animated: true)
    }
    
    func displayDeleteCard(index: Int) {
        let alert = UIAlertController(title: "Do you want to delete this card?", message: "**** **** **** \(listCard[index].lastFourDigit)", preferredStyle: .Alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        let okButton = UIAlertAction(title: "Ok", style: .Default) { (action) in
            self.removeCardRequest(self.listCard[index])
            self.listCard.removeAtIndex(index)
            self.tableView.reloadData()
        }
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if listCard.count != 0 {
            return listCard.count + 1
        } else {
            return 1
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if listCard.count != 0 && indexPath.row < listCard.count {
            let cellID = "defaultCardCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as? DefaultCardCell
                let card = listCard[indexPath.row]
                if card.isDefault == true {
                    cell!.defaultCardLabel.text = "DEFAULT CARD"
                } else {
                    cell?.delegate = self
                    cell?.setRightUtilityButtons(rightButtons() as [AnyObject], withButtonWidth: 70)
                    cell!.defaultCardLabel.text = "CARD"
                }
                cell!.endCardNumber.text = "**** **** **** \(card.lastFourDigit)"
            return cell!
        } else {
                let cellId = "addNewCardCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as? AddNewCardCell
                return cell!
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == listCard.count {
            
            self.showAddNewCardVC()
        }
    }
    
}
extension PaymentMethodsTableViewController: SWTableViewCellDelegate {
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        switch (index) {
        case 0:
            cell.hideUtilityButtonsAnimated(true)
            let index = self.tableView.indexPathForCell(cell)
            self.defaultCardRequest(listCard[(index?.row)!])
        case 1:
            cell.hideUtilityButtonsAnimated(true)
            let index = self.tableView.indexPathForCell(cell)
            self.displayDeleteCard((index?.row)!)
        default:
            break
        }
    }
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell) -> Bool {
        return true
    }
    
}

//
//  AddNewCardTableViewController.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 1/19/17.
//  Copyright © 2017 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain


class AddNewCardTableViewController: BaseTableViewController {
    

    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var cardLogo: UIImageView!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var addCardButton: UIButton!
    
    var expiryDate: NSDate!
    var newCard = Card()
     var isEnableAddButton = false
    var paymentToken: String!
    
    let createTokenCard = CreateNewTokenCardService()
    let createCustomerCard = CreateCustomerCardService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = true
        self.navigationItem.title = "ADD CARD"
    }

    private func checkFullFillRequiredFields(card: Card?) {
        var isFullFilled = true
        
        if let card = card {
                isFullFilled = Validation.isFullFillRequiredTexts([card.number, (card.expiryMonth == 0 ? "" : "\(card.expiryMonth)"), card.cvv])
        }
        
        isEnableAddButton = isFullFilled
        ValidationUI.changeRequiredFieldsUI(isEnableAddButton, button: addCardButton)
    }
    
    @IBAction func addCardAction(){
        self.dismissKeyboard()
        if cardNumberTextField.text == "" || cvvTextField.text == ""{
            showAlertView(LocalizedStrings.updateSuccessTitle, message: LocalizedStrings.asteriskRequiredField, requestType: nil)
            return
        }
        
        getCardTokenRequest()
    }
    
    @IBAction func hanlderDismiss() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func onTextFieldEditingChangedAction(sender: AnyObject) {
        
        guard let textField = sender as? UITextField else {
            return
        }
        
       if textField.tag == 101 {
            newCard.number = StringHelper.trimWhiteSpace(textField.text!)
			if CardHelper.getCardLogo(textField.text!, isSmall: true) != nil {
				newCard.cardLogoData = UIImagePNGRepresentation(CardHelper.getCardLogo(textField.text!, isSmall: true)!)
			}
			self.showPaymentInfo(newCard)
        }
        else if textField.tag == 102 {
            newCard.cvv = textField.text
        }
        
        checkFullFillRequiredFields(newCard)
    }
    func showPaymentInfo(card: Card) {
        
        cardNumberTextField.text = CardHelper.reformatCardNumber(card.number)
		if card.cardLogoData != nil {
			cardLogo.image = UIImage(data: card.cardLogoData!)	
		}
        
        if card.expiryMonth != 0 && card.expiryYear != 0 {
            expiryDateTextField.text = DateTimeHelper.getExpiryDateString(card.expiryMonth, year: card.expiryYear)
            //card.expiryDate?.getStringFromDate(DateFormater.monthYearFormat)
        }
        cvvTextField.text = card.cvv
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = StringHelper.trimWhiteSpace(textField.text!).characters.count ?? 0
        let newLength = currentCharacterCount + string.characters.count - range.length
        
        // Limit the maximum length of card number and card cvv
        if textField.tag == 101 {
            return newLength <= 19
        }
        else if textField.tag == 102 {
            return newLength <= 4
        }
        
        return true
    }
    
    func getCardTokenRequest() {
        let parameters = createTokenCard.getCardTokenParams(newCard, newCard: newCard)
        print(parameters)
        sendRequest(parameters, request: createTokenCard, requestType: .CreateCardToken, isSetLoadingView: true)
    }
    func createCustomerCardRequest() {
        let parameters = createCustomerCard.getCustomerCardParams(paymentToken)
        sendRequest(parameters, request: createCustomerCard, requestType: .CreateCustomerCard, isSetLoadingView: true)
    }

    
    func sendRequest(parameters: [String: AnyObject]?,
                     request: RequestManager,
                     requestType: RequestType,
                     isSetLoadingView: Bool) {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
            return
        }
        
        // Set loading view center
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
        if requestType == .CreateCardToken {
            handleCardTokenResponse(response)
            return
        } else if requestType == .CreateCustomerCard {
            self.navigationController?.popViewControllerAnimated(true)
        }
      
    }
    
    func handleCardTokenResponse(response: Response<AnyObject, NSError>) {
        let result = ResponseHandler.payfortResponseHandling(response)
        
        if result.error != nil {
            if result.error == .ErrorCreatingCardPayfort {
                handleResponseError(nil, title: LocalizedStrings.invalidCardTitle, message: LocalizedStrings.invalidCardMessage, requestType: .CreateCardToken)
            }
            else {
                handleResponseError(result.error, title: LocalizedStrings.invalidCardTitle, message: LocalizedStrings.invalidCardMessage, requestType: .CreateCardToken)
            }
            return
        }
        
        // Create token successfully
        
        paymentToken = result.tokenID!
        createCustomerCardRequest()
        
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return self.tableView.frame.size.height - 300
        }
        return super.tableView(self.tableView, heightForRowAtIndexPath: indexPath)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSelectExpiryDateView" {
            guard let destination = segue.destinationViewController as? SelectExprixeDateView else{
                return
            }
            destination.delegate = self
        }
    }
    
}


extension AddNewCardTableViewController: SelectExpiryDateDelegate {
    func showExpiryDate(expiryDate: NSDate) {
        self.expiryDate = expiryDate
        newCard.expiryMonth = expiryDate.getMonth()
        newCard.expiryYear = expiryDate.getYear()
         checkFullFillRequiredFields(newCard)
         expiryDateTextField.text = expiryDate.getStringFromDate(DateFormater.monthYearFormat)
    }
    
}

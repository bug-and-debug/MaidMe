//
//  PaymentViewController.swift
//  MaidMe
//
//  Created by Romecon on 3/5/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PaymentViewController: BaseTableViewController {

    @IBOutlet weak var paymentHeaderCell: PaymentHeaderCell!
    @IBOutlet weak var cardSumaryCell: CardViewCell!
    @IBOutlet weak var paymentInfoCell: PaymentInfoCell!
    @IBOutlet weak var datePickerCell: DatePickerCell!
//    @IBOutlet weak var countryCell: CountryCell!
    @IBOutlet weak var storePaymentSettingCell: StoredPaymentSettingCell!
    @IBOutlet weak var payActionCell: PayActionCell!
    @IBOutlet weak var totalPaymentCell: TotalPaymentCell!
    
    var selectedCard: Card?
    var newCard = Card()
    var cardList = [Card]()
    
    var datePickerHidden = true
    let datePickerIndex = 2
    var expiryDate: NSDate!
    var isSaveChecked: Bool = false
    var isEnablePayButton = false
    var bookingInfo: Booking!
    var address = Address()
    
    var messageCode: MessageCode?
    let createTokenCard = CreateNewTokenCardService()
    let createCustomerCard = CreateCustomerCardService()
    let lockABooking = LockABookingService()
    let fetchAllCard = FetchAllCardsService()
    let createABooking = CreateABookingService()
    var paymentToken: String!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSegueData()
        
        // Fetch cards list
        fetchAllCardsRequest()
        self.bookingInfo.address = self.address
        self.navigationItem.title = "PAYMENT"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.hideBackbutton(true)
        self.tabBarController?.tabBar.hidden = true
        checkFullFillRequiredFields(selectedCard == nil ? newCard : selectedCard)
        tableView.hideTableEmptyCell()
        updateCellLine()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI
    
    func updateCellLine() {
        tableView.removeSeparatorLineInset([paymentHeaderCell, datePickerCell])
        
        let cell1 = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
        let cell2 = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
        
        
        let cell4 = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 5, inSection: 0))
        let cell5 = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 6, inSection: 0))
        
        guard let tableCell1 = cell1, let tableCell2 = cell2, let tableCell4 = cell4, let tableCell5 = cell5 else {
            return
        }
        
        self.tableView.removeSeparatorLine([tableCell1, tableCell2, tableCell4, tableCell5])
        
        datePickerCell.datePicker.monthPickerDelegate = self

    }
    
    func resetPaymentInfor() {
        newCard = Card()
        paymentInfoCell.resetCardInfor()
        datePickerCell.resetDatePicker()
        
    }
    
    func showSegueData() {
        totalPaymentCell.setPrice(bookingInfo.price + bookingInfo.materialPrice)
        
    }
    
    func getDefaultCard(cardList: [Card]) -> Card? {
        for card in cardList {
            if card.isDefault == true {
                return card
            }
        }
        
        return nil
    }
    
    // MARK: - Unwind segues
    
    @IBAction func onUpdateBillingAddressAction(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }
    
    @IBAction func onChangeCardAction(segue: UIStoryboardSegue) {
        tableView.reloadData()
        
        guard let card = selectedCard else {
            return
        }
        
        cardSumaryCell.setCardInfo(card)
    }
    
    // MARK: - Time picker
    
    func toggleDatepicker() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func datePickerChanged(date: NSDate, dateFormat: String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        expiryDate = date
        newCard.expiryMonth = expiryDate.getMonth()
        newCard.expiryYear = expiryDate.getYear()
        checkFullFillRequiredFields(newCard)
        
        paymentInfoCell.expiryDateTextField.text = expiryDate.getStringFromDate(DateFormater.monthYearFormat)
    }
    
    @IBAction func onPickTimeAction(sender: AnyObject) {
        dismissKeyboard()
    }
    
    func showHideDatePicker() {
        datePickerHidden = !datePickerHidden
        toggleDatepicker()
    }
    
    @IBAction func backSearchResult(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    private func checkFullFillRequiredFields(card: Card?) {
        var isFullFilled = true
        
        if let card = card {
            if selectedCard == nil {
                isFullFilled = Validation.isFullFillRequiredTexts([card.number, (card.expiryMonth == 0 ? "" : "\(card.expiryMonth)"), card.cvv])
            }
        }
        
        isEnablePayButton = isFullFilled
        ValidationUI.changeRequiredFieldsUI(isEnablePayButton, button: payActionCell.payButton)
    }
    
    // MARK: - Textfield delegate
    
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
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if !datePickerHidden {
            showHideDatePicker()
        }
        
        return true
    }
    
    @IBAction func onTextFieldEditingChangedAction(sender: AnyObject) {
        guard let textField = sender as? UITextField else {
            return
        }
        
        if textField.tag == 100 {
            // Name
            newCard.ownerName = StringHelper.trimBeginningWhiteSpace(textField.text!)
        }
        else if textField.tag == 101 {
            newCard.number = StringHelper.trimWhiteSpace(textField.text!)
			if CardHelper.getCardLogo(textField.text!, isSmall: true) != nil {
				if CardHelper.getCardLogo(textField.text!, isSmall: true) != nil {
					newCard.cardLogoData = UIImagePNGRepresentation(CardHelper.getCardLogo(textField.text!, isSmall: true)!)
				}	
			}
            paymentInfoCell.showPaymentInfo(newCard)
        }
        else if textField.tag == 102 {
            newCard.cvv = textField.text
        }
        
        checkFullFillRequiredFields(newCard)
    }
    
    // MARK: - Save action
    
    @IBAction func onTickCheckboxAction(sender: AnyObject) {
        isSaveChecked = !isSaveChecked
        print(isSaveChecked)
        storePaymentSettingCell.updateButtonImage(isSaveChecked)
    }
    
    @IBAction func onPayAction(sender: AnyObject) {
        dismissKeyboard()
        
        ValidationUI.changeRequiredFieldsUI(false, button: payActionCell.payButton)
        startLoadingView()
        if selectedCard == nil {
            let validationResult = CardHelper.isValidData(newCard)
            
            if !validationResult.isValid {
                // Show invalid alert
                stopLoadingView()
                showAlertView(validationResult.title, message: validationResult.message, requestType: nil)
                return
            }
            
            let card = (selectedCard == nil ? newCard : selectedCard)
            
            let startCard = createTokenCard.startCard(card!)
            let price = (bookingInfo.price + bookingInfo.materialPrice)
            createTokenCard.getCardToken(startCard, amount: NSNumber(float: price), completionHandler: { (token, error) in
                guard let token = token else {
                    self.stopLoadingView()
                    self.showAlertView(validationResult.title, message: validationResult.message, requestType: nil)
                    return
                }
                
                // Book with selected card
                self.paymentToken = token
                if self.isSaveChecked {
                    self.createCustomerCardRequest()
                }else {
                    self.createABookingRequest()
                }
            })

        }else {
            // Book with selected card
            isSaveChecked = true
            createABookingRequest()
        }
    }
    
    // MARK: - API
    
    func getCardTokenRequest() {
        let parameters = createTokenCard.getCardTokenParams(selectedCard, newCard: newCard)
        
        sendRequest(parameters, request: createTokenCard, requestType: .CreateCardToken, isSetLoadingView: true)
    }
    
    func createCustomerCardRequest() {
        let parameters = createCustomerCard.getCustomerCardParams(paymentToken)
        sendRequest(parameters, request: createCustomerCard, requestType: .CreateCustomerCard, isSetLoadingView: true)
    }
    
    func fetchAllCardsRequest() {
        sendRequest(nil, request: fetchAllCard, requestType: .FetchAllCard, isSetLoadingView: false)
    }
    
    func createABookingRequest() {
        var parameters = [String: AnyObject]()
        
        if isSaveChecked {
            let card = (selectedCard == nil ? newCard : selectedCard)
            parameters = createABooking.getCreateABookingParams((card?.cardPaymentID)!, address: address, booking: bookingInfo)
            print("Create booking params: ", parameters)
        }else {
            parameters = createABooking.getCreateABookingParams(paymentToken, address: address, booking: bookingInfo)

        }

        print("PARAMETERS \(parameters)")
        sendRequest(parameters, request: createABooking, requestType: .CreateABooking, isSetLoadingView: true)

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
            if isSetLoadingView {
                setLoadingUI(.White, color: UIColor.whiteColor())
                self.setRequestLoadingViewCenter(payActionCell.payButton)
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
        if requestType == .CreateCardToken {
            handleCardTokenResponse(response)
            return
        }
        else {
            handleCardResponse(response, requestType: requestType)
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
        if isSaveChecked {
            createCustomerCardRequest()
        } else {
            createABookingRequest()
        }
    }
    
    func handleCardResponse(response: Response<AnyObject, NSError>, requestType: RequestType) {
        let result = ResponseHandler.responseHandling(response)
        if result.messageCode != MessageCode.Success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            
            if let error = result.messageCode {
                messageCode = error
            }
            
            return
        }
        
        if requestType == .CreateCustomerCard {
            let cardID = result.body?["id"]
            newCard.cardPaymentID = cardID?.stringValue
            
            // Send book request.
            createABookingRequest()
        }
        
        if requestType == .FetchAllCard {
            handleCardListResponse(result.body)
        }
        
        if requestType == .CreateABooking {
            bookingInfo.bookingCode = createABooking.getBookingCode(result.body)
            self.performSegueWithIdentifier(SegueIdentifiers.showBookingSummary, sender: self)
            guard let reminderTime = bookingInfo.time?.dateByAddingTimeInterval(-30.0 * 60.0) else { return }
            NotificationManager.createReminderNotification(bookingInfo.workerName ?? "", fireDate: reminderTime)
        }
    }
    
    func handleCardListResponse(responseBody: JSON?) {
        guard let list = responseBody else {
            return
        }
        
        cardList = fetchAllCard.getCardList(list)
        for card in cardList {
            if card.isDefault == true {
                selectedCard = card
                break
            }
        }
        
        // Reload table view
        tableView.beginUpdates()
        
        if selectedCard != nil {
            cardSumaryCell.cardView.showCardInfo(selectedCard!)
        }
        else {
            newCard = Card()
        }
        
        tableView.endUpdates()
        
        
        checkFullFillRequiredFields(selectedCard == nil ? newCard : selectedCard)
    }
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(requestType: RequestType) {
        if requestType == .CreateCardToken {
            self.getCardTokenRequest()
        }
        else if requestType == .CreateCustomerCard {
            self.createCustomerCardRequest()
        }
        else if requestType == .FetchAllCard {
            self.fetchAllCardsRequest()
        }
        else if requestType == .CreateABooking {
            self.createABookingRequest()
        }
    }
    
    override func handleAlertViewAction(requestType: RequestType?) {
        if messageCode == .BookingTimeout && requestType == .CreateABooking {
            self.performSegueWithIdentifier(SegueIdentifiers.backToAvailableWorker, sender: self)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 1 {
            if selectedCard == nil {
                return 0
            }
        }
        
        if indexPath.row == 2 || indexPath.row == 4  {
            if selectedCard != nil {
                return 0
            }
        }
        if indexPath.row == 3 {
            if datePickerHidden {
                return 0
            }
        }
        if indexPath.row == 6 {
            if selectedCard != nil {
                if self.view.frame.size.height > 440 {
                    return (self.view.frame.height - 350)
                } else {
                    return 90
                }
            } else {
                if self.view.frame.size.height > 485 {
                    return (self.view.frame.size.height - 390)
                } else {
                    return 90
                }
            }
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "showSelectExpiryDateView" {
            guard let destination = segue.destinationViewController as? SelectExprixeDateView else{
                return
            }
            destination.delegate = self
        }
        
        
        if segue.identifier == SegueIdentifiers.showBookingSummary {
            guard let destination = segue.destinationViewController as? BookingSummaryViewController else {
                return
            }
            
            if selectedCard == nil && newCard.number != "" {
                newCard.lastFourDigit = newCard.getLastFourDigit()
            }
            
            bookingInfo.payerCard = (selectedCard == nil ? newCard : selectedCard)
            destination.pushOderDelegate = self
            destination.bookingInfo = bookingInfo
//            destination.navController = self.navigationController
//            destination.currentViewcontroller = self
        }
        
        if segue.identifier == SegueIdentifiers.showCardList {
            guard let destination = segue.destinationViewController as? ListCardTableViewController else {
                return
            }
            
            destination.cardList = cardList
        }
    }
}
extension PaymentViewController: PushToOderBookingDelegate {
    func pushToOrderBooking(flag: Bool){
        if flag == true {
            UIView.animateWithDuration(0.3, animations: {
                self.tabBarController?.selectedIndex = 2
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
        }
    }
}

extension PaymentViewController: SelectExpiryDateDelegate {
    func showExpiryDate(expiryDate: NSDate) {
        self.expiryDate = expiryDate
        newCard.expiryMonth = expiryDate.getMonth()
        newCard.expiryYear = expiryDate.getYear()
        checkFullFillRequiredFields(newCard)
        paymentInfoCell.expiryDateTextField.text = expiryDate.getStringFromDate(DateFormater.monthYearFormat)
    }
    
}

extension PaymentViewController: MAKMonthPickerDelegate {
    func monthPickerDidChangeDate(picker: MAKMonthPicker) {
        if picker.restorationIdentifier == "expirydatePicker" {
            datePickerChanged(picker.date, dateFormat: DateFormater.monthYearFormat)
        }
    }
}

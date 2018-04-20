//
//  SearchDetailsViewController.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 12/23/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SSKeychain
import Alamofire

protocol showTabbarDelegate {
    func showTabar(visable: Bool)
}


class SearchDetailsViewController: BaseTableViewController  {
    
    @IBOutlet weak var checkPossibleImage: UIImageView!
    @IBOutlet weak var checkAddMaterialImage: UIImageView!
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var hourView: SelectValueView!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var descriptionServiceLabel:UILabel!
    @IBOutlet weak var selectDateButton: UIButton!
    @IBOutlet weak var buttonSearchTopLayoutConstrant: NSLayoutConstraint!
    @IBOutlet weak var selectedDateIconImage: UIImageView!
   
    
    var tabbarDelegate : showTabbarDelegate?
    var asSoonAsPossible = true
 
    var addressList = [Address]()
    var selectedAddress: Address?
    var messageCode: MessageCode?
    var serviceList = [WorkingService]()
    var areaID: String?
    var searchTime: Double?
    var navController: UINavigationController?
    var currentViewController: AnyObject!
    var selectedDate: NSDate?
    var selectedService : WorkingService?
    
    let fetchBookingDoneNotRatingAPI = FetchBookingDoneNotRatingService()
    let getMinPeriodWorkingHourAPI = GetMinPeriodWorkingHourService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMinPeriodWorkingHourRequest()
        updateLabel()
		if selectedService?.avatar != nil {
			print(selectedService?.avatar)
			loadImageFromURL(selectedService!.avatar!, imageLoad: serviceImage)
		}
		
    }
    override func viewWillAppear(animated: Bool) {
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        self.view.layer.addAnimation(transition, forKey:kCATransition)
        buttonSearchTopLayoutConstrant.constant = self.view.frame.height/8.2
        selectDateButton.enabled = true
        selectedDateLabel.alpha = 1
        selectedDateIconImage.alpha = 1
    }
 
    func updateLabel(){
        if let service:String = selectedService?.name,let descriptionService = selectedService?.serviceDescription {
            serviceLabel.text = service
            descriptionServiceLabel.text = descriptionService
        }    }
    //MARK: -Action
    @IBAction func dismissHandler() {
         tabbarDelegate?.showTabar(false)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func onPossible(sender: AnyObject) {
        asSoonAsPossible = !asSoonAsPossible
        checkPossibleImage.image = asSoonAsPossible ? UIImage(named: ImageResources.checkedBox) : UIImage(named: ImageResources.uncheckBox)
        if !asSoonAsPossible {
            selectedDateLabel.alpha = 1
            selectedDateIconImage.alpha = 1
            let nextRoundedTime = NSDate().getNextOneRoundedHourTime()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd yyyy, HH:mma"
            self.selectedDate = nextRoundedTime
            self.selectedDateLabel.text = dateFormatter.stringFromDate(selectedDate!)
        } else {
            selectedDateLabel.text = "Choose a date"
            selectedDateLabel.alpha = 0.4
            selectedDateIconImage.alpha = 0.4
        }
        self.tableView.reloadData()
    }
    @IBAction func searchHandler(sender: AnyObject) {
        if !asSoonAsPossible {
            if selectedDate!.isLessThanCurrentTime() {
                showAlertView(LocalizedStrings.invalidDateTitle, message: LocalizedStrings.invalidDateMessage, requestType: nil)
                return
            }
        }
        tabbarDelegate?.showTabar(false)
        self.dismissViewControllerAnimated(true, completion: nil)
        showSearch()
    }
  
    func getMinPeriodWorkingHourRequest() {
        sendRequest(nil, request: getMinPeriodWorkingHourAPI, requestType: .GetMinPeriodWorkingHour, isSetLoadingView: false, view: nil)
    }
    func sendRequest(parameters: [String: AnyObject]?,
                     request: RequestManager,
                     requestType: RequestType,
                     isSetLoadingView: Bool, view: UIView?) {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
            return
        }
        // Set loading view center
        if isSetLoadingView && view != nil {
            self.setRequestLoadingViewCenter1(view!)
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
      
        if requestType == .GetMinPeriodWorkingHour {
            handleGetMinPeriodWorkingHour(result, requestType: .GetMinPeriodWorkingHour)
        }
    }
  
    func handleGetMinPeriodWorkingHour(result: ResponseObject, requestType: RequestType) {
        guard let body = result.body else {
            return
        }
        let mins = (body["min_period_working_hour"].int == nil ? 0 : body["min_period_working_hour"].int!)
        let minHour = ceil(Double(mins) / Double(60))
        
        // Update the min value of hour view.
        let hour:Int = Int(minHour)
        if hour > 1 {
            hoursLabel.text = "Min: \(hour) Hours"
        } else {
            hoursLabel.text = "Min: \(hour) Hour"
        }
        hourView.minValue = Int(minHour)
    }
    
    override func handleTryAgainTimeoutAction(requestType: RequestType) {
        if requestType == .GetMinPeriodWorkingHour {
            getMinPeriodWorkingHourRequest()
        }
    }
    func getParam() -> [String: AnyObject] {
        if asSoonAsPossible {
            // Get next rounded one hour
            searchTime = NSDate().timeIntervalSince1970 * 1000 + 5 * 60 * 1000
        }
        else {
            searchTime = Double(selectedDate!.timeIntervalSince1970 * 1000)
        }
        //MARK: TO DO
        return ["service_id": getServiceIDFromService(selectedService!.name, list: serviceList),
                "date_time": searchTime!, //Double(datePicker.date.timeIntervalSince1970 * 1000),
            "area_id": (selectedAddress?.workingArea_ref == nil ? "" : selectedAddress?.workingArea_ref)!,
            "hours": hourView.currentValue,
            "asap": asSoonAsPossible]
    }
	
	var picker : DateTimePicker!
	@IBAction func chooseDateTapped(sender: AnyObject) {
		
		
		var defaultDate = NSDate()
		let calendar = NSCalendar.currentCalendar()
		let comp = calendar.components([.Hour], fromDate: defaultDate)
		let hour = comp.hour
		if hour >= 18 {
			// If it's later than 18:00
			defaultDate = calendar.dateByAddingUnit(.Day,value: 1,toDate: defaultDate,options: [])!
			defaultDate = defaultDate.setTo8AM()
		}
		
		picker = DateTimePicker.show(defaultDate, minimumDate: defaultDate, maximumDate: NSDate().dateByAddingTimeInterval(60 * 60 * 24 * 7))
		picker.daysBackgroundColor = UIColor(red:0.31, green:0.73, blue:0.80, alpha:1.00)
		picker.highlightColor = UIColor(red:0.31, green:0.73, blue:0.80, alpha:1.00)
		picker.completionHandler = { selecteddate in
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat =  "MMM dd yyyy, HH:mma"
			self.selectedDate = selecteddate
			self.selectedDateLabel.text = dateFormatter.stringFromDate(selecteddate)
			
			self.asSoonAsPossible = false
			self.selectDateButton.enabled = true
			self.checkPossibleImage.image = UIImage(named: ImageResources.uncheckBox)
			self.selectedDateLabel.alpha = 1
			self.selectedDateIconImage.alpha = 1
			self.tableView.reloadData()
		}
		
		
	}
	
	func dismissCalendar() {
		picker.dismissView()
	}
	
    //tableView
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 3 {
            if self.view.frame.height > 500{
                        return (self.view.frame.height - 435)
            } else {
                return 70
            }
        }
        else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.showSelecDateStart {
            guard let destination = segue.destinationViewController as? TestVC else {
                return
            }
            destination.delegate = self
        }
    }
    func showSearch(){
        let storyboard = self.storyboard
        
        guard let searchResult = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIDs.searchResults) as? SearchResultsViewController else {
            return
        }
        searchResult.availableWorkerParams = getParam()
        searchResult.workService = self.selectedService
        searchResult.hour = self.hourView.currentValue
        searchResult.serviceList = self.serviceList
        searchResult.isMoveFromSearchDetails = true
        searchResult.asap = asSoonAsPossible
        searchResult.searchTime = self.searchTime
        searchResult.selectedAddress = selectedAddress
        searchResult.addressList = self.addressList
        searchResult.booking =  Booking(bookingID: nil, workerName: nil, workerID: nil, time: nil, service: WorkingService.getService(selectedService?.name, list: serviceList), workingAreaRef: nil, hours: hourView.currentValue, price: nil, materialPrice: nil, payerCard: nil, avartar: nil,maid: nil)
        guard let _ = currentViewController as? SearchResultsViewController else {
            navController?.pushViewController(searchResult, animated: true)
            return
        }
    }
}
extension SearchDetailsViewController: SelectDateDelegate {
    func selectedDate(dateSelected: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat =  "MMM dd yyyy, HH:mma"
        self.selectedDate = dateSelected
        self.selectedDateLabel.text = dateFormatter.stringFromDate(selectedDate!)
		
		asSoonAsPossible = false
		selectDateButton.enabled = true
		checkPossibleImage.image = UIImage(named: ImageResources.uncheckBox)
		selectedDateLabel.alpha = 1
		selectedDateIconImage.alpha = 1
		self.tableView.reloadData()
    }
}

//
//  AvailabelServicesViewController.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 12/23/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//
import UIKit
import Alamofire
import SSKeychain
import SVProgressHUD
import RealmSwift

var isReloadAvailable: Bool?

class AvailabelServicesViewController: BaseTableViewController,UIGestureRecognizerDelegate {
    
    var serviceList = [WorkingService]()
    var messageCode: MessageCode?
    var addressList = [Address]()
    var customer: Customer!
    var selectedAddress: Address?
    var isMovedFromLogin = false
    var bookingList = [Booking]()
    var ratingList = [Rating]()
    var timesShowRatingAndComment = 0
    var indexItemBookingList = 0
    var isSubmitted: Bool = false
    var isObsever : Bool?
    
    let fetchServiceTypeAPI = FetchServiceTypeService()
    let fetchAllAddresses = FetchAllBookingAddressesService()
	let fetchBookingDoneNotRatingAPI = FetchBookingDoneNotRatingService()
    var isPopView : Bool?
    
    
    @IBOutlet weak var addressMenuButton: UIButton!
    
    var areaID :String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideBackbutton(true)
        self.tableView.separatorStyle = .None
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        if customerSelectedAddress == nil{
         isPopView = false
        }
		
        sendFetchServiceTypesRequest()

		if let cachedAddressName: String = NSUserDefaults.standardUserDefaults().stringForKey("cachedAddressName"){
			self.navTitleView.buildingNameLabel.text = cachedAddressName
		}
		
        setupMenuAddressButton()
        fetchAllBookingAddressesRequest()
		fetchBookingDoneNotRatingRequest()
        self.navTitleView.showListAddressButton.addTarget(self, action: #selector(showAddressMenu), forControlEvents: .TouchUpInside)
    }
	
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        hideBackbutton(true)
//        setDefaultUIForLoadingIndicator()
        self.view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        self.navigationController?.navigationBar.hidden = false
        self.tabBarController?.tabBar.hidden = false
        
    }
	
    override func viewDidAppear(animated: Bool) {
        if customerSelectedAddress != nil && customerSelectedAddress?.addressID != selectedAddress?.addressID  {
            selectedAddress = customerSelectedAddress
            if let buildingName = selectedAddress?.buildingName {
                self.navTitleView.buildingNameLabel.text = cutString(buildingName)
            }
        }
        if isReloadAvailable == true {
            updateServiceList()
        }
//        }
//     NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateServiceList), name: "updateAvailabelAddress", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        isPopView = true
        isObsever = false
        isReloadAvailable = false
        
    }
    override func setDefaultUIForLoadingIndicator() {
        self.loadingIndicator.activityIndicatorViewStyle = .WhiteLarge
        self.loadingIndicator.color = UIColor.blackColor()
        if let window = UIApplication.sharedApplication().keyWindow {
            self.loadingIndicator.center = window.center
            window.addSubview(self.loadingIndicator)
        }
    }
    func updateServiceList(){
        print("update service list")
        isObsever = true
        isPopView = false
        fetchAllBookingAddressesRequest()
//         NSNotificationCenter.defaultCenter().removeObserver(self, name: "updateAvailabelAddress", object: nil)
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
	
	
	func fetchBookingDoneNotRatingRequest() {
//		sendRequest(nil, request: fetchBookingDoneNotRatingAPI, requestType: .FetchBookingDoneNotRating, isSetLoadingView: false, button: nil)
		sendRequest(nil, request: fetchBookingDoneNotRatingAPI, requestType: .FetchBookingDoneNotRating, isSetLoadingView: false, view: nil)
	}
	func handleFetchBookingDoneNotRatingResponse(result: ResponseObject, requestType: RequestType) {
		guard let body = result.body else {
			return
		}
		
		let result = fetchBookingDoneNotRatingAPI.getBookingList(body)
		ratingList = result
		timesShowRatingAndComment = ratingList.count
		if ratingList.count > 0 {
			self.performSegueWithIdentifier(SegueIdentifiers.giveCommentAndRating, sender: self)
		}
		else {
			return
		}
	}

	func prepareToRatingAndComment() {
		if timesShowRatingAndComment > 0 {
			self.performSegueWithIdentifier(SegueIdentifiers.giveCommentAndRating, sender: self)
		}
		else {
			return
		}
	}
	
    func sendFetchServiceTypesRequest() {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
            setUserInteraction(false)
            return
        }
		
		if serviceList.count == 0 {
			startLoadingView()
		}
		
        fetchServiceTypeAPI.request {
            [weak self] (response) in
            
            dispatch_async(dispatch_get_main_queue(), {
                if let strongSelf = self {
                    strongSelf.handleFetchServiceTypesResponse(response)
                    strongSelf.handleAPIResponse()
                }
            })
        }
    }
    
    func handleFetchServiceTypesResponse(response: Response<AnyObject, NSError>) {
        let result = ResponseHandler.responseHandling(response)
        if result.messageCode != MessageCode.Success || result.body == nil {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.connectionFailedTitle, message: result.messageInfo, requestType: .FetchServiceTypes)
            
            if let error = result.messageCode {
                messageCode = error
            }
            return
        }
        setUserInteraction(true)
        var list = [String]()
        var listArea = [WorkingService]()
        
        for (_, dic) in result.body! {
            let item = WorkingService(serviceDic: dic)
            if item.serviceID == nil && item.name != nil {
                continue
            }
            listArea.append(item)
            list.append("\(item.name!)")
        }
		
		if serviceList != listArea {
			// Cache service list
			serviceList = listArea
			self.tableView.reloadData()
		}
		
    }
    // mark: test
    func fetchAllBookingAddressesRequest() {
        sendRequest(nil, request: fetchAllAddresses, requestType: .FetchAllBookingAddresses, isSetLoadingView: true, view: nil)
    }
    func handleFetchAllBookingAddressesResponse(result: ResponseObject, requestType: RequestType) {
        //print("Booking addresses: ", result.body)
        guard let list = result.body else {
            return
        }
        addressList = fetchAllAddresses.getAddressList(list)
        if isPopView == false {
        if addressList.count == 1{
            self.navTitleView.dropDownImage.image = UIImage(named: "")
        } else {
            self.navTitleView.dropDownImage.image = UIImage(named: "dropIcon")
        }
        for address in addressList {
            if (address.isDefault == true) {
                if let buildingName: String = cutString(address.buildingName) {
                    self.navTitleView.buildingNameLabel.text = buildingName
					NSUserDefaults.standardUserDefaults().setValue(buildingName, forKey: "cachedAddressName")
                }
                
                selectedAddress = address
            }
        }
        }
    }
    func sendRequest(parameters: [String: AnyObject]?,
                     request: RequestManager,
                     requestType: RequestType,
                     isSetLoadingView: Bool, view: UIView?) {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
			
			if let cachedAddressName: String = NSUserDefaults.standardUserDefaults().stringForKey("cachedAddressName"){
				self.navTitleView.buildingNameLabel.text = cachedAddressName
			}
            return
        }
		
		if NSUserDefaults.standardUserDefaults().stringForKey("cachedAddressName") == nil{
			// Set loading view center
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
            if let error = result.messageCode {
                messageCode = error
            }
        }
        setUserInteraction(true)
        if requestType == .FetchAllBookingAddresses {
            handleFetchAllBookingAddressesResponse(result, requestType: .FetchAllBookingAddresses)
		}else if requestType == .FetchBookingDoneNotRating {
			handleFetchBookingDoneNotRatingResponse(result, requestType: .FetchBookingDoneNotRating)
		}
    }
    // MARK: - Fetch default address
	
          //MARK: -Action
    @IBAction func showAddressMenu(){
        self.showCustomerAddressMenu()
        
    }
    func showCustomerAddressMenu() {
        if addressList.count > 1 {
        let storyboard = self.storyboard
        guard let addressMenu = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIDs.customerAddressMenu) as? AddressMenu else {
            return
        }
        addressMenu.availabelServiceVC = self
        addressMenu.addressList = self.addressList
        addressMenu.navController = self.navigationController
        addressMenu.currentViewController = self
        addressMenu.view.backgroundColor = .clearColor()
        addressMenu.modalPresentationStyle = .OverCurrentContext
            self.presentViewController(addressMenu, animated: false, completion: nil)
        }
    }
    func getAreaIdToSearch(address: Address) {
        self.selectedAddress = address
        if let buildingName: String = selectedAddress!.buildingName
        {
            self.navTitleView.buildingNameLabel.text = cutString(buildingName)
        }
    }
    //MARK: -Show Search Details
    func showSearchDetailsVC(indexPath: NSIndexPath) {
        let storyboard = self.storyboard
        guard let searchDetails = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIDs.searchDetailsVC) as? SearchDetailsViewController else {
            return
        }
        searchDetails.tabbarDelegate = self
        searchDetails.navController = self.navigationController
        searchDetails.currentViewController = self
        searchDetails.selectedService = serviceList[indexPath.row]
        searchDetails.serviceList = self.serviceList
        searchDetails.addressList = self.addressList
        if selectedAddress != nil{
            searchDetails.selectedAddress = self.selectedAddress
		}else {
			let realm = try! Realm()
			let cachedAddresses = realm.objects(Address.self)
			if cachedAddresses.count > 0 {
				searchDetails.selectedAddress = cachedAddresses[0];
			}

		}
        searchDetails.view.backgroundColor = .clearColor()
        searchDetails.modalPresentationStyle = .OverCurrentContext
        self.presentViewController(searchDetails, animated: false, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.giveCommentAndRating {
            guard let commentAndRatingVC = segue.destinationViewController as? GiveRatingTableViewController else {
                return
            }
            commentAndRatingVC.listBookingDoneWithoutRating2 = ratingList
            commentAndRatingVC.timesShow = timesShowRatingAndComment
            commentAndRatingVC.indexItemShow = indexItemBookingList
            commentAndRatingVC.delegate = self
        }

        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceList.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let availabelCellid = "Cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(availabelCellid, forIndexPath: indexPath) as? AvailabelServiceCell
        if cell == nil {
            cell = AvailabelServiceCell(style: UITableViewCellStyle.Default, reuseIdentifier: availabelCellid)
        }
        let service = serviceList[indexPath.row]
        
        if serviceList.count != 0 {
			if service.name != nil{
                cell?.serviceName.text = service.name!.uppercaseString
            }
			if service.avatar != nil {
				cell?.loadImageFromURLwithCache(service.avatar!, imageLoad: (cell?.imageName)!)
			}
			
			if service.serviceDescription != nil {
				cell?.detailService.text = service.serviceDescription
			}
			
        }
        return cell!
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.tabBarController?.tabBar.hidden = true
        
        showSearchDetailsVC(indexPath)
    }
}
extension AvailabelServicesViewController: GiveRatingTableViewControllerDelegate {
    func didDismissRatingAndCommentBooking(isSubmitted: Bool) {
        if isSubmitted {
            timesShowRatingAndComment = timesShowRatingAndComment - 1
            indexItemBookingList = indexItemBookingList + 1
            prepareToRatingAndComment()
        }
        else {
        }
    }
}
extension AvailabelServicesViewController: showTabbarDelegate,UITabBarDelegate {
    func showTabar(visable: Bool) {
        self.tabBarController?.tabBar.hidden = visable
    }
}

//
//  AddAddressFirstTimeTableViewController.swift
//  MaidMe
//
//  Created by Vo Minh Long on 1/4/17.
//  Copyright © 2017 SmartDev. All rights reserved.
//

import Foundation


import UIKit
import GooglePlaces
import GoogleMaps
import SSKeychain
import Alamofire
import SwiftyJSON
import GooglePlacesSearchController

class AddAddressFirstTimeTableViewController: BaseTableViewController {
    @IBOutlet weak var buildingNameTextFiled: UITextField!
    @IBOutlet weak var areaAndEmiratesTetxField: UITextField!
    @IBOutlet weak var apartmentNoTextField: UITextField!
    @IBOutlet weak var landmarkTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    let textFontSize: CGFloat = 16.0
    var bookingAddress = Address()
    var isEdited: Bool?
    var addNewAddressService = AddNewBookingAddressService()
    
    var messageCode: MessageCode?
    var googleApi = FetchGoogleAPI()
    var area : String?
    var emirates : String?
    var long: Float?
    var lat: Float?
    let workingAreaAPI = FetchWorkingAreaService()
    var areaList: [WorkingArea]?
    var filteredAreas = [WorkingArea]()
    var selectedArea: WorkingArea?
    var isMovedFromLogin = false
    let isdefault: Bool = true
    // MARK: - Life Cycle
	private var placesClient: GMSPlacesClient!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
		placesClient = GMSPlacesClient()
        self.tableView.hideTableEmptyCell()
        StringHelper.setPlaceHolderFont([buildingNameTextFiled, apartmentNoTextField, areaAndEmiratesTetxField, landmarkTextField], font: CustomFont.quicksanRegular, fontsize: textFontSize)
        fetchDefaultAreaRequest()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "NEW ADDRESS"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupView() {
        buildingNameTextFiled.delegate = self
        areaAndEmiratesTetxField.delegate = self
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        addTapGestureDismissKeyboard(self.view)
        self.tableView.separatorStyle = .None
    }
    
    @IBAction func onTextFieldEditingChangedAction(sender: AnyObject) {
//        checkFullFillRequiredFields()
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        
    }
    @IBAction func onDoneAction(sender: AnyObject) {
        if areaAndEmiratesTetxField.text == "" || buildingNameTextFiled.text == "" || apartmentNoTextField.text == ""{
            showAlertView(LocalizedStrings.updateSuccessTitle, message: LocalizedStrings.asteriskRequiredField, requestType: nil)
            return
        } else {
            
            dismissKeyboard()
            bookingAddress.buildingName = buildingNameTextFiled.text
            bookingAddress.apartmentNo = apartmentNoTextField.text
            bookingAddress.area = self.area
            bookingAddress.emirate = self.emirates
            bookingAddress.city = self.emirates
            bookingAddress.additionalDetails = landmarkTextField.text
            bookingAddress.country = "UAE"
            bookingAddress.longitude = long ?? 0.0
            bookingAddress.latitude = lat ?? 0.0
            bookingAddress.isDefault = isdefault
            addNewBookingAddressRequest()
        }
    }
    
    // MARK: - UI
    
    private func checkFullFillRequiredFields() {
        let isFullFilled = Validation.isFullFillRequiredFields([buildingNameTextFiled, areaAndEmiratesTetxField,apartmentNoTextField])
        ValidationUI.changeRequiredFieldsUI(isFullFilled, button: doneButton)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifiers.saveUserAddress {
            guard segue.destinationViewController is ScheduleAndDetail else {
                return
            }
        }
        
        if segue.identifier == SegueIdentifiers.loginSuccess {
            guard let destination = segue.destinationViewController as? AvailabelServicesViewController else {
                return
            }
            
            destination.isMovedFromLogin = true
        }
        
        if segue.identifier == SegueIdentifiers.showWorkingAreaList {
            guard let destination = segue.destinationViewController as? UINavigationController else {
                return
            }
            guard let destinationVC = destination.viewControllers[0] as? WorkingAreaTableViewController else {
                return
            }
            
            destinationVC.delegate = self
        }
        
    }
    
    // MARK: - API
    
    func addNewBookingAddressRequest() {
        let parameters = addNewAddressService.getParams(bookingAddress, areaID: selectedArea!.areaID)
        sendRequest(parameters, request: addNewAddressService, requestType: .AddNewBookingAddress, isSetLoadingView: true)
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
            self.setRequestLoadingViewCenter(doneButton)
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
        
//        if result.messageCode != MessageCode.Success {
//            // Show alert
//            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
//            
//            if let error = result.messageCode {
//                messageCode = error
//            }
//            return
//        }
        if requestType == .AddNewBookingAddress {
            handleAddNewBookingResponse(result, requestType: .AddNewBookingAddress)
        }
        else if requestType == .FetchWorkingArea {
            handleFetchWorkingAreaResponse(result, requestType: .FetchWorkingArea)
        }
    }
    
    func handleAddNewBookingResponse(result: ResponseObject, requestType: RequestType) {
        if let addressID = result.body?["address_id"] {
            bookingAddress.addressID = addressID.stringValue
        }
        else {
            // Handle error when address ID is nil
            showAlertView(LocalizedStrings.internalErrorTitle, message: LocalizedStrings.internalErrorMessage, requestType: .AddNewBookingAddress)
            return
        }
     self.performSegueWithIdentifier(SegueIdentifiers.loginSuccess, sender: self)
    }
	
    
    // MARK: - Handle UIAlertViewAction
    override func handleTryAgainTimeoutAction(requestType: RequestType) {
        if requestType == .AddNewBookingAddress {
            self.addNewBookingAddressRequest()
        }
        else if requestType == .FetchWorkingArea {
            self.fetchDefaultAreaRequest()
        }
    }
    
    //MARK: Tabelview Delegate
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as? UITableViewHeaderFooterView
        switch section {
        case 0:
            headerView?.textLabel?.text = LocalizedStrings.customersBuildingTitle
        case 1:
            headerView?.textLabel?.text = LocalizedStrings.customersAppartmentTitle
        case 2:
            headerView?.textLabel?.text = LocalizedStrings.customersAreaTitle
        case 3:
            headerView?.textLabel?.text = LocalizedStrings.customersLandmarkTitle
        default:
            break
        }
    }
}

extension AddAddressFirstTimeTableViewController: GMSAutocompleteViewControllerDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == buildingNameTextFiled {

			let controller = GooglePlacesSearchController(
				apiKey: "AIzaSyDIFkg6k7vryfWXNza1r6bJC-xp1O7lgWA",
				placeType: PlaceType.Establishment
			)
			
			controller.didSelectGooglePlace { (place) -> Void in
				print(place.description)
				
				self.areaAndEmiratesTetxField.text = ""
				self.buildingNameTextFiled.text = place.name
				let latitude = String(place.coordinate.latitude)
				let longtitude = String(place.coordinate.longitude)
				self.long = Float(longtitude)
				self.lat = Float(latitude)
				self.googleApi.getAddressWithLngLat(latitude, longtitude: longtitude) {
					self.filterContentForText(self.googleApi.emirates, areaText: self.googleApi.area)
				}
				controller.dismissViewControllerAnimated(true, completion: nil)
			}
			
            controller.searchBar.setValue("Done", forKey: "_cancelButtonText")
            guard let _textField = controller.searchBar.valueForKey("_searchField") as? UITextField else {
                return
            }
            
            _textField.addTarget(self, action: #selector(textFieldDidChange), forControlEvents: .EditingChanged)

			self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        buildingNameTextFiled.text = textField.text
    }

    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        self.areaAndEmiratesTetxField.text = ""
        self.buildingNameTextFiled.text = place.name
        let latitude = String(place.coordinate.latitude)
        let longtitude = String(place.coordinate.longitude)
        long = Float(longtitude)
        lat = Float(latitude)
        self.googleApi.getAddressWithLngLat(latitude, longtitude: longtitude) {
            self.filterContentForText(self.googleApi.emirates, areaText: self.googleApi.area)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        print(error.localizedDescription)
    }
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func didRequestAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    func didUpdateAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
extension AddAddressFirstTimeTableViewController {
    func fetchDefaultAreaRequest() {
        sendRequest(nil, request: workingAreaAPI, requestType: .FetchWorkingArea, isSetLoadingView: false, button: nil)
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
        
        // Set loading view center
        if isSetLoadingView {
            setLoadingUI(.White, color: UIColor.whiteColor())
            self.setRequestLoadingViewCenter(button!)
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
    func handleFetchWorkingAreaResponse(result: ResponseObject, requestType: RequestType) {
        setUserInteraction(true)
        var list = [String]()
        var listArea = [WorkingArea]()
        
        for (_, dic) in result.body! {
            let item = WorkingArea(areaDic: dic)
            if item.areaID == nil && item.emirate != nil && item.area != nil {
                continue
            }
            listArea.append(item)
            list.append("\(item.emirate!) - \(item.area!)")
        }
        areaList = listArea
    }
	
	func placeAutocomplete() {
		let filter = GMSAutocompleteFilter()
		filter.type = GMSPlacesAutocompleteTypeFilter.Establishment
		placesClient.autocompleteQuery("Sydney Oper", bounds: nil, filter: filter, callback: {(results, error) -> Void in
		if let error = error {
			print("Autocomplete error \(error)")
			return
		}
		if let results = results {
			for result in results {
				print("Result \(result.attributedFullText) with placeID \(result.placeID)")
			}
		}
		})
	}
	
    func filterContentForText(emiratesText:String,areaText: String) {
        
        guard let areaList = areaList else {
            return
        }
        filteredAreas = areaList.filter { emirates in
            return emirates.emirate!.lowercaseString.containsString(emiratesText.lowercaseString)
        }
        if filteredAreas.count == 0 {
            self.areaAndEmiratesTetxField.text = ""
        } else {
            let emi = filteredAreas[0].emirate!
            var areaString = areaText
            for _ in 0..<areaString.characters.count {
                filteredAreas = areaList.filter({ (area) -> Bool in
                    return (area.area?.lowercaseString.containsString((areaString.lowercaseString)))!
                })
                if filteredAreas.count == 0 {
                    self.area = ""
                    areaString = String(areaString.characters.dropLast())
                    if areaString.characters.count < 4 {
                        return
                    }
                } else {
                    self.area = filteredAreas[0].area!
                    self.emirates = emi
                }
            }
            for i in 0..<areaList.count {
                if areaList[i].area == self.area && areaList[i].emirate == self.emirates {
                    self.areaAndEmiratesTetxField.text = areaList[i].emirate! + " - " + areaList[i].area!
                    self.selectedArea = areaList[i]
                    return
                } else {
                    self.areaAndEmiratesTetxField.text = ""
                }
            }
        }
    }
    
}

extension AddAddressFirstTimeTableViewController: WorkingAreaTableViewControllerDelegate {
    func didSelectArea(selectedArea: WorkingArea?) {
        if selectedArea?.area != nil && selectedArea?.emirate != nil {
            self.area = selectedArea?.area
            self.emirates = selectedArea?.emirate
            self.selectedArea = selectedArea
            self.areaAndEmiratesTetxField.text = (selectedArea?.emirate)! + " - " + (selectedArea?.area)!
        }
    }
}




//
//  WorkingAreaTableViewController.swift
//  MaidMe
//
//  Created by Mai Nguyen Thi Quynh on 4/26/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

protocol WorkingAreaTableViewControllerDelegate {
    func didSelectArea(selectedArea: WorkingArea?)
}

class WorkingAreaTableViewController: BaseTableViewController {
    
    let workingAreaAPI = FetchWorkingAreaService()
    var messageCode: MessageCode?
    var areaList: [WorkingArea]?
    var filteredAreas = [WorkingArea]()
    var selectedArea: WorkingArea?
    var selectedAreaIndex: Int?
    var searchController: UISearchController!
    var delegate: WorkingAreaTableViewControllerDelegate?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDefaultAreaRequest()
        setUpSearchController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyboard()
    }
    
    deinit {
        self.searchController.view.removeFromSuperview()
    }
    
    // MARK: UI
    func setUpSearchController() {
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            definesPresentationContext = true
            controller.searchBar.searchBarStyle = UISearchBarStyle.Prominent
            // 6
            
            controller.searchBar.scopeButtonTitles = []
            controller.searchBar.sizeToFit() // Needed for iOS 8
            tableView.tableHeaderView = controller.searchBar
            //self.navigationItem.titleView = controller.searchBar
            
            return controller
        })()
    }
    
    // MARK: - IBActions
    
    @IBAction func onCancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - API
    
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
        
        if requestType == .FetchWorkingArea {
            handleFetchWorkingAreaResponse(result, requestType: .FetchWorkingArea)
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
        self.tableView.reloadData()
    }
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(requestType: RequestType) {
        if requestType == .FetchWorkingArea {
            self.fetchDefaultAreaRequest()
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        guard let areaList = areaList else {
            return
        }
        filteredAreas = areaList.filter { area in
            return area.area!.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let areaList = areaList else {
            return 0
        }
        
        guard let _ = searchController else {
            return areaList.count
        }
        
        if searchController.active && searchController.searchBar.text != "" {
            return filteredAreas.count
        }
        else {
            return areaList.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("workingAreaCell", forIndexPath: indexPath) as! WorkingAreaCell

        guard let areaList = areaList else {
            return cell
        }
        
        var area: WorkingArea
        
        if searchController != nil {
            if searchController.active && searchController.searchBar.text != "" {
                area = filteredAreas[indexPath.row]
            }
            else {
                area = areaList[indexPath.row]
            }
        }
        else {
            area = areaList[indexPath.row]
        }
        
        cell.areaName.text = area.emirate! + " - " + area.area!

        if indexPath.row == selectedAreaIndex {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let index = selectedAreaIndex {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
            cell?.accessoryType = .None
        }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
        
        if searchController.active && searchController.searchBar.text != "" {
            selectedAreaIndex = indexPath.row
            selectedArea = filteredAreas[selectedAreaIndex!]
        }
        else {
            selectedAreaIndex = indexPath.row
            selectedArea = areaList![selectedAreaIndex!]
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        delegate?.didSelectArea(selectedArea)
    }
}

// MARK: - UISearchResultsUpdating

extension WorkingAreaTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
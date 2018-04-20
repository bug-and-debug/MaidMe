//
//  GoogleAPI.swift
//  MaidMe
//
//  Created by Ngoc Duong Phan on 12/14/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FetchGoogleAPI: NSObject {
    
    var area : String!
    var country: String!
    var emirates : String!
    
    func getAddressWithLngLat(latitude: String,longtitude: String,completion: () -> Void) {
        let urlString: String = "\(GooglePlacesSearchAddress.baseUrl)latlng=\(latitude),\(longtitude)"
        Alamofire.request(.GET, urlString, parameters: nil).responseJSON { response in
            if response.result.isSuccess {
                let responeJSON = JSON(response.result.value!)
                if let results = responeJSON["results"].arrayObject {
                    let address_comp = results[0]["address_components"] as! NSArray
                    if let area = address_comp[0][GooglePlacesSearchAddress.typeNameAddress] as? String,let emirates = address_comp[address_comp.count - 2][GooglePlacesSearchAddress.typeNameAddress] as? String{
                        self.area = area
                        self.emirates = emirates
                        completion()
                    }
                    for i in 0...(results.count - 1){
                        if let addressType = results[i]["types"] as? NSArray {
                            if addressType == ["neighborhood","political"] || addressType == ["political","sublocality","sublocality_level_1"] {
                                if let address_component = (results[i]["address_components"]) as? NSArray {
                                    for a in 0...(address_component.count - 1) {
                                        if let addresDic = address_component[a] as? NSDictionary {
                                            if let types = addresDic["types"] as? NSArray{
                                                if types == ["neighborhood","political"]{
                                                    if let area = address_component[a][GooglePlacesSearchAddress.typeNameAddress] as? String ,let emirates = address_component[address_component.count - 2][GooglePlacesSearchAddress.typeNameAddress] as? String {
                                                        self.area = area
                                                        self.emirates = emirates
                                                    }
                                                    completion()
                                                    return
                                                }
                                                else if types == ["political","sublocality","sublocality_level_1"]{
                                                    if let area = address_component[a][GooglePlacesSearchAddress.typeNameAddress] as? String ,let emirates = address_component[address_component.count - 2][GooglePlacesSearchAddress.typeNameAddress] as? String {
                                                        self.area = area
                                                        self.emirates = emirates
                                                    }
                                                    completion()
                                                    return
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}










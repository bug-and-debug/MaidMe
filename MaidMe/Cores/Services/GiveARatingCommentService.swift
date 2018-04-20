//
//  GiveARatingCommentService.swift
//  MaidMe
//
//  Created by LuanVo on 5/12/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GiveARatingCommentService: RequestManager {
//    func request(parameters: [NSURLQueryItem], completionHandler: (AnyObject?, NSError?) -> ()) {
//        let urlComponents = NSURLComponents()
//        urlComponents.scheme = "http"
//        urlComponents.host = "m-api.maidme.ae"
//        urlComponents.path = "/api/bookings/ratings/new"
//        urlComponents.queryItems = parameters
//        
//        var headers = getAuthenticateHeader()
//        headers["Content-Type"] = "application/json"
//        
//        let dictionary = parameters.reduce([:]) { (dict, item) -> [String: String] in
//            var _params = dict
//            _params[item.name] = item.value
//            return _params
//        }
//        let data = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
//        let urlRequest = NSMutableURLRequest(URL: urlComponents.URL!)
//        urlRequest.HTTPMethod = "POST"
//        urlRequest.HTTPBody = data
//        
//        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        urlRequest.allHTTPHeaderFields = headers
//        
//        let session = NSURLSession.sharedSession()
//        let task = session.dataTaskWithRequest(urlRequest) { (data, response, error) in
//            guard let data = data else { return }
//            let json = try! NSJSONSerialization.JSONObjectWithData(dataxf)
//            print(response)
//            print(json)
//            completionHandler(json, error)
//        }
//        task.resume()
//    }
    
    override func request(method: Alamofire.Method? = nil,
                          _ URLString: URLStringConvertible? = nil,
                            parameters: [String : AnyObject]?,
                            encoding: ParameterEncoding? = nil,
                            headers: [String : String]? = nil,
                            completionHandler: Response<AnyObject, NSError> -> ()) {
        super.request(.POST, "\(Configuration.serverUrl)\(Configuration.giveARatingACommentURL)", parameters: parameters, encoding: .JSON) {
            response in
            completionHandler(response)
            
        }
    }
    
    func getParams(bookingId: String, rating: Int, comment: String) -> [String: AnyObject] {
        return [
            "booking_id": bookingId,
            "rating": rating,
            "comment": comment
//            NSURLQueryItem(name: "booking_id", value: bookingId),
//            NSURLQueryItem(name: "rating", value: "\(rating)"),
//            NSURLQueryItem(name: "comment", value: comment)
        ]
    }
}

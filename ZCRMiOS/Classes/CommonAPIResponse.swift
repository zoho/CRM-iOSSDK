//
//  CommonAPIResponse.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 3/7/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class CommonAPIResponse
{
    internal var response : HTTPURLResponse?
    internal var responseJSON : [String:Any] = [String:Any]()
    internal var httpStatusCode : HTTPStatusCode?
    
    init(response : HTTPURLResponse, responseData : Data?) throws
    {
        self.response = response
        self.httpStatusCode = HTTPStatusCode(rawValue: response.statusCode)!
        try setResponseJSON(responseData: responseData)
        try processResponse()
    }
    
    init()
    {
    }
    
    internal func setResponseJSON(responseData : Data?) throws
    {
        if(httpStatusCode != HTTPStatusCode.NO_CONTENT)
        {
            let jsonStr : Any? = try? JSONSerialization.jsonObject(with: responseData!, options: [])
            if let tempJSON = jsonStr as? [String : Any]
            {
                responseJSON = tempJSON
            }
        }
    }
    
    internal func processResponse() throws
    {
        if(faultyStatusCodes.contains(httpStatusCode!))
        {
            try handleForFaultyResponses()
        }
        else if(httpStatusCode == HTTPStatusCode.ACCEPTED || httpStatusCode == HTTPStatusCode.OK || httpStatusCode == HTTPStatusCode.CREATED )
        {
            try processDataResponse()
        }
    }
    
    internal func handleForFaultyResponses() throws
    {
        
    }
    
    internal func processDataResponse() throws
    {
        
    }
    
    public func getResponseJSON() -> [String:Any]
    {
        return self.responseJSON
    }
    
    public func getHTTPStatusCode() -> Int
    {
        return self.httpStatusCode!.rawValue
    }
    
    public func toString() -> String
    {
        return "STATUS_CODE = \( self.getHTTPStatusCode() ), RESPONSE_JSON = \( self.getResponseJSON().description )"
    }
    
    public func getResponseHeaders() -> String
    {
        return ResponseHeaders( response : self.response! ).toString()
    }
}

public class ResponseHeaders
{
    private var remainingCountForThisDay : Int
    private var remainingCountForThisWindow : Int
    private var remainingTimeForWindowReset : Int
    
    init(response : HTTPURLResponse)
    {
        remainingCountForThisDay = Int( response.allHeaderFields[REMAINING_COUNT_FOR_THIS_DAY] as! String )!
        remainingCountForThisWindow = Int( response.allHeaderFields[REMAINING_COUNT_FOR_THIS_WINDOW] as! String )!
        remainingTimeForWindowReset = Int( response.allHeaderFields[REMAINING_TIME_FOR_THIS_WINDOW_RESET] as! String )!
    }
    
    public func getRemainingAPICountForThisDay() -> Int
    {
        return self.remainingCountForThisDay
    }
    
    public func getRemainingCountForThisWindow() -> Int
    {
        return self.remainingCountForThisWindow
    }
    
    public func getRemainingTimeForThisWindowReset() -> Int
    {
        return self.remainingTimeForWindowReset
    }
    
    public func toString() -> String
    {
        return "\(REMAINING_COUNT_FOR_THIS_DAY) = \(remainingCountForThisDay) \n \(REMAINING_COUNT_FOR_THIS_WINDOW) = \(remainingCountForThisWindow) \n \(REMAINING_TIME_FOR_THIS_WINDOW_RESET) = \(remainingTimeForWindowReset)"
    }
}

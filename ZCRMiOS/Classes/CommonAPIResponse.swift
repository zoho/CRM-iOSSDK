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
    internal var info : ResponseInfo?
    internal var responseJSONRootKey : String?
    
    init(response : HTTPURLResponse, responseData : Data?, responseJSONRootKey : String?) throws
    {
        self.response = response
        self.httpStatusCode = HTTPStatusCode(rawValue: response.statusCode)!
        self.responseJSONRootKey = responseJSONRootKey
        try setResponseJSON(responseData: responseData)
        try processResponse()
        self.setInfo()
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
    
    internal func setInfo()
    {
        if( self.responseJSON.hasValue( forKey : INFO ) && self.responseJSON.hasValue( forKey : PRIVATE_FIELDS ) )
        {
            self.info = ResponseInfo( infoObj : self.responseJSON.getDictionary( key : INFO ), privateFieldsDetails : self.responseJSON.getArrayOfDictionaries( key : PRIVATE_FIELDS ) )
        }
        else if( self.responseJSON.hasValue( forKey : INFO ) )
        {
            self.info = ResponseInfo( infoObj : self.responseJSON.getDictionary( key : INFO ) )
        }
        else if( self.responseJSON.hasValue( forKey : PRIVATE_FIELDS ) )
        {
            self.info = ResponseInfo( privateFields : self.responseJSON.getArrayOfDictionaries( key : PRIVATE_FIELDS ) )
        }
    }
    
    internal func getInfo() -> ResponseInfo?
    {
        return self.info
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

public class ResponseInfo
{
    private var moreRecords : Bool?
    private var recordCount : Int?
    private var pageNo : Int?
    private var perPage : Int?
    private var fieldNameVsValue : [ String : Any ]?
    private var privateFields : [ ZCRMField ]?
    
    convenience init( infoObj : [ String : Any ] )
    {
        self.init( infoObj : infoObj, privateFieldsDetails : nil )
    }
    
    convenience init( privateFields : [ [ String : Any ] ] )
    {
        self.init( infoObj : nil, privateFieldsDetails : privateFields )
    }
    
    init( infoObj : [ String : Any ]?, privateFieldsDetails : [ [ String : Any ] ]? )
    {
        if let infoDetails = infoObj
        {
            for fieldAPIName in infoDetails.keys
            {
                if( MORE_RECORDS == fieldAPIName )
                {
                    self.moreRecords = infoDetails.optBoolean( key : MORE_RECORDS )!
                }
                else if( COUNT == fieldAPIName )
                {
                    self.recordCount = infoDetails.optInt( key : COUNT )!
                }
                else if( PAGE == fieldAPIName )
                {
                    self.pageNo = infoDetails.optInt( key : PAGE )!
                }
                else if( PER_PAGE == fieldAPIName )
                {
                    self.perPage = infoDetails.optInt( key : PER_PAGE )!
                }
                else
                {
                    if( fieldNameVsValue == nil )
                    {
                        self.fieldNameVsValue = [ String : Any ]()
                    }
                    self.fieldNameVsValue![ fieldAPIName ] = infoDetails.optValue( key : fieldAPIName )
                }
            }
        }
        if( privateFieldsDetails != nil )
        {
            if( self.privateFields == nil )
            {
                self.privateFields = [ ZCRMField ]()
            }
            for privateFieldDetails in privateFieldsDetails!
            {
                let field : ZCRMField = ZCRMField( fieldAPIName : privateFieldDetails.getString( key : "api_name" ) )
                field.setId( fieldId : privateFieldDetails.getInt64( key : "id" ) )
                if( privateFieldDetails.hasValue( forKey : "private" ) )
                {
                    let fieldPrivateDetails = privateFieldDetails.getDictionary( key : "private" )
                    field.setIsSupportExport( exportSupported : fieldPrivateDetails.getBoolean( key : "export" ) )
                    field.setIsRestricted( isRestricted : fieldPrivateDetails.getBoolean( key : "restricted" ) )
                    field.setRestrictedType( type : fieldPrivateDetails.getString( key : "type" ) )
                }
                self.privateFields!.append( field )
            }
        }
    }
    
    public func hasMoreRecords() -> Bool?
    {
        return self.moreRecords
    }
    
    public func getRecordCount() -> Int?
    {
        return self.recordCount
    }
    
    public func getPageNo() -> Int?
    {
        return self.pageNo
    }
    
    public func getPerPageCount() -> Int?
    {
        return self.perPage
    }
    
    public func getPrivateFieldList() -> [ ZCRMField ]?
    {
        return self.privateFields
    }
    
    public func getFieldValue( fieldAPIName : String ) -> Any?
    {
        return self.fieldNameVsValue?[ fieldAPIName ]
    }
    
    public func getFieldNameVsValue() -> [ String : Any ]?
    {
        return self.fieldNameVsValue
    }
}

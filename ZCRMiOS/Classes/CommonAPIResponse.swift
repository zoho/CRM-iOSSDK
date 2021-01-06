//
//  CommonAPIResponse.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 3/7/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation
import ZCacheiOS

public class CommonAPIResponse: ZCacheResponse
{
    public var hasMoreRecords: Bool = false
    
    public var recordsCount: Int = 0
    
    public var json: [String : Any] = [:]
    
    public var zCacheEntityInfo: [ZCacheEntityResponse]?
    
    internal var response : HTTPURLResponse?
    internal var responseJSON : [String:Any] = [String:Any]()
    internal var httpStatusCode : HTTPStatusCode?
    internal var info : ResponseInfo?
    internal var responseJSONRootKey = String()
    internal var responseHeaders : ResponseHeaders?
    internal var requestAPIName : String?
    
    init( responseJSON : Dictionary< String, Any >, responseJSONRootKey : String, requestAPIName : String? ) throws
    {
        self.responseJSONRootKey = responseJSONRootKey
        self.responseJSON = responseJSON
        self.requestAPIName = requestAPIName
        try self.setInfo()
    }
    
    init( response : HTTPURLResponse, responseJSONRootKey : String, requestAPIName : String? ) throws
    {
        self.response = response
        self.requestAPIName = requestAPIName
        self.httpStatusCode = HTTPStatusCode( statusCodeValue : response.statusCode )
        self.responseJSONRootKey = responseJSONRootKey
        try setResponseJSON(responseData: nil)
        try processResponse()
        try self.setInfo()
        responseHeaders = ResponseHeaders(response: response)
    }
    
    init(response : HTTPURLResponse, responseData : Data, responseJSONRootKey : String, requestAPIName : String? ) throws
    {
        self.response = response
        self.requestAPIName = requestAPIName
        self.httpStatusCode = HTTPStatusCode( statusCodeValue : response.statusCode )
        self.responseJSONRootKey = responseJSONRootKey
        try setResponseJSON(responseData: responseData)
        try processResponse()
        try self.setInfo()
        responseHeaders = ResponseHeaders(response: response)
    }
    
    init()
    {
    }
    
    internal func setResponseJSON(responseData : Data?) throws
    {
        if httpStatusCode != HTTPStatusCode.noContent && httpStatusCode != HTTPStatusCode.notModified
        {
            if let respData = responseData
            {
                let jsonStr : Any? = try? JSONSerialization.jsonObject(with: respData, options: [])
                if let tempJSON = jsonStr as? [String : Any]
                {
                    responseJSON = tempJSON
                }
            }
            else
            {
                throw ZCRMError.processingError( code : ErrorCode.internalError, message : "Response data is nil", details : nil )
            }
        }
    }
    
    internal func processResponse() throws
    {
        if let statusCode = httpStatusCode, faultyStatusCodes.contains(statusCode)
        {
            try handleForFaultyResponses()
        }
        else if(httpStatusCode == HTTPStatusCode.accepted || httpStatusCode == HTTPStatusCode.ok || httpStatusCode == HTTPStatusCode.created || httpStatusCode == HTTPStatusCode.multiStatus )
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
    
    internal func setInfo() throws
    {
        if( self.responseJSON.hasValue( forKey : APIConstants.INFO ) && self.responseJSON.hasValue( forKey : APIConstants.PRIVATE_FIELDS ) )
        {
            self.info = try ResponseInfo( infoDetails : self.responseJSON.getDictionary( key : APIConstants.INFO ), privateFieldsDetails : self.responseJSON.getArrayOfDictionaries( key : APIConstants.PRIVATE_FIELDS ) )
        }
        else if( self.responseJSON.hasValue( forKey : APIConstants.INFO ) )
        {
            self.info = try ResponseInfo( infoDetails : self.responseJSON.getDictionary( key : APIConstants.INFO ) )
        }
        else if( self.responseJSON.hasValue( forKey : APIConstants.PRIVATE_FIELDS ) )
        {
            self.info = try ResponseInfo( privateFields : self.responseJSON.getArrayOfDictionaries( key : APIConstants.PRIVATE_FIELDS ) )
        }
        
        hasMoreRecords = info?.moreRecords ?? false
        recordsCount = info?.recordCount ?? 0
        json = responseJSON
    }
    
    public func getInfo() -> ResponseInfo?
    {
        return self.info
    }
    
    public func getResponseJSON() -> [String:Any]
    {
        return self.responseJSON
    }
    
    public func getHTTPStatusCode() -> Int?
    {
        return self.httpStatusCode?.rawValue
    }
    
    public func toString() -> String
    {
        if let statusCode = self.getHTTPStatusCode()
        {
            return "STATUS_CODE = \( statusCode ), RESPONSE_JSON = \( self.getResponseJSON().description )"
        }
        else
        {
            ZCRMLogger.logError(message: "Status code is NIL")
            return "RESPONSE_JSON = \( self.getResponseJSON().description )"
        }
    }
    
    public func getResponseHeaders() -> ResponseHeaders?
    {
        return self.responseHeaders
    }
}

public class ResponseHeaders
{
    public var remainingCountForThisDay : Int = Int()
    public var remainingCountForThisWindow : Int = Int()
    public var remainingTimeForWindowReset : Int = Int()
    public var date : String = String()
    
    init(response : HTTPURLResponse)
    {
        if let remainingCountForThisDay = response.allHeaderFields[APIConstants.REMAINING_COUNT_FOR_THIS_DAY] as? String, let countForThisDay = Int( remainingCountForThisDay )
        {
            self.remainingCountForThisDay = countForThisDay
        }
        if let remainingCountForThisWindow = response.allHeaderFields[APIConstants.REMAINING_COUNT_FOR_THIS_WINDOW] as? String, let countForThisWindow = Int( remainingCountForThisWindow )
        {
            self.remainingCountForThisWindow = countForThisWindow
        }
        if let remainingTimeForWindowReset = response.allHeaderFields[APIConstants.REMAINING_TIME_FOR_THIS_WINDOW_RESET] as? String, let countForWindowReset = Int( remainingTimeForWindowReset )
        {
            self.remainingTimeForWindowReset = countForWindowReset
        }
        if let date = response.allHeaderFields[APIConstants.DATE] as? String
        {
            self.date = date
        }
    }
    
    public func toString() -> String
    {
        return "\(APIConstants.REMAINING_COUNT_FOR_THIS_DAY) = \(remainingCountForThisDay) \n \(APIConstants.REMAINING_COUNT_FOR_THIS_WINDOW) = \(remainingCountForThisWindow) \n \(APIConstants.REMAINING_TIME_FOR_THIS_WINDOW_RESET) = \(remainingTimeForWindowReset) \n \(APIConstants.DATE) = \(date)"
    }
}

public class ResponseInfo
{
    var moreRecords : Bool?
    var recordCount : Int?
    private var pageNo : Int?
    private var perPage : Int?
    private var fieldNameVsValue : [ String : Any ]?
    private var privateFields : [ ZCRMField ]?
    
    convenience init( infoDetails : [ String : Any ] ) throws
    {
        try self.init( infoDetails : infoDetails, privateFieldsDetails : nil )
    }
    
    convenience init( privateFields : [ [ String : Any ] ] ) throws
    {
        try self.init( infoDetails : nil, privateFieldsDetails : privateFields )
    }
    
    init( infoDetails : [ String : Any ]?, privateFieldsDetails : [ [ String : Any ] ]? ) throws
    {
        if let infoDetails = infoDetails
        {
            for fieldAPIName in infoDetails.keys
            {
                if( APIConstants.MORE_RECORDS == fieldAPIName )
                {
                    self.moreRecords = try infoDetails.getBoolean( key : APIConstants.MORE_RECORDS )
                }
                else if( APIConstants.COUNT == fieldAPIName )
                {
                    self.recordCount = try infoDetails.getInt( key : APIConstants.COUNT )
                }
                else if( APIConstants.PAGE == fieldAPIName )
                {
                    self.pageNo = try infoDetails.getInt( key : APIConstants.PAGE )
                }
                else if( APIConstants.PER_PAGE == fieldAPIName )
                {
                    self.perPage = try infoDetails.getInt( key : APIConstants.PER_PAGE )
                }
                else
                {
                    if( fieldNameVsValue == nil )
                    {
                        self.fieldNameVsValue = [ String : Any ]()
                    }
                    self.fieldNameVsValue?[ fieldAPIName ] = infoDetails.optValue( key : fieldAPIName )
                }
            }
        }
        if let privateFieldsDetails = privateFieldsDetails
        {
            if( self.privateFields == nil )
            {
                self.privateFields = [ ZCRMField ]()
            }
            for privateFieldDetails in privateFieldsDetails
            {
                let field : ZCRMField = ZCRMField( apiName : try privateFieldDetails.getString( key : "api_name" ) )
                field.id = try privateFieldDetails.getString( key : "id" )
                if( privateFieldDetails.hasValue( forKey : "private" ) )
                {
                    let fieldPrivateDetails = try privateFieldDetails.getDictionary( key : "private" )
                    field.isExportable = try fieldPrivateDetails.getBoolean( key : "export" )
                    field.isRestricted = try fieldPrivateDetails.getBoolean( key : "restricted" )
                    field.dataType = try fieldPrivateDetails.getString( key : "type" )
                }
                self.privateFields?.append( field )
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

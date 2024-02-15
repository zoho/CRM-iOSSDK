//
//  APIRequest.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 09/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

import Foundation
import MobileCoreServices
import CommonCrypto

internal class APIRequest : NSObject
{
    private var requestMethod : ZCRMRequestMethod
    private var headers : [String : String] = [String : String]()
    private var requestBody : Any?
    internal var request : URLRequest?
    private var url : URL?
    private var isOAuth : Bool = true
    internal var jsonRootKey = String()
    private var cacheFlavour : ZCRMCacheFlavour
    private var isCacheable : Bool
    private var isForceCacheable : Bool = false
    private var isOrganizationsAPI : Bool = false
    private static let configuration = URLSessionConfiguration.default
    internal static let session = URLSession( configuration : APIRequest.configuration, delegate: ( ZCRMSDKClient.shared.authorizationCredentials ?? [:] ).isEmpty ? nil : SSLValidator(), delegateQueue: nil )
    private var requestedModule : String?
    internal var includeCommonReqHeaders : Bool = true
    internal var checkInfoOptional: Bool = false // If the response info is optional, set the value to true.
    private var dbType : DBType?
    
    init( absoluteURL : URL, requestMethod : ZCRMRequestMethod, cacheFlavour : ZCRMCacheFlavour? = nil, isCacheable : Bool? = false, isForceCacheable : Bool? = false, isOrganizationsAPI : Bool = false, jsonRootKey : String? = nil, requestHeaders : [ String : String ]? = nil, includeCommonReqHeaders : Bool, dbType : DBType? = nil )
    {
        self.url = absoluteURL
        self.requestMethod = requestMethod
        self.isCacheable = isCacheable ?? false
        self.isForceCacheable = isForceCacheable ?? false
        self.cacheFlavour = cacheFlavour ?? .noCache
        self.jsonRootKey = jsonRootKey ?? String()
        self.includeCommonReqHeaders = includeCommonReqHeaders
        self.headers = requestHeaders ?? [:]
        self.isOrganizationsAPI = isOrganizationsAPI
        self.dbType = dbType
    }
    
    init( handler : APIHandler, cacheFlavour : ZCRMCacheFlavour, dbType : DBType? = nil )
    {
        self.url = handler.getUrl()
        self.requestMethod = handler.getRequestMethod()
        self.headers = handler.getRequestHeaders()
        self.requestBody = handler.getRequestBody()
        self.isOAuth = handler.getRequestType()
        self.jsonRootKey = handler.getJSONRootKey()
        self.cacheFlavour = cacheFlavour
        self.isCacheable = handler.getIsCacheable()
        self.isForceCacheable = handler.getIsForceCacheable()
        self.requestedModule = handler.getModuleName()
        self.isOrganizationsAPI = handler.getIsOrganizationsAPI()
        self.dbType = dbType
    }
    
    convenience init( handler : APIHandler)
    {
        self.init( handler : handler, cacheFlavour : .noCache )
    }
    
    internal func authenticateRequest( completion : @escaping( ZCRMError? ) -> () )
    {
        ZCRMSDKClient.shared.getAccessToken() { result in
            switch result
            {
            case .success(let accessToken) :
                guard accessToken.isEmpty == false else
                {
                    ZCRMLogger.logError(message: "\(ZCRMErrorCode.oauthTokenNil) : \(ZCRMErrorMessage.oauthTokenNilMsg)")
                    completion( ZCRMError.unAuthenticatedError( code : ZCRMErrorCode.oauthTokenNil, message : ZCRMErrorMessage.oauthTokenNilMsg, details : nil ) )
                    return
                }
                self.addHeader( headerName : AUTHORIZATION, headerVal : "\(ZOHO_OAUTHTOKEN) \( accessToken )" )
                if let userAgent = self.headers.optString(key: USER_AGENT)
                {
                    self.addHeader( headerName : USER_AGENT, headerVal : userAgent )
                }
                else
                {
                    self.addHeader( headerName : USER_AGENT, headerVal : ZCRMSDKClient.shared.userAgent )
                }
                if ZCRMSDKClient.shared.appType == .zcrmcp, let organizationName = self.headers[ X_CRM_PORTAL ]
                {
                    self.addHeader(headerName: X_CRM_PORTAL, headerVal: organizationName )
                }
                else if !self.isOrganizationsAPI, let organizationId = ZCRMSDKClient.shared.organizationId, self.headers[ X_CRM_ORG ] == nil , self.url?.absoluteString.lastPathComponent() != "\( ZCRMDefaultModuleAPINames.ORGANIZATIONS )"
                {
                    self.addHeader( headerName : X_CRM_ORG, headerVal : String(organizationId) )
                }
                if let requestHeaders = ZCRMSDKClient.shared.requestHeaders
                {
                    for ( key, value ) in requestHeaders
                    {
                        if ( (!self.includeCommonReqHeaders || self.isOrganizationsAPI ) && key == X_ZOHO_SERVICE )
                        {
                            continue
                        }
                        if !self.headers.hasValue(forKey: key)
                        {
                            self.addHeader(headerName: key, headerVal: value)
                        }
                    }
                }
                for ( key, value ) in self.headers
                {
                    self.request?.setValue( value, forHTTPHeaderField: key)
                }
                completion( nil )
            case .failure( let error ) :
                if let zcrmError = error.ZCRMErrordetails
                {
                    ZCRMLogger.logError( message : "\( zcrmError.code ) : \( zcrmError )" )
                    completion( error )
                }
                else
                {
                    ZCRMLogger.logError(message: "\( error ). \(ZCRMErrorCode.typeCastError) : Error - Expected type -> ZCRMError, \( APIConstants.DETAILS ) : -")
                    completion( error )
                }
            }
        }
    }
    
    private func addHeader(headerName : String, headerVal : String)
    {
        self.headers[headerName] = headerVal
    }
    
    internal func initialiseRequest( completion : @escaping( ZCRMError? ) -> () )
    {
        if isOAuth == true
        {
            if let myUrl = self.url
            {
                self.request = URLRequest(url: myUrl )
                if self.requestMethod == ZCRMRequestMethod.undefined
                {
                    ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidOperation) : Invalid Request method!!!, \( APIConstants.DETAILS ) : -")
                    completion( ZCRMError.inValidError( code : ZCRMErrorCode.invalidOperation, message: "Invalid Request method!!!", details: nil ) )
                    return
                }
                self.request?.httpMethod = self.requestMethod.rawValue
                self.request?.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
                for (key, value) in self.headers
                {
                    self.request?.setValue(value, forHTTPHeaderField: key)
                }
                if self.requestBody != nil, let requestBody = self.requestBody as? [ String : Any ], requestBody.isEmpty == false
                {
                    let reqBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
                    self.request?.httpBody = reqBody
                    self.addHeader(headerName: "Content-Type", headerVal: "application/json")
                }
                completion( nil )
                return
            }
            else
            {
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.internalError) : Unable to construct URLRequest, \( APIConstants.DETAILS ) : -")
                completion(ZCRMError.sdkError(code: ZCRMErrorCode.internalError, message: "Unable to construct URLRequest", details : nil))
                return
            }
        }
        else
        {
            completion(nil)
        }
    }
    
    /**
     To intialize the request with url and headers.
     
     Used only for acquiring raw response from the server for any apiRequests.
     
     - Parameters:
        - headers : Headers that has to be included for the request ( Optional Value )
        - completion : Returns the raw Data and HTTPURLResponse
     */
    func initialiseRequest( _ headers : [ String : String ]?, _ requestBody : [ String : Any ]?, completion : @escaping ( ZCRMResult.DataURLResponse<Data, HTTPURLResponse> ) -> Void )
    {
        if let requestHeaders = headers
        {
            for ( key, value ) in requestHeaders
            {
                self.addHeader(headerName: key, headerVal: value)
            }
        }
        
        if let requestBody = requestBody
        {
            self.requestBody = requestBody
        }
        
        ZCRMLogger.logDebug( message : "Request : \( self.toString() )" )
        self.initialiseRequest() { error in
            if let error = error
            {
                completion( .failure( error ) )
            }
            else
            {
                self.makeRequest() { result in
                    switch result
                    {
                    case .success(let data, let response) :
                        completion( .success(data, response) )
                    case .failure(let error) :
                        completion( .failure( error ) )
                    }
                }
            }
        }
    }
    
    internal func getAPIResponse( completion : @escaping (ZCRMResult.Response<APIResponse>) -> Void )
    {
        self.initialiseRequest { ( err ) in
            
            if let error = err
            {
                ZCRMLogger.logError( message : "\( error )" )
                completion(.failure(error))
                return
            }
            else
            {
                if self.useCache()
                {
                    self.getResponseFromDB { ( responseJSON, error ) in
                        if let err = error
                        {
                            ZCRMLogger.logDebug( message : "ZCRM SDK - Error occured while response from DB. Details \( err )" )
                            self.getAPIResponseFromServer { ( result ) in
                                completion( result )
                                return
                            }
                        }
                        else if let respJSON = responseJSON
                        {
                            do
                            {
                                let response = try APIResponse( responseJSON : respJSON, responseJSONRootKey: self.jsonRootKey, requestAPIName: self.requestedModule )
                                completion(.success(response))
                                return
                            }
                            catch
                            {
                                ZCRMLogger.logError( message : "\( error )" )
                                completion(.failure( typeCastToZCRMError( error ) ) )
                                return
                            }
                        }
                        else
                        {
                            ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseNilMsg), \( APIConstants.DETAILS ) : -")
                            completion(.failure(ZCRMError.sdkError(code: ZCRMErrorCode.responseNil, message: ZCRMErrorMessage.responseNilMsg, details : nil)))
                            return
                        }
                    }
                }
                else
                {
                    self.getAPIResponseFromServer { ( result ) in
                        completion( result )
                        return
                    }
                }
            }
        }
    }
    
    private func getAPIResponseFromServer( completion : @escaping (ZCRMResult.Response<APIResponse>) -> Void )
    {
        self.makeRequest() { result in
            var response : APIResponse
            do {
                switch result {
                case .success(let respdata, let resp) :
                    if !respdata.isEmpty {
                        response = try APIResponse( response : resp, responseData: respdata, responseJSONRootKey: self.jsonRootKey, requestAPIName: self.requestedModule)
                        completion(.success(response))
                        if !self.insertDataInDB(response: response, bulkResponse: nil)
                        {
                            ZCRMLogger.logDebug(message: "ZCRM SDK - Error occurred while inserting response into database.")
                        }
                    } else {
                        response = try APIResponse( response : resp, responseJSONRootKey: self.jsonRootKey, requestAPIName: self.requestedModule)
                        completion(.success(response))
                        if !self.insertDataInDB(response: response, bulkResponse: nil)
                        {
                            ZCRMLogger.logDebug(message: "ZCRM SDK - Error occurred while inserting response into database.")
                        }
                    }
                case .failure(let error) :
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            } catch {
                do {
                    try self.clearCacheData()
                } catch {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ))
                    return
                }
                ZCRMLogger.logError( message : "\( error )" )
                completion(.failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getBulkAPIResponse( completion : @escaping(ZCRMResult.Response<BulkAPIResponse>) -> () )
    {
        self.initialiseRequest { ( err ) in
            
            if let error = err
            {
                ZCRMLogger.logError( message : "\( error )" )
                completion(.failure(error))
                return
            }
            else
            {
                if self.useCache()
                {
                    self.getResponseFromDB { ( responseJSON, error ) in
                        if let err = error
                        {
                            ZCRMLogger.logDebug( message : "ZCRM SDK - Error occured while response from DB. Details \( err )" )
                            self.getBulkAPIResponseFromServer { ( result ) in
                                completion( result )
                                return
                            }
                        }
                        else if let respJSON = responseJSON
                        {
                            do
                            {
                                let response = try BulkAPIResponse( responseJSON : respJSON, responseJSONRootKey: self.jsonRootKey, requestAPIName: self.requestedModule, checkInfoOptional: self.checkInfoOptional )
                                completion(.success(response))
                            }
                            catch
                            {
                                ZCRMLogger.logError( message : "\( error )" )
                                completion(.failure( typeCastToZCRMError( error ) ) )
                            }
                        }
                        else
                        {
                            ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseNilMsg), \( APIConstants.DETAILS ) : -")
                            completion(.failure(ZCRMError.sdkError(code: ZCRMErrorCode.responseNil, message: ZCRMErrorMessage.responseNilMsg, details : nil)))
                        }
                    }
                }
                else
                {
                    self.getBulkAPIResponseFromServer { ( result ) in
                        completion( result )
                    }
                }
            }
        }
    }
    
    private func getBulkAPIResponseFromServer( completion : @escaping(ZCRMResult.Response<BulkAPIResponse>) -> () )
    {
        self.makeRequest() { result in
            var response : BulkAPIResponse
            do {
                switch result {
                case .success(let respdata, let resp) :
                    if !respdata.isEmpty {
                        response = try BulkAPIResponse( response : resp, responseData: respdata, responseJSONRootKey: self.jsonRootKey, requestAPIName: self.requestedModule, checkInfoOptional: self.checkInfoOptional )
                        completion(.success(response))
                        if !self.insertDataInDB(response: nil, bulkResponse: response)
                        {
                            ZCRMLogger.logDebug(message: "ZCRM SDK - Error occurred while inserting response into database.")
                        }
                    } else {
                        response = try BulkAPIResponse( response : resp, responseJSONRootKey: self.jsonRootKey, requestAPIName: self.requestedModule, checkInfoOptional: self.checkInfoOptional )
                        completion(.success(response))
                        if !self.insertDataInDB(response: nil, bulkResponse: response)
                        {
                            ZCRMLogger.logDebug(message: "ZCRM SDK - Error occurred while inserting response into database.")
                        }
                    }
                case .failure(let error) :
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            } catch {
                do {
                    try self.clearCacheData()
                } catch {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ))
                    return
                }
                ZCRMLogger.logError( message : "\( error )" )
                completion(.failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    // yet to return success & failure
    private func insertDataInDB( response : APIResponse?, bulkResponse : BulkAPIResponse? ) -> Bool
    {
        guard let dbType = dbType else {
            ZCRMLogger.logError(message: "\( ZCRMErrorCode.processingError) :  DBType cannot be nil, \( APIConstants.DETAILS ) : -")
            ZCRMLogger.logDebug( message : "Unable to insert data in db. error details : \( ZCRMError.sdkError( code : ZCRMErrorCode.unableToConstructURL, message: "DBType cannot be nil", details : nil ) )" )
            return false
        }
        do
        {
            if self.cacheFlavour == .forceCache || isForceCacheable
            {
                guard let url = self.request?.url?.absoluteString else {
                    ZCRMLogger.logError(message: "\( ZCRMErrorCode.unableToConstructURL ) : Unable to fetch url string from urlrequest")
                    return false
                }
                if let resp = ( response != nil ? response : bulkResponse ), let respJSON = resp.getResponseJSON().toJSON()
                {
                    try ZCRMSDKClient.shared.getPersistentDB( dbType: dbType ).insertData( withURL : url, data : respJSON, validity : DBConstant.VALIDITY_TIME, isOrganizationsAPI: isOrganizationsAPI )
                }
            }
            else if self.useCache() || (self.cacheFlavour == .noCache && ZCRMSDKClient.shared.isDBCacheEnabled && self.isCacheable)
            {
                guard let url = self.request?.url?.absoluteString else {
                    ZCRMLogger.logError(message: "\( ZCRMErrorCode.unableToConstructURL ) : Unable to fetch url string from urlrequest")
                    return false
                }
                if let resp = ( response != nil ? response : bulkResponse ), let respJSON = resp.getResponseJSON().toJSON()
                {
                    try ZCRMSDKClient.shared.getNonPersistentDB( dbType: dbType ).insertData( withURL : url, data : respJSON, validity : DBConstant.VALIDITY_TIME, isOrganizationsAPI: isOrganizationsAPI )
                }
            }
            else
            {
                ZCRMLogger.logDebug(message: "Invalid cache type")
                return false
            }
        }
        catch
        {
            ZCRMLogger.logDebug( message : "Unable to insert data in db. error details : \( error )" )
            return false
        }
        return true
    }
    
    private func clearCacheData() throws  {
        do {
            if self.cacheFlavour == .forceCache, let dbType = dbType
            {
                guard let url = self.request?.url?.absoluteString else {
                    ZCRMLogger.logError(message: "\( ZCRMErrorCode.unableToConstructURL ) : Unable to fetch url string from urlrequest")
                    return
                }
                try ZCRMSDKClient.shared.getPersistentDB( dbType : dbType ).deleteData(withURL: url, isOrganizationsAPI: isOrganizationsAPI)
            }
            else if ( self.useCache() || (self.cacheFlavour == .noCache && ZCRMSDKClient.shared.isDBCacheEnabled && self.isCacheable) ), let dbType = dbType
            {
                guard let url = self.request?.url?.absoluteString else {
                    ZCRMLogger.logError(message: "\( ZCRMErrorCode.unableToConstructURL ) : Unable to fetch url string from urlrequest")
                    return
                }
                try ZCRMSDKClient.shared.getNonPersistentDB( dbType: dbType ).deleteData(withURL: url, isOrganizationsAPI: isOrganizationsAPI)
            }
            else
            {
                ZCRMLogger.logDebug(message: "Invalid cache type")
            }
        } catch {
            ZCRMLogger.logDebug( message : "Unable to Delete data in DB. Error Details : \( error )" )
        }
    }
    
    private func getResponseFromDB( completion : @escaping( Dictionary< String, Any>?, ZCRMError? ) -> Void )
    {
        guard let url = self.request?.url?.absoluteString else {
            ZCRMLogger.logError(message: "\( ZCRMErrorCode.unableToConstructURL) :  Unable to fetch url string from urlrequest, \( APIConstants.DETAILS ) : -")
            completion( nil, ZCRMError.sdkError( code : ZCRMErrorCode.unableToConstructURL, message: "Unable to fetch url string from urlrequest", details : nil ) )
            return
        }
        guard let dbType = dbType else {
            ZCRMLogger.logError(message: "\( ZCRMErrorCode.processingError) :  DBType cannot be nil, \( APIConstants.DETAILS ) : -")
            completion( nil, ZCRMError.sdkError( code : ZCRMErrorCode.unableToConstructURL, message: "DBType cannot be nil", details : nil ) )
            return
        }
        switch self.cacheFlavour
        {
        case .urlVsResponse :
            do
            {
                if let responseFromDB = try ZCRMSDKClient.shared.getNonPersistentDB( dbType: dbType ).fetchData( withURL : url, isOrganizationsAPI: isOrganizationsAPI )
                {
                    completion( responseFromDB, nil )
                }
                else
                {
                    completion( nil, ZCRMError.sdkError( code : ZCRMErrorCode.responseNil, message: ZCRMErrorMessage.dbDataNotAvailable, details : nil ) )
                }
            }
            catch
            {
                completion( nil, ZCRMError.sdkError( code : ZCRMErrorCode.responseNil, message: ZCRMErrorMessage.dbDataNotAvailable, details : nil ) )
            }
        case .forceCache :
            do
            {
                if let responseFromDB = try ZCRMSDKClient.shared.getPersistentDB( dbType: dbType ).fetchData( withURL : url, isOrganizationsAPI: isOrganizationsAPI )
                {
                    completion( responseFromDB, nil )
                }
                else
                {
                    completion( nil, ZCRMError.sdkError( code : ZCRMErrorCode.responseNil, message: ZCRMErrorMessage.dbDataNotAvailable, details: nil ) )
                }
            }
            catch
            {
                completion( nil, ZCRMError.sdkError( code : ZCRMErrorCode.responseNil, message: ZCRMErrorMessage.dbDataNotAvailable, details: nil ) )
            }
            
        default :
            ZCRMLogger.logDebug(message: "Invalid cache type")
        }
    }
    
    internal func makeRequest( completion : @escaping ( ZCRMResult.DataURLResponse<Data, HTTPURLResponse> ) -> () )
    {
        self.authenticateRequest() { error in
            if let error = error
            {
                completion( .failure( typeCastToZCRMError( error )) )
                return
            }
            if let request = self.request
            {
                APIRequest.configuration.timeoutIntervalForRequest = ZCRMSDKClient.shared.requestTimeout
                APIRequest.session.dataTask(with: request) { resultType in
                    switch resultType
                    {
                    case .success(let data, let response) :
                        completion( .success(data, response) )
                    case .failure(let error) :
                        if error.ZCRMErrordetails?.code != ZCRMErrorCode.noInternetConnection && error.ZCRMErrordetails?.code != ZCRMErrorCode.requestTimeOut && error.ZCRMErrordetails?.code !=  ZCRMErrorCode.networkConnectionLost
                        {
                            do
                            {
                                try self.clearCacheData()
                            }
                            catch
                            {
                                ZCRMLogger.logError( message : "\( error )" )
                                completion( .failure( typeCastToZCRMError( error ) ))
                                return
                            }
                        }
                        completion( .failure( error ) )
                    }
                }.resume()
            }
            else
            {
                do {
                    try self.clearCacheData()
                } catch {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ))
                    return
                }
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.internalError) : Request is nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.sdkError(code: ZCRMErrorCode.internalError, message: "Request is nil", details : nil) ) )
                return
            }
        }
    }
    
    public func toString() -> String
    {
        var headers : [ String : String ] = self.headers
        if headers.hasKey( forKey : AUTHORIZATION )
        {
            headers[ AUTHORIZATION ] = "## ***** ##"
        }
        return "Request: \( self.url?.absoluteString  ??  "nil" ) \n HEADERS : \( headers.description )"
    }
    
    private func useCache() -> Bool
    {
        return ( cacheFlavour.rawValue ==  ZCRMCacheFlavour.forceCache.rawValue || ( ZCRMSDKClient.shared.isDBCacheEnabled && cacheFlavour.rawValue != ZCRMCacheFlavour.noCache.rawValue ) )
    }
}

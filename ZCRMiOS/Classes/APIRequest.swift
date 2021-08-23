 //
 //  APIRequest.swift
 //  ZCRMiOS
 //
 //  Created by Vijayakrishna on 09/11/16.
 //  Copyright © 2016 zohocrm. All rights reserved.
 //
 
 import Foundation
 import MobileCoreServices
 
 internal class APIRequest : NSObject
 {
    private var requestMethod : RequestMethod
    private var headers : [String : String] = [String : String]()
    private var requestBody : Any?
    internal var request : URLRequest?
    private var url : URL?
    private var isOAuth : Bool = true
    internal var jsonRootKey = String()
    private var cacheFlavour : CacheFlavour!
    private var isCacheable : Bool
    private var isForceCacheable : Bool = false
    private static let configuration = URLSessionConfiguration.default
    internal static let session = URLSession( configuration : APIRequest.configuration )
    private var requestedModule : String?
    internal var includeCommonReqHeaders : Bool = true
    
    init( absoluteURL : URL, requestMethod : RequestMethod, cacheFlavour : CacheFlavour? = nil, isCacheable : Bool? = false, isForceCacheable : Bool? = false, jsonRootKey : String? = nil, requestHeaders : [ String : String ]? = nil, includeCommonReqHeaders : Bool )
    {
        self.url = absoluteURL
        self.requestMethod = requestMethod
        self.isCacheable = isCacheable ?? false
        self.isForceCacheable = isForceCacheable ?? false
        self.cacheFlavour = cacheFlavour ?? CacheFlavour.noCache
        self.jsonRootKey = jsonRootKey ?? String()
        self.includeCommonReqHeaders = includeCommonReqHeaders
        self.headers = requestHeaders ?? [:]
    }
    
    init( handler : APIHandler, cacheFlavour : CacheFlavour )
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
                    ZCRMLogger.logError(message: "\(ErrorCode.oauthTokenNil) : \(ErrorMessage.oauthTokenNilMsg)")
                    completion( ZCRMError.unAuthenticatedError( code : ErrorCode.oauthTokenNil, message : ErrorMessage.oauthTokenNilMsg, details : nil ) )
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
                else if let organizationId = ZCRMSDKClient.shared.portalId, self.headers[ X_CRM_ORG ] == nil , self.url?.absoluteString.lastPathComponent() != "\( DefaultModuleAPINames.ORGANIZATIONS )"
                {
                    self.addHeader( headerName : X_CRM_ORG, headerVal : String(organizationId) )
                }
                if let requestHeaders = ZCRMSDKClient.shared.requestHeaders
                {
                    for ( key, value ) in requestHeaders
                    {
                        if ( !self.includeCommonReqHeaders && key == X_ZOHO_SERVICE )
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
                    ZCRMLogger.logError(message: "\( error ). \(ErrorCode.typeCastError) : Error - Expected type -> ZCRMError, \( APIConstants.DETAILS ) : -")
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
                if self.requestMethod == RequestMethod.undefined
                {
                    ZCRMLogger.logError(message: "\(ErrorCode.invalidOperation) : Invalid Request method!!!, \( APIConstants.DETAILS ) : -")
                    completion( ZCRMError.inValidError( code : ErrorCode.invalidOperation, message: "Invalid Request method!!!", details: nil ) )
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
                }
                completion( nil )
                return
            }
            else
            {
                ZCRMLogger.logError(message: "\(ErrorCode.internalError) : Unable to construct URLRequest, \( APIConstants.DETAILS ) : -")
                completion(ZCRMError.sdkError(code: ErrorCode.internalError, message: "Unable to construct URLRequest", details : nil))
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
    func initialiseRequest( _ headers : [ String : String ]?, _ requestBody : [ String : Any ]?, completion : @escaping ( Result.DataURLResponse<Data, HTTPURLResponse> ) -> Void )
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
    
    internal func getAPIResponse( completion : @escaping (Result.Response<APIResponse>) -> Void )
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
                            ZCRMLogger.logError(message: "\(ErrorCode.responseNil) : \(ErrorMessage.responseNilMsg), \( APIConstants.DETAILS ) : -")
                            completion(.failure(ZCRMError.sdkError(code: ErrorCode.responseNil, message: ErrorMessage.responseNilMsg, details : nil)))
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
    
    private func getAPIResponseFromServer( completion : @escaping (Result.Response<APIResponse>) -> Void )
    {
        self.makeRequest() { result in
            var response : APIResponse
            do {
                switch result {
                case .success(let respdata, let resp) :
                    if !respdata.isEmpty {
                        response = try APIResponse( response : resp, responseData: respdata, responseJSONRootKey: self.jsonRootKey, requestAPIName: self.requestedModule)
                        if !self.insertDataInDB(response: response, bulkResponse: nil)
                        {
                            ZCRMLogger.logDebug(message: "ZCRM SDK - Error occurred while inserting response into database.")
                        }
                        completion(.success(response))
                    } else {
                        response = try APIResponse( response : resp, responseJSONRootKey: self.jsonRootKey, requestAPIName: self.requestedModule)
                        if !self.insertDataInDB(response: response, bulkResponse: nil)
                        {
                            ZCRMLogger.logDebug(message: "ZCRM SDK - Error occurred while inserting response into database.")
                        }
                        completion(.success(response))
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
    
    internal func getBulkAPIResponse( completion : @escaping(Result.Response<BulkAPIResponse>) -> () )
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
                                let response = try BulkAPIResponse( responseJSON : respJSON, responseJSONRootKey: self.jsonRootKey, requestAPIName: self.requestedModule )
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
                            ZCRMLogger.logError(message: "\(ErrorCode.responseNil) : \(ErrorMessage.responseNilMsg), \( APIConstants.DETAILS ) : -")
                            completion(.failure(ZCRMError.sdkError(code: ErrorCode.responseNil, message: ErrorMessage.responseNilMsg, details : nil)))
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
    
    private func getBulkAPIResponseFromServer( completion : @escaping(Result.Response<BulkAPIResponse>) -> () )
    {
        self.makeRequest() { result in
            var response : BulkAPIResponse
            do {
                switch result {
                case .success(let respdata, let resp) :
                    if !respdata.isEmpty {
                        response = try BulkAPIResponse( response : resp, responseData: respdata, responseJSONRootKey: self.jsonRootKey, requestAPIName: self.requestedModule)
                        if !self.insertDataInDB(response: nil, bulkResponse: response)
                        {
                            ZCRMLogger.logDebug(message: "ZCRM SDK - Error occurred while inserting response into database.")
                        }
                        completion(.success(response))
                    } else {
                        response = try BulkAPIResponse( response : resp, responseJSONRootKey: self.jsonRootKey, requestAPIName: self.requestedModule)
                        if !self.insertDataInDB(response: nil, bulkResponse: response)
                        {
                            ZCRMLogger.logDebug(message: "ZCRM SDK - Error occurred while inserting response into database.")
                        }
                        completion(.success(response))
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
        do
        {
            if self.cacheFlavour == CacheFlavour.forceCache || isForceCacheable
            {
                guard let url = self.request?.url?.absoluteString else {
                    ZCRMLogger.logError(message: "\( ErrorCode.unableToConstructURL ) : Unable to fetch url string from urlrequest")
                    return false
                }
                if let resp = ( response != nil ? response : bulkResponse ), let respJSON = resp.getResponseJSON().toJSON()
                {
                    try ZCRMSDKClient.shared.getPersistentDB().insertData( withURL : url, data : respJSON, validity : DBConstant.VALIDITY_TIME )
                }
            }
            else if self.useCache() || (self.cacheFlavour == CacheFlavour.noCache && ZCRMSDKClient.shared.isDBCacheEnabled && self.isCacheable)
            {
                guard let url = self.request?.url?.absoluteString else {
                    ZCRMLogger.logError(message: "\( ErrorCode.unableToConstructURL ) : Unable to fetch url string from urlrequest")
                    return false
                }
                if let resp = ( response != nil ? response : bulkResponse ), let respJSON = resp.getResponseJSON().toJSON()
                {
                    try ZCRMSDKClient.shared.getNonPersistentDB().insertData( withURL : url, data : respJSON, validity : DBConstant.VALIDITY_TIME )
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
            if self.cacheFlavour == CacheFlavour.forceCache
            {
                guard let url = self.request?.url?.absoluteString else {
                    ZCRMLogger.logError(message: "\( ErrorCode.unableToConstructURL ) : Unable to fetch url string from urlrequest")
                    return
                }
                try ZCRMSDKClient.shared.getPersistentDB().deleteData(withURL: url)
            }
            else if self.useCache() || (self.cacheFlavour == CacheFlavour.noCache && ZCRMSDKClient.shared.isDBCacheEnabled && self.isCacheable)
            {
                guard let url = self.request?.url?.absoluteString else {
                    ZCRMLogger.logError(message: "\( ErrorCode.unableToConstructURL ) : Unable to fetch url string from urlrequest")
                    return
                }
                try ZCRMSDKClient.shared.getNonPersistentDB().deleteData(withURL: url)
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
            ZCRMLogger.logError(message: "\( ErrorCode.unableToConstructURL) :  Unable to fetch url string from urlrequest, \( APIConstants.DETAILS ) : -")
            completion( nil, ZCRMError.sdkError( code : ErrorCode.unableToConstructURL, message: "Unable to fetch url string from urlrequest", details : nil ) )
            return
        }
        if let cacheType = self.cacheFlavour
        {
            switch cacheType
            {
            case .urlVsResponse :
                do
                {
                    if let responseFromDB = try ZCRMSDKClient.shared.getNonPersistentDB().fetchData( withURL : url )
                    {
                        completion( responseFromDB, nil )
                    }
                    else
                    {
                        completion( nil, ZCRMError.sdkError( code : ErrorCode.responseNil, message: ErrorMessage.dbDataNotAvailable, details : nil ) )
                    }
                }
                catch
                {
                    completion( nil, ZCRMError.sdkError( code : ErrorCode.responseNil, message: ErrorMessage.dbDataNotAvailable, details : nil ) )
                }
            case .forceCache :
                do
                {
                    if let responseFromDB = try ZCRMSDKClient.shared.getPersistentDB().fetchData( withURL : url )
                    {
                        completion( responseFromDB, nil )
                    }
                    else
                    {
                        completion( nil, ZCRMError.sdkError( code : ErrorCode.responseNil, message: ErrorMessage.dbDataNotAvailable, details: nil ) )
                    }
                }
                catch
                {
                    completion( nil, ZCRMError.sdkError( code : ErrorCode.responseNil, message: ErrorMessage.dbDataNotAvailable, details: nil ) )
                }
                
            default :
                ZCRMLogger.logDebug(message: "Invalid cache type")
            }
        }
    }
    
    internal func makeRequest( completion : @escaping ( Result.DataURLResponse<Data, HTTPURLResponse> ) -> () )
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
                        if error.ZCRMErrordetails?.code != ErrorCode.noInternetConnection && error.ZCRMErrordetails?.code != ErrorCode.requestTimeOut && error.ZCRMErrordetails?.code !=  ErrorCode.networkConnectionLost
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
                ZCRMLogger.logError(message: "\(ErrorCode.internalError) : Request is nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.sdkError(code: ErrorCode.internalError, message: "Request is nil", details : nil) ) )
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
        return ( cacheFlavour.rawValue ==  CacheFlavour.forceCache.rawValue || ( ZCRMSDKClient.shared.isDBCacheEnabled && cacheFlavour.rawValue != CacheFlavour.noCache.rawValue ) )
    }
 }

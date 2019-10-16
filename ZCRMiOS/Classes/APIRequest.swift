 //
 //  APIRequest.swift
 //  ZCRMiOS
 //
 //  Created by Vijayakrishna on 09/11/16.
 //  Copyright © 2016 zohocrm. All rights reserved.
 //
 
 import Foundation
 import MobileCoreServices
 internal enum HTTPStatusCode : Int
 {
    case OK = 200
    case CREATED = 201
    case ACCEPTED = 202
    case NO_CONTENT = 204
    case MOVED_PERMANENTLY = 301
    case MOVED_TEMPORARILY = 302
    case NOT_MODIFIED = 304
    case BAD_REQUEST = 400
    case AUTHORIZATION_ERROR = 401
    case FORBIDDEN = 403
    case NOT_FOUND = 404
    case METHOD_NOT_ALLOWED = 405
    case REQUEST_ENTITY_TOO_LARGE = 413
    case UNSUPPORTED_MEDIA_TYPE = 415
    case TOO_MANY_REQUEST = 429
    case INTERNAL_SERVER_ERROR = 500
    case BAD_GATEWAY = 502
    case UNHANDLED
    
    init( statusCodeValue : Int )
    {
        if let code = HTTPStatusCode( rawValue: statusCodeValue )
        {
            self = code
        }
        else
        {
            ZCRMLogger.logInfo(message: "UNHANDLED -> HTTP status code : \( statusCodeValue )")
            self = .UNHANDLED
        }
    }
 }
 
 internal let faultyStatusCodes : [HTTPStatusCode] = [HTTPStatusCode.AUTHORIZATION_ERROR, HTTPStatusCode.BAD_REQUEST, HTTPStatusCode.FORBIDDEN, HTTPStatusCode.INTERNAL_SERVER_ERROR, HTTPStatusCode.METHOD_NOT_ALLOWED, HTTPStatusCode.MOVED_TEMPORARILY, HTTPStatusCode.MOVED_PERMANENTLY, HTTPStatusCode.REQUEST_ENTITY_TOO_LARGE, HTTPStatusCode.TOO_MANY_REQUEST, HTTPStatusCode.UNSUPPORTED_MEDIA_TYPE, HTTPStatusCode.NO_CONTENT, HTTPStatusCode.NOT_FOUND, HTTPStatusCode.BAD_GATEWAY, HTTPStatusCode.UNHANDLED]
 
 internal enum RequestMethod : String
 {
    case GET = "GET"
    case POST = "POST"
    case PATCH = "PATCH"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case UNDEFINED = "UNDEFINED"
 }
 
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
    private static let configuration = URLSessionConfiguration.default
    private static let session = URLSession( configuration : APIRequest.configuration )
    
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
    }
    
    convenience init( handler : APIHandler)
    {
        self.init( handler : handler, cacheFlavour : .NO_CACHE )
    }
    
    private func authenticateRequest( completion : @escaping( ZCRMError? ) -> () )
    {
        self.addHeader( headerName : "User-Agent", headerVal : ZCRMSDKClient.shared.userAgent )
        if let headers = ZCRMSDKClient.shared.requestHeaders
        {
            do{
                for headerName in headers.keys
                {
                    if headers.hasValue( forKey : headerName )
                    {
                        self.addHeader( headerName : headerName, headerVal : try headers.getString( key : headerName ) )
                    }
                }
            }
            catch
            {
                ZCRMLogger.logDebug( message:"Error occured in authenticateRequest() >>> \(error)")
            }
        }
        if( ZCRMSDKClient.shared.appType == AppType.ZCRM.rawValue )
        {
            ZCRMSDKClient.shared.zcrmLoginHandler?.getOauth2Token { ( token, error ) in
                if let err = error
                {
                    completion(ZCRMError.SDKError(code: ErrorCode.OAUTH_FETCH_ERROR, message: err.description, details: nil))
                    return
                }
                if let oAuthtoken = token, token.notNilandEmpty
                {
                    self.addHeader( headerName : "Authorization", headerVal : "Zoho-oauthtoken \( oAuthtoken )" )
                    completion( nil )
                    return
                }
                else
                {
                    ZCRMLogger.logDebug( message: "oAuthtoken is nil." )
                    completion(ZCRMError.SDKError(code: ErrorCode.OAUTHTOKEN_NIL, message: ErrorMessage.OAUTHTOKEN_NIL_MSG, details: nil))
                }
            }
        }
        else
        {
            ZCRMSDKClient.shared.zcrmLoginHandler?.getOauth2Token { ( token, error ) in
                if( ZCRMSDKClient.shared.appType == AppType.ZCRMCP.rawValue  && self.headers.hasValue( forKey : "X-CRMPORTAL" ) == false )
                {
                    self.addHeader( headerName : "X-CRMPORTAL", headerVal : "SDKCLIENT" )
                }
                if let err = error
                {
                    completion(ZCRMError.SDKError(code: ErrorCode.OAUTH_FETCH_ERROR, message: err.description, details: nil))
                    return
                }
                if let oAuthtoken = token, token.notNilandEmpty
                {
                    self.addHeader( headerName : "Authorization", headerVal : "Zoho-oauthtoken \( oAuthtoken )")
                    completion( nil )
                    return
                }
                else
                {
                    print( "oAuthtoken is empty." )
                    completion(ZCRMError.SDKError(code: ErrorCode.OAUTHTOKEN_NIL, message: ErrorMessage.OAUTHTOKEN_NIL_MSG, details: nil))
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
            self.authenticateRequest { ( error ) in
                if let err = error
                {
                    ZCRMLogger.logError( message : "Error Occured : \( err )" )
                    completion( typeCastToZCRMError( err ) )
                    return
                }
                else
                {
                    if let myUrl = self.url
                    {
                        self.request = URLRequest(url: myUrl )
                        if self.requestMethod == RequestMethod.UNDEFINED
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.INVALID_OPERATION) : Invalid Request method!!!")
                            completion( ZCRMError.InValidError( code : ErrorCode.INVALID_OPERATION, message: "Invalid Request method!!!", details: nil ) )
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
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.INTERNAL_ERROR) : Unable to construct URLRequest")
                        completion(ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: "Unable to construct URLRequest", details : nil))
                        return
                    }
                }
            }
        }
        else
        {
            completion(nil)
        }
    }
    
    internal func getAPIResponse( completion : @escaping (Result.Response<APIResponse>) -> Void )
    {
        self.initialiseRequest { ( err ) in
            
            if let error = err
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
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
                                let response = try APIResponse( responseJSON : respJSON, responseJSONRootKey: self.jsonRootKey )
                                completion(.success(response))
                                return
                            }
                            catch
                            {
                                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                                completion(.failure( typeCastToZCRMError( error ) ) )
                                return
                            }
                        }
                        else
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_NIL_MSG)")
                            completion(.failure(ZCRMError.SDKError(code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG, details : nil)))
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
        self.makeRequest { ( urlResp, responseData, error ) in
            if let err = error
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
                completion(.failure(err))
                return
            }
            else if let urlResponse = urlResp
            {
                do
                {
                    if let respData = responseData
                    {
                        let response = try APIResponse( response : urlResponse, responseData : respData, responseJSONRootKey : self.jsonRootKey )
                        if !self.insertDataInDB(response: response, bulkResponse: nil)
                        {
                            ZCRMLogger.logDebug(message: "ZCRM SDK - Error occurred while inserting response into database.")
                        }
                        completion(.success(response))
                    }
                    else
                    {
                        let response = try APIResponse( response : urlResponse, responseJSONRootKey : self.jsonRootKey )
                        if !self.insertDataInDB(response: response, bulkResponse: nil)
                        {
                            ZCRMLogger.logDebug(message: "ZCRM SDK - Error occurred while inserting response into database.")
                        }
                        completion(.success(response))
                    }
                }
                catch
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion(.failure( typeCastToZCRMError( error ) ) )
                }
            }
            else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_NIL_MSG)")
                completion(.failure(ZCRMError.SDKError(code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG, details : nil)))
            }
        }
    }
    
    internal func getBulkAPIResponse( completion : @escaping(Result.Response<BulkAPIResponse>) -> () )
    {
        self.initialiseRequest { ( err ) in
            
            if let error = err
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
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
                                let response = try BulkAPIResponse( responseJSON : respJSON, responseJSONRootKey: self.jsonRootKey )
                                completion(.success(response))
                            }
                            catch
                            {
                                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                                completion(.failure( typeCastToZCRMError( error ) ) )
                            }
                        }
                        else
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_NIL_MSG)")
                            completion(.failure(ZCRMError.SDKError(code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG, details : nil)))
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
        self.makeRequest { ( urlResp, responseData, error ) in
            if let reqError = error
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( reqError )" )
                completion(.failure(reqError))
                return
            }
            else if let urlResponse = urlResp
            {
                do
                {
                    if let respData = responseData
                    {
                        let response = try BulkAPIResponse( response : urlResponse, responseData : respData, responseJSONRootKey : self.jsonRootKey )
                        if !self.insertDataInDB(response: nil, bulkResponse: response)
                        {
                            ZCRMLogger.logDebug(message: "ZCRM SDK - Error occurred while inserting response into database.")
                        }
                        completion(.success(response))
                    }
                    else
                    {
                        let response = try BulkAPIResponse( response : urlResponse, responseJSONRootKey : self.jsonRootKey )
                        if !self.insertDataInDB(response: nil, bulkResponse: response)
                        {
                            ZCRMLogger.logDebug(message: "ZCRM SDK - Error occurred while inserting response into database.")
                        }
                        completion(.success(response))
                    }
                }
                catch
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion(.failure( typeCastToZCRMError( error ) ) )
                }
            }
            else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_NIL_MSG)")
                completion(.failure(ZCRMError.SDKError(code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG, details : nil)))
            }
        }
    }
    
    // yet to return success & failure
    private func insertDataInDB( response : APIResponse?, bulkResponse : BulkAPIResponse? ) -> Bool
    {
        do
        {
            if self.cacheFlavour == CacheFlavour.FORCE_CACHE
            {
                guard let url = self.request?.url?.absoluteString else {
                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( ErrorCode.UNABLE_TO_CONSTRUCT_URL ) : Unable to fetch url string from urlrequest")
                    return false
                }
                if let resp = ( response != nil ? response : bulkResponse ), let respJSON = resp.getResponseJSON().toJSON()
                {
                    try ZCRMSDKClient.shared.getPersistentDB().insertData( withURL : url, data : respJSON, validity : DBConstant.VALIDITY_TIME )
                }
            }
            else if self.useCache() || (self.cacheFlavour == CacheFlavour.NO_CACHE && ZCRMSDKClient.shared.isDBCacheEnabled && self.isCacheable)
            {
                guard let url = self.request?.url?.absoluteString else {
                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( ErrorCode.UNABLE_TO_CONSTRUCT_URL ) : Unable to fetch url string from urlrequest")
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
    
    private func getResponseFromDB( completion : @escaping( Dictionary< String, Any>?, ZCRMError? ) -> Void )
    {
        guard let url = self.request?.url?.absoluteString else {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( ErrorCode.UNABLE_TO_CONSTRUCT_URL) :  Unable to fetch url string from urlrequest")
            completion( nil, ZCRMError.SDKError( code : ErrorCode.UNABLE_TO_CONSTRUCT_URL, message: "Unable to fetch url string from urlrequest", details : nil ) )
            return
        }
        if let cacheType = self.cacheFlavour
        {
            switch cacheType
            {
            case .URL_VS_RESPONSE :
                do
                {
                    if let responseFromDB = try ZCRMSDKClient.shared.getNonPersistentDB().fetchData( withURL : url )
                    {
                        completion( responseFromDB, nil )
                    }
                    else
                    {
                        completion( nil, ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message: ErrorMessage.DB_DATA_NOT_AVAILABLE, details : nil ) )
                    }
                }
                catch
                {
                    completion( nil, ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message: ErrorMessage.DB_DATA_NOT_AVAILABLE, details : nil ) )
                }
            case .FORCE_CACHE :
                do
                {
                    if let responseFromDB = try ZCRMSDKClient.shared.getPersistentDB().fetchData( withURL : url )
                    {
                        completion( responseFromDB, nil )
                    }
                    else
                    {
                        completion( nil, ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message: ErrorMessage.DB_DATA_NOT_AVAILABLE, details: nil ) )
                    }
                }
                catch
                {
                    completion( nil, ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message: ErrorMessage.DB_DATA_NOT_AVAILABLE, details: nil ) )
                }
                
            default :
                ZCRMLogger.logDebug(message: "Invalid cache type")
            }
        }
    }
    
    internal func makeRequest( completion : @escaping ( HTTPURLResponse?, Data?, ZCRMError? ) -> () )
    {
        if let request = self.request
        {
            APIRequest.configuration.timeoutIntervalForRequest = ZCRMSDKClient.shared.requestTimeout
            APIRequest.session.dataTask( with : request, completionHandler:{
                ( data, response, err ) in
                
                if let error = err
                {
                    let zcrmError = typeCastToZCRMError( error )
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( nil, nil, zcrmError )
                    return
                }
                if let urlResponse = response, let httpResponse = urlResponse as? HTTPURLResponse
                {
                    completion( httpResponse, data, nil )
                }
                else
                {
                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_NIL_MSG)")
                    completion(nil, nil, ZCRMError.SDKError(code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG, details : nil))
                }
            }).resume()
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.INTERNAL_ERROR) : Request is nil")
            completion(nil, nil, ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: "Request is nil", details : nil))
            return
        }
    }
    
    public func toString() -> String
    {
        var headers : [ String : String ] = self.headers
        if headers.hasKey( forKey : AUTHORIZATION )
        {
            headers[ AUTHORIZATION ] = "## ***** ##"
        }
        return "\( self.url?.absoluteString  ??  "nil" ) \n HEADERS : \( headers.description )"
    }
    
    private func useCache() -> Bool
    {
        return ( cacheFlavour.rawValue ==  CacheFlavour.FORCE_CACHE.rawValue || ( ZCRMSDKClient.shared.isDBCacheEnabled && cacheFlavour.rawValue != CacheFlavour.NO_CACHE.rawValue ) )
    }
 }

 struct ZCRMURLBuilder
 {
    let path : String
    var queryItems : [ URLQueryItem ]?
    
    var url : URL?{
        var components = URLComponents()
        components.scheme = "https"
        components.host = ZCRMSDKClient.shared.apiBaseURL
        components.path = path
        if self.queryItems?.isEmpty == false
        {
            components.queryItems = queryItems
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return components.url
    }
 }

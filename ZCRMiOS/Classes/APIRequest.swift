 //
 //  APIRequest.swift
 //  ZCRMiOS
 //
 //  Created by Vijayakrishna on 09/11/16.
 //  Copyright © 2016 zohocrm. All rights reserved.
 //
 
 import Foundation
 import MobileCoreServices
 
 internal extension URLSession {
    func dataTask(with request : URLRequest, completion : @escaping (Result.DataURLResponse<Data, HTTPURLResponse>) -> Void) -> URLSessionDataTask {
        return dataTask(with: request) { (data, response, error) in

            if let error = error {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
                return
            }
            
            guard let data = data else {
                return
            }
            
            guard let urlResponse = response, let httpResponse = urlResponse as? HTTPURLResponse else {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseNilMsg), \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.sdkError(code: ErrorCode.responseNil, message: ErrorMessage.responseNilMsg, details : nil) ) )
                return
            }
            
            completion( .success(data, httpResponse) )
        }
    }
    
    func uploadTask(with request : URLRequest, fromFile url : URL, completion : @escaping (Result.DataURLResponse<Data, HTTPURLResponse>) -> Void) -> URLSessionUploadTask {
        return uploadTask(with: request, fromFile: url) { (data, response, error) in
            if let error = error {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
                return
            }
            
            guard let data = data else {
                return
            }
            
            guard let urlResponse = response, let httpResponse = urlResponse as? HTTPURLResponse else {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseNilMsg), \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.sdkError( code: ErrorCode.responseNil, message: ErrorMessage.responseNilMsg, details : nil ) ) )
                return
            }
            
            completion( .success(data, httpResponse) )
        }
    }
    
    func downloadTask(with request : URLRequest, completion : @escaping (Result.DataURLResponse<Any, HTTPURLResponse>) -> Void) -> URLSessionDownloadTask {
        return downloadTask(with: request) { (tempLocalURL, response, error) in
            if let error = error {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
                return
            }
            
            guard let localURL = tempLocalURL else {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( ErrorCode.unableToConstructURL ) : \( ErrorMessage.unableToConstructURLMsg ), \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.sdkError(code: ErrorCode.unableToConstructURL, message: ErrorMessage.unableToConstructURLMsg, details: nil) ) )
                return
            }
            
            guard let urlResponse = response, let httpResponse = urlResponse as? HTTPURLResponse  else {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseNilMsg), \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.sdkError( code: ErrorCode.responseNil, message: ErrorMessage.responseNilMsg, details : nil ) ) )
                return
            }
            completion( .success(localURL, httpResponse) )
        }
    }
 }
 internal enum HTTPStatusCode : Int
 {
    case ok = 200
    case created = 201
    case accepted = 202
    case noContent = 204
    case movedPermanently = 301
    case movedTemporarily = 302
    case notModified = 304
    case badRequest = 400
    case authorizationError = 401
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case requestEntityTooLarge = 413
    case unsupportedMediaType = 415
    case tooManyRequest = 429
    case internalServerError = 500
    case badGateway = 502
    case unhandled
    
    init( statusCodeValue : Int )
    {
        if let code = HTTPStatusCode( rawValue: statusCodeValue )
        {
            self = code
        }
        else
        {
            ZCRMLogger.logInfo(message: "UNHANDLED -> HTTP status code : \( statusCodeValue )")
            self = .unhandled
        }
    }
 }
 
 internal let faultyStatusCodes : [HTTPStatusCode] = [HTTPStatusCode.authorizationError, HTTPStatusCode.badRequest, HTTPStatusCode.forbidden, HTTPStatusCode.internalServerError, HTTPStatusCode.methodNotAllowed, HTTPStatusCode.movedTemporarily, HTTPStatusCode.movedPermanently, HTTPStatusCode.requestEntityTooLarge, HTTPStatusCode.tooManyRequest, HTTPStatusCode.unsupportedMediaType, HTTPStatusCode.noContent, HTTPStatusCode.notFound, HTTPStatusCode.badGateway, HTTPStatusCode.unhandled, HTTPStatusCode.notModified]
 
 internal enum RequestMethod : String
 {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
    case undefined = "UNDEFINED"
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
    private var requestedModule : String?
    
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
        self.requestedModule = handler.getModuleName()
    }
    
    convenience init( handler : APIHandler)
    {
        self.init( handler : handler, cacheFlavour : .noCache )
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
        if( ZCRMSDKClient.shared.appType == AppType.zcrm )
        {
            ZCRMSDKClient.shared.zcrmLoginHandler?.getOauth2Token { ( token, error ) in
                if let err = error
                {
                    completion(ZCRMError.sdkError(code: ErrorCode.oauthFetchError, message: err.description, details: nil))
                    return
                }
                if let oAuthtoken = token, token.notNilandEmpty
                {
                    self.addHeader( headerName : "Authorization", headerVal : "Zoho-oauthtoken \( oAuthtoken )" )
                    ZCRMLogger.logError(message: "Request >>> \( self.toString() )")
                    ZCRMLogger.logError(message: "Access Token >>> \( oAuthtoken )")
                    completion( nil )
                    return
                }
                else
                {
                    ZCRMLogger.logDebug( message: "oAuthtoken is nil." )
                    completion(ZCRMError.sdkError(code: ErrorCode.oauthTokenNil, message: ErrorMessage.oauthTokenNilMsg, details: nil))
                }
            }
        }
        else
        {
            ZCRMSDKClient.shared.zvcrmLoginHandler?.getOauth2Token { ( token, error ) in
                if( ZCRMSDKClient.shared.appType == AppType.zcrmcp  && self.headers.hasValue( forKey : "X-CRMPORTAL" ) == false )
                {
                    self.addHeader( headerName : "X-CRMPORTAL", headerVal : "SDKCLIENT" )
                }
                if let err = error
                {
                    completion(ZCRMError.sdkError(code: ErrorCode.oauthFetchError, message: err.description, details: nil))
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
                    completion(ZCRMError.sdkError(code: ErrorCode.oauthTokenNil, message: ErrorMessage.oauthTokenNilMsg, details: nil))
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
                        if self.requestMethod == RequestMethod.undefined
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidOperation) : Invalid Request method!!!, \( APIConstants.DETAILS ) : -")
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
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.internalError) : Unable to construct URLRequest, \( APIConstants.DETAILS ) : -")
                        completion(ZCRMError.sdkError(code: ErrorCode.internalError, message: "Unable to construct URLRequest", details : nil))
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
                                let response = try APIResponse( responseJSON : respJSON, responseJSONRootKey: self.jsonRootKey, requestAPIName: self.requestedModule )
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
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseNilMsg), \( APIConstants.DETAILS ) : -")
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
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ))
                    return
                }
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion(.failure( typeCastToZCRMError( error ) ) )
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
                                let response = try BulkAPIResponse( responseJSON : respJSON, responseJSONRootKey: self.jsonRootKey, requestAPIName: self.requestedModule )
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
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseNilMsg), \( APIConstants.DETAILS ) : -")
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
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ))
                    return
                }
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion(.failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    // yet to return success & failure
    private func insertDataInDB( response : APIResponse?, bulkResponse : BulkAPIResponse? ) -> Bool
    {
        do
        {
            if self.cacheFlavour == CacheFlavour.forceCache
            {
                guard let url = self.request?.url?.absoluteString else {
                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( ErrorCode.unableToConstructURL ) : Unable to fetch url string from urlrequest")
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
                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( ErrorCode.unableToConstructURL ) : Unable to fetch url string from urlrequest")
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
                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( ErrorCode.unableToConstructURL ) : Unable to fetch url string from urlrequest")
                    return
                }
                try ZCRMSDKClient.shared.getPersistentDB().deleteData(withURL: url)
            }
            else if self.useCache() || (self.cacheFlavour == CacheFlavour.noCache && ZCRMSDKClient.shared.isDBCacheEnabled && self.isCacheable)
            {
                guard let url = self.request?.url?.absoluteString else {
                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( ErrorCode.unableToConstructURL ) : Unable to fetch url string from urlrequest")
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
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( ErrorCode.unableToConstructURL) :  Unable to fetch url string from urlrequest, \( APIConstants.DETAILS ) : -")
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
                            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
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
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ))
                return
            }
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.internalError) : Request is nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.sdkError(code: ErrorCode.internalError, message: "Request is nil", details : nil) ) )
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
        return ( cacheFlavour.rawValue ==  CacheFlavour.forceCache.rawValue || ( ZCRMSDKClient.shared.isDBCacheEnabled && cacheFlavour.rawValue != CacheFlavour.noCache.rawValue ) )
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

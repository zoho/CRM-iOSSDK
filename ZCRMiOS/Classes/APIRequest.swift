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
}

internal let faultyStatusCodes : [HTTPStatusCode] = [HTTPStatusCode.AUTHORIZATION_ERROR, HTTPStatusCode.BAD_REQUEST, HTTPStatusCode.FORBIDDEN, HTTPStatusCode.INTERNAL_SERVER_ERROR, HTTPStatusCode.METHOD_NOT_ALLOWED, HTTPStatusCode.MOVED_TEMPORARILY, HTTPStatusCode.MOVED_PERMANENTLY, HTTPStatusCode.REQUEST_ENTITY_TOO_LARGE, HTTPStatusCode.TOO_MANY_REQUEST, HTTPStatusCode.UNSUPPORTED_MEDIA_TYPE, HTTPStatusCode.NO_CONTENT, HTTPStatusCode.NOT_FOUND]

internal enum RequestMethod : String
{
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

 internal class APIRequest
 {
    private var baseUrl : String = "\( APIBASEURL )/crm/\( APIVERSION )"
    private var urlPath : String = ""
    private var requestMethod : RequestMethod
    private var headers : [String : String] = [String : String]()
    private var params : [String : String] = [String : String]()
    private var requestBody : Any?
    private var request : URLRequest?
    private var url : URL?
    private var isOAuth : Bool = true
    private var jsonRootKey = String()
    
    init( handler : APIHandler)
    {
        if let urlPath = handler.getUrlPath()
        {
            self.urlPath = urlPath
        }
        else if let url = handler.getUrl()
        {
            self.url = url
        }
        self.requestMethod = handler.getRequestMethod()
        self.params = handler.getRequestParams()
        self.headers = handler.getRequestHeaders()
        self.requestBody = handler.getRequestBody()
        self.isOAuth = handler.getRequestType()
        self.jsonRootKey = handler.getJSONRootKey()
    }
    
    
    private func authenticateRequest( completion : @escaping( ZCRMError? ) -> () )
    {
        if let bundleID = Bundle.main.bundleIdentifier
        {
            self.addHeader( headerName : "User-Agent", headerVal : "ZCRMiOS_\(bundleID)" )
        }
        else
        {
            self.addHeader( headerName : "User-Agent", headerVal : "ZCRMiOS_unknown_bundle" )
        }
        if( APPTYPE == "ZCRM" )
        {
            ZCRMLoginHandler().getOauth2Token { ( token, error ) in
                if let err = error
                {
                    completion(ZCRMError.SDKError(code: ErrorCode.OAUTH_FETCH_ERROR, message: err.description))
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
                    print( "oAuthtoken is nil." )
                    completion(ZCRMError.SDKError(code: ErrorCode.OAUTHTOKEN_NIL, message: ErrorMessage.OAUTHTOKEN_NIL_MSG))
                }
            }
        }
        else
        {
            ZVCRMLoginHandler().getOauth2Token { ( token, error ) in
                if( APPTYPE == "ZCRMCP" )
                {
                    self.addHeader( headerName : "X-CRMPORTAL", headerVal : "SDKCLIENT" )
                }
                if let err = error
                {
                    completion(ZCRMError.SDKError(code: ErrorCode.OAUTH_FETCH_ERROR, message: err.description))
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
                    completion(ZCRMError.SDKError(code: ErrorCode.OAUTHTOKEN_NIL, message: ErrorMessage.OAUTHTOKEN_NIL_MSG))
                }
            }
        }
    }
    
    
    private func addHeader(headerName : String, headerVal : String)
    {
        self.headers[headerName] = headerVal
    }
    
    private func initialiseRequest( completion : @escaping( ZCRMError? ) -> () )
    {
        if isOAuth == true
        {
            self.authenticateRequest { ( error ) in
                if let err = error
                {
                    print( "Error Occured : \( err.localizedDescription )" )
                    completion( err )
                }
                else
                {
                    if(!self.params.isEmpty)
                    {
                        self.urlPath += "?"
                        for (key, value) in self.params
                        {
                            self.urlPath += key + "=" + value + "&"
                        }
                        self.urlPath = String(self.urlPath.dropLast())
                    }
                    if ( self.url?.absoluteString == nil )
                    {
                        let urlString = self.baseUrl+self.urlPath
                        
                        let set = CharacterSet(charactersIn: " ").inverted
                        if let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: set)
                        {
                            let requestURL = URL(string: encodedURLString )
                            if let reqURL = requestURL
                            {
                                self.url = reqURL
                            }
                            else
                            {
                                completion(ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: "Unable to construct URL"))
                                return
                            }
                        }
                        else
                        {
                            completion(ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: "Adding percent encoding error occured"))
                        }
                    }
                    else
                    {
                        let urlSting = self.url!.absoluteString
                        self.url = URL( string : ( urlSting + self.urlPath ) )!
                    }
                    self.request = URLRequest(url: self.url!)
                    self.request?.httpMethod = self.requestMethod.rawValue
                    for (key, value) in self.headers
                    {
                        self.request?.setValue(value, forHTTPHeaderField: key)
                    }
                    if(self.requestBody != nil && (self.requestBody as! [ String : Any? ] ).isEmpty == false )
                    {
                        let reqBody = try? JSONSerialization.data(withJSONObject: self.requestBody!, options: [])
                        self.request?.httpBody = reqBody
                    }
                    completion( nil )
                }
            }
        } else {
            completion(nil)
        }
    }
    
    
    internal func getAPIResponse( completion : @escaping (Result.Response<APIResponse>) -> Void )
    {
        self.initialiseRequest { ( err ) in
            
            if let error = err
            {
                completion(.failure(error))
                return
            }
            else
            {
                self.makeRequest { ( urlResp, responseData, error ) in
                    if let err = error
                    {
                        completion(.failure(err))
                        return
                    }
                    else if let urlResponse = urlResp
                    {
                        do
                        {
                            let response = try APIResponse( response : urlResponse, responseData : responseData, responseJSONRootKey : self.jsonRootKey )
                            completion(.success(response))
                        }
                        catch
                        {
                            completion(.failure( typeCastToZCRMError( error ) ) )
                        }
                    }
                    else
                    {
                        completion(.failure(ZCRMError.SDKError(code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG)))
                    }
                }
            }
        }
    }
    
    internal func getBulkAPIResponse( completion : @escaping(Result.Response<BulkAPIResponse>) -> () )
    {
        self.initialiseRequest { ( err ) in
            if let initialiseReqError = err
            {
                completion(.failure(initialiseReqError))
            }
            else
            {
                self.makeRequest { ( urlResp, responseData, error ) in
                    if let reqError = error
                    {
                        completion(.failure(reqError))
                        return
                    }
                    else if let urlResponse = urlResp
                    {
                        do
                        {
                            let response = try BulkAPIResponse( response : urlResponse, responseData : responseData, responseJSONRootKey : self.jsonRootKey )
                            completion(.success(response))
                        }
                        catch
                        {
                            completion(.failure( typeCastToZCRMError( error ) ) )
                        }
                    }
                    else
                    {
                        completion(.failure(ZCRMError.SDKError(code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG)))
                    }
                }
            }
        }
    }

    internal func uploadLink( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        let boundary = APIConstants.BOUNDARY
        self.createMultipartRequest( bodyData : Data(), boundary : boundary )
        self.makeRequest { ( urlResp, responseData, error ) in
            if let err = error
            {
                completion( .failure( typeCastToZCRMError( err ) ) )
                return
            }
            else if let urlResponse = urlResp
            {
                do
                {
                    let response = try APIResponse( response : urlResponse, responseData : responseData, responseJSONRootKey : self.jsonRootKey )
                    completion( .success( response ) )
                }
                catch
                {
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
            else
            {
                completion( .failure( ZCRMError.SDKError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG ) ) )
            }
        }
    }

    internal func uploadFile( filePath : String, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        let fileURL = URL( fileURLWithPath : filePath )
        let boundary = APIConstants.BOUNDARY
        let httpBodyData = getFilePart( fileURL : fileURL, data : nil, fileName: nil, boundary : boundary )
        createMultipartRequest( bodyData : httpBodyData, boundary : boundary )
        self.makeRequest { ( urlResponse, responseData, error ) in
            if let err = error
            {
                completion( .failure( typeCastToZCRMError( err ) ) )
                return
            }
            else if let urlResp = urlResponse
            {
                do
                {
                    let response = try APIResponse( response : urlResp, responseData : responseData, responseJSONRootKey : self.jsonRootKey )
                    completion( .success( response ) )
                }
                catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
            else
            {
                completion( .failure( ZCRMError.SDKError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG ) ) )
            }
        }
    }
    
    internal func uploadFileWithData( fileName : String, data : Data, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        let boundary = APIConstants.BOUNDARY
        let httpBodyData = getFilePart( fileURL : nil, data : data, fileName : fileName, boundary : boundary )
        createMultipartRequest(bodyData: httpBodyData, boundary: boundary)
        self.makeRequest { ( urlResponse, responseData, error) in
            if let err = error
            {
                completion( .failure( typeCastToZCRMError( err ) ) )
                return
            }
            else if let urlResp = urlResponse
            {
                do
                {
                    let response = try APIResponse( response : urlResp, responseData : responseData, responseJSONRootKey : self.jsonRootKey )
                    completion( .success( response ) )
                }
                catch
                {
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
            else
            {
                completion( .failure( ZCRMError.SDKError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG ) ) )
                
            }
        }
    }
    
    private func makeRequest( completion : @escaping ( HTTPURLResponse?, Data?, ZCRMError? ) -> () )
    {
        if let request = self.request
        {
            URLSession.shared.dataTask( with : request, completionHandler:{
                ( data, response, err ) in
                
                if let error = err
                {
                    completion( nil, nil, ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: (error.description)) )
                    return
                }
                if let urlResponse = response, let httpResponse = urlResponse as? HTTPURLResponse
                {
                    completion( httpResponse, data, nil )
                }
                else
                {
                    completion(nil, nil, ZCRMError.SDKError(code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG))
                    return
                }
            }).resume()
        }
        else
        {
            completion(nil, nil, ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: "Request is nil"))
        }
    }
    
    private func createMultipartRequest( bodyData : Data, boundary : String )
    {
        var httpBodyData = bodyData
        httpBodyData.append( "\r\n--\(boundary)".data( using : String.Encoding.utf8 )! )
        
        self.initialiseRequest { ( error ) in
            if error == nil
            {
                self.request!.setValue( "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField : "Content-Type" )
                
                self.request!.setValue( "\(httpBodyData.count)", forHTTPHeaderField : "Content-Length" )
                self.request!.httpBody = httpBodyData
            }
        }
    }
    
    private func getFilePart( fileURL : URL?, data : Data?, fileName : String?, boundary : String ) -> Data
    {
        var filePartData : Data = Data()
        filePartData.append( "\r\n--\(boundary)\r\n".data( using : String.Encoding.utf8 )! )
        if let url = fileURL
        {
            filePartData.append( "Content-Disposition: form-data; name=\"file\"; filename=\"\(url.lastPathComponent)\"\r\n".data( using : String.Encoding.utf8 )! )
            filePartData.append( "Content-Type: \(getMimeTypeFor( fileURL : url ))\r\n\r\n".data( using : String.Encoding.utf8 )! )
            filePartData.append( try! Data( contentsOf : url ) )
        }
        if let fileData = data, let name = fileName
        {
            filePartData.append( "Content-Disposition: form-data; name=\"file\"; filename=\"\( name )\"\r\n".data( using : String.Encoding.utf8 )! )
            filePartData.append( "Content-Type: \(getMimeTypeFor( fileURL : URL(string : name)! ))\r\n\r\n".data( using : String.Encoding.utf8 )! )
            filePartData.append( fileData )
        }
        return filePartData
    }
    
    private func getMimeTypeFor( fileURL : URL ) -> String
    {
        let pathExtension = fileURL.pathExtension
        if let uniformTypeIdentifier = UTTypeCreatePreferredIdentifierForTag( kUTTagClassFilenameExtension, pathExtension as CFString, nil )?.takeRetainedValue()
        {
            if let mimeType = UTTypeCopyPreferredTagWithClass( uniformTypeIdentifier, kUTTagClassMIMEType )?.takeRetainedValue()
            {
                return mimeType as String
            }
        }
        return "application/octet-stream"
    }

    internal func downloadFile( completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        self.initialiseRequest { ( err ) in
            if let error = err
            {
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
            else
            {
                var error : Error?
                URLSession.shared.downloadTask(with: self.request!, completionHandler: { tempLocalUrl, response, err in
                    guard err == nil else
                    {
                        error = err
                        completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.INTERNAL_ERROR, message : ( error?.description )! ) ) )
                        return
                    }
                    if let fileResponse = response as? HTTPURLResponse, let localUrl = tempLocalUrl
                    {
                        do
                        {
                            let response = try FileAPIResponse( response : fileResponse, tempLocalUrl : localUrl )
                            completion( .success( response ) )
                        }
                        catch
                        {
                            completion( .failure( typeCastToZCRMError( error ) ) )
                        }
                    }
                    else
                    {
                        completion( .failure( ZCRMError.SDKError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG ) ) )
                    }
                }).resume()
            }
        }
    }
    
    public func toString() -> String
    {
        var headers : [ String : String ] = self.headers
        if headers.hasKey( forKey : "Authorization" )
        {
            headers[ "Authorization" ] = "## ***** ##"
        }
        var params : [ String : String ] = self.params
        if params.hasKey( forKey : "authtoken" )
        {
            params[ "authtoken" ] = "## ***** ##"
        }
        if( url?.absoluteString != nil )
        {
            return "URL : \( url!.absoluteString ), HEADERS : \( headers.description ) PARAMS : \( params.description )"
        }
        else
        {
            return "URL : \( self.baseUrl + self.urlPath ), HEADERS : \( headers.description ) PARAMS : \( params.description )"
        }
    }
}

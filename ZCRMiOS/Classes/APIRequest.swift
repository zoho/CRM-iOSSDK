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
    private var requestBody : [ String : Any ]?
    private var request : URLRequest?
    private var url : URL?
	private var isOAuth : Bool = true
	
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
	}
	
    private func authenticateRequest()
    {
        if( APPTYPE == "ZCRM" )
        {
            self.addHeader( headerName : "Authorization", headerVal : "Zoho-oauthtoken \( ZCRMLoginHandler().getOauth2Token() )" )
        }
        else
        {
            self.addHeader( headerName : "Authorization", headerVal : "Zoho-oauthtoken \( ZVCRMLoginHandler().getOauth2Token() )" )
        }
    }
    
    private func addHeader(headerName : String, headerVal : String)
    {
        self.headers[headerName] = headerVal
    }
    
    internal func addParam(paramName : String, paramVal : String)
    {
        self.params[paramName] = paramVal
    }
    
    internal func setRequestBody( body : [ String : Any ] )
    {
        self.requestBody = body
    }
    
    private func initialiseRequest()
    {
		if isOAuth == true
		{
			self.authenticateRequest()
		}
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
            self.url = URL(string: (self.baseUrl + self.urlPath))!
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
            request?.setValue(value, forHTTPHeaderField: key)
        }
		if(self.requestBody != nil && (self.requestBody as! [ String : Any? ] ).isEmpty == false )
        {
            let reqBody = try? JSONSerialization.data(withJSONObject: self.requestBody!, options: [])
            self.request?.httpBody = reqBody
        }
        print( "Request : \( self.toString() )" )
    }
    
    internal func getResponse() throws -> ([String : Any])
    {
        let sema = DispatchSemaphore(value: 0)
        self.initialiseRequest()
        var urlResponse : URLResponse?
        var responseData : Data?
        var error : Error? = nil
        URLSession.shared.dataTask(with: self.request!, completionHandler: { data, response, err in
            guard err == nil else
            {
                error = err
                return
            }
            responseData = data
            urlResponse = response
            sema.signal()
        }).resume()
        sema.wait()
        if error != nil
        {
            throw ZCRMSDKError.ProcessingError( "URLSession dataTask error : \( error!.description )" )
        }
        try self.checkForException(response: urlResponse, responseData: responseData)
        let jsonStr : Any? = try? JSONSerialization.jsonObject(with: responseData!, options: [])
        var responseJSON : [String : Any] = [String : Any]()
        if let tempJSON = jsonStr as? [String : Any]
        {
            responseJSON = tempJSON
        }
        return responseJSON
    }
    
    internal func getAPIResponse() throws -> APIResponse
    {
        let sema = DispatchSemaphore(value: 0)
        self.initialiseRequest()
        var urlResponse : HTTPURLResponse = HTTPURLResponse()
        var responseData : Data?
        var error : Error? = nil
        URLSession.shared.dataTask(with: self.request!, completionHandler: { data, response, err in
            responseData = data
            urlResponse = response as! HTTPURLResponse
            sema.signal()
        }).resume()
        sema.wait()
        if error != nil
        {
            throw ZCRMSDKError.ProcessingError( "URLSession dataTask error : \( error!.description )" )
        }
        return try APIResponse(response: urlResponse, responseData: responseData)
    }
    
    internal func getBulkAPIResponse() throws -> BulkAPIResponse
    {
        let sema = DispatchSemaphore(value: 0)
        self.initialiseRequest()
        var urlResponse : HTTPURLResponse = HTTPURLResponse()
        var responseData : Data?
        var error : Error?
        URLSession.shared.dataTask(with: self.request!, completionHandler: { data, response, err in
            guard err == nil else
            {
                error = err
                return
            }
            responseData = data
			urlResponse = response as! HTTPURLResponse
            sema.signal()
        }).resume()
        sema.wait()
        if error != nil
        {
            throw ZCRMSDKError.ProcessingError( "URLSession dataTask error : \( error!.description )" )
        }
        return try BulkAPIResponse(response: urlResponse, responseData: responseData)
    }
    
    internal func uploadLink() throws -> APIResponse
    {
        let boundary = BOUNDARY
        self.createMultipartRequest( bodyData : Data(), boundary : boundary )
        var urlResponse : HTTPURLResponse = HTTPURLResponse()
        var responseData : Data?
        let sema = DispatchSemaphore( value : 0 )
        var err : Error?
        URLSession.shared.dataTask( with : self.request!, completionHandler : { data, response, error in
            guard error == nil else
            {
                err = error
                return
            }
            responseData = data
            urlResponse = response as! HTTPURLResponse
            sema.signal()
        } ).resume()
        sema.wait()
        if err != nil {
            throw ZCRMSDKError.ProcessingError( "URLSession dataTask error : \( err!.description )" )
        }
        return try APIResponse( response : urlResponse, responseData : responseData )
    }
    
    internal func uploadFile( filePath : String ) throws -> APIResponse
    {
        let fileURL = URL( fileURLWithPath : filePath )
        let boundary = BOUNDARY
        let httpBodyData = getFilePart( fileURL : fileURL, boundary : boundary )
        createMultipartRequest( bodyData : httpBodyData, boundary : boundary )
        var urlResponse : HTTPURLResponse = HTTPURLResponse()
        var responseData : Data?
        let sema = DispatchSemaphore( value : 0 )
        var err : Error?
        URLSession.shared.dataTask( with : self.request!, completionHandler : { data, response, error in
            guard error == nil else
            {
                err = error
                return
            }
            responseData = data
            urlResponse = response as! HTTPURLResponse
            sema.signal()
        } ).resume()
        sema.wait()
        if err != nil {
            throw ZCRMSDKError.ProcessingError( "URLSession dataTask error : \( err!.description )" )
        }
        return try APIResponse( response : urlResponse, responseData : responseData )
    }
    
    private func createMultipartRequest( bodyData : Data, boundary : String )
    {
        var httpBodyData = bodyData
        httpBodyData.append( "\r\n--\(boundary)".data( using : String.Encoding.utf8 )! )
        
        self.initialiseRequest()
        self.request!.setValue( "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField : "Content-Type" )
        
        self.request!.setValue( "\(httpBodyData.count)", forHTTPHeaderField : "Content-Length" )
        self.request!.httpBody = httpBodyData
    }
    
    private func getFilePart( fileURL : URL, boundary : String ) -> Data
    {
        var filePartData : Data = Data()
        filePartData.append( "\r\n--\(boundary)\r\n".data( using : String.Encoding.utf8 )! )
        filePartData.append( "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data( using : String.Encoding.utf8 )! )
        filePartData.append( "Content-Type: \(getMimeTypeFor( fileURL : fileURL ))\r\n\r\n".data( using : String.Encoding.utf8 )! )
        filePartData.append( try! Data( contentsOf : fileURL ) )
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
    
    internal func downloadFile() throws -> FileAPIResponse
    {
        let sema = DispatchSemaphore(value: 0)
        self.initialiseRequest()
        var fileResponse : HTTPURLResponse?
        var localUrl : URL?
        var error : Error?
        URLSession.shared.downloadTask(with: self.request!, completionHandler: {tempLocalUrl, response, err in
            guard err == nil else
            {
                error = err
                return
            }
            fileResponse = response as? HTTPURLResponse
            localUrl = tempLocalUrl!
            sema.signal()
        }).resume()
        sema.wait()
        if error != nil
        {
            throw ZCRMSDKError.ProcessingError( "URLSession dataTask error : \( error!.description )" )
        }
        return try FileAPIResponse(response: fileResponse!, tempLocalUrl: localUrl!)
    }
    
    private func checkForException(response : URLResponse?, responseData : Data?) throws
    {
        let httpResponse = response as! HTTPURLResponse
        let responseCode : HTTPStatusCode = HTTPStatusCode(rawValue: httpResponse.statusCode)!
        if(faultyStatusCodes.contains(responseCode))
        {
            if(responseCode == HTTPStatusCode.NO_CONTENT)
            {
                throw ZCRMSDKError.InValidError("The given id seems to be invalid.")
            }
            else
            {
                let responseJSON = try? JSONSerialization.jsonObject(with: responseData!, options: [])
                let errJSON = (responseJSON as? [String:Any])!
                let errMsg : String = "\(errJSON["status"]!) - \(errJSON["message"]!)"
                throw ZCRMSDKError.ProcessingError(errMsg)
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
            return "URL : \( url!.absoluteString ), HEADERS : \( headers.description ) PARAMS : \( params.description ), METHOD : \( self.requestMethod.rawValue )"
        }
        else
        {
            return "URL : \( self.baseUrl + self.urlPath ), HEADERS : \( headers.description ) PARAMS : \( params.description ), METHOD : \( self.requestMethod.rawValue )"
        }
    }
    
    public func getRequestBodyString() -> String
    {
        return "BODY : \( self.requestBody.debugDescription )"
    }
}


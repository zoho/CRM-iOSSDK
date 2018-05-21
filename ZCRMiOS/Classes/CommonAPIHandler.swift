//
//  CommonAPIHandler.swift
// ZCRMiOS
//
//  Created by Sarath Kumar Rajendran on 16/04/18.
//

internal protocol APIHandler : class
{
	func getUrlPath() -> String?
	
	func getUrl() -> URL?
	
	func getRequestMethod() -> RequestMethod
	
	func getRequestHeaders() -> [ String : String ]
	
	func getRequestBody() -> [ String : Any ]
	
	func getRequestParams() -> [ String : String ]
	
	func getRequestType() -> Bool
	
}

internal class CommonAPIHandler : APIHandler
{

	private var url : URL?
	private var urlPath : String?
	private var requestMethod : RequestMethod?
	private var requestBody : [String : Any ] = [ String : Any ]()
	private var requestParams : [ String : String ] = [String : String]()
	private var requestHeaders : [ String : String ] = [String : String]()
	private var isOAuthRequest : Bool = true

	internal func setUrl( url : URL )
	{
		self.url = url
	}
	
	internal func getUrl() -> URL?
	{
		return self.url
	}
	
	internal func setUrlPath( urlPath : String )
	{
		self.urlPath = urlPath
	}
	
	internal func getUrlPath() -> String?
	{
		return self.urlPath
	}
	
	internal func setRequestMethod( requestMethod : RequestMethod )
	{
		self.requestMethod = requestMethod
	}
	
	internal func getRequestMethod() -> RequestMethod
	{
		return self.requestMethod!
	}
	
	internal func addRequestHeader( header : String , value : String)
	{
		self.requestHeaders[header] = value
	}
	
	internal func getRequestHeaders() -> [String : String]
	{
		return self.requestHeaders
	}
	
	internal func setRequestBody( requestBody : [ String : Any ] )
	{
		self.requestBody = requestBody
	}
	
	internal func getRequestBody() -> [String : Any]
	{
		return self.requestBody
	}
	
	internal func addRequestParam( param : String , value : String )
	{
		self.requestParams[param] = value
	}
	
	internal func getRequestParams() -> [String : String]
	{
		return self.requestParams
	}
	
	internal func setRequestType( isOAuthRequest : Bool )
	{
		self.isOAuthRequest = isOAuthRequest
	}
	internal func getRequestType() -> Bool
	{
		return self.isOAuthRequest
	}
}

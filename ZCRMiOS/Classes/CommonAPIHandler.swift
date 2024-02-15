//
//  CommonAPIHandler.swift
// ZCRMiOS
//
//  Created by Sarath Kumar Rajendran on 16/04/18.
//

internal protocol APIHandler : AnyObject
{
	func getUrlPath() -> String?
	
	func getUrl() -> URL?
	
	func getRequestMethod() -> ZCRMRequestMethod
	
	func getRequestHeaders() -> [ String : String ]
	
	func getRequestBody() -> [ String : Any? ]
	
	func getRequestType() -> Bool
    
    func getJSONRootKey() -> String
    
    func getIsCacheable() -> Bool
    
    func getIsForceCacheable() -> Bool
    
    func getModuleName() -> String?
    
    func getIsOrganizationsAPI() -> Bool
}

internal class CommonAPIHandler : APIHandler
{
	private var url : URL?
	private var urlPath : String?
    private var apiVersion : String = ZCRMSDKClient.shared.apiVersion
	private var requestMethod : ZCRMRequestMethod = .undefined
	private var requestBody : [String : Any? ] = [ String : Any? ]()
	private var requestParams : [ URLQueryItem ] = []
	private var requestHeaders : [ String : String ] = [String : String]()
	private var isOAuthRequest : Bool = true
    private var jsonRootKey : String = JSONRootKey.DATA  // most handlers use DATA as root key
    private var isCacheable : Bool = false
    private var isForceCacheable : Bool = false
    private var isEmail : Bool = false
    private var isBigin : Bool = false
    private var isOrganizationsAPI : Bool = false
    internal var requestedModule : String?
    
    init()
    {
        self.setModuleName()
    }
    
    func setModuleName() {}
    
    func getModuleName() -> String?
    {
        return requestedModule
    }
	
	internal func getUrl() -> URL?
	{
        if let path = self.urlPath
        {
            var urlBuilder : ZCRMURLBuilder
            if isEmail
            {
                urlBuilder = ZCRMURLBuilder(path: "/\(CRM)/\(EMAIL)/\( apiVersion )/\(path)", queryItems: self.getQueryItems())
            }
            else if isBigin
            {
                urlBuilder = ZCRMURLBuilder(path: "/\(BIGIN)/\( apiVersion )/\(path)", queryItems: self.getQueryItems())
            }
            else
            {
                urlBuilder = ZCRMURLBuilder(path: "/\(CRM)/\( apiVersion )/\(path)", queryItems: self.getQueryItems())
            }
            return urlBuilder.url
        }
        return nil
	}
    
    internal func getQueryItems() -> [ URLQueryItem ]
    {
        return requestParams
    }
	
	internal func setUrlPath( urlPath : String )
	{
		self.urlPath = urlPath
	}
	
	internal func getUrlPath() -> String?
	{
		return self.urlPath
	}
	
	internal func setRequestMethod( requestMethod : ZCRMRequestMethod )
	{
		self.requestMethod = requestMethod
	}
	
	internal func getRequestMethod() -> ZCRMRequestMethod
	{
		return self.requestMethod
	}
	
	internal func addRequestHeader( header : String , value : String)
	{
		self.requestHeaders[header] = value
	}
	
	internal func getRequestHeaders() -> [String : String]
	{
		return self.requestHeaders
	}
	
	internal func setRequestBody( requestBody : [ String : Any? ] )
	{
		self.requestBody = requestBody
	}
	
	internal func getRequestBody() -> [String : Any?]
	{
		return self.requestBody
	}
	
	internal func addRequestParam( param : String , value : String )
	{
        self.requestParams.append( URLQueryItem(name: param, value: value) )
	}
	
	internal func setRequestType( isOAuthRequest : Bool )
	{
		self.isOAuthRequest = isOAuthRequest
	}
	internal func getRequestType() -> Bool
	{
		return self.isOAuthRequest
	}
    
    internal func setJSONRootKey( key : String )
    {
        self.jsonRootKey = key
    }
    
    internal func getJSONRootKey() -> String {
        return self.jsonRootKey
    }
    
    internal func setIsCacheable( _ isCacheable : Bool )
    {
        self.isCacheable = isCacheable
    }
    
    internal func setIsForceCacheable( _ isForceCacheable : Bool )
    {
        self.isForceCacheable = isForceCacheable
    }
    
    internal func getIsCacheable() -> Bool
    {
        return self.isCacheable
    }
    
    internal func getIsForceCacheable() -> Bool
    {
        return self.isForceCacheable
    }
    
    internal func setIsEmail( _ isEmail : Bool )
    {
        self.isEmail = isEmail
    }
    
    internal func setIsBigin( _ isBigin : Bool )
    {
        self.isBigin = isBigin
    }
    
    internal func setAPIVersion( _ version : String )
    {
        self.apiVersion = version
    }
    
    internal func setIsOrganizationsAPI( _ isOrganizationsAPI : Bool )
    {
        self.isOrganizationsAPI = isOrganizationsAPI
    }
    
    internal func getIsOrganizationsAPI() -> Bool
    {
        return isOrganizationsAPI
    }
}

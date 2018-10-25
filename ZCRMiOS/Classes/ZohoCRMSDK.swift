//
//  ZohoCRMSDK.swift
//  ZCRMiOS
//
//  Created by Sarath Kumar Rajendran on 06/09/18.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import UIKit

public class ZohoCRMSDK {
	
	public static let shared = ZohoCRMSDK()
    public var userAgent : String = "ZCRMiOS_unknown_bundle"
    public var requestHeaders : Dictionary< String, String >?
	private var isVerticalCRM: Bool = false
	private var zcrmLoginHandler: ZCRMLoginHandler = ZCRMLoginHandler.init()
	private var zvcrmLoginHandler: ZVCRMLoginHandler = ZVCRMLoginHandler.init()
    private var crmAppConfigs : CRMAppConfigUtil!
	
	private init() {}
	
	private func clearFirstLaunch() {
		let alreadyLaunched = UserDefaults.standard.bool(forKey:"first")
		if !alreadyLaunched{
			if self.isVerticalCRM {
				self.zvcrmLoginHandler.clearIAMLoginFirstLaunch()
			} else {
				self.zcrmLoginHandler.clearIAMLoginFirstLaunch()
			}
			UserDefaults.standard.set(true, forKey: "first")
		}
	}
	
	public func handleUrl( url : URL, sourceApplication : String?, annotation : Any )
	{
		if self.isVerticalCRM
        {
			self.zvcrmLoginHandler.iamLoginHandleURL(url: url, sourceApplication: sourceApplication, annotation: annotation)
		}
        else
        {
			self.zcrmLoginHandler.iamLoginHandleURL(url: url, sourceApplication: sourceApplication, annotation: annotation)
		}
	}
	
    public func initialise( window : UIWindow, appType : String? =  nil, apiBaseURL : String? = nil, oauthScopes : [ Any ]? = nil, clientID : String? = nil, clientSecretID : String? = nil, redirectURLScheme : String? = nil, accountsURL : String? = nil, portalID : String? = nil ) throws
    {
        self.crmAppConfigs = CRMAppConfigUtil(appConfigDict: Dictionary< String, Any >() )
        if let file = Bundle.main.path(forResource : "AppConfiguration", ofType: "plist" )
        {
            if let appConfiguration = NSDictionary( contentsOfFile : file ) as? [String : Any]
            {
                crmAppConfigs = CRMAppConfigUtil( appConfigDict : appConfiguration )
                if let type = appType
                {
                    try self.handleAppType( appType : type, appConfigurations : crmAppConfigs )
                }
                else if let type = appConfiguration[ "Type" ] as? String
                {
                    try self.handleAppType( appType : type, appConfigurations : crmAppConfigs )
                }
                else
                {
                    throw ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : "appType is not specified" )
                }
            }
            else
            {
                throw ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: "AppConfiguration.plist has no data.")
            }
        }
        else
        {
            throw ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: "AppConfiguration.plist is not foud.")
        }
        if let baseURL = apiBaseURL
        {
            APIBASEURL = baseURL
        }
        if let type = appType
        {
            APPTYPE = type
            crmAppConfigs.setAppType(type: type)
        }
        if let scopes = oauthScopes
        {
            crmAppConfigs.setOauthScopes( scopes : scopes )
        }
        if let accountURL = accountsURL
        {
            crmAppConfigs.setAccountsURL( url : accountURL )
        }
        if let clientId = clientID
        {
            crmAppConfigs.setClientID( id : clientId )
        }
        if let clientSecretId = clientSecretID {
            crmAppConfigs.setClientSecretID(id: clientSecretId)
        }
        if let portalId = portalID
        {
            crmAppConfigs.setPortalID(id: portalId)
        }
        if let redirectURLScheme = redirectURLScheme {
            crmAppConfigs.setRedirectURLScheme(scheme: redirectURLScheme)
        }
        if let bundleID = Bundle.main.bundleIdentifier
        {
            self.userAgent = "ZCRMiOS_\(bundleID)"
        }

        self.initIAMLogin( appType : APPTYPE, window : window, apiBaseURL : apiBaseURL )
    }
    
    fileprivate func initIAMLogin( appType : String, window : UIWindow, apiBaseURL : String? )
    {
        if self.isVerticalCRM
        {
            self.zvcrmLoginHandler.initIAMLogin(window: window)
        }
        else
        {
            self.zcrmLoginHandler.initIAMLogin(window: window)
            guard let baseURL = apiBaseURL else
            {
                do
                {
                    self.zcrmLoginHandler.setAppConfigurations()
                    try self.zcrmLoginHandler.updateBaseURL( countryDomain : COUNTRYDOMAIN )
                    print( "Country Domain : \( COUNTRYDOMAIN )" )
                }
                catch
                {
                    print( "Error : \( error )" )
                }
                return
            }
            APIBASEURL = baseURL
        }
    }
    
    fileprivate func handleAppType( appType : String, appConfigurations : CRMAppConfigUtil ) throws
    {
        appConfigurations.setAppType( type : appType )
        do
        {
            if appType == "ZCRM"
            {
                self.zcrmLoginHandler = try ZCRMLoginHandler( appConfigUtil : appConfigurations )
            }
            else
            {
                self.zvcrmLoginHandler = try ZVCRMLoginHandler( appConfigUtil : appConfigurations )
                self.isVerticalCRM = true
            }
            self.clearFirstLaunch()
        }
        catch
        {
            throw ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: error.description)
        }
    }
	
	public func showLogin(completion: @escaping (Bool) -> ())
	{
		self.isUserSignedIn { (isUserSignedIn) in
			if isUserSignedIn
			{
				completion(true)
			}
			else
			{
				if self.isVerticalCRM
				{
					self.zvcrmLoginHandler.handleLogin { (success) in
						completion(success)
					}
				}
				else
				{
					self.zcrmLoginHandler.handleLogin(completion: { (success) in
						completion(success)
					})
				}
			}
		}
		
	}
	
	public func isUserSignedIn(completion: @escaping (Bool) -> ())
	{
		if self.isVerticalCRM
		{
			self.zvcrmLoginHandler.getOauth2Token { (token, error) in
				if error != nil
				{
					completion(false)
				} else {
					completion(true)
				}
			}
		}
		else
		{
			self.zcrmLoginHandler.getOauth2Token { (token, error) in
				if error != nil
				{
					completion(false)
				} else {
					completion(true)
				}
			}
		}
	}

	public func logout(completion: @escaping (Bool) -> ())
	{
		if self.isVerticalCRM
		{
			self.zvcrmLoginHandler.logout { (success) in
				completion(success)
			}
		}
		else
		{
			self.zcrmLoginHandler.logout { (success) in
				completion(success)
			}
		}
	}
    
    public func setAPIBaseURL( url : String )
    {
        APIBASEURL = url
    }
    
    public func setAppType( type : String )
    {
        APPTYPE = type
    }
    
    public func setAccountsURL( url : String )
    {
        self.crmAppConfigs.setAccountsURL( url : url )
    }
    
    public func getAPIBaseURL() -> String
    {
        return "\( APIBASEURL )/crm/\( APIVERSION )"
    }
    
    public func setPortalID( id : String )
    {
        self.crmAppConfigs.setPortalID( id : id )
    }
    
    public func transformAPIBaseURL( baseURL : String )
    {
        APIBASEURL = baseURL
    }
    
    public func setClientID( id : String )
    {
        self.crmAppConfigs.setClientID( id : id )
    }
    
    public func setClientSecretID( id : String )
    {
        self.crmAppConfigs.setClientSecretID( id : id )
    }
    
    public func setRedirectURLScheme( urlScheme : String )
    {
        self.crmAppConfigs.setRedirectURLScheme( scheme : urlScheme )
    }
    
}

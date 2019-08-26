//
//  LoginActivity.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 27/06/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class ZCRMLoginHandler
{
    private var appConfigurationUtil : CRMAppConfigUtil = CRMAppConfigUtil()
    private var accessType : String = String()
    private var configurationKeys : [ String ] = [ "DomainSuffix", "ApiVersion", "ClientID", "ClientSecretID", "RedirectURLScheme", "AccountsURL", "OAuthScopes", "AccessType", "LoginCustomization" ]
    public init(){}
    
    public init( appConfigUtil : CRMAppConfigUtil ) throws
    {
        self.appConfigurationUtil = appConfigUtil
        try self.validateAppConfigs( dict : appConfigUtil.getAppConfigurations() )
    }
    
    internal func validateAppConfigs( dict : Dictionary< String, Any > ) throws
    {
        if( dict.keys.count > 0 )
        {
            for key in configurationKeys
            {
                if( dict.keys.contains( key ) == false )
                {
                    throw ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : "\( key ) not present in the App configuration plist!", details: nil )
                }
            }
            for key in dict.keys
            {
                if( dict[ key ] == nil )
                {
                    throw ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : "\( key ) is nil. It should have value", details: nil )
                }
            }
        }
        else
        {
            throw ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : "App configuration property list is empty!", details: nil )
        }
    }
    
    public func initIAMLogin( window : UIWindow? )
    {
        do
        {
            self.setAppConfigurations()
            try self.updateBaseURL( countryDomain : COUNTRYDOMAIN )
            print( "Country Domain : \( COUNTRYDOMAIN )" )
            ZohoAuth.initWithClientID( try appConfigurationUtil.getClientID(), clientSecret : try appConfigurationUtil.getClientSecretID(), scope : try appConfigurationUtil.getAuthscopes(), urlScheme : try appConfigurationUtil.getRedirectURLScheme(), mainWindow : window, accountsURL : try appConfigurationUtil.getAccountsURL() )
            print( "redirectURL : \( try appConfigurationUtil.getRedirectURLScheme() )")
        }
        catch
        {
            print( "Error : \( error )" )
        }
        
    }
    
    internal func setAppConfigurations()
    {
        do
        {
            ZCRMSDKClient.shared.appType = appConfigurationUtil.getAppType()
            ZCRMSDKClient.shared.apiVersion = try appConfigurationUtil.getApiVersion()
            if( ZCRMSDKClient.shared.apiVersion.isEmpty == true )
            {
                ZCRMSDKClient.shared.apiVersion = "v2"
            }
                COUNTRYDOMAIN = try appConfigurationUtil.getCountryDomain()
                accessType = try appConfigurationUtil.getAccessType()
        }
        catch
        {
            print("Error occured > \(error)")
        }
    }
    
    internal func updateBaseURL( countryDomain : String ) throws
    {
        var domain : String = String()
        switch accessType
        {
        case AccessType.DEVELOPMENT.rawValue :
            domain = "developer"
            break
            
        case AccessType.SANDBOX.rawValue :
            domain = "sandbox"
            break
            
        default :
            domain = "www"
        }
        switch ( countryDomain )
        {
        case ( "com" ), ( "us" ) :
            ZCRMSDKClient.shared.apiBaseURL = "https://\( domain ).zohoapis.com"
            ACCOUNTSURL = "https://accounts.zoho.com"
            break
            
        case "eu" :
            ZCRMSDKClient.shared.apiBaseURL = "https://\( domain ).zohoapis.eu"
            ACCOUNTSURL = "https://accounts.zoho.eu"
            break
            
        case "cn" :
            ZCRMSDKClient.shared.apiBaseURL = "https://\( domain ).zohoapis.com.cn"
            ACCOUNTSURL = "https://accounts.zoho.com.cn"
            break
            
        default :
            print( "Country domain is invalid. \( domain )" )
            throw ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message :  "Country domain is invalid.", details: nil )
        }
        print( "API Base URL : \(ZCRMSDKClient.shared.apiBaseURL)")
    }
    
    public func clearIAMLoginFirstLaunch()
    {
        ZohoAuth.clearDetailsForFirstLaunch()
    }
    
    public func getBaseURL() -> String
    {
        return ZCRMSDKClient.shared.apiBaseURL
    }
    
    public func iamLoginHandleURL( url : URL, sourceApplication : String?, annotation : Any )
    {
        ZohoAuth.handleURL( url, sourceApplication :sourceApplication, annotation : annotation )
    }
    
    public func handleLogin( completion: @escaping ( Bool ) -> () )
    {
        ZohoAuth.presentZohoSign(inHavingCustomParams: getLoginScreenParams()) { (success, error) in
            if( error != nil )
            {
                switch( error!.code )
                {
                // SFSafari Dismissed
                case 205 :
                    print( "Error Detail : \( error!.description ), code : \( error!.code )" )
                    completion( false )
                    self.handleLogin( completion : { _ in
                        
                    })
                    break
                    
                // access_denied
                case 905 :
                    print( "Error Detail : \( error!.description ), code : \( error!.code )" )
                    completion( false )
                    self.handleLogin( completion : { _ in
                        
                    })
                    break
                    
                default :
                    completion( false )
                    print( "Error : \( error! )" )
                }
            }
            else
            {
                completion( true )
            }
        }
    }
    
    public func logout( completion : @escaping ( Bool ) -> () )
    {
        ZohoAuth.revokeAccessToken(
            { (error) in
                if( error != nil )
                {
                    print( "Error occured in removeAllScopesWithSuccess() : \(error!)" )
                    completion( false )
                }
                else
                {
                    self.clearIAMLoginFirstLaunch()
                    print( "removed AllScopesWithSuccess!" )
                    URLCache.shared.removeAllCachedResponses()
                    if let cookies = HTTPCookieStorage.shared.cookies {
                        for cookie in cookies {
                            HTTPCookieStorage.shared.deleteCookie( cookie )
                        }
                    }
                    if( self.appConfigurationUtil.isLoginCustomized() == false )
                    {
                        self.handleLogin( completion : { success in
                            if success == true
                            {
                                print( "login screen loaded successfully on Logout call!")
                            }
                        })
                    }
                    completion( true )
                    print( "logout ZCRM!" )
                }
        })
    }
    
    internal func getOauth2Token( completion : @escaping( String?, Error? ) -> () )
    {
        ZohoAuth.getOauth2Token { ( token, error ) in
            completion( token, error )
        }
    }
    
    internal func getLoginScreenParams() -> String
    {
        var loginScreenParams : String = ""
        do
        {
            let showSignUp = try appConfigurationUtil.getShowSignUp()
            if( appConfigurationUtil.getAppConfigurations().hasKey( forKey : "ShowSignUp" ) && showSignUp == "true" )
            {
                loginScreenParams = "hide_signup=false"
            }
            
            let portalID = try appConfigurationUtil.getPortalID()
            if( appConfigurationUtil.getAppConfigurations().hasKey( forKey : "PortalID" ) && portalID.isEmpty == false )
            {
                if( loginScreenParams != "" && !loginScreenParams.contains( "PortalID" ) )
                {
                    loginScreenParams = loginScreenParams + "&portal_id=" + portalID
                }
                else
                {
                    loginScreenParams = "portal_id=" + portalID
                }
            }
        }
        catch
        {
            print("Error occured in getLoginScreenParams() \(error)")
        }
        print( "login screen params = \( loginScreenParams )" )
        return loginScreenParams
    }
}

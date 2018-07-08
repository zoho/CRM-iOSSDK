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
                    throw ZCRMSDKError.InternalError( "\( key ) not present in the App configuration plist!" )
                }
            }
            for key in dict.keys
            {
                if( dict[ key ] == nil )
                {
                    throw ZCRMSDKError.InternalError( "\( key ) is nil. It should have value" )
                }
            }
        }
        else
        {
            throw ZCRMSDKError.InternalError( "App configuration property list is empty!" )
        }
    }
    
    public func initIAMLogin( window : UIWindow? )
    {
        do
        {
            self.setAppConfigurations()
            try self.updateBaseURL( countryDomain : COUNTRYDOMAIN )
            print( "Country Domain : \( COUNTRYDOMAIN )" )
        }
        catch
        {
            print( "Error : \( error )" )
        }
        
        ZohoAuth.initWithClientID( appConfigurationUtil.getClientID(), clientSecret : appConfigurationUtil.getClientSecretID(), scope : appConfigurationUtil.getAuthscopes(), urlScheme : appConfigurationUtil.getRedirectURLScheme(), mainWindow : window, accountsURL : appConfigurationUtil.getAccountsURL() )
        print( "redirectURL : \( appConfigurationUtil.getRedirectURLScheme() )")
    }
    
    private func setAppConfigurations()
    {
        APPTYPE = appConfigurationUtil.getAppType()
        APIVERSION = appConfigurationUtil.getApiVersion()
        if( APIVERSION.isEmpty == true )
        {
            APIVERSION = "v2"
        }
        COUNTRYDOMAIN = appConfigurationUtil.getCountryDomain()
        accessType = appConfigurationUtil.getAccessType()
    }
    
    private func updateBaseURL( countryDomain : String ) throws
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
            APIBASEURL = "https://\( domain ).zohoapis.com"
            break
            
        case "eu" :
            APIBASEURL = "https://\( domain ).zohoapis.eu"
            break
            
        case "cn" :
            APIBASEURL = "https://\( domain ).zohoapis.com.cn"
            break
            
        default :
            print( "Country domain is invalid. \( domain )" )
            throw ZCRMSDKError.InternalError( "Country domain is invalid." )
        }
        print( "API Base URL : \(APIBASEURL)")
    }
    
    public func clearIAMLoginFirstLaunch()
    {
        ZohoAuth.clearDetailsForFirstLaunch()
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
                    if( self.appConfigurationUtil.isLoginCustomized() == false )
                    {
                        self.handleLogin( completion : { _ in
                            
                        })
                    }
                    URLCache.shared.removeAllCachedResponses()
                    if let cookies = HTTPCookieStorage.shared.cookies {
                        for cookie in cookies {
                            HTTPCookieStorage.shared.deleteCookie( cookie )
                        }
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
        if( appConfigurationUtil.getAppConfigurations().hasKey( forKey : "ShowSignUp" ) && appConfigurationUtil.getShowSignUp() == "true" )
        {
            loginScreenParams = "hide_signup=false"
        }
        
        if( appConfigurationUtil.getAppConfigurations().hasKey( forKey : "PortalID" ) && appConfigurationUtil.getPortalID().isEmpty == false )
        {
            let portalID = appConfigurationUtil.getPortalID()
            if( loginScreenParams != "" && !loginScreenParams.contains( "PortalID" ) )
            {
                loginScreenParams = loginScreenParams + "&portal_id=" + portalID
            }
            else
            {
                loginScreenParams = "portal_id=" + portalID
            }
        }
        print( "login screen params = \( loginScreenParams )" )
        return loginScreenParams
    }
    
}

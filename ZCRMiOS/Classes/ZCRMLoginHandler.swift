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
    private var configurationKeys : [ String ] = [ "DomainSuffix", "ApiVersion", "ClientID", "ClientSecretID", "RedirectURLScheme", "AccountsURL", "OAuthScopes", "AccessType" ]
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
    
    public func loadIAMLoginView()
    {
        ZohoAuth.presentZohoSign(inHavingCustomParams: getLoginScreenParams()) { (success, error) in
            if( error != nil )
            {
                switch( error!.code )
                {
                // SFSafari Dismissed
                case 205 :
                    print( "Error Detail : \( error!.description ), code : \( error!.code )" )
                    self.loadIAMLoginView()
                    break
                    
                // access_denied
                case 905 :
                    print( "Error Detail : \( error!.description ), code : \( error!.code )" )
                    self.loadIAMLoginView()
                    break
                    
                default :
                    print( "Error : \( error! )" )
                }
            }
        }
    }
    
    public func logout()
    {
        ZohoAuth.revokeAccessToken(
            { (error) in
                if( error != nil )
                {
                    print( "Error occured in removeAllScopesWithSuccess() : \(error!)" )
                }
                else
                {
                    self.clearIAMLoginFirstLaunch()
                    print( "removed AllScopesWithSuccess!" )
                    self.loadIAMLoginView()
                    URLCache.shared.removeAllCachedResponses()
                    if let cookies = HTTPCookieStorage.shared.cookies {
                        for cookie in cookies {
                            HTTPCookieStorage.shared.deleteCookie(cookie)
                        }
                    }
                }
        })
        print( "logout ZCRM!" )
    }
    
    internal func getOauth2Token() -> String
    {
        var oAuth2Token : String = String()
        
        ZohoAuth.getOauth2Token { (accessToken, error) in
            if( accessToken == nil )
            {
                print( "Unable to get oAuthToken!" )
            }
            else
            {
                oAuth2Token = accessToken!
                print( "Got the oAuthtoken!" )
            }
            if( error != nil )
            {
                print( "Error occured in getOauth2Token(): \(error!)" )
            }
        }
        return oAuth2Token
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

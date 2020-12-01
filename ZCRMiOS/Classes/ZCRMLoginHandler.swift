//
//  LoginActivity.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 27/06/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation
import UIKit

public class ZCRMLoginHandler : ZohoAuthProvider
{
    private var appConfigurationUtil : Dictionary < String, Any > = Dictionary < String, Any >()
    private var accessType : String = String()
    private var configurationKeys : [ String ] = [ "DomainSuffix", "ApiVersion", "ClientID", "ClientSecretID", "RedirectURLScheme", "AccountsURL", "OAuthScopes", "AccessType", "LoginCustomization" ]
    public init(){}
    
    public init( appConfigUtil : Dictionary < String, Any > ) throws
    {
        self.appConfigurationUtil = appConfigUtil
        try self.validateAppConfigs( dict : appConfigUtil )
    }
    
    internal func validateAppConfigs( dict : Dictionary< String, Any > ) throws
    {
        if( dict.keys.count > 0 )
        {
            for key in configurationKeys
            {
                if( dict.keys.contains( key ) == false )
                {
                    throw ZCRMError.sdkError( code : ErrorCode.internalError, message : "\( key ) not present in the App configuration plist!", details: nil )
                }
            }
            for key in dict.keys
            {
                if( dict[ key ] == nil )
                {
                    throw ZCRMError.sdkError( code : ErrorCode.internalError, message : "\( key ) is nil. It should have value", details: nil )
                }
            }
        }
        else
        {
            throw ZCRMError.sdkError( code : ErrorCode.internalError, message : "App configuration property list is empty!", details: nil )
        }
    }
    
    public func initIAMLogin( window : UIWindow? )
    {
        do
        {
            self.setAppConfigurations()
            ZCRMLogger.logDebug( message: "Country Domain : \( COUNTRYDOMAIN )" )
            ZohoAuth.initWithClientID( try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.clientId ), clientSecret : try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.clientSecretId ), scope : try appConfigurationUtil.getArray( key : CRMAppConfigurationKeys.oAuthScopes ), urlScheme : try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.redirectURLScheme ), mainWindow : window, accountsURL : try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.accountsURL ) )
            ZCRMLogger.logDebug( message: "redirectURL : \( try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.redirectURLScheme ) )")
        }
        catch
        {
            ZCRMLogger.logDebug( message: "Error occured in ZCRMLoginHandler.initIAMLogin() : \( error )" )
        }
        
    }
    
    internal func setAppConfigurations()
    {
        do
        {
            ZCRMSDKClient.shared.apiVersion = try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.apiVersion )
            if( ZCRMSDKClient.shared.apiVersion.isEmpty == true )
            {
                ZCRMSDKClient.shared.apiVersion = "v2"
            }
            COUNTRYDOMAIN = try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.countryDomain )
            accessType = try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.accessType )
        }
        catch
        {
            ZCRMLogger.logDebug( message:"Error occured in ZCRMLoginHandler.setAppConfigurations(). Details : \(error)")
        }
    }
    
    internal func updateBaseURL( countryDomain : String ) throws
    {
        var domain : String = String()
        switch accessType
        {
        case AccessType.development.rawValue :
            domain = "developer"
            break
            
        case AccessType.sandBox.rawValue :
            domain = "sandbox"
            break
            
        default :
            domain = "www"
        }
        switch ( countryDomain )
        {
        case ( "com" ), ( "us" ) :
            ZCRMSDKClient.shared.apiBaseURL = "\( domain ).zohoapis.com"
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
            
        case "in" :
            ZCRMSDKClient.shared.apiBaseURL = "https://\( domain ).zohoapis.in"
            ACCOUNTSURL = "https://accounts.zoho.in"
            break
            
        case "au" :
            ZCRMSDKClient.shared.apiBaseURL = "https://\( domain ).zohoapis.com.au"
            ACCOUNTSURL = "https://accounts.zoho.com.au"
            break
            
        default :
            ZCRMLogger.logDebug( message:  "Country domain is invalid. \( domain )" )
            throw ZCRMError.sdkError( code : ErrorCode.internalError, message :  "Country domain is invalid.", details: nil )
        }
        ZCRMLogger.logDebug( message: "API Base URL : \(ZCRMSDKClient.shared.apiBaseURL)")
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
    
    public func handleLogin( completion: @escaping ( ZCRMError? ) -> () )
    {
        ZohoAuth.presentZohoSign(inHavingCustomParams: self.getLoginScreenParams()) { (success, error) in
            if let error = error
            {
                switch( error.code )
                {
                    // SFSafari Dismissed
                    case 205 :
                        ZCRMLogger.logDebug( message: "Login view dismissed. Detail : \( error.description ), code : \( error.code )" )
                        completion( typeCastToZCRMError( error ) )
                        break
                        
                    // access_denied
                    case 905 :
                        ZCRMLogger.logDebug( message: "User denied the access : \( error.description ), code : \( error.code )" )
                        completion( typeCastToZCRMError( error ) )
                        break
                        
                    default :
                        completion( typeCastToZCRMError( error ) )
                        ZCRMLogger.logDebug( message: "Error occured while present sign in page. Detail : \( error )" )
                }
            }
            else
            {
                completion( nil )
            }
        }
    }
    
    public func logout( completion : @escaping ( ZCRMError? ) -> () )
    {
        do
        {
            try ZCRMSDKClient.shared.clearAllCache()
            ZohoAuth.revokeAccessToken( { ( error ) in
                if let error = error
                {
                    ZCRMLogger.logDebug( message: "Error occured in removeAllScopesWithSuccess() : \(error)" )
                    completion( typeCastToZCRMError( error ) )
                }
                else
                {
                    self.clearIAMLoginFirstLaunch()
                    ZCRMLogger.logDebug( message: "removed AllScopesWithSuccess!" )
                    ZCRMSDKClient.shared.requestHeaders?.removeAll()
                    URLCache.shared.removeAllCachedResponses()
                    
                    ZCRMSDKClient.shared.portalId = nil
                    if let cookies = HTTPCookieStorage.shared.cookies {
                        for cookie in cookies {
                            HTTPCookieStorage.shared.deleteCookie( cookie )
                        }
                    }
                    completion( nil )
                    ZCRMLogger.logDebug( message: "logout ZCRM!" )
                }
            } )
        }
        catch
        {
            completion( typeCastToZCRMError( error ) )
        }
    }
    
    internal func getLoginScreenParams() -> String
    {
        var loginScreenParams : String = ""
        do
        {
            let showSignUp = try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.showSignUp )
            if( showSignUp == "true" )
            {
                loginScreenParams = "hide_signup=false"
            }
            
            if let portalID = appConfigurationUtil.optString( key : CRMAppConfigurationKeys.portalId )
            {
                if portalID.isEmpty == false
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
        }
        catch
        {
            ZCRMLogger.logDebug( message : "Error occured in getLoginScreenParams() \( error )" )
        }
        ZCRMLogger.logDebug( message : "login screen params = \( loginScreenParams )" )
        return loginScreenParams
    }
    
    public func getAccessToken( completion : @escaping ( ResultType.Data< String > ) -> () )
    {
        ZohoAuth.getOauth2Token { ( token, error ) in
            if let error = error
            {
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
            else if let token = token
            {
                completion( .success( token ) )
            }
        }
    }
}

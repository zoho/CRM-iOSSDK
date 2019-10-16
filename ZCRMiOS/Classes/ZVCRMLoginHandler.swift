//
//  LoginZVCRMActivity.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 27/11/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class ZVCRMLoginHandler
{
    private var appConfigurationUtil : CRMAppConfigUtil = CRMAppConfigUtil()
    private var configurationKeys : [ String ] = [ "ClientID", "ClientSecretID", "AccountsURL", "PortalID", "OAuthScopes", "RedirectURLScheme", "ApiBaseURL", "ApiVersion" ]

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
        do {
            ZCRMSDKClient.shared.appType = appConfigurationUtil.getAppType()
            ZCRMSDKClient.shared.apiBaseURL = try appConfigurationUtil.getApiBaseURL()
            ZCRMSDKClient.shared.apiVersion = try appConfigurationUtil.getApiVersion()
            
            ZohoPortalAuth.initWithClientID( try appConfigurationUtil.getClientID(), clientSecret : try appConfigurationUtil.getClientSecretID(), portalID : try appConfigurationUtil.getPortalID(), scope : try appConfigurationUtil.getAuthscopes(), urlScheme : try appConfigurationUtil.getRedirectURLScheme(), mainWindow : window, accountsPortalURL : try appConfigurationUtil.getAccountsURL()  )
        }
        catch
        {
            ZCRMLogger.logDebug( message:"Error occured in ZVCRMLoginHandler.initIAMLogin(). Details -> \(error)")
        }
        
    }

    public func handleLogin( completion : @escaping( Bool ) -> () )
    {
        ZohoPortalAuth.presentZohoPortalSign { ( success, error ) in
            if( error != nil )
            {
                switch( error!.code )
                {
                // SFSafari Dismissed
                case 205 :
                    ZCRMLogger.logDebug( message: "Login view dismissed. Detail : \( error!.description ), code : \( error!.code )" )
                    completion( false )
                    break

                // access_denied
                case 905 :
                    ZCRMLogger.logDebug( message: "User denied the access. Detail : \( error!.description ), code : \( error!.code )" )
                    completion( false )
                    break

                default :
                    completion( false )
                    ZCRMLogger.logDebug( message: "Error occured while present login screen. Details : \( error! )" )
                }
            }
            else
            {
                completion( true )
            }
        }
    }

    public func iamLoginHandleURL( url : URL, sourceApplication : String?, annotation : Any )
    {
        ZohoPortalAuth.handleURL( url, sourceApplication : sourceApplication, annotation : annotation )
    }

    internal func getOauth2Token( completion : @escaping( String?, Error? ) -> () )
    {
        ZohoPortalAuth.getOauth2Token { ( token, error ) in
            completion( token, error )
        }
    }

    public func clearIAMLoginFirstLaunch()
    {
        ZohoPortalAuth.clearZohoAuthPortalDetailsForFirstLaunch()
    }

    public func logout( completion : @escaping ( Bool ) -> () )
    {
        ZohoPortalAuth.revokeAccessToken(
            { ( error ) in
                if( error != nil )
                {
                    ZCRMLogger.logDebug( message: "Error occured in logout() : \(error!)" )
                    completion( false )
                }
                else
                {
                    self.clearIAMLoginFirstLaunch()
                    URLCache.shared.removeAllCachedResponses()
                    ZCRMLogger.logDebug( message: "removed AllScopesWithSuccess!" )
                    ZCRMSDKClient.shared.clearAllCache()
//                    self.handleLogin( completion : { _ in
//
//                    })
                    ZCRMSDKClient.shared.requestHeaders?.removeAll()
                    URLCache.shared.removeAllCachedResponses()
                    if let cookies = HTTPCookieStorage.shared.cookies {
                        for cookie in cookies {
                            HTTPCookieStorage.shared.deleteCookie(cookie)
                        }
                    }
                    completion( true )
                    ZCRMLogger.logDebug( message: "logout ZVCRM successful!" )
                }
        })
    }
}

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
        APPTYPE = appConfigurationUtil.getAppType()
        APIBASEURL = appConfigurationUtil.getApiBaseURL()
        APIVERSION = appConfigurationUtil.getApiVersion()

        ZohoPortalAuth.initWithClientID( appConfigurationUtil.getClientID(), clientSecret : appConfigurationUtil.getClientSecretID(), portalID : appConfigurationUtil.getPortalID(), scope : appConfigurationUtil.getAuthscopes(), urlScheme : appConfigurationUtil.getRedirectURLScheme(), mainWindow : window, accountsPortalURL : appConfigurationUtil.getAccountsURL()  )
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

    public func iamLoginHandleURL( url : URL, sourceApplication : String?, annotation : Any )
    {
        ZohoPortalAuth.handleURL( url, sourceApplication : sourceApplication, annotation : annotation )
    }

    internal func getOauth2Token() -> String
    {
        var oAuth2Token : String = String()
        ZohoPortalAuth.getOauth2Token { ( accessToken, error ) in
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
                    print( "Error occured in logout() : \(error!)" )
                    completion( false )
                }
                else
                {
                    self.clearIAMLoginFirstLaunch()
                    print( "removed AllScopesWithSuccess!" )
                    self.handleLogin( completion : { _ in
                            
                    })
                    URLCache.shared.removeAllCachedResponses()
                    if let cookies = HTTPCookieStorage.shared.cookies {
                        for cookie in cookies {
                            HTTPCookieStorage.shared.deleteCookie(cookie)
                        }
                    }
                    completion( true )
                    print( "logout ZVCRM successful!" )
                }
        })
    }
    
}

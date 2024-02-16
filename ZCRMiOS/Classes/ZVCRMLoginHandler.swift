//
//  LoginZVCRMActivity.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 27/11/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

internal class ZVCRMLoginHandler : ZohoAuthProvider
{
    private var appConfiguration : ZCRMSDKConfigs

    init( appConfiguration : ZCRMSDKConfigs ) throws
    {
        self.appConfiguration = appConfiguration
    }

    func initIAMLogin( window : UIWindow? ) throws
    {
        ZCRMSDKClient.shared.apiBaseURL = appConfiguration.apiBaseURL
        ZCRMSDKClient.shared.apiVersion = appConfiguration.apiVersion
        
        ZohoPortalAuth.initWithClientID( appConfiguration.clientId, clientSecret : appConfiguration.clientSecret, portalID : appConfiguration.portalId, scope : appConfiguration.oauthScopes, urlScheme : appConfiguration.redirectURLScheme, mainWindow : window, accountsPortalURL : appConfiguration.accountsURL )
    }

    func handleLogin( completion : @escaping( ZCRMError? ) -> () )
    {
        ZohoPortalAuth.presentZohoPortalSign { ( success, error ) in
            if let error = error
            {
                switch( error.code )
                {
                // SFSafari Dismissed
                case 205 :
                    ZCRMLogger.logError(message: "Error Detail : \( error.description ), code : \( error.code )")
                    completion( typeCastToZCRMError( error ) )
                    break

                // access_denied
                case 905 :
                    ZCRMLogger.logError(message: "Error Detail : \( error.description ), code : \( error.code )")
                    completion( typeCastToZCRMError( error ) )
                    break

                default :
                    ZCRMLogger.logError(message: "Error : \( error )")
                    completion( typeCastToZCRMError( error ) )
                }
            }
            else
            {
                completion( nil )
            }
        }
    }

    func iamLoginHandleURL( url : URL, sourceApplication : String?, annotation : Any )
    {
        ZohoPortalAuth.handleURL( url, sourceApplication : sourceApplication, annotation : annotation )
    }

    func clearIAMLoginFirstLaunch()
    {
        ZohoPortalAuth.clearZohoAuthPortalDetailsForFirstLaunch()
    }

    func logout( completion : @escaping ( ZCRMError? ) -> () )
    {
        do
        {
            try ZCRMSDKClient.shared.clearAllCache(isLogoutAction: true)
            ZohoPortalAuth.revokeAccessToken(
                { ( error ) in
                    if let error = error
                    {
                        ZCRMLogger.logError(message: "Error occured in logout() : \( error )")
                        completion( typeCastToZCRMError( error ) )
                    }
                    else
                    {
                        self.clearIAMLoginFirstLaunch()
                        ZCRMLogger.logDebug(message: "removed AllScopesWithSuccess!")
                        ZCRMSDKClient.shared.requestHeaders?.removeAll()
                        URLCache.shared.removeAllCachedResponses()
                        if let cookies = HTTPCookieStorage.shared.cookies {
                            for cookie in cookies {
                                HTTPCookieStorage.shared.deleteCookie(cookie)
                            }
                        }
                        ZCRMLogger.logDebug(message: "Logout ZVCRM successful!")
                        completion( nil )
                    }
            })
        }
        catch
        {
            completion( typeCastToZCRMError( error ) )
        }
    }
    
    func getAccessToken( completion : @escaping ( ZCRMResult.Data< String > ) -> () )
    {
        ZohoPortalAuth.getOauth2Token { ( token, error ) in
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

//
//  LoginActivity.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 27/06/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation
import UIKit

internal class ZCRMLoginHandler : ZohoAuthProvider
{
    private var appConfiguration : ZCRMSDKConfigs
    
    init( appConfiguration : ZCRMSDKConfigs ) throws
    {
        self.appConfiguration = appConfiguration
    }
    
    func initIAMLogin( window : UIWindow? ) throws
    {
        ZCRMLogger.logDebug( message: "Country Domain : \( COUNTRYDOMAIN )" )
        ZohoAuth.initWithClientID( appConfiguration.clientId, clientSecret : appConfiguration.clientSecret, scope : appConfiguration.oauthScopes, urlScheme : appConfiguration.redirectURLScheme, mainWindow : window, accountsURL : appConfiguration.accountsURL )
        ZCRMLogger.logDebug( message: "redirectURL : \( appConfiguration.redirectURLScheme )")
    }
    
    func clearIAMLoginFirstLaunch()
    {
        ZohoAuth.clearDetailsForFirstLaunch()
    }
    
    func getBaseURL() -> String
    {
        return ZCRMSDKClient.shared.apiBaseURL
    }
    
    func iamLoginHandleURL( url : URL, sourceApplication : String?, annotation : Any )
    {
        ZohoAuth.handleURL( url, sourceApplication :sourceApplication, annotation : annotation )
    }
    
    func handleLogin( completion: @escaping ( ZCRMError? ) -> () )
    {
        ZohoAuth.presentZohoSign(inHavingCustomParams: self.getLoginScreenParams()) { (success, error) in
            if let error = error
            {
                switch error.code
                {
                    // SFSafari Dismissed
                    case 205 :
                        ZCRMLogger.logError( message: "Login view dismissed. Detail : \( error.description ), code : \( error.code )" )
                        completion( typeCastToZCRMError( error ) )
                        break
                        
                    // access_denied
                    case 905 :
                        ZCRMLogger.logError( message: "User denied the access : \( error.description ), code : \( error.code )" )
                        completion( typeCastToZCRMError( error ) )
                        break
                        
                    default :
                        ZCRMLogger.logError( message: "Error occured while present sign in page. Detail : \( error )" )
                        completion( typeCastToZCRMError( error ) )
                }
            }
            else
            {
                completion( nil )
            }
        }
    }
    
    func logout( completion : @escaping ( ZCRMError? ) -> () )
    {
        do
        {
            try ZCRMSDKClient.shared.clearAllCache(isLogoutAction: true)
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

                    ZCRMSDKClient.shared.organizationId = nil
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
    
    func getLoginScreenParams() -> String
    {
        var loginScreenParams : String = ""
        if appConfiguration.showSignUp
        {
            loginScreenParams = "hide_signup=false"
        }
        
        if let portalID = appConfiguration.portalId
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
        ZCRMLogger.logDebug( message : "login screen params = \( loginScreenParams )" )
        return loginScreenParams
    }
    
    func getAccessToken( completion : @escaping ( ZCRMResult.Data< String > ) -> () )
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

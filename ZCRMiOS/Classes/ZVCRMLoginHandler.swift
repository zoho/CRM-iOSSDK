//
//  LoginZVCRMActivity.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 27/11/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class ZVCRMLoginHandler : ZohoAuthProvider
{
    private var appConfigurationUtil : Dictionary < String, Any > = Dictionary < String, Any >()
    private var configurationKeys : [ String ] = [ "ClientID", "ClientSecretID", "AccountsURL", "PortalID", "OAuthScopes", "RedirectURLScheme", "ApiBaseURL", "ApiVersion" ]

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
            ZCRMSDKClient.shared.apiBaseURL = try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.apiBaseURL )
            ZCRMSDKClient.shared.apiVersion = try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.apiVersion )
            
            ZohoPortalAuth.initWithClientID( try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.clientId ), clientSecret : try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.clientSecretId ), portalID : try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.portalId ), scope : try appConfigurationUtil.getArray( key : CRMAppConfigurationKeys.oAuthScopes ), urlScheme : try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.redirectURLScheme ), mainWindow : window, accountsPortalURL : try appConfigurationUtil.getString( key : CRMAppConfigurationKeys.accountsURL )  )
        }
        catch
        {
            print("Error occured initIAMLogin() -> \(error)")
        }
        
    }

    public func handleLogin( completion : @escaping( ZCRMError? ) -> () )
    {
        ZohoPortalAuth.presentZohoPortalSign { ( success, error ) in
            if let error = error
            {
                switch( error.code )
                {
                // SFSafari Dismissed
                case 205 :
                    print( "Error Detail : \( error.description ), code : \( error.code )" )
                    completion( typeCastToZCRMError( error ) )
                    break

                // access_denied
                case 905 :
                    print( "Error Detail : \( error.description ), code : \( error.code )" )
                    completion( typeCastToZCRMError( error ) )
                    break

                default :
                    completion( typeCastToZCRMError( error ) )
                    print( "Error : \( error )" )
                }
            }
            else
            {
                completion( nil )
            }
        }
    }

    public func iamLoginHandleURL( url : URL, sourceApplication : String?, annotation : Any )
    {
        ZohoPortalAuth.handleURL( url, sourceApplication : sourceApplication, annotation : annotation )
    }

    public func clearIAMLoginFirstLaunch()
    {
        ZohoPortalAuth.clearZohoAuthPortalDetailsForFirstLaunch()
    }

    public func logout( completion : @escaping ( ZCRMError? ) -> () )
    {
        ZohoPortalAuth.revokeAccessToken(
            { ( error ) in
                if let error = error
                {
                    print( "Error occured in logout() : \(error)" )
                    completion( typeCastToZCRMError( error ) )
                }
                else
                {
                    self.clearIAMLoginFirstLaunch()
                    print( "removed AllScopesWithSuccess!" )
                    self.handleLogin( completion : { _ in
                            
                    })
                    ZCRMSDKClient.shared.requestHeaders?.removeAll()
                    URLCache.shared.removeAllCachedResponses()
                    ZCRMSDKClient.shared.clearAllCache()
                    ZCRMSDKClient.shared.portalId = nil
                    if let cookies = HTTPCookieStorage.shared.cookies {
                        for cookie in cookies {
                            HTTPCookieStorage.shared.deleteCookie(cookie)
                        }
                    }
                    completion( nil )
                    ZCRMLogger.logDebug( message: "logout ZVCRM successful!" )
                }
        })
    }
    
    public func getAccessToken( completion : @escaping ( Result.Data< String > ) -> () )
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

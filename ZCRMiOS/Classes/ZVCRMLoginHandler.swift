//
//  LoginZVCRMActivity.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 27/11/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation
//import CP_Login

public class ZVCRMLoginHandler
{
//    private var appConfigurationUtil : CRMAppConfigUtil = CRMAppConfigUtil()
//    private var configurationKeys : [ String ] = [ "ClientID", "ClientSecretID", "AccountsURL", "PortalID", "AuthScopes", "RedirectURLScheme", "ApiBaseURL", "ApiVersion" ]
//    
//    public init(){}
//    
//    public init( appConfigUtil : CRMAppConfigUtil ) throws
//    {
//        self.appConfigurationUtil = appConfigUtil
//        try self.validateAppConfigs( dict : appConfigUtil.getAppConfigurations() )
//    }
//    
//    internal func validateAppConfigs( dict : Dictionary< String, Any > ) throws
//    {
//        if( dict.keys.count > 0 )
//        {
//            for key in configurationKeys
//            {
//                if( dict.keys.contains( key ) == false )
//                {
//                    throw ZCRMSDKError.InternalError( "\( key ) not present in the App configuration plist!" )
//                }
//            }
//            for key in dict.keys
//            {
//                if( dict[ key ] == nil )
//                {
//                    throw ZCRMSDKError.InternalError( "\( key ) is nil. It should have value" )
//                }
//            }
//        }
//        else
//        {
//            throw ZCRMSDKError.InternalError( "App configuration property list is empty!" )
//        }
//    }
//    
//    public func initIAMLogin( window : UIWindow? )
//    {
//        APPTYPE = appConfigurationUtil.getAppType()
//        APIBASEURL = appConfigurationUtil.getApiBaseURL()
//        APIVERSION = appConfigurationUtil.getApiVersion()
//        let cpLoginUtil = ClientZIAMUtil.shared()!
//        cpLoginUtil.initWithClientID( appConfigurationUtil.getClientID(), clientSecret : appConfigurationUtil.getClientSecretID(), portalID : appConfigurationUtil.getPortalID(), scope : appConfigurationUtil.getAuthscopes(), urlScheme : appConfigurationUtil.getRedirectURLScheme(), mainWindow : window, accountsPortalURL : appConfigurationUtil.getAccountsURL()  )
//    }
//    
//    public func loadIAMLoginView()
//    {
//        ClientZIAMUtil.shared()!.presentInitialViewController(
//            success :
//            {_ in
//                print( "access token received!" )
//        },
//            andFailure :
//            {
//                error in
//                switch( error!.code )
//                {
//                // SFSafari Dismissed
//                case 205 :
//                    print( "Error Detail : \( error!.description ), code : \( error!.code )" )
//                    self.loadIAMLoginView()
//                    break
//                    
//                // access_denied
//                case 905 :
//                    print( "Error Detail : \( error!.description ), code : \( error!.code )" )
//                    self.loadIAMLoginView()
//                    break
//                    
//                default :
//                    print( "Error : \( error! )" )
//                }
//        } )
//    }
//    
//    public func iamLoginHandleURL( url : URL, sourceApplication : String?, annotation : Any )
//    {
//        ClientZIAMUtil.shared()!.handleURL( url, sourceApplication : sourceApplication, annotation : annotation )
//    }
//    
//    internal func getOauth2Token() -> String
//    {
//        var oAuth2Token : String = String()
//        ClientZIAMUtil.shared()!.getOauth2Token(
//            {
//                accessToken in
//                oAuth2Token = accessToken!
//                
//        },
//            failure :
//            {
//                error in
//                print( "Error occured in getOauth2Token(): \( error! )" )
//        } )
//        return oAuth2Token
//    }
//    
//    public func clearIAMLoginFirstLaunch()
//    {
//        ClientZIAMUtil.shared()!.clearClientDetailsForFirstLaunch()
//    }
//    
//    public func logout()
//    {
//        ClientZIAMUtil.shared()!.removeAllScopesWithsuccess(
//            {
//                self.clearIAMLoginFirstLaunch()
//                print( "removed AllScopesWithSuccess!" )
//            },
//            failure :
//            {
//                error in
//                print( "Error occured in logout() : \(error!)" )
//        } )
//        print( "logout ZVCRM!" )
//    }
    
}

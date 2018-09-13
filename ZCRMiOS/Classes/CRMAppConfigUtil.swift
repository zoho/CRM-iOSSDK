//
//  CRMAppConfigUtil.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 08/08/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class CRMAppConfigUtil
{
    private var appConfigDict : Dictionary < String, Any > = Dictionary < String, Any >()
    private var appType : String?
    
    public init( appConfigDict : Dictionary< String, Any> )
    {
        self.appConfigDict = appConfigDict
        print( "App Configuration : \( appConfigDict.description )" )
    }
    
    public init() {}
    
    internal func getClientID() -> String
    {
        return self.appConfigDict.getString( key : "ClientID" )
    }
    
    internal func getClientSecretID() -> String
    {
        return self.appConfigDict.getString( key : "ClientSecretID" )
    }
    
    internal func getRedirectURLScheme() -> String
    {
        return self.appConfigDict.getString( key : "RedirectURLScheme" )
    }
    
    internal func getAuthscopes() -> [ Any ]
    {
        return self.appConfigDict.getArray( key : "OAuthScopes" )
    }
    
    internal func getAccountsURL() -> String
    {
        return self.appConfigDict.getString( key : "AccountsURL" )
    }
    
    public func setAppType( type : String )
    {
        self.appType = type
    }
    
    internal func getAppType() -> String
    {
        return self.appType!
    }
    
    public func getPortalID() -> String
    {
        return self.appConfigDict.getString( key : "PortalID" )
    }
    
    internal func getApiBaseURL() -> String
    {
        return self.appConfigDict.getString( key : "ApiBaseURL" )
    }
    
    internal func getApiVersion() -> String
    {
        return self.appConfigDict.getString( key : "ApiVersion" )
    }
    
    internal func getCountryDomain() -> String
    {
        return self.appConfigDict.getString( key : "DomainSuffix" )
    }
    
    internal func getAccessType() -> String
    {
        return self.appConfigDict.getString( key : "AccessType" )
    }
    
    internal func getShowSignUp() -> String
    {
        return self.appConfigDict.getString( key : "ShowSignUp" )
    }
    
    internal func getAppConfigurations() -> Dictionary< String, Any >
    {
        return self.appConfigDict
    }
    
    internal func isLoginCustomized() -> Bool
    {
        if( self.appConfigDict.hasValue( forKey : "LoginCustomization" ) && self.appConfigDict.getString( key : "LoginCustomization" ) == "true" )
        {
            return true
        }
        else
        {
            return false
        }
    }
}

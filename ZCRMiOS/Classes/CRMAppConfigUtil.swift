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
    
    internal func setClientID( id : String )
    {
        self.appConfigDict[ "ClientID" ] = id
    }
    
    internal func setClientSecretID( id : String )
    {
        self.appConfigDict[ "ClientSecretID" ] = id
    }
    
    internal func setRedirectURLScheme( scheme : String )
    {
        self.appConfigDict[ "RedirectURLScheme" ] = scheme
    }
    
    internal func setOauthScopes( scopes : [ Any ] )
    {
        self.appConfigDict[ "OAuthScopes" ] = scopes
    }
    
    internal func setAccountsURL( url : String )
    {
        self.appConfigDict[ "AccountsURL" ] = url
    }
    
    public func setAppType( type : String )
    {
        self.appType = type
    }
    
    internal func setPortalID( id : String )
    {
        self.appConfigDict[ "PortalID" ] = id
    }
    
    internal func getClientID() throws -> String
    {
        return try self.appConfigDict.getString( key : "ClientID" )
    }
    
    internal func getClientSecretID() throws -> String
    {
        return try self.appConfigDict.getString( key : "ClientSecretID" )
    }
    
    internal func getRedirectURLScheme() throws -> String
    {
        return try self.appConfigDict.getString( key : "RedirectURLScheme" )
    }
    
    internal func getAuthscopes() throws -> [ Any ]
    {
        return try self.appConfigDict.getArray( key : "OAuthScopes" )
    }
    
    internal func getAccountsURL() throws -> String
    {
        return try self.appConfigDict.getString( key : "AccountsURL" )
    }
    
    internal func getAppType() -> String
    {
        return self.appType!
    }
    
    public func getPortalID() throws -> String
    {
        return try self.appConfigDict.getString( key : "PortalID" )
    }
    
    internal func getApiBaseURL() throws -> String
    {
        return try self.appConfigDict.getString( key : "ApiBaseURL" )
    }
    
    internal func getApiVersion() throws -> String
    {
        return try self.appConfigDict.getString( key : "ApiVersion" )
    }
    
    internal func getCountryDomain() throws -> String
    {
        return try self.appConfigDict.getString( key : "DomainSuffix" )
    }
    
    internal func getAccessType() throws -> String
    {
        return try self.appConfigDict.getString( key : "AccessType" )
    }
    
    internal func getShowSignUp() throws -> String
    {
        return try self.appConfigDict.getString( key : "ShowSignUp" )
    }
    
    internal func getAppConfigurations() -> Dictionary< String, Any >
    {
        return self.appConfigDict
    }
    
    internal func isLoginCustomized() -> Bool
    {
        do {
            if ( try self.appConfigDict.getString( key : "LoginCustomization" ) == "true" )
            {
                return true
            }
            else
            {
                return false
            }
        }
        catch
        {
            return false
        }
    }
}

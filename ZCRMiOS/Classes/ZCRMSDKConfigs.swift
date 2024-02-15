//
//  ZCRMSDKConfigs.swift
//  ZCRMiOS
//
//  Created by gowtham-pt2177 on 05/08/20.
//

import Foundation

public class ZCRMSDKConfigs
{
    public internal( set ) var clientId : String = String()
    public internal( set ) var clientSecret : String = String()
    public internal( set ) var redirectURLScheme : String = String()
    public internal( set ) var apiVersion : String = "v2"
    public internal( set ) var showSignUp : Bool = false
    public internal( set ) var accountsURL : String = String()
    {
        didSet
        {
            ACCOUNTSURL = accountsURL
        }
    }
    public internal( set ) var oauthScopes : [ String ] = []
    public internal( set ) var apiBaseURL : String = "www.zohoapis.com"
    public internal( set ) var accessType : ZCRMAccessType = .production
    public internal( set ) var countryDomain : ZCRMCountryDomain = .com
    {
        didSet
        {
            COUNTRYDOMAIN = countryDomain.rawValue
        }
    }
    public internal( set ) var portalId : String?
    public internal( set ) var groupIdentifier : String?
    public internal( set ) var appType : ZCRMAppType = .zcrm
    public internal( set ) var authorizationCredentials : [ String : [ String ] ]?
    private var emptyProperties : [ String ] = []
    
    init() {}
    
    public func validateProperties() throws
    {
        if clientId.isEmpty
        {
            emptyProperties.append( "clientId" )
        }
        if clientSecret.isEmpty
        {
            emptyProperties.append( "clientSecret" )
        }
        if redirectURLScheme.isEmpty
        {
            emptyProperties.append( "redirectURLScheme" )
        }
        if apiVersion.isEmpty
        {
            emptyProperties.append( "apiVersion" )
        }
        if accountsURL.isEmpty
        {
            emptyProperties.append( "accountsURL" )
        }
        if oauthScopes.isEmpty
        {
            emptyProperties.append( "oauthScopes" )
        }
        if appType == .zcrmcp || appType == .zvcrm
        {
            if !portalId.notNilandEmpty
            {
                emptyProperties.append( "portalId" )
            }
        }
        if appType != .zcrm
        {
            if apiBaseURL.isEmpty
            {
                emptyProperties.append( "apiBaseURL" )
            }
        }
        else
        {
            if apiBaseURL.isEmpty || apiBaseURL == "www.zohoapis.com"
            {
                self.updateBaseURL( countryDomain : countryDomain )
                ZCRMLogger.logDebug( message : "Country Domain : \( COUNTRYDOMAIN )")
            }
            else
            {
                ZCRMSDKClient.shared.apiBaseURL = apiBaseURL
            }
        }
        if !emptyProperties.isEmpty
        {
            ZCRMLogger.logDebug( message:"Error occured in ZCRMSDKConfig init() - Mandatory properties not found. Details : \( emptyProperties ) ")
            throw ZCRMError.inValidError(code: ZCRMErrorCode.mandatoryNotFound, message: "Mandatory properties not found - \( emptyProperties )", details: nil)
        }
    }
    
    private func updateBaseURL( countryDomain : ZCRMCountryDomain )
    {
        var domain : String = String()
        switch accessType
        {
        case .development :
            domain = "developer"
            break
            
        case .sandBox :
            domain = "sandbox"
            break
            
        default :
            domain = "www"
        }
        
        apiBaseURL = "\( domain ).zohoapis.\( countryDomain.rawValue )"
        
        ZCRMLogger.logDebug( message: "API Base URL : \( apiBaseURL )")
    }
    
    private func updateAccountsURL( countryDomain : ZCRMCountryDomain )
    {
        if appType == .zcrmcp || appType == .zvcrm
        {
            accountsURL = "https://accounts.zohoportal.\( countryDomain.rawValue )"
        }
        else
        {
            accountsURL = "https://accounts.zoho.\( countryDomain.rawValue )"
        }
    }
    
    public class Builder
    {
        internal var configs : ZCRMSDKConfigs = ZCRMSDKConfigs()
        
        /**
          To initialize the Zoho CRM iOS SDK Configuration Builder object
         
         Needs to be used for appType .zcrm
         
         - Attention: AppType Bigin is not supported
        
         - Parameters:
            - clientId : Id of the client
            - clientSecret : ClientSecret obtained during client creation
            - redirectURL : The URL to which the app returns after authentication
            - oauthScopes : Scopes required to hit the apis
        */
        public init( clientId : String, clientSecret : String, redirectURL : String, oauthScopes : [ String ] )
        {
            configs.clientId = clientId
            configs.clientSecret = clientSecret
            configs.redirectURLScheme = redirectURL
            configs.oauthScopes = oauthScopes
        }
        
        /**
         To initialize the Zoho CRM iOS SDK Configuration object
         
        Needs to be used for appTypes .zvcrm, .zcrmcp
        
        - Attention: AppType Bigin is not supported
        
        - Parameters:
           - clientId : Id of the client
           - clientSecret : ClientSecret obtained during client creation
           - redirectURL : The URL to which the app returns after authentication
           - oauthScopes : Scopes required to hit the apis
           - portalId : The portalId of the client
        */
        public convenience init( clientId : String, clientSecret : String, redirectURL : String, oauthScopes : [ String ], portalId : String )
        {
            self.init( clientId : clientId, clientSecret : clientSecret, redirectURL : redirectURL, oauthScopes : oauthScopes )
            configs.portalId = portalId
        }
        
        public func setAPPType( _ apptype : ZCRMAppType ) -> Builder
        {
            configs.appType = apptype
            return self
        }
        
        public func setShowSignUp( _ showSignUp : Bool ) -> Builder
        {
            configs.showSignUp = showSignUp
            return self
        }
        
        public func setAccountsURL( _ accountsURL : String) -> Builder
        {
            configs.accountsURL = accountsURL
            return self
        }
        
        public func setAPIBaseURL( _ baseURL : String ) -> Builder
        {
            configs.apiBaseURL = baseURL
            
            var countryDomain : ZCRMCountryDomain
            switch baseURL
            {
            case let url where url.contains(".cn") :
                countryDomain = .cn
            case let url where url.contains(".au") :
                countryDomain = .au
            case let url where url.contains(".com") :
                countryDomain = .com
            case let url where url.contains(".eu") :
                countryDomain = .eu
            case let url where url.contains(".in") :
                countryDomain = .in
            case let url where url.contains(".jp") :
                countryDomain = .jp
            default:
                countryDomain = configs.countryDomain
            }
            configs.countryDomain = countryDomain
            return self
        }
        
        public func setAccessType( _ accessType : ZCRMAccessType ) -> Builder
        {
            configs.accessType = accessType
            return self
        }
        
        public func setGroupIdentifier( _ identifier : String ) -> Builder
        {
            configs.groupIdentifier = identifier
            return self
        }
        
        public func setAuthorizationCredentials( _ authorizationCredentials : [ String : [ String ] ] ) -> Builder
        {
            configs.authorizationCredentials = authorizationCredentials
            return self
        }
        
        public func build() throws -> ZCRMSDKConfigs
        {
            if configs.appType == .bigin || configs.appType == .solutions
            {
                ZCRMLogger.logError(message: "Error occured in ZCRMSDKConfig init() - AppType : \( configs.appType.rawValue ) is not supported")
                throw ZCRMError.inValidError(code: ZCRMErrorCode.notSupported, message: "AppType : \( configs.appType.rawValue ) is not supported", details: nil)
            }
            if configs.accountsURL.isEmpty
            {
                configs.updateAccountsURL(countryDomain: configs.countryDomain)
            }
            return configs
        }
    }
}

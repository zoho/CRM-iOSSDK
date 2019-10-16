//
//  ZohoCRMSDK.swift
//  ZCRMiOS
//
//  Created by Sarath Kumar Rajendran on 06/09/18.
//  Copyright © 2017 zohocrm. All rights reserved.
//

public class ZCRMSDKClient
{
	public static let shared = ZCRMSDKClient()
    public var requestHeaders : Dictionary< String, String >?
    public var isDBCacheEnabled : Bool = true
    
    public var userAgent : String = "ZCRMiOS_unknown_bundle"
    internal var apiBaseURL : String = String()
    public var apiVersion : String = "v2"
    internal var appType : String = String()
    public var requestTimeout : Double = 120.0
    
    internal static var persistentDB : CacheDBHandler?
    internal static var nonPersistentDB : CacheDBHandler?
    
    private var isVerticalCRM: Bool = false
    internal var zcrmLoginHandler: ZCRMLoginHandler?
    internal var zvcrmLoginHandler: ZVCRMLoginHandler?
    private var crmAppConfigs : CRMAppConfigUtil!
    
    private init() {}
    
    public func initSDK( window : UIWindow, appType : String? =  nil, apiBaseURL : String? = nil, oauthScopes : [ Any ]? = nil, clientID : String? = nil, clientSecretID : String? = nil, redirectURLScheme : String? = nil, accountsURL : String? = nil, portalID : String? = nil ) throws
    {
        guard let appConfigPlist = Bundle.main.path( forResource : "AppConfiguration", ofType : "plist" ) else
        {
            throw ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: "AppConfiguration.plist is not foud.", details: nil)
        }
        if let appConfiguration = NSDictionary( contentsOfFile : appConfigPlist ) as? [String : Any]
        {
            self.crmAppConfigs = CRMAppConfigUtil( appConfigDict : appConfiguration )
            if let baseURL = apiBaseURL
            {
                ZCRMSDKClient.shared.apiBaseURL = baseURL
                if ZCRMSDKClient.shared.apiBaseURL.isEmpty == true
                {
                    throw ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : "API Base URL is empty", details : nil )
                }
            }
            if let scopes = oauthScopes
            {
                crmAppConfigs.setOauthScopes( scopes : scopes )
            }
            if let accountURL = accountsURL
            {
                crmAppConfigs.setAccountsURL( url : accountURL )
            }
            if let clientId = clientID
            {
                crmAppConfigs.setClientID( id : clientId )
            }
            if let clientSecretId = clientSecretID {
                crmAppConfigs.setClientSecretID(id: clientSecretId)
            }
            if let portalId = portalID
            {
                crmAppConfigs.setPortalID(id: portalId)
            }
            if let redirectURLScheme = redirectURLScheme {
                crmAppConfigs.setRedirectURLScheme(scheme: redirectURLScheme)
            }
            if let bundleID = Bundle.main.bundleIdentifier
            {
                self.userAgent = "ZCRMiOS_\(bundleID)"
            }
            if let type = appType
            {
                try self.handleAppType( appType : type, appConfigurations : crmAppConfigs )
                ZCRMSDKClient.shared.appType = type
            }
            else if let type = appConfiguration[ "Type" ] as? String
            {
                try self.handleAppType( appType : type, appConfigurations : crmAppConfigs )
                ZCRMSDKClient.shared.appType = type
            }
            else
            {
                throw ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : "appType is not specified", details: nil )
            }
        }
        else
        {
            throw ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: "AppConfiguration.plist has no data.", details: nil)
        }
        do
        {
            try ZCRMSDKClient.shared.createDB()
            try ZCRMSDKClient.shared.createTables()
        }
        catch
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : Table creation failed!")
        }
        self.initIAMLogin( appType : ZCRMSDKClient.shared.appType, window : window, apiBaseURL : apiBaseURL )
    }
    
    public static func notifyLogout()
    {
        shared.clearAllCache()
    }
    
    public func clearCache()
    {
        do
        {
            try SQLite( dbName : DBConstant.CACHE_DB_NAME ).deleteDB()
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
        }
    }
    
    internal func clearAllCache()
    {
        do
        {
            try SQLite( dbName : DBConstant.CACHE_DB_NAME ).deleteDB()
            try SQLite( dbName : DBConstant.PERSISTENT_DB_NAME ).deleteDB()
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
        }
    }
    
    /// default minLogLevel is set as ERROR
    public func turnLoggerOn( minLogLevel : LogLevels? )
    {
        if let minLogLevel = minLogLevel
        {
            ZCRMLogger.initLogger(isLogEnabled: true, minLogLevel: minLogLevel)
        }
        else
        {
            ZCRMLogger.initLogger(isLogEnabled: true, minLogLevel: LogLevels.ERROR)
        }
    }
    
    public func turnLoggerOff()
    {
        ZCRMLogger.initLogger(isLogEnabled: false)
    }
    
    public func getLoggedInUser( completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler(cacheFlavour: CacheFlavour.FORCE_CACHE).getCurrentUser() { ( result ) in
            completion( result )
        }
    }
    
    internal func createDB() throws
    {
        ZCRMSDKClient.persistentDB = try CacheDBHandler( dbName : DBConstant.PERSISTENT_DB_NAME )
        ZCRMSDKClient.nonPersistentDB = try CacheDBHandler( dbName : DBConstant.CACHE_DB_NAME )
    }
    
    internal func createTables() throws
    {
        if let persistentDB = ZCRMSDKClient.persistentDB, let nonPersistentDB = ZCRMSDKClient.nonPersistentDB
        {
            try persistentDB.createResponsesTable()
            try nonPersistentDB.createResponsesTable()
        }
        else
        {
            try createDB()
            try ZCRMSDKClient.persistentDB?.createResponsesTable()
            try ZCRMSDKClient.nonPersistentDB?.createResponsesTable()
        }
    }
    
    internal func getPersistentDB() throws -> CacheDBHandler
    {
        if let persistentDB = ZCRMSDKClient.persistentDB
        {
            return persistentDB
        }
        else
        {
            try createDB()
            return ZCRMSDKClient.persistentDB!
        }
    }
    
    internal func getNonPersistentDB() throws -> CacheDBHandler
    {
        if let nonPersistentDB = ZCRMSDKClient.nonPersistentDB
        {
            return nonPersistentDB
        }
        else
        {
            try createDB()
            return ZCRMSDKClient.nonPersistentDB!
        }
    }
    
    private func clearFirstLaunch() {
        let alreadyLaunched = UserDefaults.standard.bool(forKey:"first")
        if !alreadyLaunched{
            if self.isVerticalCRM {
                self.zvcrmLoginHandler?.clearIAMLoginFirstLaunch()
            } else {
                self.zcrmLoginHandler?.clearIAMLoginFirstLaunch()
            }
            UserDefaults.standard.set(true, forKey: "first")
        }
    }
    
    public func handle( url : URL, sourceApplication : String?, annotation : Any )
    {
        if self.isVerticalCRM
        {
            self.zvcrmLoginHandler?.iamLoginHandleURL(url: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        else
        {
            self.zcrmLoginHandler?.iamLoginHandleURL(url: url, sourceApplication: sourceApplication, annotation: annotation)
        }
    }
    
    fileprivate func initIAMLogin( appType : String, window : UIWindow, apiBaseURL : String? )
    {
        if self.isVerticalCRM
        {
            self.zvcrmLoginHandler?.initIAMLogin(window: window)
        }
        else
        {
            self.zcrmLoginHandler?.initIAMLogin(window: window)
            guard let baseURL = apiBaseURL else
            {
                do
                {
                    ZCRMSDKClient.shared.zcrmLoginHandler?.setAppConfigurations()
                    try ZCRMSDKClient.shared.zcrmLoginHandler?.updateBaseURL( countryDomain : COUNTRYDOMAIN )
                    ZCRMLogger.logDebug( message : "Country Domain : \( COUNTRYDOMAIN )")
                }
                catch
                {
                    ZCRMLogger.logDebug( message : "Error in initIAMLogin(): \( error )" )
                }
                return
            }
            ZCRMSDKClient.shared.apiBaseURL = baseURL
        }
    }
    
    fileprivate func handleAppType( appType : String, appConfigurations : CRMAppConfigUtil ) throws
    {
        appConfigurations.setAppType( type : appType )
        do
        {
            if appType == AppType.ZCRM.rawValue
            {
                self.zcrmLoginHandler = try ZCRMLoginHandler( appConfigUtil : appConfigurations )
                self.isVerticalCRM = false
            }
            else
            {
                self.zvcrmLoginHandler = try ZVCRMLoginHandler( appConfigUtil : appConfigurations )
                self.isVerticalCRM = true
            }
            self.clearFirstLaunch()
        }
        catch
        {
            throw ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: error.description, details: nil)
        }
    }
    
    public func showLogin(completion: @escaping (Bool) -> ())
    {
        self.isUserSignedIn { (isUserSignedIn) in
            if isUserSignedIn
            {
                ZCRMLogger.logDebug(message: "User already signed in.")
                completion(true)
            }
            else
            {
                if self.isVerticalCRM
                {
                    self.zvcrmLoginHandler?.handleLogin { (success) in
                        completion(success)
                    }
                }
                else
                {
                    self.zcrmLoginHandler?.handleLogin(completion: { (success) in
                        completion(success)
                    })
                }
            }
        }
        
    }
    
    public func isUserSignedIn(completion: @escaping (Bool) -> ())
    {
        if self.isVerticalCRM
        {
            self.zvcrmLoginHandler?.getOauth2Token { (token, error) in
                if error != nil
                {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
        else
        {
            self.zcrmLoginHandler?.getOauth2Token { (token, error) in
                if error != nil
                {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    public func logout(completion: @escaping (Bool) -> ())
    {
        if self.isVerticalCRM
        {
            self.zvcrmLoginHandler?.logout { (success) in
                completion(success)
            }
        }
        else
        {
            self.zcrmLoginHandler?.logout { (success) in
                completion(success)
            }
        }
    }
    
    public func setPortalID( id : String )
    {
        ZCRMSDKClient.shared.crmAppConfigs.setPortalID( id : id )
    }
    
    public func transformAPIBaseURL( baseURL : String )
    {
        ZCRMSDKClient.shared.apiBaseURL = baseURL
    }
}

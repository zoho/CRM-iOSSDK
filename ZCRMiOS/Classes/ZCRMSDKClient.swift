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
   
    public var fileUploadURLSessionConfiguration : URLSessionConfiguration = .default
    public var fileDownloadURLSessionConfiguration : URLSessionConfiguration = .default
    
    public var userAgent : String = "ZCRMiOS_unknown_bundle"
    internal var apiBaseURL : String = String()
    public var apiVersion : String = "v2"
    internal var portalId : Int64?
    internal var appType : AppType = AppType.zcrm
    public var requestTimeout : Double = 120.0
    /**
     The time until the db data can be used for specific URL Request. After the time ends the data will be fetched from the server.
     
    Default time is 6 hours.
     */
    public var cacheValidityTimeInHours : Float = 6
    
    internal static var persistentDB : CacheDBHandler?
    internal static var nonPersistentDB : CacheDBHandler?
        private var isVerticalCRM: Bool = false
        internal var zcrmLoginHandler: ZCRMLoginHandler?
        internal var zvcrmLoginHandler: ZVCRMLoginHandler?
        private var crmAppConfigs : CRMAppConfigUtil!
    
    internal var sessionCompletionHandlers : [ String : () -> () ] = [ String : () -> () ]()
    
    private init() {}
    
    public func initSDK( window : UIWindow, appType : AppType? =  AppType.zcrm, apiBaseURL : String? = nil, oauthScopes : [ Any ]? = nil, clientID : String? = nil, clientSecretID : String? = nil, redirectURLScheme : String? = nil, accountsURL : String? = nil, portalID : String? = nil ) throws
    {
        guard let appConfigPlist = Bundle.main.path( forResource : "AppConfiguration", ofType : "plist" ) else
        {
            throw ZCRMError.sdkError(code: ErrorCode.internalError, message: "AppConfiguration.plist is not foud.", details: nil)
        }
        if let appConfiguration = NSDictionary( contentsOfFile : appConfigPlist ) as? [String : Any]
        {
            self.crmAppConfigs = CRMAppConfigUtil( appConfigDict : appConfiguration )
            if let baseURL = apiBaseURL
            {
                ZCRMSDKClient.shared.apiBaseURL = baseURL
                if ZCRMSDKClient.shared.apiBaseURL.isEmpty == true
                {
                    throw ZCRMError.sdkError( code : ErrorCode.internalError, message : "API Base URL is empty", details : nil )
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
            else if let type = appConfiguration[ "Type" ] as? String, let appType = AppType(rawValue: type)
            {
                try self.handleAppType( appType : appType, appConfigurations : crmAppConfigs )
                ZCRMSDKClient.shared.appType = appType
            }
            else
            {
                throw ZCRMError.sdkError( code : ErrorCode.internalError, message : "appType is not specified", details: nil )
            }
        }
        else
        {
            throw ZCRMError.sdkError(code: ErrorCode.internalError, message: "AppConfiguration.plist has no data.", details: nil)
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
        shared.portalId = nil
    }
    
    public func getCurrentPortal() -> Int64?
    {
        return self.portalId
    }
    
    public func clearCache() -> Bool
    {
        do
        {
            try SQLite( dbName : DBConstant.CACHE_DB_NAME ).deleteDB()
            return true
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            return false
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
            ZCRMLogger.initLogger(isLogEnabled: true, minLogLevel: LogLevels.error)
        }
    }
    
    public func turnLoggerOff()
    {
        ZCRMLogger.initLogger(isLogEnabled: false)
    }
    
    public func getLoggedInUser( completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler(cacheFlavour: CacheFlavour.forceCache).getCurrentUser() { ( result ) in
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
            try persistentDB.createPortalTable()
            try persistentDB.createPushNotificationsTable()
            try nonPersistentDB.createResponsesTable()
        }
        else
        {
            try createDB()
            try ZCRMSDKClient.persistentDB?.createResponsesTable()
            try ZCRMSDKClient.persistentDB?.createPortalTable()
            try ZCRMSDKClient.persistentDB?.createPushNotificationsTable()
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
            guard let persistentDB = ZCRMSDKClient.persistentDB else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( ErrorCode.dbNotCreated ) : Unable To Create \( DBConstant.PERSISTENT_DB_NAME ), \( APIConstants.DETAILS ) : -")
                throw ZCRMError.sdkError(code: ErrorCode.dbNotCreated, message: "Unable To Create DB", details: nil)
            }
            return persistentDB
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
            guard let nonPersistentDB = ZCRMSDKClient.nonPersistentDB else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( ErrorCode.dbNotCreated ) : Unable To Create \( DBConstant.CACHE_DB_NAME ), \( APIConstants.DETAILS ) : -")
                throw ZCRMError.sdkError(code: ErrorCode.dbNotCreated, message: "Unable To Create DB", details: nil)
            }
            return nonPersistentDB
        }
    }
        
        private func clearFirstLaunch()
        {
            let alreadyLaunched = UserDefaults.standard.bool( forKey : "first" )
            if !alreadyLaunched
            {
                if self.isVerticalCRM
                {
                    self.zvcrmLoginHandler?.clearIAMLoginFirstLaunch()
                }
                else
                {
                    self.zcrmLoginHandler?.clearIAMLoginFirstLaunch()
                }
                UserDefaults.standard.set( true, forKey : "first" )
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
        
        fileprivate func initIAMLogin( appType : AppType, window : UIWindow, apiBaseURL : String? )
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
        
        fileprivate func handleAppType( appType : AppType, appConfigurations : CRMAppConfigUtil ) throws
        {
            appConfigurations.setAppType( type : appType.rawValue )
            do
            {
                if appType == AppType.zcrm
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
                throw ZCRMError.sdkError(code: ErrorCode.internalError, message: error.description, details: nil)
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
    
    /**
     To resume the URLSession delegate method calls when the app transition from background to foreground
     
     NSURLSession delegate methods won't get invoked in some devices when app resumes from background. We have to resume atleast one task in that URLSession to resume the delgate method calls.
     */
    public func notifyApplicationEnterForeground()
    {
        FileAPIRequest.fileUploadURLSessionWithDelegates.getTasksWithCompletionHandler() { _, uploadTasks, _ in
            uploadTasks.first?.resume()
        }
        FileAPIRequest.fileDownloadURLSessionWithDelegates.getTasksWithCompletionHandler() { _, _, downloadTasks in
            downloadTasks.first?.resume()
        }
    }
    
    public func notifyBackgroundSessionEvent(_ identifier : String, _ completionHandler : @escaping () -> Void)
    {
        ZCRMSDKClient.shared.sessionCompletionHandlers.updateValue( completionHandler, forKey: identifier)
    }
    
    internal func clearDBOnNoPermissionError( _ name : String?, _ responseJSON : [ String : Any ] ) throws
    {
        let msgJSON : [ String : Any ] = responseJSON
        if let status = msgJSON[ APIConstants.STATUS ] as? String, let code = msgJSON[ APIConstants.CODE ] as? String
        {
            if( status == APIConstants.CODE_ERROR && code == ErrorCode.noPermission)
            {
                if let details = msgJSON[ APIConstants.DETAILS ] as? [ String : Any ], let permissions = details[ APIConstants.PERMISSIONS ] as? [ String ]
                {
                    for permission in permissions
                    {
                        if permission.contains( "Crm_Implied_View_" )
                        {
                            if let moduleName = name
                            {
                                do
                                {
                                    try ZCRMSDKClient.shared.getPersistentDB().deleteZCRMRecords(withModuleName: moduleName)
                                    try ZCRMSDKClient.shared.getNonPersistentDB().deleteZCRMRecords(withModuleName: moduleName)
                                }
                                catch
                                {
                                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                                    throw error
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

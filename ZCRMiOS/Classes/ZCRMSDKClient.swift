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
    var isDBCacheEnabled : Bool = false
   
    public var fileUploadURLSessionConfiguration : URLSessionConfiguration = .default
    public var fileDownloadURLSessionConfiguration : URLSessionConfiguration = .default
    
    internal var userAgent : String = "ZCRMiOS_unknown_app"
    internal var apiBaseURL : String = String()
    internal var apiVersion : String = "v2"
    internal var portalId : Int64?
    internal var appType : AppType = AppType.zcrm
    public var requestTimeout : Double = 120.0
    /**
      The maximum amount of time that a resource request should be allowed to take.
     
     Resource request - Upload and Download operations
     ```
     Default value is 7 days
     ```
     */
    public var timeoutIntervalForResource : Double = 604800
    {
        didSet
        {
            ZCRMSDKClient.shared.fileDownloadURLSessionConfiguration.timeoutIntervalForResource = timeoutIntervalForResource
            ZCRMSDKClient.shared.fileUploadURLSessionConfiguration.timeoutIntervalForResource = timeoutIntervalForResource
        }
    }
    private var zohoAuthProvider : ZohoAuthProvider?
    /**
     The time until the db data can be used for specific URL Request. After the time ends the data will be fetched from the server.
     
     ```
     Default time is 6 hours.
     ```
     */
    public var cacheValidityTimeInHours : Float = 6
    
    internal static var persistentDB : CacheDBHandler?
    internal static var nonPersistentDB : CacheDBHandler?
    private var isVerticalCRM: Bool = false
    internal var zcrmLoginHandler: ZCRMLoginHandler?
    internal var zvcrmLoginHandler: ZVCRMLoginHandler?
    private var crmAppConfigs : Dictionary < String, Any >!
    
    internal var sessionCompletionHandlers : [ String : () -> () ] = [ String : () -> () ]()
    
    private init() {}
    
    public func initSDK( window : UIWindow, appConfiguration : ZCRMSDKConfigs ) throws
    {
        if let packageName = Bundle.main.infoDictionary?[ kCFBundleNameKey as String ] as? String, let appVersion = Bundle.main.infoDictionary?[ "CFBundleShortVersionString" ] as? String
        {
            self.userAgent = "\( packageName )/\( appVersion )(iPhone) ZCRMiOSSDK"
        }
        ZCRMSDKClient.shared.apiBaseURL = appConfiguration.apiBaseURL
        ZCRMSDKClient.shared.apiVersion = appConfiguration.apiVersion
        try self.handleAppType( appConfigurations : appConfiguration )
        ZCRMSDKClient.shared.appType = appConfiguration.appType
        if let groupIdentifier = appConfiguration.groupIdentifier
        {
            SQLite.sharedURL = FileManager().containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        }
        
        do
        {
            try ZCRMSDKClient.shared.createDB()
            try ZCRMSDKClient.shared.createTables()
        }
        catch
        {
            ZCRMLogger.logError(message: "Table creation failed!")
        }
        try self.initIAMLogin( window : window )
    }
    
    public static func notifyLogout() throws
    {
        try shared.clearAllCache()
        shared.clearAllURLSessionCache()
        shared.portalId = nil
    }
    
    public func getCurrentOrganization() -> Int64?
    {
        return self.portalId
    }
    
    public func clearCache() throws
    {
        try SQLite( dbName : DBConstant.CACHE_DB_NAME ).deleteDB()
    }
    
    internal func clearAllCache() throws
    {
        try SQLite( dbName : DBConstant.CACHE_DB_NAME ).deleteDB()
        try SQLite( dbName : DBConstant.PERSISTENT_DB_NAME ).deleteDB()
    }
    
    public func enableDBCaching()
    {
        isDBCacheEnabled = true
    }

    public func disableDBCaching() throws
    {
        isDBCacheEnabled = false
        try clearAllCache()
    }
    
    internal func getAccessToken( completion : @escaping ( Result.Data< String > ) -> ())
    {
        if let zohoAuthProvider = self.zohoAuthProvider
        {
            zohoAuthProvider.getAccessToken() { result in
                completion( result )
            }
        }
        else
        {
            ZCRMLogger.logError(message: "\( ErrorCode.mandatoryNotFound ) : Zoho Auth provider cannot be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.sdkError(code: ErrorCode.mandatoryNotFound, message: "Zoho Auth provider cannot be nil", details: nil) ) )
        }
    }
    
    public func clearAllURLSessionCache()
    {
        APIRequest.session.configuration.urlCache?.removeAllCachedResponses()
        FileAPIRequest.fileUploadURLSessionWithDelegates.configuration.urlCache?.removeAllCachedResponses()
        FileAPIRequest.fileDownloadURLSessionWithDelegates.configuration.urlCache?.removeAllCachedResponses()
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
    
    /// To change the Zoho CRM SDK LogLevel
    public func changeMinLogLevel( _ minLogLevel : LogLevels )
    {
        ZCRMLogger.minLogLevel = minLogLevel
    }
    
    public func turnLoggerOff()
    {
        ZCRMLogger.initLogger(isLogEnabled: false)
    }
    
    public func getCurrentUser( completion : @escaping( Result.Data< ZCRMUser > ) -> () )
    {
        UserAPIHandler(cacheFlavour: CacheFlavour.forceCache).getCurrentUser() { ( result ) in
            switch result
            {
            case .success(let currentUser, _) :
                completion( .success( currentUser ) )
            case .failure(let error) :
                completion( .failure( error ) )
            }
        }
    }
    
    public func getCurrentUserFromServer( completion : @escaping( Result.Data< ZCRMUser > ) -> () )
    {
        UserAPIHandler(cacheFlavour: CacheFlavour.noCache).getCurrentUser() { ( result ) in
            switch result
            {
            case .success(let currentUser, _) :
                completion( .success( currentUser ) )
            case .failure(let error) :
                completion( .failure( error ) )
            }
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
            guard let persistentDB = ZCRMSDKClient.persistentDB else
            {
                ZCRMLogger.logError(message: "\( ErrorCode.dbNotCreated ) : Unable To Create \( DBConstant.PERSISTENT_DB_NAME ), \( APIConstants.DETAILS ) : -")
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
                ZCRMLogger.logError(message: "\( ErrorCode.dbNotCreated ) : Unable To Create \( DBConstant.CACHE_DB_NAME ), \( APIConstants.DETAILS ) : -")
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

    fileprivate func initIAMLogin( window : UIWindow ) throws
    {
        if self.isVerticalCRM
        {
            try self.zvcrmLoginHandler?.initIAMLogin(window: window)
        }
        else
        {
            try self.zcrmLoginHandler?.initIAMLogin(window: window)
        }
    }
    
    fileprivate func handleAppType( appConfigurations : ZCRMSDKConfigs ) throws
    {
        do
        {
            if appConfigurations.appType == AppType.zcrm
            {
                self.zcrmLoginHandler = try ZCRMLoginHandler(appConfiguration: appConfigurations)
                self.zohoAuthProvider = self.zcrmLoginHandler
                self.isVerticalCRM = false
            }
            else
            {
                self.zvcrmLoginHandler = try ZVCRMLoginHandler(appConfiguration: appConfigurations)
                self.zohoAuthProvider = self.zvcrmLoginHandler
                self.isVerticalCRM = true
            }
            self.clearFirstLaunch()
        }
        catch
        {
            throw ZCRMError.sdkError(code: ErrorCode.internalError, message: error.description, details: nil)
        }
    }
    
    public func showLogin(completion: @escaping ( ZCRMError? ) -> ())
    {
        if self.isUserSignedIn()
        {
            ZCRMLogger.logDebug(message: "User already signed in.")
            completion( nil )
        }
        else
        {
            if self.isVerticalCRM
            {
                self.zvcrmLoginHandler?.handleLogin( completion: completion )
            }
            else
            {
                self.zcrmLoginHandler?.handleLogin( completion: completion )
            }
        }
    }
    
    public func isUserSignedIn() -> Bool
    {
        if self.isVerticalCRM && self.appType != .solutions
        {
            return ZohoPortalAuth.isUserSignedIn()
        }
        return ZohoAuth.isUserSignedIn()
    }
    
    public func logout(completion: @escaping (ZCRMError?) -> ())
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
                                    ZCRMLogger.logError( message : "\( error )" )
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

struct CRMAppConfigurationKeys
{
    static let clientId = "ClientID"
    static let clientSecretId = "ClientSecretID"
    static let redirectURLScheme = "RedirectURLScheme"
    static let oAuthScopes = "OAuthScopes"
    static let accountsURL = "AccountsURL"
    static let portalId = "PortalID"
    static let apiBaseURL = "ApiBaseURL"
    static let apiVersion = "ApiVersion"
    static let countryDomain = "DomainSuffix"
    static let accessType = "AccessType"
    static let showSignUp = "ShowSignUp"
}

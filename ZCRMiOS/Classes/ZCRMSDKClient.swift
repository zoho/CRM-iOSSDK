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
    @UserDefaultsBacked(key: DBConstant.IS_DB_CACHE_ENABLED, defaultValue: false)
    public internal( set ) var isDBCacheEnabled : Bool
    
    public var fileUploadURLSessionConfiguration : URLSessionConfiguration = .default
    public var fileDownloadURLSessionConfiguration : URLSessionConfiguration = .default
    
    public internal( set ) var userAgent : String = "ZCRMiOS_unknown_app"
    public internal( set ) var apiBaseURL : String = String()
    {
        didSet
        {
            switch ZCRMSDKClient.shared.apiBaseURL
            {
            case let url where url.contains(".cn") :
                COUNTRYDOMAIN = ZCRMCountryDomain.cn.rawValue
            case let url where url.contains(".au") :
                COUNTRYDOMAIN = ZCRMCountryDomain.au.rawValue
            case let url where url.contains(".com") :
                COUNTRYDOMAIN = ZCRMCountryDomain.com.rawValue
            case let url where url.contains(".eu") :
                COUNTRYDOMAIN = ZCRMCountryDomain.eu.rawValue
            case let url where url.contains(".in") :
                COUNTRYDOMAIN = ZCRMCountryDomain.in.rawValue
            case let url where url.contains(".jp") :
                COUNTRYDOMAIN = ZCRMCountryDomain.jp.rawValue
            default:
                COUNTRYDOMAIN = ZCRMCountryDomain.com.rawValue
            }
        }
    }
    public var apiVersion : String = "v2"
    public internal( set ) var organizationId : Int64?
    public internal( set ) var appType : ZCRMAppType = .zcrm
    public internal( set ) var authorizationCredentials : [ String : [ String ] ]?
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
    internal var zohoAuthProvider : ZohoAuthProvider?
    /**
     The time until the db data can be used for specific URL Request. After the time ends the data will be fetched from the server.
     
     ```
     Default time is 6 hours.
     ```
     */
    public var cacheValidityTimeInHours : Float = 6
    @UserDefaultsBacked(key: DBConstant.MULTIORG_DB_SUPPORT_PREFERENCE, defaultValue: APIConstants.BOOL_MOCK)
    public internal( set ) var isMultiOrgInstanceSupported : Bool
    internal var orgAPIDB : CacheDBHandler?
    internal var userAPIDB : CacheDBHandler?
    internal var metaAPIDB : CacheDBHandler?
    internal var analyticsAPIDB : CacheDBHandler?
    internal var appDataDB : CacheDBHandler?
    private var isVerticalCRM: Bool = false
    internal var zcrmLoginHandler: ZCRMLoginHandler?
    internal var zvcrmLoginHandler: ZVCRMLoginHandler?
    private var crmAppConfigs : Dictionary < String, Any >!
    internal var isInternal : Bool = false
    internal var orgLicensePlan = FREE_PLAN
    internal var account : String = "External"
    @UserDefaultsBacked(key: DBConstant.IS_DB_ENCRYPTED, defaultValue: false)
    internal var isDBEncrypted : Bool
    @UserDefaultsBacked(key: DBConstant.DB_Key_Name, defaultValue: DBConstant.DB_Key_Value)
    internal var dbKeyValue : String
    
    internal var sessionCompletionHandlers : [ String : () -> () ] = [ String : () -> () ]()
    private let serialQueue = DispatchQueue( label : "com.zoho.crm.sdk.sqlite.execCommand", qos : .utility )
    
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
        ZCRMSDKClient.shared.authorizationCredentials = appConfiguration.authorizationCredentials
        if let groupIdentifier = appConfiguration.groupIdentifier
        {
            SQLite.sharedURL = FileManager().containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        }
        
        try self.initIAMLogin( window : window )
    }
    
    public static func notifyLogout() throws
    {
        try shared.clearAllCache(isLogoutAction: true)
        shared.clearAllURLSessionCache()
        shared.organizationId = nil
        shared.deinitialiseALLDBs()
        let query = KeychainPasswordItem.keychainQuery(withService: ZCRMSDKClient.shared.dbKeyValue, account: ZCRMSDKClient.shared.account, accessGroup: nil)
        let status = SecItemDelete(query as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainPasswordItem.KeychainError.unhandledError(status: status) }
        UserDefaults.standard.removeObject(forKey: DBConstant.DB_Key_Name)
        UserDefaults.standard.removeObject(forKey: DBConstant.IS_DB_ENCRYPTED)
    }
    
    public func getCurrentOrganization() -> Int64?
    {
        return self.organizationId
    }
    
    public func clearCache() throws
    {
        try SQLite( dbType : DBType.metaData ).deleteDB()
        try SQLite( dbType : DBType.analyticsData ).deleteDB()
        ZCRMSDKClient.shared.metaAPIDB = nil
        ZCRMSDKClient.shared.analyticsAPIDB = nil
    }
    
    internal func clearAllCache(isLogoutAction : Bool = false) throws
    {
        try SQLite( dbType : DBType.orgData ).deleteDB()
        try SQLite( dbType : DBType.userData ).deleteDB()
        if isLogoutAction
        {
            try SQLite( dbType : DBType.appData ).deleteDB()
            ZCRMSDKClient.shared.appDataDB = nil
        }
        ZCRMSDKClient.shared.orgAPIDB = nil
        ZCRMSDKClient.shared.userAPIDB = nil
        try clearCache()
    }
    
    public func enableDBCaching() throws
    {
        isDBCacheEnabled = true
        try initialiseALLDBs()
    }
    
    public func disableDBCaching() throws
    {
        isDBCacheEnabled = false
        isMultiOrgInstanceSupported = false
        try clearAllCache()
        clearAllURLSessionCache()
        deinitialiseALLDBs()
    }
    
    internal func getOrgId() -> String
    {
        guard let organizationId = organizationId, isMultiOrgInstanceSupported else {
            return ""
        }
        return "_\( organizationId )"
    }
    
    private func deinitialiseALLDBs()
    {
        orgAPIDB = nil
        userAPIDB = nil
        analyticsAPIDB = nil
        metaAPIDB = nil
        appDataDB = nil
    }
    
    private func initialiseALLDBs() throws
    {
        orgAPIDB  = CacheDBHandler(dbType: .orgData)
        userAPIDB = CacheDBHandler(dbType: .userData)
        metaAPIDB = CacheDBHandler(dbType: .metaData)
        analyticsAPIDB = CacheDBHandler(dbType: .analyticsData)
        appDataDB = CacheDBHandler(dbType: .appData)
    }
    
    internal func getAccessToken( completion : @escaping ( ZCRMResult.Data< String > ) -> ())
    {
        if let zohoAuthProvider = self.zohoAuthProvider
        {
            zohoAuthProvider.getAccessToken() { result in
                completion( result )
            }
        }
        else
        {
            ZCRMLogger.logError(message: "\( ZCRMErrorCode.mandatoryNotFound ) : Zoho Auth provider cannot be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.sdkError(code: ZCRMErrorCode.mandatoryNotFound, message: "Zoho Auth provider cannot be nil", details: nil) ) )
        }
    }
    
    public func clearAllURLSessionCache()
    {
        APIRequest.session.configuration.urlCache?.removeAllCachedResponses()
        FileAPIRequest.fileUploadURLSessionWithDelegates.configuration.urlCache?.removeAllCachedResponses()
        FileAPIRequest.fileDownloadURLSessionWithDelegates.configuration.urlCache?.removeAllCachedResponses()
    }
    
    /// default minLogLevel is set as ERROR
    public func turnLoggerOn( minLogLevel : ZCRMLogLevels? )
    {
        ZCRMLogger.initLogger(isLogEnabled: true, minLogLevel: minLogLevel ?? .error)
    }
    
    /// To change the Zoho CRM SDK LogLevel
    public func changeMinLogLevel( _ minLogLevel : ZCRMLogLevels )
    {
        ZCRMLogger.minLogLevel = minLogLevel
    }
    
    public func turnLoggerOff()
    {
        ZCRMLogger.initLogger(isLogEnabled: false)
    }
    
    public func enableDBEncryption() throws
    {
        if !ZCRMSDKClient.shared.isDBEncrypted
        {
            let password : String = try getDBPassPhrase()
            try serialQueue.sync {
                try ZCRMSDKClient.shared.getPersistentDB(dbType: .orgData).encryptDB( password )
                try ZCRMSDKClient.shared.getPersistentDB(dbType: .userData).encryptDB( password )
                try ZCRMSDKClient.shared.getNonPersistentDB(dbType: .analyticsData).encryptDB( password )
                ZCRMSDKClient.shared.isDBEncrypted = true
            }
        }
    }
    
    public func disableDBEncryption() throws
    {
        if ZCRMSDKClient.shared.isDBEncrypted
        {
            let password : String = try getDBPassPhrase()
            try serialQueue.sync {
                try ZCRMSDKClient.shared.getPersistentDB(dbType: .orgData).decryptDB( password )
                try ZCRMSDKClient.shared.getPersistentDB(dbType: .userData).decryptDB( password )
                try ZCRMSDKClient.shared.getNonPersistentDB(dbType: .analyticsData).decryptDB( password )
                ZCRMSDKClient.shared.isDBEncrypted = false
            }
        }
    }
    
    public func getCurrentUser( completion : @escaping( ZCRMResult.Data< ZCRMUser > ) -> () )
    {
        UserAPIHandler(cacheFlavour: .forceCache).getCurrentUser() { ( result ) in
            switch result
            {
            case .success(let currentUser, _) :
                completion( .success( currentUser ) )
            case .failure(let error) :
                completion( .failure( error ) )
            }
        }
    }
    
    public func getCurrentUserFromServer( completion : @escaping( ZCRMResult.Data< ZCRMUser > ) -> () )
    {
        UserAPIHandler(cacheFlavour: .noCache).getCurrentUser() { ( result ) in
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
        if orgAPIDB.isNil
        {
            orgAPIDB = CacheDBHandler( dbType: DBType.orgData )
        }
        if userAPIDB.isNil
        {
            userAPIDB = CacheDBHandler( dbType: DBType.userData )
        }
        if metaAPIDB.isNil
        {
            metaAPIDB = CacheDBHandler( dbType: DBType.metaData )
        }
        if analyticsAPIDB.isNil
        {
            analyticsAPIDB = CacheDBHandler( dbType: DBType.analyticsData )
        }
        if appDataDB.isNil
        {
            appDataDB = CacheDBHandler( dbType: DBType.appData )
        }
    }
    
    internal func createTables() throws
    {
        if let orgAPIDB = orgAPIDB, let userAPIDB = userAPIDB, let metaAPIDB = metaAPIDB, let analyticsAPIDB = analyticsAPIDB, let appDataDB = appDataDB
        {
            try createSeparateTables(cacheDBHandlers: [ orgAPIDB, userAPIDB, metaAPIDB, analyticsAPIDB, appDataDB ])
        }
        else
        {
            try createDB()
            try createSeparateTables(cacheDBHandlers: [ orgAPIDB, userAPIDB, metaAPIDB, analyticsAPIDB, appDataDB ])
        }
    }
    
    private func createSeparateTables( cacheDBHandlers : [ CacheDBHandler? ] ) throws
    {
        for cacheDBHandler in cacheDBHandlers
        {
            try cacheDBHandler?.createResponsesTable()
            if cacheDBHandler?.dbRequest.dbType != .metaData && cacheDBHandler?.dbRequest.dbType != .analyticsData
            {
                try cacheDBHandler?.createOrganizationTable()
            }
        }
    }
    
    internal func getPersistentDB( dbType : DBType ) throws -> CacheDBHandler
    {
        var cacheDBHandler : CacheDBHandler?
        switch dbType {
        case .orgData:
            cacheDBHandler = orgAPIDB
        case .userData:
            cacheDBHandler = userAPIDB
        case .appData:
            cacheDBHandler = appDataDB
        default :
            ZCRMLogger.logError(message: "\( ZCRMErrorCode.invalidOperation ) : Not a valid dbType to access persistent DB : \( dbType ), \( APIConstants.DETAILS ) : -")
            throw ZCRMError.sdkError(code: ZCRMErrorCode.invalidOperation, message: "Not a valid dbType to access persistent DB : \( dbType )", details: nil)
        }
        guard let persistentDB = cacheDBHandler  else
        {
            try createDB()
            return try getPersistentDB(dbType: dbType)
        }
        return persistentDB
    }
    
    internal func getNonPersistentDB( dbType : DBType ) throws -> CacheDBHandler
    {
        var cacheHandler : CacheDBHandler?
        switch dbType {
        case .metaData:
            cacheHandler = metaAPIDB
        case .analyticsData:
            cacheHandler = analyticsAPIDB
        default :
            ZCRMLogger.logError(message: "\( ZCRMErrorCode.invalidOperation ) : Not a valid dbType to access persistent DB : \( dbType ), \( APIConstants.DETAILS ) : -")
            throw ZCRMError.sdkError(code: ZCRMErrorCode.invalidOperation, message: "Not a valid dbType to access persistent DB : \( dbType )", details: nil)
        }
        guard let nonPersistentDB = cacheHandler else
        {
            try createDB()
            return try getNonPersistentDB(dbType: dbType)
        }
        return nonPersistentDB
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
            if appConfigurations.appType == .zcrm
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
            throw ZCRMError.sdkError(code: ZCRMErrorCode.internalError, message: error.description, details: nil)
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
     
     NSURLSession delegate methods won't get invoked in some devices when app resumes from background. We have to resume atleast one task in that URLSession to resume the delegate method calls.
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
            if( status == APIConstants.CODE_ERROR && code == ZCRMErrorCode.noPermission)
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
                                    try ZCRMSDKClient.shared.getPersistentDB( dbType: .orgData ).deleteZCRMRecords(withModuleName: moduleName)
                                    try ZCRMSDKClient.shared.getPersistentDB( dbType: .userData ).deleteZCRMRecords(withModuleName: moduleName)
                                    try ZCRMSDKClient.shared.getNonPersistentDB( dbType: .metaData ).deleteZCRMRecords(withModuleName: moduleName)
                                    try ZCRMSDKClient.shared.getNonPersistentDB( dbType: .analyticsData ).deleteZCRMRecords(withModuleName: moduleName)
                                    try ZCRMSDKClient.shared.getPersistentDB( dbType: .appData ).deleteZCRMRecords(withModuleName: moduleName)
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

public extension ZCRMSDKClient
{
    struct CacheValidityTime
    {
        public var tagsAPI : Float = 3
        public var metaData : Float = 6
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

//
//  CommonUtil.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//
import Foundation
import CommonCrypto

let PhotoSupportedModules = ["Leads", "Contacts"]


public enum ZCRMError : Error
{
    case unAuthenticatedError( code : String, message : String, details : Dictionary< String, Any >? )
    case inValidError( code : String, message : String, details : Dictionary< String, Any >? )
    case maxRecordCountExceeded( code : String, message : String, details : Dictionary< String, Any >? )
    case fileSizeExceeded( code : String, message : String, details : Dictionary< String, Any >? )
    case processingError( code : String, message : String, details : Dictionary< String, Any >? )
    case sdkError( code : String, message : String, details : Dictionary< String, Any >? )
    case networkError( code : String, message : String, details : Dictionary< String, Any >? )

    static func getResponseNilSDKError(details: Dictionary<String, Any>? = nil) -> ZCRMError {
        ZCRMError.sdkError(
            code: ZCRMErrorCode.responseNil,
            message: ZCRMErrorMessage.responseJSONNilMsg,
            details: details
        )
    }

    static func getValueNilInavlidError(_ message: String, details: Dictionary<String, Any>? = nil) -> ZCRMError {
        ZCRMError.inValidError(
            code: ZCRMErrorCode.valueNil,
            message: "\(ZCRMErrorCode.invalidData): \(message)",
            details: details
        )
    }
}

public struct ZCRMErrorCode
{
    public static var invalidData = "INVALID_DATA"
    public static var internalError = "INTERNAL_ERROR"
    public static var responseNil = "RESPONSE_NIL"
    public static var valueNil = "VALUE_NIL"
    public static var mandatoryNotFound = "MANDATORY_NOT_FOUND"
    public static var responseRootKeyNil = "RESPONSE_ROOT_KEY_NIL"
    public static var fileSizeExceeded = "FILE_SIZE_EXCEEDED"
    public static var maxCountExceeded = "MAX_COUNT_EXCEEDED"
    public static var fieldNotFound = "FIELD_NOT_FOUND"
    public static var oauthTokenNil = "OAUTHTOKEN_NIL"
    public static var oauthFetchError = "OAUTH_FETCH_ERROR"
    public static var unableToConstructURL = "UNABLE_TO_CONSTRUCT_URL"
    public static var invalidFileType = "INVALID_FILE_TYPE"
    public static var invalidModule = "INVALID_MODULE"
    public static var processingError = "PROCESSING_ERROR"
    public static var moduleFieldNotFound = "MODULE_FIELD_NOT_FOUND"
    public static var invalidOperation = "INVALID_OPERATION"
    public static var notSupported = "NOT_SUPPORTED"
    public static var noPermission = "NO_PERMISSION"
    public static var typeCastError = "TYPECAST_ERROR"
    public static var moduleNotAvailable = "MODULE_NOT_AVAILABLE"
    public static var noInternetConnection = "NO_INTERNET_CONNECTION"
    public static var dbNotCreated = "DB_NOT_CREATED"
    public static var requestTimeOut = "REQUEST_TIMEOUT"
    public static var insufficientData = "INSUFFICIENT_DATA"
    public static var networkConnectionLost = "NETWORK_CONNECTION_LOST"
    public static var cannotFindHost = "CANNOT_FIND_HOST"
    public static var notModified = "NOT_MODIFIED"
    public static let limitExceeded = "LIMIT_EXCEEDED"
    public static let unhandled = "UNHANDLED"
    public static let portalNotFound = "PORTAL_NOT_FOUND"
    public static let duplicateData = "DUPLICATE_DATA"
    public static let initializationError = "INITIALIZATION_ERROR"
    public static let sandboxDisabled = "SANDBOX_DISABLED"
    public static let invalidToken = "INVALID_TOKEN"
    public static let oauthScopeMismatch = "OAUTH_SCOPE_MISMATCH"
}

public struct ZCRMErrorMessage
{
    public static let invalidIdMsg  = "The given id seems to be invalid."
    public static let apiMaxRecordsMsg = "Cannot process more than 100 records at a time."
    public static let responseNilMsg  = "Response is nil."
    public static let responseJSONNilMsg = "Response JSON is empty."
    public static let oauthTokenNilMsg = "The oauth token is nil."
    public static let oauthFetchErrorMsg = "There was an error in fetching oauth Token."
    public static let unableToConstructURLMsg = "There was a problem constructing the URL."
    public static let invalidFileTypeMsg = "The file you have chosen is not supported. Please choose a PNG, JPG, JPEG, BMP, or GIF file type."
    public static let dbDataNotAvailable = "ZCRM iOS SDK DB - Data NOT Available."
    public static let permissionDenied = "permission denied."
    public static let notModifiedSinceMsg = "There is no changes made after the specified time."
    public static let unableToConstructComponent = "Insufficient data to construct component."
    public static let invalidPortalType = "The portal type seems to be invalid."
    public static let missingPortalName = "Cannot initialise zcrmcp without portal name. Include the header X-CRMPORTAL in headers."
    public static let limitExceeded = "Limit value cannot be more than 200."
    public static let maxFieldCountExceeded = "Fields count cannot be more than 50."
    public static let invalidTax = "Tax id cannot be nil."
    public static let invalidDealsModule = "This operation is available only for Deals Module."
    public static let invalidTemplateCategory = "this template category is not applicable for BIGIN"
}

public extension Error
{
    var code : Int
    {
        return ( self as NSError ).code
    }
    
    var description : String
    {
        return ( self as NSError ).description
    }
    
    var ZCRMErrordetails : ( code : String, description : String, details : Dictionary< String, Any>? )?
    {
        guard let error = self as? ZCRMError else {
            return nil
        }
        switch error
        {
            case .unAuthenticatedError( let code, let desc, let details ):
                return ( code, desc, details )
            case .inValidError( let code, let desc, let details ):
                return ( code, desc, details )
            case .maxRecordCountExceeded( let code, let desc, let details ):
                return ( code, desc, details )
            case .fileSizeExceeded( let code, let desc, let details ):
                return ( code, desc, details )
            case .processingError( let code, let desc, let details ):
                return ( code, desc, details )
            case .sdkError( let code, let desc, let details ):
                return ( code, desc, details )
            case .networkError( let code, let desc, let details ):
                return ( code, desc, details )
        }
    }
}

public enum ZCRMSortOrder : String
{
    case ascending = "asc"
    case descending = "desc"
}

public enum ZCRMAccessType : String
{
    case production = "Production"
    case development = "Development"
    case sandBox = "Sandbox"
}

public enum ZCRMCommunicationPreferences : String
{
    case email = "Email"
    case phone = "Phone"
    case survey = "Survey"
}

public enum ZCRMCurrencyRoundingOption : String
{
    case roundOff = "round_off"
    case roundDown = "round_down"
    case roundUp = "round_up"
    case normal = "normal"
}

public enum ZCRMTrigger : String
{
    case workFlow = "workflow"
    case approval = "approval"
    case bluePrint = "blueprint"
}

internal enum ZCRMCacheFlavour : String
{
    case noCache = "NO_CACHE"
    case urlVsResponse = "URL_VS_RESPONSE"
    case data = "DATA"
    case forceCache = "FORCE_CACHE"
}

public enum ZCRMDrillBy : String
{
    case user = "user"
    case role = "role"
    case criteria = "criteria"
}

internal struct FieldDataTypeConstants
{
    static let subform = "subform"
    static let lookup = "lookup"
    static let userLookup = "userlookup"
    static let ownerLookup = "ownerlookup"
    static let multiModuleLookup = "multi_module_lookup"
    static let picklist = "picklist"
    static let multiSelectPicklist = "multiselectpicklist"
    static let fileUpload = "fileupload"
    static let multiSelectLookup = "multiselectlookup"
}

public enum ZCRMAccessPermission
{
    public enum Readable : String
    {
        case fullAccess = "full_access"
        case readOnly = "read_only"
        case readWrite = "read_write"
        case unhandled
    }
    
    public enum Writable : String
    {
        case fullAccess = "full_access"
        case readOnly = "read_only"
        case readWrite = "read_write"
        
        func toReadable() -> ZCRMAccessPermission.Readable
        {
            switch self
            {
            case .fullAccess :
                return .fullAccess
            case .readOnly :
                return .readOnly
            case .readWrite :
                return .readWrite
            }
        }
    }
    
    static func getType( rawValue : String ) -> ZCRMAccessPermission.Readable
    {
        if rawValue == "full_access" || rawValue == "read_write_delete"
        {
            return .fullAccess
        }
        else if rawValue == "read_only"
        {
            return .readOnly
        }
        else if rawValue == "read_write"
        {
            return .readWrite
        }
        else
        {
            ZCRMLogger.logDebug(message: "UNHANDLED -> Access Permission : \( rawValue )")
            return .unhandled
        }
    }
}

public enum ZCRMSharedUsersCategory
{
    public enum Readable : String
    {
        case all
        case selected
        case onlyMe
        case unHandled
    }
    
    public enum Writable : String
    {
        case all = "public"
        case selected = "shared"
        case onlyMe = "only_to_me"
        
        func toReadable() -> ZCRMSharedUsersCategory.Readable
        {
            switch self
            {
            case .all :
                return .all
            case .selected :
                return .selected
            case .onlyMe :
                return .onlyMe
            }
        }
    }
    
    static func getType( _ rawValue : String ) -> ZCRMSharedUsersCategory.Readable
    {
        if rawValue == "public" || rawValue == "all"
        {
            return .all
        }
        else if rawValue == "only_me" || rawValue == "only_to_me"
        {
            return .onlyMe
        }
        else if rawValue == "shared" || rawValue == "selected"
        {
            return .selected
        }
        else
        {
            ZCRMLogger.logDebug(message: "UNHANDLED -> Shared Users Type : \( rawValue )")
            return .unHandled
        }
    }
}

public enum ZCRMSelectedUsersType : String
{
    case roles
    case users
    case territories
    case groups
    case unHandled
    
    static func getType( _ rawValue : String ) -> ZCRMSelectedUsersType
    {
        if let type = ZCRMSelectedUsersType(rawValue: rawValue)
        {
            return type
        }
        else
        {
            ZCRMLogger.logDebug(message: "UNHANDLED -> Selected User's Type : \( rawValue )")
            return .unHandled
        }
    }
}

public enum ZCRMLogLevels : Int
{
    case byDefault = 0
    case info = 1
    case debug = 2
    case error = 3
    case fault = 4
}

public enum ZCRMAppType : String
{
    case zcrm = "zcrm"
    case solutions = "solutions"
    case bigin = "bigin"
    case zvcrm = "zvcrm"
    case zcrmcp = "zcrmcp"
}

public enum ZCRMOrganizationType : String
{
    case production = "production"
    case sandBox = "sandbox"
    case developer = "developer"
    case bigin = "bigin"
}

internal enum ZCRMSDKDataType
{
    case string
    case int
    case int64
    case double
    case bool
    case dictionary
    case arrayOfDictionaries
    case nsNull
    case zcrmRecordDelegate
    case zcrmUserDelegate
    case zcrmProfileDelegate
    case zcrmRoleDelegate
    case zcrmInventoryLineItem
    case zcrmPriceBookPricing
    case zcrmEventParticipant
    case zcrmLineTax
    case zcrmTaxDelegate
    case zcrmTagDelegate
    case arrayOfStrings
    case zcrmDataProcessingBasisDetails
    case zcrmLayoutDelegate
    case zcrmSubformRecord
    case arrayOfZCRMSubformRecord
    case undefined
}

@available(*, deprecated, message: "use ZCRMUser.Category enum instead")
public enum ZCRMUserTypes : String
{
    case allUsers = "AllUsers"
    case activeUsers = "ActiveUsers"
    case deactiveUsers = "DeactiveUsers"
    case notConfirmedUsers = "NotConfirmedUsers"
    case confirmedUsers = "ConfirmedUsers"
    case activeConfirmedUsers = "ActiveConfirmedUsers"
    case deletedUsers = "DeletedUsers"
    case adminUsers = "AdminUsers"
    case activeConfirmedAdmins = "ActiveConfirmedAdmins"
}

public enum ZCRMTrashRecordTypes : String
{
    case all
    case recycle
    case permanent
}

internal enum ZCRMMaxFileSize : Int64 {
    case notesAttachment = 20971520 // 20 MB
    case attachment = 104857600 // 100 MB
    case profilePhoto = 5242880 // 5 MB
    case entityImageAttachment = 2097152 // 2 MB
    case emailAttachment = 10485760 // 10 MB
}

public enum ZCRMVariableType : String
{
    case singleLine = "text"
    case currency = "currency"
    case date = "date"
    case datetime = "datetime"
    case decimal = "double"
    case email = "email"
    case longInteger = "long"
    case multiLine = "textarea"
    case number = "integer"
    case percent = "percent"
    case phone = "phone"
    case url = "website"
    case checkbox = "checkbox"
}

public enum ZCRMTemplateType : String
{
    case systemTemplates = "system_templates"
    case customTemplates = "custom_templates"
    case normal = "normal"
    case draft = "draft"
    case unhandled
    
    static func getType( rawValue : String? ) -> ZCRMTemplateType?
    {
        guard let rawValue = rawValue else
        {
            return nil
        }
        if let type = ZCRMTemplateType( rawValue : rawValue)
        {
            return type
        }
        else
        {
            ZCRMLogger.logDebug(message: "UNHANDLED -> Template Sub type : \( rawValue )")
            return .unhandled
        }
    }
}

public enum ZCRMTemplateEditorMode : String
{
    case plainText = "plain_text"
    case richText = "rich_text"
    case gallery = "gallery"
    case unhandled
    
    static func getType( rawValue : String ) -> ZCRMTemplateEditorMode
    {
        if let type = ZCRMTemplateEditorMode( rawValue : rawValue)
        {
            return type
        }
        else
        {
            ZCRMLogger.logDebug(message: "UNHANDLED -> Template Sub type : \( rawValue )")
            return .unhandled
        }
    }
}

public enum ZCRMTemplateCategory : String
{
    case favorite
    case createdByMe = "created_by_me"
    case sharedWithMe = "shared_with_me"
    case associated
    case draft
    
    static func getString(for category: ZCRMTemplateCategory, isBigin: Bool) -> String {
       switch category {
            case .favorite:
                return isBigin ? "Favorite" : "favorite"
            case .createdByMe:
                return isBigin ? "CreatedByMe" : "created_by_me"
            case .sharedWithMe:
                return isBigin ? "SharedWithMe" : "shared_with_me"
            case .associated:
                return isBigin ? "" : "associated"
            case .draft:
                return isBigin ? "" : "draft"
        }
    }
}

public enum ZCRMCountryDomain : String
{
    case eu = "eu"
    case `in` = "in"
    case com = "com"
    case cn = "com.cn"
    case au = "com.au"
    case jp = "jp"
}

public extension Dictionary
{
    /**
      Returns **true** if the dictionary has the given key
     
     - Parameter forKey : Key which needs to be checked
     - Returns: A Boolean indicating whether the key is present in the dictionary or not
     */
    func hasKey( forKey : Key ) -> Bool
    {
        return self[ forKey ] != nil
    }
    
    /**
      Returns **true** if the given key in the dictionary has a **Non Nil** value
     
     - Parameter forKey : Key which needs to be checked
     - Returns: A Boolean indicating whether the given key has a **Non Nil** value
     */
    func hasValue(forKey : Key) -> Bool
    {
        return self[forKey] != nil && !(self[forKey] is NSNull)
    }
    
    /**
      To Check whether the dictionary has a **Non Nil** value for the given key or not
     
     - Parameter forKey : Key which needs to be checked
     - Throws: When the given key doesn't have a value in the dictionary
     */
    func valueCheck( forKey : Key ) throws
    {
        if hasValue(forKey: forKey) == false
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.valueNil) : \( forKey ) must not be nil, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ZCRMErrorCode.valueNil, message : "\( forKey ) must not be nil", details : nil )
        }
    }
    
    /**
      To get the value of the key from the dictinoary as an optional **Any** type
     
     - Parameter key : Key whose value has to be fetched from the dictionary
     - Returns: The value of the key from the dictionary
     */
    func optValue(key: Key) -> Any?
    {
        if( self.hasValue( forKey : key ) ), let value = self[ key ]
        {
            return value
        }
        else
        {
            return nil
        }
    }
    
    /**
      To get the value of the key from the dictinoary as an optional value of specified type
     
     - Parameter key : Key whose value has to be fetched from the dictionary
     - Returns: The value of the key from the dictionary
     */
    func optValue<T>(key: Key) -> T?
    {
        if let value = optValue( key: key ) as? T
        {
            return value
        }
        return nil
    }
    
    /**
      To get the value of the key from the dictinoary as an optional **String** type
     
     - Parameter key : Key whose value has to be fetched from the dictionary as **String** type
     - Returns: The value Conditionally downcasted **( as? )** into type String
     */
    func optString(key : Key) -> String?
    {
        return optValue(key: key) as? String
    }
    
    /**
     To get the value of the key from the dictinoary as an optional **Int** type
    
    - Parameter key : Key whose value has to be fetched from the dictionary as **Int** type
    - Returns: The value Conditionally downcasted **( as? )** into type Int
    */
    func optInt(key : Key) -> Int?
    {
        return optValue(key: key) as? Int
    }
    
    /**
     To get the value of the key from the dictinoary as an optional **Int64** type
    
    - Parameter key : Key whose value has to be fetched from the dictionary as **Int64** type
    - Returns: A Int64 value, if the value can be Converted into Int64 type
    */
    func optInt64(key : Key) -> Int64?
    {
        guard let stringID = optValue(key: key) as? String else {
            return nil
        }
        
        return Int64(stringID)
    }
    
    /**
     To get the value of the key from the dictinoary as an optional **Double** type
    
    - Parameter key : Key whose value has to be fetched from the dictionary as **Double** type
    - Returns: The value Conditionally downcasted **( as? )** into type Double
    */
    func optDouble(key : Key) -> Double?
    {
        return optValue(key: key) as? Double
    }
    
    /**
     To get the value of the key from the dictinoary as an optional **Boolean** type
    
    - Parameter key : Key whose value has to be fetched from the dictionary as **Boolean** type
    - Returns: The value Conditionally downcasted **( as? )** into type Boolean
    */
    func optBoolean(key : Key) -> Bool?
    {
        return optValue(key: key) as? Bool
    }
    
    /**
     To get the value of the key from the dictinoary as an optional **Dictionary** type with **String type** as Key and **Any type** as value
    
    - Parameter key : Key whose value has to be fetched from the dictionary as **Dictionary** type
    - Returns: The value Conditionally downcasted **( as? )** into a Dictionary
    */
    func optDictionary(key : Key) -> Dictionary<String, Any>?
    {
        return optValue(key: key) as? Dictionary<String, Any>
    }
    
    /**
     To get the value of the key from the dictinoary as an optional **Array of Any**
    
    - Parameter key : Key whose value has to be fetched from the dictionary as **Array** type
    - Returns: The value Conditionally downcasted **( as? )** into an Array
    */
    func optArray(key : Key) -> Array<Any>?
    {
        return optValue(key: key) as? Array<Any>
    }
    
    /**
     To get the value of the key from the dictinoary as an optional **Array of Dictionary** type
    
    - Parameter key : Key whose value has to be fetched from the dictionary as **Array of Dictionary** type
    - Returns: The value Conditionally downcasted **( as? )** into an Array of Dictionary, With the dictionary having String type as Key and Any type as Value
    */
    func optArrayOfDictionaries( key : Key ) -> Array< Dictionary < String, Any > >?
    {
        return ( optValue( key : key ) as? Array< Dictionary < String, Any > > )
    }
    
    /**
     To get the value of the key from the dictinoary as an **Int**
    
    - Parameter key : Key whose value has to be fetched from the dictionary as **Int**
    - Returns: An Int value
    - Throws : If the value cannot be converted into Int
    */
    func getInt( key : Key ) throws -> Int
    {
        try self.valueCheck( forKey : key )
        guard let value = optInt( key : key ) else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.typeCastError) : \( key ) - Expected type -> INT, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ZCRMErrorCode.typeCastError, message : "\( key ) - Expected type -> INT", details : nil )
        }
        return value
    }
    
    /**
     To get the value of the key from the dictinoary as an **Int64**
    
    - Parameter key : Key whose value has to be fetched from the dictionary as **Int64**
    - Returns: An Int64 value
    - Throws : If the value cannot be converted into Int64
    */
    func getInt64( key : Key ) throws -> Int64
    {
        try self.valueCheck( forKey : key )
        guard let value = optInt64( key : key ) else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.typeCastError) : \( key ) - Expected type -> INT64, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ZCRMErrorCode.typeCastError, message : "\( key ) - Expected type -> INT64", details : nil )
        }
        return value
    }
        
    /**
     To get the value of the key from the dictinoary as a **String**
    
    - Parameter key : Key whose value has to be fetched from the dictionary as **String**
    - Returns: A String value
    - Throws : If the value cannot be converted into String
    */
    func getString( key : Key ) throws -> String
    {
        try self.valueCheck( forKey : key )
        guard let value = optString( key : key ) else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.typeCastError) : \( key ) - Expected type -> STRING, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ZCRMErrorCode.typeCastError, message : "\( key ) - Expected type -> STRING", details : nil )
        }
        return value
    }
    
    /**
     To get the value of the key from the dictinoary as a **Boolean**
    
    - Parameter key : Key whose value has to be fetched from the dictionary as **Boolean**
    - Returns: A Boolean value
    - Throws : If the value cannot be converted into Boolean
    */
    func getBoolean( key : Key ) throws -> Bool
    {
        try self.valueCheck( forKey : key )
        guard let value = optBoolean( key : key ) else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.typeCastError) : \( key ) - Expected type -> BOOLEAN, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ZCRMErrorCode.typeCastError, message : "\( key ) - Expected type -> BOOLEAN", details : nil )
        }
        return value
    }
    
    /**
     To get the value of the key from the dictinoary as a **Double**
    
    - Parameter key : Key whose value has to be fetched from the dictionary as **Double**
    - Returns: A Double value
    - Throws : If the value cannot be converted into Double
    */
    func getDouble( key : Key ) throws -> Double
    {
        try self.valueCheck( forKey : key )
        guard let value = optDouble( key : key ) else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.typeCastError) : \( key ) - Expected type -> DOUBLE, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ZCRMErrorCode.typeCastError, message : "\( key ) - Expected type -> DOUBLE", details : nil )
        }
        return value
    }
    
    /**
     To get the value of the key from the dictinoary as an **Array of Any**
    
    - Parameter key : Key whose value has to be fetched from the dictionary as **Array of Any**
    - Returns: An Array of type Any
    - Throws : If the value cannot be converted into an Array of Any
    */
    func getArray( key : Key ) throws -> Array< Any >
    {
        try self.valueCheck( forKey : key )
        guard let value = optArray( key : key ) else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.typeCastError) : \( key ) - Expected type -> ARRAY< ANY >, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ZCRMErrorCode.typeCastError, message : "\( key ) - Expected type -> ARRAY< ANY >", details : nil )
        }
        return value
    }
    
    /**
     To get the value of the key from the dictinoary as a **Dictionary with String type as key and Any type as Value**
    
    - Parameter key : Key whose value has to be fetched from the dictionary as **Dictionary**
    - Returns: A Dictionary
    - Throws : If the value cannot be converted into Dictionary
    */
    func getDictionary( key : Key ) throws -> Dictionary< String, Any >
    {
        try self.valueCheck( forKey : key )
        guard let value = optDictionary( key : key ) else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.typeCastError) : \( key ) - Expected type -> DICTIONARY< STRING, ANY >, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ZCRMErrorCode.typeCastError, message : "\( key ) - Expected type -> DICTIONARY< STRING, ANY >", details : nil )
        }
        return value
    }
    
    /**
     To get the value of the key from the dictinoary as a **Array of Dictionary with String type as key and Any type as Value**
    
    - Parameter key : Key whose value has to be fetched from the dictionary as **Array of Dictionary**
    - Returns: An Array of Dictionary
    - Throws : If the value cannot be converted into an Array of Dictionary
    */
    func getArrayOfDictionaries( key : Key ) throws -> Array< Dictionary < String, Any > >
    {
        try self.valueCheck( forKey : key )
        guard let value = optArrayOfDictionaries( key : key ) else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.typeCastError) : \( key ) - Expected type -> ARRAY< DICTIONARY< STRING, ANY > >, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ZCRMErrorCode.typeCastError, message : "\( key ) - Expected type -> ARRAY< DICTIONARY < STRING, ANY > >", details : nil )
        }
        return value
    }
    
    /**
     To get the value of the key from the dictinoary
    
    - Parameter key : Key whose value has to be fetched from the dictionary
    - Returns: A value ot type **Any**
    - Throws : If the key is not found in the dictionary or value of the key is nil
    */
    func getValue( key : Key ) throws -> Any
    {
        guard let value = optValue( key: key ) else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.processingError) : \( key ) - Key Not found - \( key ), \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ZCRMErrorCode.processingError, message : "\( key ) - Key not found - \( key )", details : nil )
        }
        return value
    }
    
    func getValue< T >( key : Key ) throws -> T
    {
        guard let value = try getValue( key: key ) as? T else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.typeCastError) : \( key ) - Expected type -> \( T.self ), \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ZCRMErrorCode.typeCastError, message : "\( key ) - Expected type -> \( T.self )", details : nil )
        }
        return value
    }
    
    /**
      To convert a dictionary into a JSON String with **ascii encoding**
     
     - Returns: JSONString
     */
    func convertToJSON() -> String?
    {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        if let data = jsonData
        {
            let jsonString = String(data: data, encoding: String.Encoding.ascii)
            return jsonString
        }
        return nil
    }
    
    /**
     To convert a dictionary into a JSON String with **UTF-8 encoding**
    
    - Returns: JSONString
    */
    func toJSON() -> String?
    {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [])
        if let data = jsonData
        {
            let jsonString = String(data: data, encoding: .utf8)
            return (jsonString?.base64Encoded())
        }
        return nil
    }
    
    /**
      To check if 2 dictionary has a same Set of Keys
     
     - Parameter dictionary : The dictionary whose keys has to be checked with
     - Returns: **True** if both the dictionary has the same Set of Keys
     */
    func equateKeys( dictionary : [ String : Any ] ) -> Bool
    {
        let dictKeys = dictionary.keys
        var isEqual : Bool = true
        for key in self.keys
        {
            if let key = key as? String, dictKeys.firstIndex(of: key) == nil
            {
                isEqual = false
            }
        }
        return isEqual
    }
    
    /**
     To convert a dictionary into a JSON String with **UTF-8 encoding**
    
    - Returns: JSONString
    */
    func toString() -> String?
    {
        let data = try? JSONSerialization.data( withJSONObject: self, options: .prettyPrinted)
        if let jsonData = data
        {
            let string = String(data: jsonData, encoding: .utf8)
            return string
        }
        return nil
    }
    
    /**
     To convert a dictionary into a JSON String with **UTF-8 encoding**
    
    - Returns: JSONString without white space
    */
    internal func toStringWithoutWhiteSpace() -> String?
    {
        let data = try? JSONSerialization.data( withJSONObject: self, options: .prettyPrinted)
        if let jsonData = data
        {
            var string = String(data: jsonData, encoding: .utf8)
            string = string?.components(separatedBy: "\n").joined(separator: "")
            string = string?.components(separatedBy: "\"").enumerated().map{ ( $0 % 2 == 1 ) ? $1 : $1.replacingOccurrences(of: " ", with: "") }.joined(separator: "\"")
            return string
        }
        return nil
    }
    
    internal func setCriteria() -> String? {
        let data = try? JSONSerialization.data(withJSONObject: [self], options: [])
        if let jsonData = data {
            if let string = String(data: jsonData, encoding: .utf8) {
                let modifiedString = string.replacingOccurrences(of: "\\\\", with: " ")
                return modifiedString
            }
        }
        return nil
    }
}

internal extension Array
{
    func ArrayOfDictToStringArray () -> String {
        var stringArray: [String] = []
        
        self.forEach {
            if let dictionary = $0 as? Dictionary<String, Any>, let string = dictionary.convertToJSON()
            {
                stringArray.append(string)
            }
        }
        
        let dup = stringArray.joined(separator: "-")
        return dup
    }
    
    func ArrayOfDictToString() -> String {
        var stringArray: [String] = []
        
        self.forEach {
            if let dictionary = $0 as? Dictionary<String, Any>, let str = dictionary.toString()
            {
                stringArray.append(str)
            }
        }
        
        let dup = stringArray.joined(separator: ",\"and\",")
        return dup
    }
	
}

func optZCRMValue( _ value : Any ) -> Any?
{
    switch getTypeOf(value)
    {
    case .dictionary:
        if let dict = value as? [ String : Any ]
        {
            return dict.copy()
        }
    case .arrayOfDictionaries:
        if let value = value as? [ [ String : Any ] ]
        {
            return value.copy()
        }
    case .zcrmRecordDelegate:
        if let value = value as? ZCRMRecordDelegate
        {
            return value.copy()
        }
    case .zcrmUserDelegate:
        if let value = value as? ZCRMUserDelegate
        {
            return value.copy()
        }
    case .zcrmInventoryLineItem:
        if let value = value as? ZCRMInventoryLineItem
        {
            return value.copy()
        }
    case .zcrmPriceBookPricing:
        if let value = value as? ZCRMPriceBookPricing
        {
            return value.copy()
        }
    case .zcrmEventParticipant:
        if let value = value as? ZCRMEventParticipant
        {
            return value.copy()
        }
    case .zcrmLineTax:
        if let value = value as? ZCRMLineTax
        {
            return value.copy()
        }
    case .zcrmTaxDelegate:
        if let value = value as? ZCRMTaxDelegate
        {
            return value.copy()
        }
    case .zcrmTagDelegate:
        if let value = value as? ZCRMTagDelegate
        {
            return value.copy()
        }
    case .zcrmDataProcessingBasisDetails:
        if let value = value as? ZCRMDataProcessBasisDetails
        {
            return value.copy()
        }
    case .zcrmLayoutDelegate:
        if let value = value as? ZCRMLayoutDelegate
        {
            return value.copy()
        }
    case .zcrmSubformRecord:
        if let value = value as? ZCRMSubformRecord
        {
            return value.copy()
        }
    case .arrayOfZCRMSubformRecord:
        if let value = value as? [ ZCRMSubformRecord ]
        {
            return value.copy()
        }
    default:
        return value
    }
    return value
}

extension Dictionary
{
    func copy() -> Dictionary
    {
        var tempDict : Dictionary = type(of: self).init()
        for ( key, value ) in self
        {
            if let copiedValue = optZCRMValue( value ) as? Value
            {
                tempDict.updateValue( copiedValue, forKey: key)
            }
        }
        return tempDict
    }
}

extension Array
{
    func copy() -> Array
    {
        var tempArray : Array = type(of: self).init()
        for value in self
        {
            if let copiedValue = optZCRMValue( value ) as? Element
            {
                tempArray.append( copiedValue )
            }
        }
        return tempArray
    }
}

public extension String
{
    func pathExtension() -> String
    {
        return self.nsString.pathExtension
    }
    
    func deleteLastPathComponent() -> String
    {
        return self.nsString.deletingLastPathComponent
    }
    
    func lastPathComponent( withExtension : Bool = true ) -> String
    {
        let lpc = self.nsString.lastPathComponent
        return withExtension ? lpc : lpc.nsString.deletingPathExtension
    }
    
    var nsString : NSString
    {
        return NSString( string : self )
    }
    
    func boolValue() -> Bool
    {
        switch self
        {
        case "True", "true", "yes", "1" :
            return true
        case "False", "false", "no", "0" :
            return false
        default :
            return false
        }
    }
    
    var dateFromISO8601 : Date?
    {
        return Formatter.iso8601.date( from : self )   // "Nov 14, 2017, 10:22 PM"
    }
    
    var dateFromISO8601WithTimeZone : Date?
    {
        return Formatter.iso8601WithTimeZone.date( from : self )
    }
    
    var dateComponents : DateComponents?
    {
        if let date : Date = Formatter.iso8601WithTimeZone.date( from : self )
        {
            return date.dateComponents
        }
        return nil
    }
    
    var millisecondsSince1970 : Double?
    {
        if let date : Date = Formatter.iso8601WithTimeZone.date( from : self )
        {
            return date.millisecondsSince1970
        }
        return nil
    }
    
    var removeHTMLTags: String
    {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "&[^;]+;", with: "", options:.regularExpression, range: nil)
    }
	
    func convertToDictionary() -> [String: String]? {
        if let data = self.data(using: .utf8)
        {
            let anyResult = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            return anyResult as? [String: String]
        }
        return nil
    }
    
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
    
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func toDictionary() -> [ String : Any ]?
    {
        if let decoded = self.base64Decoded(), let data = decoded.data( using : .utf8 )
        {
            do
            {
                return try JSONSerialization.jsonObject( with : data, options : .mutableContainers ) as? [ String : Any ]
            }
            catch
            {
                ZCRMLogger.logError( message : "Error occured in String.toDictionary(). Details : \( error )" )
                return nil
            }
        }
        else
        {
            ZCRMLogger.logDebug(message: "String Data is Empty!")
            return nil
        }
    }
    
    func StringArrayToArrayOfDictionary () -> Array< Dictionary < String, Any > >
    {
        var arrayOfDic : Array< Dictionary < String, Any > > = []
        let array : [String] = self.components(separatedBy: "-")
        array.forEach {
            let json = $0
            if let val = json.convertToDictionary()
            {
                arrayOfDic.append(val)
            }
        }
        return arrayOfDic
    }
    
    func toNSArray() throws -> NSArray?
    {
        var nsarray : NSArray? = NSArray()
        if(self.isEmpty == true)
        {
            return nsarray
        }
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                nsarray = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray
            }
        }
        return nsarray
    }
    
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }
}

extension Int64
{
    func millisecondsToDateString( timezone : TimeZone = .current ) -> String
    {
        let formatter : DateFormatter = Formatter.iso8601WithTimeZone
        formatter.timeZone = timezone
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval( self ) / 1000).addingTimeInterval( TimeInterval(Double( self % 1000) / 1000  )) )
    }
}

extension Formatter
{
    static let iso8601 : DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar( identifier : .iso8601 )
        formatter.locale = Locale( identifier : "en_US_POSIX" )
        formatter.timeZone = TimeZone( secondsFromGMT : 0 )
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let iso8601WithTimeZone : DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar( identifier : .iso8601 )
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }()
}

public extension Date
{
    var iso8601 : String
    {
        return Formatter.iso8601.string( from : self )
    }
    
    var iso8601WithTimeZone : String
    {
        return Formatter.iso8601WithTimeZone.string( from : self ).replacingOccurrences( of : "Z", with : "+00:00" ).replacingOccurrences( of : "z", with : "+00:00" )
    }
    
    func millisecondsToISO( timeIntervalSince1970 : Double, timeZone : TimeZone ) -> String
    {
        let date = Date( timeIntervalSince1970 : timeIntervalSince1970 )
        return self.dateToISO( date : date, timeZone : timeZone )
    }
    
    func millisecondsToISO( timeIntervalSinceNow : Double, timeZone : TimeZone ) -> String
    {
        let date = Date( timeIntervalSinceNow : timeIntervalSinceNow )
        return self.dateToISO( date : date, timeZone : timeZone )
    }
    
    func millisecondsToISO( timeIntervalSinceReferenceDate : Double, timeZone : TimeZone ) -> String
    {
        let date = Date( timeIntervalSinceReferenceDate : timeIntervalSinceReferenceDate )
        return self.dateToISO( date : date, timeZone : timeZone )
    }
    
    private func dateToISO( date : Date, timeZone : TimeZone ) -> String
    {
        let formatter = Formatter.iso8601WithTimeZone
        formatter.timeZone = timeZone
        return formatter.string( from : date ).replacingOccurrences( of : "Z", with : "+00:00" ).replacingOccurrences( of : "z", with : "+00:00" )
    }
    
    var millisecondsSince1970 : Double
    {
        return ( self.timeIntervalSince1970 * 1000.0 )
    }
    
    var dateComponents : DateComponents
    {
        let calender = Calendar.current
        var dateComponents = DateComponents()
        
        let components = calender.dateComponents( [ Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.quarter, Calendar.Component.timeZone, Calendar.Component.weekOfMonth, Calendar.Component.weekOfYear, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second ], from : self )
        dateComponents.day = components.day
        dateComponents.month = components.month
        dateComponents.year = components.year
        dateComponents.timeZone = components.timeZone
        dateComponents.weekOfMonth = components.weekOfMonth
        dateComponents.quarter = components.quarter
        dateComponents.weekOfYear = components.weekOfYear
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        dateComponents.second = components.second
        return dateComponents
    }
}

extension Data
{
    public func sha256() -> String{
        return hexStringFromData(input: digest(input: self as NSData))
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}

internal extension Optional where Wrapped == String
{
    var notNilandEmpty : Bool
    {
        if let value = self, !value.isEmpty
        {
            return true
        }
        return false
    }
}

internal extension Optional
{
    var isNil : Bool
    {
        if self == nil
        {
            return true
        }
        return false
    }
}

public func getCurrentMillisecSince1970() -> Double
{
    return  Date().timeIntervalSince1970 * 1000
}

public func getCurrentMillisecSinceNow() -> Double
{
    return  Date().timeIntervalSinceNow * 1000
}

public func getCurrentMillisecSinceReferenceDate() -> Double
{
    return  Date().timeIntervalSinceReferenceDate * 1000
}

public func getCurrentMillisec( date : Date ) -> Double
{
    return Date().timeIntervalSince( date ) * 1000
}

public func moveFile(sourceUrl: URL, destinationUrl: URL)
{
    moveFile(filePath: sourceUrl.path, newFilePath: destinationUrl.path)
}

public func moveFile(filePath: String, newFilePath: String)
{
    do
    {
        try FileManager.default.moveItem(atPath: filePath, toPath: newFilePath)
    }
    catch(let err)
    {
        ZCRMLogger.logError(message: "Exception while moving file - \(err)")
    }
}


internal func fileDetailsCheck( filePath : String?, fileData : Data?, maxFileSize : ZCRMMaxFileSize) throws
{
    let maxFileSizeValue = maxFileSize.rawValue
    if let filePath = filePath
    {
        if ( FileManager.default.fileExists( atPath : filePath )  == false )
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.mandatoryNotFound) : File not found at given path : \( filePath ), \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ZCRMErrorCode.mandatoryNotFound, message : "File not found at given path : \( filePath )", details : nil )
        }
        if ( getFileSize( filePath : filePath ) > maxFileSizeValue )
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.fileSizeExceeded) : Cannot upload. File size should not exceed \( maxFileSizeValue / 1048576 ) MB, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.fileSizeExceeded( code : ZCRMErrorCode.fileSizeExceeded, message : "Cannot upload. File size should not exceed \( maxFileSizeValue / 1048576) MB", details : nil )
        }
    }
    else if let fileData = fileData
    {
        if fileData.count > maxFileSizeValue
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.fileSizeExceeded) : Cannot upload. File size should not exceed \( maxFileSizeValue / 1048576) MB, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.fileSizeExceeded( code : ZCRMErrorCode.fileSizeExceeded, message : "Cannot upload. File size should not exceed \( maxFileSizeValue / 1048576) MB", details : nil )
        }
    }
}

internal func imageTypeValidation( _ filePath : String? ) throws
{
    let validImageExtensions : [ String ] = [ "PNG", "JPG", "JPEG", "BMP", "GIF", "png", "jpg", "jpeg", "bmp", "gif" ]
    if let filePath = filePath
    {
        let pathExtension = filePath.pathExtension()
        if !validImageExtensions.contains( pathExtension )
        {
            throw ZCRMError.processingError( code : ZCRMErrorCode.invalidFileType, message : ZCRMErrorMessage.invalidFileTypeMsg, details : nil )
        }
        
        guard UIImage(contentsOfFile: filePath) != nil else {
            throw ZCRMError.processingError( code : ZCRMErrorCode.invalidFileType, message : ZCRMErrorMessage.invalidFileTypeMsg, details : nil )
        }
    }
}

internal func getFileSize( filePath : String ) -> Int64
{
    do
    {
        let fileAttributes = try FileManager.default.attributesOfItem( atPath : filePath )
        if let fileSize = fileAttributes[ FileAttributeKey.size ] as? NSNumber
        {
            return ( fileSize ).int64Value
        }
        else
        {
            ZCRMLogger.logError(message: "Failed to get a size attribute from path : \( filePath )")
        }
    }
    catch
    {
        ZCRMLogger.logError(message: "Failed to get file attributes for local path: \( filePath ) with error: \( error )")
    }
    return 0
}

internal func getTypeOf( _ value : Any ) -> ZCRMSDKDataType
{
    if let _ = value as? String
    {
        return ZCRMSDKDataType.string
    }
    else if let _ = value as? Int
    {
        return ZCRMSDKDataType.int
    }
    else if let _ = value as? Int64
    {
        return ZCRMSDKDataType.int64
    }
    else if let _ = value as? Double
    {
        return ZCRMSDKDataType.double
    }
    else if let _ = value as? Bool
    {
        return ZCRMSDKDataType.bool
    }
    else if let _ = value as? [ String : Any ]
    {
        return ZCRMSDKDataType.dictionary
    }
    else if let _ = value as? [ [ String : Any ] ]
    {
        return ZCRMSDKDataType.arrayOfDictionaries
    }
    else if let _ = value as? NSNull
    {
        return ZCRMSDKDataType.nsNull
    }
    else if let _ = value as? ZCRMRecordDelegate
    {
        return ZCRMSDKDataType.zcrmRecordDelegate
    }
    else if let _ = value as? ZCRMUserDelegate
    {
        return ZCRMSDKDataType.zcrmUserDelegate
    }
    else if let _ = value as? ZCRMProfileDelegate
    {
        return ZCRMSDKDataType.zcrmProfileDelegate
    }
    else if let _ = value as? ZCRMRoleDelegate
    {
        return ZCRMSDKDataType.zcrmRoleDelegate
    }
    else if let _ = value as? ZCRMInventoryLineItem
    {
        return ZCRMSDKDataType.zcrmInventoryLineItem
    }
    else if let _ = value as? ZCRMPriceBookPricing
    {
        return ZCRMSDKDataType.zcrmPriceBookPricing
    }
    else if let _ = value as? ZCRMEventParticipant
    {
        return ZCRMSDKDataType.zcrmEventParticipant
    }
    else if let _ = value as? ZCRMLineTax
    {
        return ZCRMSDKDataType.zcrmLineTax
    }
    else if let _ = value as? ZCRMTaxDelegate
    {
        return ZCRMSDKDataType.zcrmTaxDelegate
    }
    else if let _ = value as? ZCRMTagDelegate
    {
        return ZCRMSDKDataType.zcrmTagDelegate
    }
    else if let _ = value as? [ String ]
    {
        return ZCRMSDKDataType.arrayOfStrings
    }
    else if let _ = value as? ZCRMDataProcessBasisDetails
    {
        return ZCRMSDKDataType.zcrmDataProcessingBasisDetails
    }
    else if let _ = value as? ZCRMLayoutDelegate
    {
        return ZCRMSDKDataType.zcrmLayoutDelegate
    }
    else if let _ = value as? ZCRMSubformRecord
    {
        return ZCRMSDKDataType.zcrmSubformRecord
    }
    else if let _ = value as? [ ZCRMSubformRecord ]
    {
        return ZCRMSDKDataType.arrayOfZCRMSubformRecord
    }
    else
    {
        return ZCRMSDKDataType.undefined
    }
}

internal func isEqual( lhs : Any?, rhs : Any? ) -> Bool
{
    if lhs == nil, rhs == nil
    {
        return true
    }
    else if let lhs = lhs, let rhs = rhs
    {
        let lhsType = getTypeOf( lhs )
        let rhsType = getTypeOf( rhs )
        
        if lhsType != rhsType
        {
            return false
        }
        else
        {
            switch lhsType
            {
            case .string :
                guard let lhsValue = lhs as? String, let rhsValue = rhs as? String else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .int :
                guard let lhsValue = lhs as? Int, let rhsValue = rhs as? Int else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .int64 :
                guard let lhsValue = lhs as? Int64, let rhsValue = rhs as? Int64 else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .double :
                guard let lhsValue = lhs as? Double, let rhsValue = rhs as? Double else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .bool :
                guard let lhsValue = lhs as? Bool, let rhsValue = rhs as? Bool else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .dictionary :
                guard let lhsValue = lhs as? [ String : Any ], let rhsValue = rhs as? [ String : Any ] else
                {
                    return false
                }
                return NSDictionary( dictionary : lhsValue ).isEqual( to : rhsValue )
            case .arrayOfDictionaries :
                guard let lhsValues = lhs as? [ [ String : Any ] ], let rhsValues = rhs as? [ [ String : Any ] ] else
                {
                    return false
                }
                if lhsValues.count != rhsValues.count
                {
                    return false
                }
                for index in 0..<lhsValues.count
                {
                    if !NSDictionary( dictionary : lhsValues[ index ] ).isEqual( to : rhsValues[ index ] )
                    {
                        return false
                    }
                }
                return true
            case .nsNull :
                return true
            case .zcrmRecordDelegate :
                guard let lhsValue = lhs as? ZCRMRecordDelegate, let rhsValue = rhs as? ZCRMRecordDelegate else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .zcrmUserDelegate :
                guard let lhsValue = lhs as? ZCRMUserDelegate, let rhsValue = rhs as? ZCRMUserDelegate else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .zcrmProfileDelegate :
                guard let lhsValue = lhs as? ZCRMProfileDelegate, let rhsValue = rhs as? ZCRMProfileDelegate else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .zcrmRoleDelegate :
                guard let lhsValue = lhs as? ZCRMRoleDelegate, let rhsValue = rhs as? ZCRMRoleDelegate else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .zcrmInventoryLineItem :
                guard let lhsValue = lhs as? ZCRMInventoryLineItem, let rhsValue = rhs as? ZCRMInventoryLineItem else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .zcrmPriceBookPricing :
                guard let lhsValue = lhs as? ZCRMPriceBookPricing, let rhsValue = rhs as? ZCRMPriceBookPricing else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .zcrmEventParticipant :
                guard let lhsValue = lhs as? ZCRMEventParticipant, let rhsValue = rhs as? ZCRMEventParticipant else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .zcrmLineTax :
                guard let lhsValue = lhs as? ZCRMLineTax, let rhsValue = rhs as? ZCRMLineTax else {
                    return false
                }
                return lhsValue == rhsValue
            case .zcrmTaxDelegate :
                guard let lhsValue = lhs as? ZCRMTaxDelegate, let rhsValue = rhs as? ZCRMTaxDelegate else {
                    return false
                }
                return lhsValue == rhsValue
            case .arrayOfStrings :
                guard let lhsValue = lhs as? [ String ], let rhsValue = rhs as? [ String ] else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .zcrmDataProcessingBasisDetails :
                guard let lhsValue = lhs as? ZCRMDataProcessBasisDetails, let rhsValue = rhs as? ZCRMDataProcessBasisDetails else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .zcrmLayoutDelegate :
                guard let lhsValue = lhs as? ZCRMLayoutDelegate, let rhsValue = rhs as? ZCRMLayoutDelegate else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .arrayOfZCRMSubformRecord :
                guard let lhsValue = lhs as? [ ZCRMSubformRecord ], let rhsValue = rhs as? [ ZCRMSubformRecord ] else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .zcrmTagDelegate:
                guard let lhsValue = lhs as? ZCRMTagDelegate, let rhsValue = rhs as? ZCRMTagDelegate else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .zcrmSubformRecord:
                guard let lhsValue = lhs as? ZCRMSubformRecord, let rhsValue = rhs as? ZCRMSubformRecord else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .undefined :
                return false
            }
        }
    }
    else
    {
        return false
    }
}

internal struct APIConstants
{
    static let BOUNDARY = String( format : "unique-consistent-string-%@", UUID.init().uuidString )
    
    static let ACTION : String = "action"
    static let DUPLICATE_FIELD : String = "duplicate_field"
    
    static let MESSAGE : String = "message"
    static let STATUS : String = "status"
    static let CODE : String = "code"
    static let CODE_ERROR : String = "error"
    static let CODE_ERRORS : String = "errors"
    static let CODE_SUCCESS : String = "success"
    static let INFO : String = "info"
    static let DETAILS : String = "details"
    static let PERMISSIONS : String = "permissions"
    
    static let MODULES : String = "modules"
    static let PRIVATE_FIELDS = "private_fields"
    static let HEADER_NAME = "header_name"
    static let PER_PAGE : String = "per_page"
    static let PAGE : String = "page"
    static let COUNT : String = "count"
    static let MORE_RECORDS : String = "more_records"
    static let PER_SET : String = "per_set"
    static let SET : String = "set"
    static let MORE_DATA : String = "more_data"
    static let AND : String = "AND"
    static let and : String = "and"

    static let REMAINING_COUNT_FOR_THIS_DAY : String = "X-RATELIMIT-LIMIT"
    static let REMAINING_COUNT_FOR_THIS_WINDOW : String = "X-RATELIMIT-REMAINING"
    static let REMAINING_TIME_FOR_THIS_WINDOW_RESET : String = "X-RATELIMIT-RESET"
    static let DATE : String = "Date"
    
    static let STRING_MOCK : String = "SDK_NIL"
    static let INT_MOCK : Int = -555
    static let INT64_MOCK : Int64 = -555
    static let DOUBLE_MOCK : Double = -55.5555555555555555
    static let BOOL_MOCK : Bool = false
    
    static let TRIGGER : String = "trigger"
    static let DUPLICATE_CHECK_FIELDS : String = "duplicate_check_fields"
    
    static let MAX_ALLOWED_FILE_SIZE_IN_MB : Int = 20
    static let MAX_ALLOWED_FILE_SIZE : Int = 20971520
    var ENABLED_DB_CACHE : Bool = true
    
    static let lineItemModules = [ ZCRMDefaultModuleAPINames.SALES_ORDERS, ZCRMDefaultModuleAPINames.PURCHASE_ORDERS, ZCRMDefaultModuleAPINames.INVOICES, ZCRMDefaultModuleAPINames.QUOTES ]
    static let API_VERSION_V2 = "v2"
    static let API = "api"
    static let API_VERSION_V2_2 = "v2.2"
    static let API_VERSION_V4 = "v4"
}

public struct ZCRMDefaultModuleAPINames
{
    public static let LEADS : String = "Leads"
    public static let ACCOUNTS : String = "Accounts"
    public static let CONTACTS : String = "Contacts"
    public static let DEALS : String = "Deals"
    public static let QUOTES : String = "Quotes"
    public static let SALES_ORDERS : String = "Sales_Orders"
    public static let INVOICES : String = "Invoices"
    public static let PURCHASE_ORDERS : String = "Purchase_Orders"
    public static let PRODUCTS : String = "Products"
    public static let EVENTS : String = "Events"
    public static let NOTES : String = "Notes"
    public static let ATTACHMENTS : String = "Attachments"
    public static let SOCIAL : String = "Social"
    public static let PRICE_BOOKS : String = "Price_Books"
    public static let CALLS : String = "Calls"
    public static let ORGANIZATIONS : String = "organizations"
    public static let TASKS : String = "Tasks"
    public static let ACTIVITIES : String = "Activities"
}

internal struct RequestParamKeys
{
    static let page : String = "page"
    static let perPage : String = "per_page"
    static let sortBy : String = "sort_by"
    static let sortOrder : String = "sort_order"
    static let id : String = "id"
    static let ids : String = "ids"
    static let roleId: String = "role_id"
    static let type : String = "type"
    static let ifModifiedSince : String = "If-Modified-Since"
    static let module : String = "module"
    static let lastMailIndex : String = "last_mail_index"
    static let startIndex : String = "start_index"
    static let dealsMail : String = "deals_mail"
    static let category : String = "category"
    static let criteria = "criteria"
    static let view = "view"
    static let regsrc = "regsrc"
    static let plan = "plan"
    static let device = "device"
    static let entityId = "entity_id"
    static let featureType = "feature_type"
}

/**
 To find the matching pattern in the content using regex
 
 - parameters:
    - regex : The regex that needs to be matched
    - text : The text from which the pattern needs to be found
 
 - returns: An array of string containing the matched patterns
 */
func findMatch(for regex: String, in text: String) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))
        var inlineAttachmentIds : [String] = [String]()
        _ = results.map {
            guard let range = Range($0.range, in: text) else {
                return
            }
            inlineAttachmentIds.append(String(text[range]))
        }
        return inlineAttachmentIds
    } catch {
        ZCRMLogger.logDebug(message: "ZCRM SDK - Invalid RegEx \(error)")
        return []
    }
}

var ACCOUNTSURL : String = String()
var CRM : String = "crm"
var BIGIN : String = "bigin"
var COUNTRYDOMAIN : String = "com"
var EMAIL : String = "email"

let AUTHORIZATION : String = "Authorization"
let USER_AGENT : String = "User-Agent"
let X_CRM_ORG : String = "X-CRM-ORG"
let X_ZOHO_SERVICE : String = "X-ZOHO-SERVICE"
let X_CRM_PORTAL : String = "X-CRMPORTAL"
let ZOHO_OAUTHTOKEN = "Zoho-oauthtoken"
let FREE_PLAN = "free"

struct JSONRootKey {
    static let DATA : String = "data"
    static let NIL : String = "NoRootKey" // used by FileAPIResponse
    static let TAGS : String = "tags"
    static let LAYOUTS : String = "layouts"
    static let FIELDS : String = "fields"
    static let CUSTOM_VIEWS : String = "custom_views"
    static let RELATED_LISTS : String = "related_lists"
    static let ORG : String = "org"
    static let USERS : String = "users"
    static let PROFILES : String = "profiles"
    static let ROLES : String = "roles"
    static let STAGES : String = "stages"
    static let TAXES : String = "taxes"
    static let ORG_TAXES : String = "org_taxes"
    static let TIMELINES : String = "timelines"
    static let ORG_EMAILS : String = "org_emails"
    static let VARIABLES : String = "variables"
    static let VARIABLE_GROUPS : String = "variable_groups"
    static let ORG_INFO : String = "org_info"
    static let TERRITORIES : String = "territories"
    static let ORGANIZATIONS : String = "organizations"
    static let FILTERS : String = "filters"
    static let CURRENCIES : String = "currencies"
    static let FEATURES : String = "features"
    static let BASE_CURRENCY : String = "base_currency"
    static let SHARE : String = "share"
    static let SHAREABLE_USER : String = "shareable_user"
    static let BLUEPRINT = "blueprint"
    static let SANDBOX = "sandbox"
    static let EMAIL_RELATED_LIST :String = "email_related_list"
    static let EMAILS :String = "Emails"
    static let INVENTORY_TEMPLATES : String = "inventory_templates"
    static let EMAIL_TEMPLATES : String = "email_templates"
    static let TEMPLATES : String = "templates"
    static let FROM_ADDRESSES : String = "from_addresses"
}

//MARK:- RESULT TYPES
//MARK:  Error Type (ZCRMError) is common to every Result Type
//MARK:  Result types can be handled in 2 ways:
//MARK:  1) Handle Result Types either by calling Resolve()
//MARK:  2) on them or use the traditional switch case pattern to handle success and failure seperately
public struct ZCRMResult {
    
    public enum DataURLResponse<Data: Any, Response: HTTPURLResponse>{
        case success(Data, Response)
        case failure(ZCRMError)
        
        public func resolve() throws -> (data:Data,response:Response){
            
            switch self {
            case .success(let data,let response):
                return (data,response)
                
            case .failure(let error):
                throw error
            } // switch
        } // func ends
    }
    
    public enum DataResponse<Data: Any,Response: CommonAPIResponse>{
        
        case success(Data,Response)
        case failure(ZCRMError)
        
        public func resolve() throws -> (data:Data,response:Response){
            
            switch self {
            case .success(let data,let response):
                return (data,response)
                
            case .failure(let error):
                throw error
            } // switch
        } // func ends
    }
    
    public enum Response<Response: CommonAPIResponse> {
        
        case success(Response)
        case failure(ZCRMError)
        
        public func resolve() throws -> Response{
            
            switch self {
            case .success(let response):
                return response
                
            case .failure(let error):
                throw error
            } // switch
        } // func ends
    }
    
    public enum Data<Data: Any> {
        
        case success(Data)
        case failure(ZCRMError)
        
        public func resolve() throws -> Data{
            
            switch self {
            case .success(let data):
                return data
                
            case .failure(let error):
                throw error
            } // switch
        } // func ends
    }
} // struct ends ..

public func typeCastToZCRMError( _ error : Error ) -> ZCRMError {
    if let typecastedError = error as? ZCRMError
    {
        return typecastedError
    }
    else
    {
        if [NSURLErrorDataNotAllowed, NSURLErrorNotConnectedToInternet].contains(error.code)
        {
            return ZCRMError.networkError( code : ZCRMErrorCode.noInternetConnection, message : error.localizedDescription, details : nil )
        }
        else if error.code == NSURLErrorTimedOut
        {
            return ZCRMError.networkError( code : ZCRMErrorCode.requestTimeOut, message : error.localizedDescription, details : nil )
        }
        else if error.code == NSURLErrorNetworkConnectionLost
        {
            return ZCRMError.networkError( code : ZCRMErrorCode.networkConnectionLost, message : error.localizedDescription, details : nil )
        }
        else if error.code == NSURLErrorCannotFindHost
        {
            return ZCRMError.networkError(code: ZCRMErrorCode.cannotFindHost, message: error.localizedDescription, details: nil)
        }
        return ZCRMError.sdkError( code : ZCRMErrorCode.internalError, message : error.description, details : nil )
    }
}

func getUserDelegate( userJSON : [ String : Any ] ) throws -> ZCRMUserDelegate
{
    let user : ZCRMUserDelegate = ZCRMUserDelegate( id : try userJSON.getInt64( key : "id" ), name : try userJSON.getString( key : "name" ) )
    for ( key, value ) in userJSON
    {
        user.data.updateValue( value, forKey: key)
    }
    return user
}

func relatedModuleCheck( module : String ) throws
{
    if module == ZCRMDefaultModuleAPINames.SOCIAL
    {
        ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidModule) : This feature is not supported for integrated modules, \( APIConstants.DETAILS ) : -")
        throw ZCRMError.inValidError(code : ZCRMErrorCode.invalidModule, message : "This feature is not supported for integrated modules", details : nil )
    }
    else if module == ZCRMDefaultModuleAPINames.NOTES || module == ZCRMDefaultModuleAPINames.ATTACHMENTS
    {
        ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidOperation) : Try using getNotes or getAttachments methods, \( APIConstants.DETAILS ) : -")
        throw ZCRMError.inValidError( code : ZCRMErrorCode.invalidOperation, message : "Try using getNotes or getAttachments methods", details : nil )
    }
}

func getTriggerArray( triggers : [ZCRMTrigger] ) -> [String]
{
    var triggerString : [String] = [String]()
    if triggers.contains(ZCRMTrigger.workFlow)
    {
        triggerString.append(ZCRMTrigger.workFlow.rawValue)
    }
    if triggers.contains(ZCRMTrigger.approval)
    {
        triggerString.append(ZCRMTrigger.approval.rawValue)
    }
    if triggers.contains(ZCRMTrigger.bluePrint)
    {
        triggerString.append(ZCRMTrigger.bluePrint.rawValue)
    }
    return triggerString
}

func getFieldVsApinameJSON( fields : [ZCRMField] ) -> [ String: ZCRMField ]
{
    var moduleFields : [ String : ZCRMField ] = [ String : ZCRMField ]()
    for field in fields
    {
        moduleFields[ field.apiName ] = field
    }
    return moduleFields
}

func getFieldDelegateVsApinameJSON( fieldDelegates : [ ZCRMFieldDelegate ] ) -> [ String: ZCRMFieldDelegate ]
{
    var moduleFields : [ String : ZCRMFieldDelegate ] = [ String : ZCRMFieldDelegate ]()
    for fieldDelegate in fieldDelegates
    {
        moduleFields[ fieldDelegate.apiName ] = fieldDelegate
    }
    return moduleFields
}

func notesAttachmentLimitCheck( note : ZCRMNote, filePath : String?, fileData : Data? ) throws
{
    var attachmentSize : Int64 = 0
    
    if let notesAttachments = note.attachments
    {
        if notesAttachments.count >= 5
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.limitExceeded) : Cannot add more than 5 attachments to a note, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ZCRMErrorCode.limitExceeded, message : "Cannot add more than 5 attachments to a note", details : nil )
        }
        for notesAttachment in notesAttachments
        {
            if let fileSize = notesAttachment.fileSize
            {
                attachmentSize += fileSize
            }
        }
    }
    
    let availableSpaceInMB : Float = Float( ZCRMMaxFileSize.notesAttachment.rawValue - attachmentSize ) / 1048576
    
    guard availableSpaceInMB > 0 else
    {
        ZCRMLogger.logError(message: "\(ZCRMErrorCode.fileSizeExceeded) : Cannot upload. Attachments size already reached the allowed value  - 20 MB, \( APIConstants.DETAILS ) : -")
        throw ZCRMError.fileSizeExceeded( code : ZCRMErrorCode.fileSizeExceeded, message : "Cannot upload. Attachments size already reached the allowed value  - 20 MB", details : nil )
    }
    
    if let filePath = filePath
    {
        if ( FileManager.default.fileExists( atPath : filePath )  == false )
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.mandatoryNotFound) : File not found at given path : \( filePath ), \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ZCRMErrorCode.mandatoryNotFound, message : "File not found at given path : \( filePath )", details : nil )
        }
        let fileSize = Float( getFileSize( filePath : filePath ) ) / 1048576
        if ( fileSize > availableSpaceInMB )
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.fileSizeExceeded) : Cannot upload. Available Free Space - \( availableSpaceInMB ) MB. The Attachment Size is \( fileSize  ) MB, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.fileSizeExceeded( code : ZCRMErrorCode.fileSizeExceeded, message : "Cannot upload. Available Free Space - \( availableSpaceInMB ) MB. The Attachment Size is \( fileSize ) MB", details : nil )
        }
    }
    else if let fileData = fileData
    {
        let fileSize = Float( fileData.count ) / 1048576
        if ( fileSize > availableSpaceInMB )
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.fileSizeExceeded) : Cannot upload. Available Free Space - \( availableSpaceInMB ) MB. The Attachment Size is \( fileSize ) MB, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.fileSizeExceeded( code : ZCRMErrorCode.fileSizeExceeded, message : "Cannot upload. Available Free Space - \( availableSpaceInMB ) MB. The Attachment Size is \( fileSize ) MB", details : nil )
        }
    }
}

//DB Constants

internal enum DBType : String
{
    case orgData = "zoho-crm-sdk-orgdata.db"
    case userData = "zoho-crm-sdk-userdata.db"
    case metaData = "zoho-crm-sdk-metadata.db"
    case analyticsData = "zoho-crm-sdk-analyticsdata.db"
    case appData = "zoho-crm-sdk-appdata.db"
}

internal struct DBConstant
{
    /// Tables in the database zoho-crm-sdk.db
    static var TABLE_RESPONSES : String
    {
        get
        {
            return "URL_VS_RESPONSE" + ZCRMSDKClient.shared.getOrgId()
        }
    }
    static let ORG_DETAILS = "ORG_DETAILS"
    // Columns in the table RESPONSES
    static let COLUMN_URL = "URL"
    static let COLUMN_DATA = "DATA"
    static let COLUMN_VALIDITY = "VALIDITY"
    
    // Tables in the database zoho-crm-sdk-persistent.db
    static let TABLE_PUSH_NOTIFICATIONS = "PUSH_NOTIFICATIONS_DETAILS"
    static let TABLE_CURRENT_ORGANIZATION = "CURRENT_ORGANIZATION"
    
    // Columns in the table PUSH_NOTIFICATIONS_DETAILS
    static let COLUMN_APP_ID = "APP_ID"
    static let COLUMN_APNS_MODE = "APNS_MODE"
    static let COLUMN_NF_ID = "NF_ID"
    static let COLUMN_NF_CHANNEL = "NF_CHANNEL"
    static let COLUMN_INS_ID = "INS_ID"
    static let COLUMN_SERVICE_NAME = "SERVICE_NAME"
    static let COLUMN_MOBILE_VERSION = "MOBILE_VERSION"
    
    // Columns in the table CURRENT_PORTAL
    static let COLUMN_ORGANIZATION_ID = "ORGANIZATION_ID"
    
    static let DML_CREATE = "CREATE"
    static let DML_INSERT = "INSERT"
    static let DML_UPDATE = "UPDATE"
    static let DML_DELETE = "DELETE"
    
    static let DQL_SELECT = "SELECT"
    static let CLAUSE_WHERE = "WHERE"
    
    static let KEYS_FROM = "FROM"
    static let KEYS_AND = "AND"
    static let KEYS_INTO = "INTO"
    static let KEYS_VALUES = "VALUES"
    static let KEYS_SELECT = "SELECT"
    static let KEYS_SET = "SET"
    static let VALIDITY_TIME = "datetime('now','+\( ZCRMSDKClient.shared.cacheValidityTimeInHours ) hours')"
    
    static let CURRENT_TIME = "datetime('now')"
    static let IS_DB_CACHE_ENABLED = "IS_DB_CACHE_ENABLED"
    static let DB_Key_Name = "DB_Key_Name"
    static let DB_Key_Value = "ZCRMiOS_DB_Key"
    static let IS_DB_ENCRYPTED = "IS_DB_ENCRYPTED"
}

internal struct ResponsesTableStatement
{
    func insert( _ withURL : String, data : String, validity : String ) -> String
    {
        return "\(DBConstant.DML_INSERT) \(DBConstant.KEYS_INTO) \(DBConstant.TABLE_RESPONSES) (\(DBConstant.COLUMN_URL), \(DBConstant.COLUMN_DATA), \(DBConstant.COLUMN_VALIDITY)) \(DBConstant.KEYS_VALUES) (\"\(withURL)\", \"\(data)\", \(validity));"
    }
    
    func createTable() -> String
    {
        return "\(DBConstant.DML_CREATE) TABLE IF NOT EXISTS \(DBConstant.TABLE_RESPONSES)(\(DBConstant.COLUMN_URL) VARCHAR PRIMARY KEY NOT NULL, \(DBConstant.COLUMN_DATA) TEXT NOT NULL, \(DBConstant.COLUMN_VALIDITY) TEXT NOT NULL);"
    }
    
    func delete(_ withURL : String ) -> String
    {
        return "\(DBConstant.DML_DELETE) \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_RESPONSES) \(DBConstant.CLAUSE_WHERE) \(DBConstant.COLUMN_URL) = \"\(withURL)\";"
    }
    
    func deleteComponent( withId : String ) -> String
    {
        return "\(DBConstant.DML_DELETE) \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_RESPONSES) \(DBConstant.CLAUSE_WHERE) \(DBConstant.COLUMN_URL) LIKE \"%/components/\( withId )%\";"
    }
    
    func deleteAllRecords( withModuleName moduleName : String ) -> String
    {
        return "\(DBConstant.DML_DELETE) \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_RESPONSES) \(DBConstant.CLAUSE_WHERE) \(DBConstant.COLUMN_URL) GLOB \"*[/?]\( moduleName )[/?]*\" OR \( DBConstant.COLUMN_URL ) GLOB \"*[/?]\( moduleName )\";"
    }
    
    func deleteAll() -> String
    {
        return "\(DBConstant.DML_DELETE) \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_RESPONSES) \( DBConstant.CLAUSE_WHERE ) \( DBConstant.COLUMN_URL ) NOT LIKE \"%organizations%\";"
    }
    
    func fetchData(_ withURL : String ) -> String
    {
        return "\(DBConstant.DQL_SELECT) * \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_RESPONSES) \(DBConstant.CLAUSE_WHERE) \(DBConstant.COLUMN_URL) = \"\(withURL)\" AND \(DBConstant.COLUMN_VALIDITY) > \(DBConstant.CURRENT_TIME);"
    }
    
    func searchData(_ withURL : String ) -> String
    {
        return "\(DBConstant.DQL_SELECT) * \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_RESPONSES) \(DBConstant.CLAUSE_WHERE) \(DBConstant.COLUMN_URL) LIKE \'\(withURL)\' OR \(DBConstant.COLUMN_URL) LIKE \'\( withURL )?%\' AND \(DBConstant.COLUMN_VALIDITY) > \(DBConstant.CURRENT_TIME);"
    }
}

internal struct OrganizationsTableStatement
{
    func insert( _ withURL : String, data : String, validity : String ) -> String
    {
        return "\(DBConstant.DML_INSERT) \(DBConstant.KEYS_INTO) \(DBConstant.ORG_DETAILS) (\(DBConstant.COLUMN_URL), \(DBConstant.COLUMN_DATA), \(DBConstant.COLUMN_VALIDITY)) \(DBConstant.KEYS_VALUES) (\"\(withURL)\", \"\(data)\", \(validity));"
    }
    
    func createTable() -> String
    {
        return "\(DBConstant.DML_CREATE) TABLE IF NOT EXISTS \(DBConstant.ORG_DETAILS)(\(DBConstant.COLUMN_URL) VARCHAR PRIMARY KEY NOT NULL, \(DBConstant.COLUMN_DATA) TEXT NOT NULL, \(DBConstant.COLUMN_VALIDITY) TEXT NOT NULL);"
    }
    
    func delete(_ withURL : String ) -> String
    {
        return "\(DBConstant.DML_DELETE) \(DBConstant.KEYS_FROM) \(DBConstant.ORG_DETAILS) \(DBConstant.CLAUSE_WHERE) \(DBConstant.COLUMN_URL) = \"\(withURL)\";"
    }
    
    func fetchData(_ withURL : String ) -> String
    {
        return "\(DBConstant.DQL_SELECT) * \(DBConstant.KEYS_FROM) \(DBConstant.ORG_DETAILS) \(DBConstant.CLAUSE_WHERE) \(DBConstant.COLUMN_URL) = \"\(withURL)\" AND \(DBConstant.COLUMN_VALIDITY) > \(DBConstant.CURRENT_TIME);"
    }
}

/// Conform to this protocol when you want to allow the user to store a transformation for particular property
/// When the user now accesses the property through a special syntax, the value is transformed using the closure provided and is given back to the user
/// This provides a single point of customisation to the user and the desired value is obtained no matter where the property is accessed
public protocol PropertyTransformer {
    static var keyPathAndTransformationDict: [PartialKeyPath<Self>: Any] { get set }
    var keyPathAndUnTransformedValuesDict: [PartialKeyPath<Self>: Any] { get set }
}

extension PropertyTransformer {
    
    public static func storeTransformation<T>(forProperty keyPath: KeyPath<Self, T>, transformation: @escaping (Self, T)->(T)) {
        keyPathAndTransformationDict[keyPath] = transformation
    }
    
    public func getUntransformedValue<T>(forProperty keyPath: KeyPath<Self, T>) -> T {
        // If no transformation exists for property, read and return the value of the property
        guard let writableKeyPath = keyPath as? WritableKeyPath, self.keyPathAndUnTransformedValuesDict[keyPath] != nil  else {
            return self[keyPath: keyPath]
        }
        
        return (self.keyPathAndUnTransformedValuesDict[writableKeyPath] as! T)
    }
    
    mutating func transform<T>(_ keyPath: PartialKeyPath<Self>, ForValue value: T) -> T {
        guard let closure = Self.keyPathAndTransformationDict[keyPath] as? ((Self, T)->(T)) else {
            ZCRMLogger.logError(message: "Failed to transform keyPath \(keyPath) for value \(value)!")
            return value
        }
        self.keyPathAndUnTransformedValuesDict[keyPath] = value
        return closure(self, value)
    }
    
    mutating func transformAndWriteBackValue(_ keyPath: AnyKeyPath) {
        if let stringWritableKeyPath = (keyPath as? WritableKeyPath<Self, String>) {
            self[keyPath: stringWritableKeyPath] = transform(stringWritableKeyPath, ForValue: self[keyPath: stringWritableKeyPath])
        }
        else if let floatWritableKeyPath = keyPath as? WritableKeyPath<Self, Float> {
            self[keyPath: floatWritableKeyPath] = transform(floatWritableKeyPath, ForValue: self[keyPath: floatWritableKeyPath])
        }
        else if let doubleWritableKeyPath = keyPath as? WritableKeyPath<Self, Double> {
            self[keyPath: doubleWritableKeyPath] = transform(doubleWritableKeyPath, ForValue: self[keyPath: doubleWritableKeyPath])
        }
        else if let intWritableKeyPath = keyPath as? WritableKeyPath<Self, Int> {
            self[keyPath: intWritableKeyPath] = transform(intWritableKeyPath, ForValue: self[keyPath: intWritableKeyPath])
        }
            
        else if let optStringWritableKeyPath = keyPath as? WritableKeyPath<Self, String?> {
            self[keyPath: optStringWritableKeyPath] = transform(optStringWritableKeyPath, ForValue: self[keyPath: optStringWritableKeyPath])
        }
        else if let optFloatWritableKeyPath = keyPath as? WritableKeyPath<Self, Float?> {
            self[keyPath: optFloatWritableKeyPath] = transform(optFloatWritableKeyPath, ForValue: self[keyPath: optFloatWritableKeyPath])
        }
        else if let optDoubleWritableKeyPath = keyPath as? WritableKeyPath<Self, Double?> {
            self[keyPath: optDoubleWritableKeyPath] = transform(optDoubleWritableKeyPath, ForValue: self[keyPath: optDoubleWritableKeyPath])
        }
        else if let optIntWritableKeyPathh = keyPath as? WritableKeyPath<Self, Int?> {
            self[keyPath: optIntWritableKeyPathh] = transform(optIntWritableKeyPathh, ForValue: self[keyPath: optIntWritableKeyPathh])
        }
            
        else {
            ZCRMLogger.logError(message: "Property transformation is currently not supported for keyPath \(keyPath)!")
        }
    }
    
    mutating func applyTransformation() {
        Self.keyPathAndTransformationDict.keys.forEach{ transformAndWriteBackValue($0) }
    }
}

func zcrmGetRandomPassword(pwdLength: Int) -> String {
    let pwdLetters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%&()0123456789"
    var passWord = ""
    for _ in 0 ..< pwdLength {
        passWord.append(pwdLetters.randomElement()!)
    }
    let salt = "ZCRMiOSSDK"
    passWord += salt
    passWord = passWord.sha256()
    return passWord
}

@propertyWrapper public struct UserDefaultsBacked< Value >
{
    var key : String
    let defaultValue : Value
    public var wrappedValue : Value
    {
        get
        {
            return UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        }
        set
        {
            UserDefaults.standard.set( newValue, forKey: key )
        }
    }
}

internal func getDBPassPhrase() throws -> String {
    let serialQueue = DispatchQueue( label : "com.zoho.crm.sdk.sqlite.execCommand", qos : .utility )
    var dbPassword : String = String()
    try serialQueue.sync {
        if ZCRMSDKClient.shared.isDBEncrypted && ZCRMSDKClient.shared.dbKeyValue == DBConstant.DB_Key_Value
        {
            let passwordItem = KeychainPasswordItem(service: DBConstant.DB_Key_Value,
                                                    account: ZCRMSDKClient.shared.account,
                                                    accessGroup: nil)
            dbPassword = try passwordItem.readPassword()
        }
        else {
            ZCRMSDKClient.shared.dbKeyValue = DBConstant.DB_Key_Value
            let password = zcrmGetRandomPassword(pwdLength: 16)
            let passwordItem = KeychainPasswordItem(service: DBConstant.DB_Key_Value,
                                                    account: ZCRMSDKClient.shared.account,
                                                    accessGroup: nil)
            
            // Save the password for the new item.
            try passwordItem.savePassword(password)
            dbPassword = password
        }
    }
    return dbPassword
}

internal class SSLValidator : NSObject, URLSessionTaskDelegate
{
    static let rsa2048Asn1Header:[UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]
    
    /**
      Creates a hash from the received data using the `sha256` algorithm.

     - Returns: The `base64` encoded representation of the hash.
     */
    private func sha256(data : Data) -> String {
        var keyWithHeader = Data(SSLValidator.rsa2048Asn1Header)
        keyWithHeader.append(data)
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        keyWithHeader.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(keyWithHeader.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
    
    public func urlSession(_ session: URLSession, task : URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        guard let allowedDomains = ZCRMSDKClient.shared.authorizationCredentials?.keys, !allowedDomains.isEmpty else
        {
            return completionHandler( .performDefaultHandling, nil )
        }
        guard let domainURL = task.currentRequest?.url?.host, allowedDomains.contains( domainURL ) else
        {
            return completionHandler( .performDefaultHandling, nil )
        }
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return completionHandler(.performDefaultHandling, nil)
        }
        let policies = NSMutableArray()
        for domain in allowedDomains
        {
            policies.add(SecPolicyCreateSSL(true, domain as CFString))
        }
        SecTrustSetPolicies(serverTrust, policies)
        var serverPublicKey : SecKey?
        if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            if #available(iOS 12.0, *) {
                serverPublicKey = SecCertificateCopyKey(serverCertificate)
            } else if #available(iOS 10.3, *) {
                serverPublicKey =  SecCertificateCopyPublicKey(serverCertificate)
            } else {
                var possibleTrust: SecTrust?
                SecTrustCreateWithCertificates(serverCertificate, SecPolicyCreateBasicX509(), &possibleTrust)
                guard let trust = possibleTrust else { return }
                var result: SecTrustResultType = .unspecified
                SecTrustEvaluate(trust, &result)
                serverPublicKey = SecTrustCopyPublicKey(trust)
            }
            if #available(iOS 10.0, *) {
                let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil )!
                let data:Data = serverPublicKeyData as Data
                // Server Hash key
                let serverHashKey = sha256(data: data)
                // Local Hash Key
                let publickKeyLocals = ( ZCRMSDKClient.shared.authorizationCredentials ?? [:] ).values
                for publicKeyLocal in publickKeyLocals
                {
                    if publicKeyLocal.contains( serverHashKey )
                    {
                        // Success! This is our server
                        ZCRMLogger.logDebug(message: "Public key pinning is successfully completed")
                        completionHandler(.useCredential, URLCredential(trust:serverTrust))
                        return
                    }
                }
                return completionHandler( .cancelAuthenticationChallenge, nil )
            }
            else
            {
                return completionHandler( .performDefaultHandling, nil )
            }
        }
        else
        {
            return completionHandler( .performDefaultHandling, nil )
        }
    }
}

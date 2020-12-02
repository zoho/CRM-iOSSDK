//
//  CommonUtil.swift
//  ZCacheiOS
//
//  Created by Umashri R on 19/10/20.
//

import Foundation

public enum DataType {
    case image
    case text
    case integer
    case bool
    case double
    case date_time
    case email
    case date
    case picklist
    case multi_select_picklist
    case lookup
    case multi_select_lookup
    case user_lookup
    case subform
    case bigint
}

public enum ConstraintType: String {
    case on_delete_cascade = "ON DELETE CASCADE"
    case on_delete_set_null = "ON DELETE SET NULL"
}

public enum VoidResult {
    case success
    case failure(ZCacheError)
}

public enum ZCacheError : Error
{
    case invalidError( code : String, message : String, details : Dictionary< String, Any >? )
    case networkError( code : String, message : String, details : Dictionary< String, Any >? )
    case maxRecordCountExceeded( code : String, message : String, details : Dictionary< String, Any >? )
    case processingError( code : String, message : String, details : Dictionary< String, Any >? )
    case sdkError( code : String, message : String, details : Dictionary< String, Any >? )
}

public struct ErrorCode
{
    public static var invalidData = "INVALID_DATA"
    public static var internalError = "INTERNAL_ERROR"
    public static var noInternet = "NO_INTERNET"

    public static var responseNil = "RESPONSE_NIL"
    public static var valueNil = "VALUE_NIL"
    public static var mandatoryNotFound = "MANDATORY_NOT_FOUND"
    public static var responseRootKeyNil = "RESPONSE_ROOT_KEY_NIL"
    public static var fileSizeExceeded = "FILE_SIZE_EXCEEDED"
    public static var maxCountExceeded = "MAX_COUNT_EXCEEDED"
    public static var fieldNotFound = "FIELD_NOT_FOUND"
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
    public static var dbNotCreated = "DB_NOT_CREATED"
    public static var insufficientData = "INSUFFICIENT_DATA"
    public static let limitExceeded = "LIMIT_EXCEEDED"
    public static let unhandled = "UNHANDLED"
    public static let duplicateData = "DUPLICATE_DATA"
    public static let initializationError = "INITIALIZATION_ERROR"
}

public struct ErrorMessage
{
    public static let cacheNotInitialised  = "Cache is not initialised."
    public static let noInternet = "The internet seems to be offline."
    
    public static let invalidIdMsg  = "The given id seems to be invalid."
    public static let apiMaxRecordsMsg = "Cannot process more than 100 records at a time."
    public static let responseNilMsg  = "Response is nil."
    public static let responseJSONNilMsg = "Response JSON is empty."
    public static let unableToConstructURLMsg = "There was a problem constructing the URL."
    public static let invalidFileTypeMsg = "The file you have chosen is not supported. Please choose a PNG, JPG, JPEG, BMP, or GIF file type."
    public static let dbDataNotAvailable = "ZCRM iOS SDK DB - Data NOT Available."
    public static let permissionDenied = "permission denied."
    public static let notModifiedSinceMsg = "There is no changes made after the specified time."
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
        guard let error = self as? ZCacheError else {
            return nil
        }
        switch error
        {
            case .invalidError( let code, let desc, let details ):
                return ( code, desc, details )
            case .networkError( let code, let desc, let details ):
                return ( code, desc, details )
            case .maxRecordCountExceeded( let code, let desc, let details ):
                return ( code, desc, details )
            case .processingError( let code, let desc, let details ):
                return ( code, desc, details )
            case .sdkError( let code, let desc, let details ):
                return ( code, desc, details )
        }
    }
}

public enum LogLevels : Int
{
    case byDefault = 0
    case info = 1
    case debug = 2
    case error = 3
    case fault = 4
}

extension String
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
}

let EXCEPTION_LOG_MSG : String = "ZCache SDK - "

internal struct DBConstant
{
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
    
    static let CONSTRAINT_NOT_NULL = "NOT NULL"
    static let CONSTRAINT_DEFAULT = "DEFAULT"
    static let CONSTRAINT_UNIQUE = "UNIQUE"
    static let CONSTRAINT_PRIMARY_KEY = "PRIMARY KEY"
    static let CONSTRAINT_CHECK = "CHECK"
    
//    static let VALIDITY_TIME = "datetime('now','+\( ZCRMSDKClient.shared.cacheValidityTimeInHours ) hours')"
//    static let CURRENT_TIME = "datetime('now')"
}

func getDataAsDictionary<T: Codable>( entity : T ) -> [ String : Any ]?
{
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    if let data = try? encoder.encode( entity ), let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [ String : Any ]
    {
        return json
    }
    return nil
}

func getDictionaryAsData< T : Codable >( json : [ String : Any? ] ) throws -> T
{
    let jsonData = try JSONSerialization.data( withJSONObject: json, options : [] )
    let decoder = JSONDecoder()
    let obj = try decoder.decode( T.self, from : jsonData )
    return obj
}

public func jsonToString(json: [String: Any?]) -> String?
{
    do {
        let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        let convertedString = String(data: data1, encoding: String.Encoding.utf8)
        return convertedString

    } catch let myJSONError {
        ZCacheLogger.logError(message: myJSONError.description)
        return nil
    }
}

public func stringToJson(string: String) -> [String: Any?]?
{
    let data = string.data(using: .utf8)
    do {
        if let data = data, let dictionary = try JSONSerialization.jsonObject(with: data, options : []) as? [String: Any?]
        {
            return dictionary
        } else {
            return nil
        }
    } catch let myJSONError {
        ZCacheLogger.logError(message: myJSONError.description)
        return nil
    }
}

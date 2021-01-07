//
//  CommonUtil.swift
//  ZCacheiOS
//
//  Created by Rajarajan K on 19/10/20.
//
import Foundation

public enum VoidResult
{
    case success
    case failure(ZCacheError)
}

public enum DataResponseCallback<A, B>
{
    case fromCache(info: A?, data: B?, waitForServer: Bool)
    case fromServer(info: A?, data: B?)
    case failure(error: ZCacheError)
}

public enum SortOrder
{
    case ascending
    case descending
}

public enum DataType: String, Codable
{
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
    case module
    case layout
    case section
    case field
}

public enum ConstraintType: String, Codable
{
    case on_delete_cascade = "ON DELETE CASCADE"
    case on_delete_set_null = "ON DELETE SET NULL"
}

public enum ZCacheError : Error
{
    case invalidError( code : String, message : String, details : Dictionary< String, Any >? )
    case networkError( code : String, message : String, details : Dictionary< String, Any >? )
    case maxRecordCountExceeded( code : String, message : String, details : Dictionary< String, Any >? )
    case processingError( code : String, message : String, details : Dictionary< String, Any >? )
    case sdkError( code : String, message : String, details : Dictionary< String, Any >? )
    case sqliteError( code : String, message : String, details : Dictionary< String, Any >? )
}

public enum Status
{
    case success
    case error
}

public struct Code
{
    public static var success = "success"
    public static var error = "error"
}

public struct ErrorCode
{
    public static var invalidData = "INVALID_DATA"
    public static var internalError = "INTERNAL_ERROR"
    public static var noInternet = "NO_INTERNET"
    public static var dbError = "DB_ERROR"
    public static var invalidType = "INVALID_TYPE"
    public static var dataNotAvailable = "DATA_NOT_AVAILABLE"
    public static var invalidOperation = "INVALID_OPERATION"
    public static var processingError = "PROCESSING_ERROR"
    public static let initializationError = "INITIALIZATION_ERROR"
}

public struct ErrorMessage
{
    public static let cacheNotInitialised  = "Cache is not initialised."
    public static let noInternet = "The internet seems to be offline."
    public static let notOfflineOperation = "Cannot perform get records with modifiedSince in offline mode."
    public static let invalidUserType = "The type 'T' is not of ZCacheUser type."
    public static let invalidModuleType = "The type 'T' is not of ZCacheModule type."
    public static let invalidLayoutType = "The type 'T' is not of ZCacheLayout type."
    public static let invalidSectionType = "The type 'T' is not of ZCacheSection type."
    public static let invalidFieldType = "The type 'T' is not of ZCacheField type."
    public static let invalidRecordType = "The type 'T' is not of ZCacheRecord type."
    public static let dataNotAvailableInCache = "Data not available in Cache."
    public static let requiredSpaceAvailableInCache = "The required space needed to insert latest records in cache is available."
    public static let requiredSpaceNotAvailableInCache = "The required space needed to insert latest records in cache is unavailable."
    public static let recordExists  = "The record already exists."
    public static let recordNotExists  = "The record does not exists."
    public static let recordDeleted  = "he record has already been deleted. Please restore it before further use."
    public static let invalidIdMsg  = "The given id seems to be invalid."
    public static let invalidIdModuleNameMsg  = "The given id/moduleName seems to be invalid."
    public static let invalidDataMsg  = "The given record seems to be invalid."
    public static let notRecordType = "The given entity is not of the record type."
    public static let dbDataNotAvailable = "ZCache iOS SDK DB - Data NOT Available."
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
            case .sqliteError( let code, let desc, let details ):
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
    
    static let VALIDITY_TIME = "datetime('now','+12 hours')"
    static let CURRENT_TIME = "datetime('now')"
}

func getCurrentDateTime() -> String
{
    let date = Date()
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
    return formatter.string(from: date)
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

func getDictionaryAsData< T: Decodable >( json : [ String : Any? ] ) throws -> T
{
    let jsonData = try JSONSerialization.data( withJSONObject: json, options : [] )
    let decoder = JSONDecoder()
    let obj = try decoder.decode( T.self, from : jsonData )
    return obj
}

public func jsonToString(json: [String: Any?]) -> String?
{   
    do
    {
        let data =  try JSONSerialization.data(withJSONObject: json, options: [])
        let convertedString = String(data: data, encoding: String.Encoding.utf8)
        return convertedString
    }
    catch let myJSONError
    {
        ZCacheLogger.logError(message: myJSONError.description)
        return nil
    }
}

public func anyToString(value: Any) -> String?
{
    do
    {
        let data = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions.prettyPrinted)
        let convertedString = String(data: data, encoding: String.Encoding.utf8)
        return convertedString

    }
    catch let myJSONError
    {
        ZCacheLogger.logError(message: myJSONError.description)
        return nil
    }
}


public func stringToJson(string: String) -> [String: Any?]?
{
    let data = string.data(using: .utf8)
    do
    {
        if let data = data, let dictionary = try JSONSerialization.jsonObject(with: data, options : []) as? [String: Any?]
        {
            return dictionary
        }
        else
        {
            return nil
        }
    }
    catch let myJSONError
    {
        ZCacheLogger.logError(message: myJSONError.description)
        return nil
    }
}

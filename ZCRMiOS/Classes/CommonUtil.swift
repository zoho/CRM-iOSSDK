//
//  CommonUtil.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

import Foundation

let PhotoSupportedModules = ["Leads", "Contacts"]


public enum ZCRMError : Error
{
    case UnAuthenticatedError( code : String, message : String, details : Dictionary< String, Any >? )
    case InValidError( code : String, message : String, details : Dictionary< String, Any >? )
    case MaxRecordCountExceeded( code : String, message : String, details : Dictionary< String, Any >? )
    case FileSizeExceeded( code : String, message : String, details : Dictionary< String, Any >? )
    case ProcessingError( code : String, message : String, details : Dictionary< String, Any >? )
    case SDKError( code : String, message : String, details : Dictionary< String, Any >? )
    case NetworkError( code : String, message : String, details : Dictionary< String, Any >? )
}

public struct ErrorCode
{
    public static var INVALID_DATA = "INVALID_DATA"
    public static var INTERNAL_ERROR = "INTERNAL_ERROR"
    public static var RESPONSE_NIL = "RESPONSE_NIL"
    public static var VALUE_NIL = "VALUE_NIL"
    public static var MANDATORY_NOT_FOUND = "MANDATORY_NOT_FOUND"
    public static var RESPONSE_ROOT_KEY_NIL = "RESPONSE_ROOT_KEY_NIL"
    public static var FILE_SIZE_EXCEEDED = "FILE_SIZE_EXCEEDED"
    public static var MAX_COUNT_EXCEEDED = "MAX_COUNT_EXCEEDED"
    public static var FIELD_NOT_FOUND = "FIELD_NOT_FOUND"
    public static var OAUTHTOKEN_NIL = "OAUTHTOKEN_NIL"
    public static var OAUTH_FETCH_ERROR = "OAUTH_FETCH_ERROR"
    public static var UNABLE_TO_CONSTRUCT_URL = "UNABLE_TO_CONSTRUCT_URL"
    public static var INVALID_FILE_TYPE = "INVALID_FILE_TYPE"
    public static var INVALID_MODULE = "INVALID_MODULE"
    public static var PROCESSING_ERROR = "PROCESSING_ERROR"
    public static var MODULE_FIELD_NOT_FOUND = "MODULE_FIELD_NOT_FOUND"
    public static var INVALID_OPERATION = "INVALID_OPERATION"
    public static var NOT_SUPPORTED = "NOT_SUPPORTED"
    public static var NO_PERMISSION = "NO_PERMISSION"
    public static var TYPECAST_ERROR = "TYPECAST_ERROR"
    public static var MODULE_NOT_AVAILABLE = "MODULE_NOT_AVAILABLE"
    public static var NO_INTERNET_CONNECTION = "NO_INTERNET_CONNECTION"
    public static var REQUEST_TIMEOUT = "REQUEST_TIMEOUT"
    public static var INSUFFICIENT_DATA = "INSUFFICIENT_DATA"
}

public struct ErrorMessage
{
    public static let INVALID_ID_MSG  = "The given id seems to be invalid."
    public static let API_MAX_RECORDS_MSG = "Cannot process more than 100 records at a time."
    public static let RESPONSE_NIL_MSG  = "Response is nil"
    public static let RESPONSE_JSON_NIL_MSG = "Response JSON is empty"
    public static let OAUTHTOKEN_NIL_MSG = "The oauth token is nil"
    public static let OAUTH_FETCH_ERROR_MSG = "There was an error in fetching oauth Token"
    public static let UNABLE_TO_CONSTRUCT_URL_MSG = "There was a problem constructing the URL"
    public static let INVALID_FILE_TYPE_MSG = "The file you have chosen is not supported. Please choose a PNG, JPG, BMP, or GIF file type."
    public static let DB_DATA_NOT_AVAILABLE = "ZCRM iOS SDK DB - Data NOT Available"
    public static let PERMISSION_DENIED = "permission denied"
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
            case .UnAuthenticatedError( let code, let desc, let details ):
                return ( code, desc, details )
            case .InValidError( let code, let desc, let details ):
                return ( code, desc, details )
            case .MaxRecordCountExceeded( let code, let desc, let details ):
                return ( code, desc, details )
            case .FileSizeExceeded( let code, let desc, let details ):
                return ( code, desc, details )
            case .ProcessingError( let code, let desc, let details ):
                return ( code, desc, details )
            case .SDKError( let code, let desc, let details ):
                return ( code, desc, details )
            case .NetworkError( let code, let desc, let details ):
                return ( code, desc, details )
        }
    }
}

public enum SortOrder : String
{
    case ASCENDING = "asc"
    case DESCENDING = "desc"
}

public enum AccessType : String
{
    case PRODUCTION = "Production"
    case DEVELOPMENT = "Development"
    case SANDBOX = "Sandbox"
}

public enum PhotoSize : String
{
    case STAMP = "stamp"
    case THUMB = "thumb"
    case ORIGINAL = "original"
    case FAVICON = "favicon"
    case MEDIUM = "medium"
}

public enum ConsentProcessThrough : String
{
    case EMAIL = "Email"
    case PHONE = "Phone"
    case SURVEY = "Survey"
    case SOCIAL = "Social"
}

public enum CurrencyRoundingOption : String
{
    case ROUND_OFF = "round_off"
    case ROUND_DOWN = "round_down"
    case ROUND_UP = "round_up"
    case NORMAL = "normal"
}

public enum Trigger : String
{
    case WORKFLOW = "workflow"
    case APPROVAL = "approval"
    case BLUEPRINT = "blueprint"
}

internal enum CacheFlavour : String
{
    case NO_CACHE = "NO_CACHE"
    case URL_VS_RESPONSE = "URL_VS_RESPONSE"
    case DATA = "DATA"
    case FORCE_CACHE = "FORCE_CACHE"
}
    
public enum APNsMode : String
{
    case SBX = "SBX"
    case PRD = "PRD"
}

public enum NFChannel : String
{
    case CNS = "CNS"
    case UNS = "UNS"
    case BOTH = "CNS,UNS"
}

public enum EventParticipantType : String
{
    case EMAIL = "email"
    case USER = "user"
    case CONTACT = "contact"
    case LEAD = "lead"
}

public enum DrillBy : String
{
    case USER = "user"
    case ROLE = "role"
}

public enum EventParticipant : Equatable
{
    case EMAIL( String)
    case USER( ZCRMUserDelegate )
    case RECORD( ZCRMRecordDelegate )
    
    public func getEmail() -> String?
    {
        switch self
        {
            case .EMAIL( let value ) :
                return value
            
            default:
                return nil
        }
    }
    
    public func getUser() -> ZCRMUserDelegate?
    {
        switch self
        {
            case .USER( let value ) :
                return value
            
            default :
                return nil
        }
    }
    
    public func getRecord() -> ZCRMRecordDelegate?
    {
        switch self
        {
            case .RECORD( let value ) :
                return value
            
            default :
                return nil
        }
    }
}

public enum LogLevels : Int
{
    case DEFAULT = 0
    case INFO = 1
    case DEBUG = 2
    case ERROR = 3
    case FAULT = 4
}

public enum AppType : String
{
    case ZCRM = "zcrm"
    case SOLUTIONS = "solutions"
    case BIGIN = "bigin"
    case ZVCRM = "zvcrm"
    case ZCRMCP = "zcrmcp"
}

public enum ComponentPeriod : String
{
    case DAY = "day"
    case MONTH = "month"
}

public enum PortalType : String
{
    case PRODUCTION = "production"
    case SANDBOX = "sandbox"
    case DEVELOPER = "developer"
    case BIGIN = "bigin"
}

internal enum ZCRMSDKDataType
{
    case String
    case Int
    case Int64
    case Double
    case Bool
    case Dictionary
    case ArrayOfDictionaries
    case ZCRMRecordDelegate
    case ZCRMUserDelegate
    case ZCRMInventoryLineItem
    case ZCRMPriceBookPricing
    case ZCRMEventParticipant
    case ZCRMLineTax
    case ZCRMTaxDelegate
    case ArrayOfStrings
    case ZCRMDataProcessingBasisDetails
    case ZCRMLayoutDelegate
    case ArrayOfZCRMSubformRecord
    case Undefined
}

@available(*, deprecated, message: "Use the enum 'DashboardFilter'" )
public enum QueryScope : String
{
    case MINE = "mine"
    case SHARED = "shared"
}

public enum DashboardFilter : String
{
    case MINE = "mine"
    case SHARED = "shared"
}

internal extension Dictionary
{
    func hasKey( forKey : Key ) -> Bool
    {
        return self[ forKey ] != nil
    }
    
    func hasValue(forKey : Key) -> Bool
    {
        return self[forKey] != nil && !(self[forKey] is NSNull)
    }
    
    private func valueCheck( forKey : Key ) throws
    {
        if hasValue(forKey: forKey) == false
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.VALUE_NIL) : \( forKey ) must not be nil")
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\( forKey ) must not be nil", details : nil )
        }
    }
    
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
    
    func optString(key : Key) -> String?
    {
        return optValue(key: key) as? String
    }
    
    func optInt(key : Key) -> Int?
    {
        return optValue(key: key) as? Int
    }
    
    func optInt64(key : Key) -> Int64?
    {
        guard let stringID = optValue(key: key) as? String else {
            return nil
        }
        
        return Int64(stringID)
    }
    
    func optDouble(key : Key) -> Double?
    {
        return optValue(key: key) as? Double
    }
    
    func optBoolean(key : Key) -> Bool?
    {
        return optValue(key: key) as? Bool
    }
    
    func optDictionary(key : Key) -> Dictionary<String, Any>?
    {
        return optValue(key: key) as? Dictionary<String, Any>
    }
    
    func optArray(key : Key) -> Array<Any>?
    {
        return optValue(key: key) as? Array<Any>
    }
    
    func optArrayOfDictionaries( key : Key ) -> Array< Dictionary < String, Any > >?
    {
        return ( optValue( key : key ) as? Array< Dictionary < String, Any > > )
    }
    
    func getInt( key : Key ) throws -> Int
    {
        try self.valueCheck( forKey : key )
        guard let value = optInt( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.TYPECAST_ERROR) : \( key ) - Expected type -> INT")
            throw ZCRMError.ProcessingError( code : ErrorCode.TYPECAST_ERROR, message : "\( key ) - Expected type -> INT", details : nil )
        }
        return value
    }
    
    func getInt64( key : Key ) throws -> Int64
    {
        try self.valueCheck( forKey : key )
        guard let value = optInt64( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.TYPECAST_ERROR) : \( key ) - Expected type -> INT64")
            throw ZCRMError.ProcessingError( code : ErrorCode.TYPECAST_ERROR, message : "\( key ) - Expected type -> INT64", details : nil )
        }
        return value
    }
    
    func getString( key : Key ) throws -> String
    {
        try self.valueCheck( forKey : key )
        guard let value = optString( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.TYPECAST_ERROR) : \( key ) - Expected type -> STRING")
            throw ZCRMError.ProcessingError( code : ErrorCode.TYPECAST_ERROR, message : "\( key ) - Expected type -> STRING", details : nil )
        }
        return value
    }
    
    func getBoolean( key : Key ) throws -> Bool
    {
        try self.valueCheck( forKey : key )
        guard let value = optBoolean( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.TYPECAST_ERROR) : \( key ) - Expected type -> BOOLEAN")
            throw ZCRMError.ProcessingError( code : ErrorCode.TYPECAST_ERROR, message : "\( key ) - Expected type -> BOOLEAN", details : nil )
        }
        return value
    }
    
    func getDouble( key : Key ) throws -> Double
    {
        try self.valueCheck( forKey : key )
        guard let value = optDouble( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.TYPECAST_ERROR) : \( key ) - Expected type -> DOUBLE")
            throw ZCRMError.ProcessingError( code : ErrorCode.TYPECAST_ERROR, message : "\( key ) - Expected type -> DOUBLE", details : nil )
        }
        return value
    }
    
    func getArray( key : Key ) throws -> Array< Any >
    {
        try self.valueCheck( forKey : key )
        guard let value = optArray( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.TYPECAST_ERROR) : \( key ) - Expected type -> ARRAY< ANY >")
            throw ZCRMError.ProcessingError( code : ErrorCode.TYPECAST_ERROR, message : "\( key ) - Expected type -> ARRAY< ANY >", details : nil )
        }
        return value
    }
    
    func getDictionary( key : Key ) throws -> Dictionary< String, Any >
    {
        try self.valueCheck( forKey : key )
        guard let value = optDictionary( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.TYPECAST_ERROR) : \( key ) - Expected type -> DICTIONARY< STRING, ANY >")
            throw ZCRMError.ProcessingError( code : ErrorCode.TYPECAST_ERROR, message : "\( key ) - Expected type -> DICTIONARY< STRING, ANY >", details : nil )
        }
        return value
    }
    
    func getArrayOfDictionaries( key : Key ) throws -> Array< Dictionary < String, Any > >
    {
        try self.valueCheck( forKey : key )
        guard let value = optArrayOfDictionaries( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.TYPECAST_ERROR) : \( key ) - Expected type -> ARRAY< DICTIONARY< STRING, ANY > >")
            throw ZCRMError.ProcessingError( code : ErrorCode.TYPECAST_ERROR, message : "\( key ) - Expected type -> ARRAY< DICTIONARY < STRING, ANY > >", details : nil )
        }
        return value
    }
    
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
    
    func equateKeys( dictionary : [ String : Any ] ) -> Bool
    {
        let dictKeys = dictionary.keys
        var isEqual : Bool = true
        for key in self.keys
        {
            if let key = key as? String, dictKeys.index(of: key) == nil
            {
                isEqual = false
            }
        }
        return isEqual
    }
    
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
    
    var dateComponents : DateComponents?
    {
        if let date : Date = Formatter.iso8601.date( from : self )
        {
            return date.dateComponents
        }
        return nil
    }
    
    var millisecondsSince1970 : Double?
    {
        if let date : Date = Formatter.iso8601.date( from : self )
        {
            return date.millisecondsSince1970
        }
        return nil
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
}

extension Formatter
{
    static let iso8601 : DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar( identifier : .iso8601 )
        formatter.locale = Locale( identifier : "en_US_POSIX" )
        formatter.timeZone = TimeZone( secondsFromGMT : 0 )
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
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
        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : Exception while moving file - \(err)")
    }
}

public func fileDetailCheck( filePath : String?, fileData : Data? ) throws
{
    if let filePath = filePath
    {
        if ( FileManager.default.fileExists( atPath : filePath )  == false )
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : File not found at given path : \( filePath )")
            throw ZCRMError.InValidError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "File not found at given path : \( filePath )", details : nil )
        }
        if ( getFileSize( filePath : filePath ) > APIConstants.MAX_ALLOWED_FILE_SIZE )
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.FILE_SIZE_EXCEEDED) : Cannot upload. File size should not exceed to 20MB")
            throw ZCRMError.FileSizeExceeded( code : ErrorCode.FILE_SIZE_EXCEEDED, message : "Cannot upload. File size should not exceed to 20MB", details : nil )
        }
    }
    else if let fileData = fileData
    {
        if fileData.count > APIConstants.MAX_ALLOWED_FILE_SIZE
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.FILE_SIZE_EXCEEDED) : Cannot upload. File size should not exceed to 20MB")
            throw ZCRMError.FileSizeExceeded( code : ErrorCode.FILE_SIZE_EXCEEDED, message : "Cannot upload. File size should not exceed to 20MB", details : nil )
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
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : Failed to get a size attribute from path : \( filePath )")
        }
    }
    catch
    {
        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : Failed to get file attributes for local path: \( filePath ) with error: \( error )")
    }
    return 0
}

internal func getTypeOf( _ value : Any ) -> ZCRMSDKDataType
{
    if let _ = value as? String
    {
        return ZCRMSDKDataType.String
    }
    else if let _ = value as? Int
    {
        return ZCRMSDKDataType.Int
    }
    else if let _ = value as? Int64
    {
        return ZCRMSDKDataType.Int64
    }
    else if let _ = value as? Double
    {
        return ZCRMSDKDataType.Double
    }
    else if let _ = value as? Bool
    {
        return ZCRMSDKDataType.Bool
    }
    else if let _ = value as? [ String : Any ]
    {
        return ZCRMSDKDataType.Dictionary
    }
    else if let _ = value as? [ [ String : Any ] ]
    {
        return ZCRMSDKDataType.ArrayOfDictionaries
    }
    else if let _ = value as? ZCRMRecordDelegate
    {
        return ZCRMSDKDataType.ZCRMRecordDelegate
    }
    else if let _ = value as? ZCRMUserDelegate
    {
        return ZCRMSDKDataType.ZCRMUserDelegate
    }
    else if let _ = value as? ZCRMInventoryLineItem
    {
        return ZCRMSDKDataType.ZCRMInventoryLineItem
    }
    else if let _ = value as? ZCRMPriceBookPricing
    {
        return ZCRMSDKDataType.ZCRMPriceBookPricing
    }
    else if let _ = value as? ZCRMEventParticipant
    {
        return ZCRMSDKDataType.ZCRMEventParticipant
    }
    else if let _ = value as? ZCRMLineTax
    {
        return ZCRMSDKDataType.ZCRMLineTax
    }
    else if let _ = value as? ZCRMTaxDelegate
    {
        return ZCRMSDKDataType.ZCRMTaxDelegate
    }
    else if let _ = value as? [ String ]
    {
        return ZCRMSDKDataType.ArrayOfStrings
    }
    else if let _ = value as? ZCRMDataProcessBasisDetails
    {
        return ZCRMSDKDataType.ZCRMDataProcessingBasisDetails
    }
    else if let _ = value as? ZCRMLayoutDelegate
    {
        return ZCRMSDKDataType.ZCRMLayoutDelegate
    }
    else if let _ = value as? [ ZCRMSubformRecord ]
    {
        return ZCRMSDKDataType.ArrayOfZCRMSubformRecord
    }
    else
    {
        return ZCRMSDKDataType.Undefined
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
            case .String :
                guard let lhsValue = lhs as? String, let rhsValue = rhs as? String else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .Int :
                guard let lhsValue = lhs as? Int, let rhsValue = rhs as? Int else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .Int64 :
                guard let lhsValue = lhs as? Int64, let rhsValue = rhs as? Int64 else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .Double :
                guard let lhsValue = lhs as? Double, let rhsValue = rhs as? Double else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .Bool :
                guard let lhsValue = lhs as? Bool, let rhsValue = rhs as? Bool else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .Dictionary :
                guard let lhsValue = lhs as? [ String : Any ], let rhsValue = rhs as? [ String : Any ] else
                {
                    return false
                }
                return NSDictionary( dictionary : lhsValue ).isEqual( to : rhsValue )
            case .ArrayOfDictionaries :
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
            case .ZCRMRecordDelegate :
                guard let lhsValue = lhs as? ZCRMRecordDelegate, let rhsValue = rhs as? ZCRMRecordDelegate else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .ZCRMUserDelegate :
                guard let lhsValue = lhs as? ZCRMUserDelegate, let rhsValue = rhs as? ZCRMUserDelegate else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .ZCRMInventoryLineItem :
                guard let lhsValue = lhs as? ZCRMInventoryLineItem, let rhsValue = rhs as? ZCRMInventoryLineItem else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .ZCRMPriceBookPricing :
                guard let lhsValue = lhs as? ZCRMPriceBookPricing, let rhsValue = rhs as? ZCRMPriceBookPricing else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .ZCRMEventParticipant :
                guard let lhsValue = lhs as? ZCRMEventParticipant, let rhsValue = rhs as? ZCRMEventParticipant else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .ZCRMLineTax :
                guard let lhsValue = lhs as? ZCRMLineTax, let rhsValue = rhs as? ZCRMLineTax else {
                    return false
                }
                return lhsValue == rhsValue
            case .ZCRMTaxDelegate :
                guard let lhsValue = lhs as? ZCRMTaxDelegate, let rhsValue = rhs as? ZCRMTaxDelegate else {
                    return false
                }
                return lhsValue == rhsValue
            case .ArrayOfStrings :
                guard let lhsValue = lhs as? [ String ], let rhsValue = rhs as? [ String ] else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .ZCRMDataProcessingBasisDetails :
                guard let lhsValue = lhs as? ZCRMDataProcessBasisDetails, let rhsValue = rhs as? ZCRMDataProcessBasisDetails else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .ZCRMLayoutDelegate :
                guard let lhsValue = lhs as? ZCRMLayoutDelegate, let rhsValue = rhs as? ZCRMLayoutDelegate else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .ArrayOfZCRMSubformRecord :
                guard let lhsValue = lhs as? [ ZCRMSubformRecord ], let rhsValue = rhs as? [ ZCRMSubformRecord ] else
                {
                    return false
                }
                return lhsValue == rhsValue
            case .Undefined :
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
    static let CODE_SUCCESS : String = "success"
    static let INFO : String = "info"
    static let DETAILS : String = "details"
    
    static let MODULES : String = "modules"
    static let PRIVATE_FIELDS = "private_fields"
    static let PER_PAGE : String = "per_page"
    static let PAGE : String = "page"
    static let COUNT : String = "count"
    static let MORE_RECORDS : String = "more_records"
    
    static let REMAINING_COUNT_FOR_THIS_DAY : String = "X-RATELIMIT-LIMIT"
    static let REMAINING_COUNT_FOR_THIS_WINDOW : String = "X-RATELIMIT-REMAINING"
    static let REMAINING_TIME_FOR_THIS_WINDOW_RESET : String = "X-RATELIMIT-RESET"
    static let DATE : String = "Date"
    
    static let STRING_MOCK : String = "SDK_NIL"
    static let INT_MOCK : Int = -555
    static let INT64_MOCK : Int64 = -555
    static let DOUBLE_MOCK : Double = -55.5555555555555555
    static let BOOL_MOCK : Bool = false
    
    static let SETTINGS : String = "settings"
    static let EMAILS : String = "emails"
    static let ORG_EMAILS : String = "org_emails"
    static let TRIGGER : String = "trigger"
    
    static let MAX_ALLOWED_FILE_SIZE_IN_MB : Int = 20
    static let MAX_ALLOWED_FILE_SIZE : Int = 20971520
    var ENABLED_DB_CACHE : Bool = true
    
    static let EXCEPTION_LOG_MSG : String = "ZCRM SDK - "
}

internal struct DefaultModuleAPINames
{
    static let LEADS : String = "Leads"
    static let ACCOUNTS : String = "Accounts"
    static let CONTACTS : String = "Contacts"
    static let DEALS : String = "Deals"
    static let QUOTES : String = "Quotes"
    static let SALES_ORDERS : String = "Sales_Orders"
    static let INVOICES : String = "Invoices"
    static let PURCHASE_ORDERS : String = "Purchase_Orders"
    static let PRODUCTS : String = "Products"
    static let EVENTS : String = "Events"
    static let NOTES : String = "Notes"
    static let ATTACHMENTS : String = "Attachments"
    static let SOCIAL : String = "Social"
    static let PRICE_BOOKS : String = "Price_Books"
    static let CALLS : String = "Calls"
    static let ORGANIZATIONS : String = "organizations"
    static let TASKS : String = "Tasks"
}

internal struct RequestParamKeys
{
    static let page : String = "page"
    static let perPage : String = "per_page"
    static let sortBy : String = "sort_by"
    static let sortOrder : String = "sort_order"
    static let id : String = "id"
    static let ids : String = "ids"
    static let type : String = "type"
    static let ifModifiedSince : String = "If-Modified-Since"
    static let module : String = "module"
}

var ACCOUNTSURL : String = String()
var CRM : String = "crm"
var COUNTRYDOMAIN : String = "com"
var EMAIL : String = "email"

var AUTHORIZATION : String = "Authorization"
var USER_AGENT : String = "User-Agent"
var X_CRM_ORG : String = "X-CRM-ORG"
var ZOHO_OAUTHTOKEN = "Zoho-oauthtoken"

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
    static let ANALYTICS : String = "Analytics"
    static let STAGES : String = "stages"
    static let TAXES : String = "taxes"
    static let TIMELINES : String = "timelines"
    static let ORG_EMAILS : String = "org_emails"
    static let VARIABLES : String = "variables"
    static let VARIABLE_GROUPS : String = "variable_groups"
    static let ORG_INFO : String = "org_info"
    static let NOTIFICATIONS : String = "notifications"
    static let EMAIL_RELATED_LIST :String = "email_related_list"
    static let ORGANIZATIONS : String = "organizations"
    static let PIPELINE : String = "pipeline"
    static let FILTERS : String = "filters"
    static let CURRENCIES : String = "currencies"
}

//MARK:- RESULT TYPES
//MARK:  Error Type (ZCRMError) is common to every Result Type
//MARK:  Result types can be handled in 2 ways:
//MARK:  1) Handle Result Types either by calling Resolve()
//MARK:  2) on them or use the traditional switch case pattern to handle success and failure seperately
public struct Result {
    
    //MARK: DATA RESPONSE RESULT TYPE (Data,Response,Error)
    //MARK: This either gives (DATA,RESPONSE) as TUPLE OR (ERROR) but NOT BOTH AT THE SAME TIME
    //MARK: Data -> Any ZCRMInstance
    //MARK: Response -> (FileAPIResponse,APIResponse,BulkAPIResponse)->>> (Any Class inhering from CommonAPIResponse)
    //MARK: Error -> ZCRMError ->>> (Conforms to Error Type)
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
    
    //MARK: RESPONSE RESULT TYPE (Only Response and Error)
    //MARK: This either gives (RESPONSE) OR (ERROR) but NOT BOTH AT THE SAME TIME
    //MARK: Response -> (FileAPIResponse,APIResponse,BulkAPIResponse)->>> (Any Class inhering from CommonAPIResponse)
    //MARK: Error -> ZCRMError ->>> (Conforms to Error Type)
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
    
    //MARK: DATA RESULT TYPE (Only Response and Error)
    //MARK: This either gives (RESPONSE) OR (ERROR) but NOT BOTH AT THE SAME TIME
    //MARK: Response -> (FileAPIResponse,APIResponse,BulkAPIResponse)->>> (Any Class inhering from CommonAPIResponse)
    //MARK: Error -> ZCRMError ->>> (Conforms to Error Type)
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

func typeCastToZCRMError( _ error : Error ) -> ZCRMError {
    if let typecastedError = error as? ZCRMError
    {
        return typecastedError
    }
    else
    {
        if error.code == NSURLErrorNotConnectedToInternet
        {
            return ZCRMError.NetworkError( code : ErrorCode.NO_INTERNET_CONNECTION, message : error.localizedDescription, details : nil )
        }
        else if error.code == NSURLErrorTimedOut
        {
            return ZCRMError.NetworkError( code : ErrorCode.REQUEST_TIMEOUT, message : error.localizedDescription, details : nil )
        }
        return ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : error.description, details : nil )
    }
}

func getUserDelegate( userJSON : [ String : Any ] ) throws -> ZCRMUserDelegate
{
    let user : ZCRMUserDelegate = ZCRMUserDelegate( id : try userJSON.getInt64( key : "id" ), name : try userJSON.getString( key : "name" ) )
    return user
}

func setUserDelegate( userObj : ZCRMUserDelegate ) -> [ String : Any ]
{
    var userJSON : [String:Any] = [String:Any]()
    userJSON[ "id" ] = userObj.id
    userJSON[ "name" ] = userObj.name
    return userJSON
}

func activitiesCVModuleCheck( module : String ) throws
{
    if !( module == DefaultModuleAPINames.TASKS || module == DefaultModuleAPINames.EVENTS || module == DefaultModuleAPINames.CALLS )
    {
        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.INVALID_MODULE) : the module given seems to be invalid")
        throw ZCRMError.InValidError(code: ErrorCode.INVALID_MODULE, message: "the module given seems to be invalid", details: nil)
    }
}

func relatedModuleCheck( module : String ) throws
{
    if module == DefaultModuleAPINames.SOCIAL
    {
        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.INVALID_MODULE) : This feature is not supported for integrated modules")
        throw ZCRMError.InValidError(code : ErrorCode.INVALID_MODULE, message : "This feature is not supported for integrated modules", details : nil )
    }
    else if module == DefaultModuleAPINames.NOTES || module == DefaultModuleAPINames.ATTACHMENTS
    {
        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.INVALID_OPERATION) : Try using getNotes or getAttachments methods")
        throw ZCRMError.InValidError( code : ErrorCode.INVALID_OPERATION, message : "Try using getNotes or getAttachments methods", details : nil )
    }
}

func callsModuleCheck( module : String ) throws
{
    if !(module == DefaultModuleAPINames.CALLS)
    {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.NOT_SUPPORTED) : This feature is not supported for this module")
        throw ZCRMError.InValidError(code: ErrorCode.NOT_SUPPORTED, message: "This feature is not supported for this module", details: nil)
    }
}

func getTriggerArray( triggers : [Trigger] ) -> [String]
{
    var triggerString : [String] = [String]()
    if triggers.contains(Trigger.WORKFLOW)
    {
        triggerString.append(Trigger.WORKFLOW.rawValue)
    }
    if triggers.contains(Trigger.APPROVAL)
    {
        triggerString.append(Trigger.APPROVAL.rawValue)
    }
    if triggers.contains(Trigger.BLUEPRINT)
    {
        triggerString.append(Trigger.BLUEPRINT.rawValue)
    }
    return triggerString
}

func getFieldVsApinameMap( fields : [ZCRMField] ) -> [ String: ZCRMField ]
{
    var moduleFields : [ String : ZCRMField ] = [ String : ZCRMField ]()
    for field in fields
    {
        moduleFields[ field.apiName ] = field
    }
    return moduleFields
}

func notesAttachmentLimitCheck( note : ZCRMNote ) throws
{
    var count : Int = 0
    if let attachments = note.attachments
    {
        count = attachments.count
    }
    if count > 5
    {
        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.INVALID_OPERATION) : Cannot add more than 5 attachments to a note")
        throw ZCRMError.ProcessingError( code : ErrorCode.INVALID_OPERATION, message : "Cannot add more than 5 attachments to a note", details : nil )
    }
}

//DB Constants

internal struct DBConstant
{
    static let CACHE_DB_NAME = "zoho-crm-sdk-cache.db"
    
    /// Tables in the database zoho-crm-sdk.db
    static let TABLE_RESPONSES = "URL_VS_RESPONSE"
    
    // Columns in the table RESPONSES
    static let COLUMN_URL = "URL"
    static let COLUMN_DATA = "DATA"
    static let COLUMN_VALIDITY = "VALIDITY"
    
    static let PERSISTENT_DB_NAME = "zoho-crm-sdk-persistent.db"
    
    // Tables in the database zoho-crm-sdk-persistent.db
    static let TABLE_PUSH_NOTIFICATIONS = "PUSH_NOTIFICATIONS_DETAILS"
    static let TABLE_CURRENT_PORTAL = "CURRENT_PORTAL"
    
    // Columns in the table PUSH_NOTIFICATIONS_DETAILS
    static let COLUMN_APP_ID = "APP_ID"
    static let COLUMN_APNS_MODE = "APNS_MODE"
    static let COLUMN_NF_ID = "NF_ID"
    static let COLUMN_NF_CHANNEL = "NF_CHANNEL"
    static let COLUMN_INS_ID = "INS_ID"
    static let COLUMN_SERVICE_NAME = "SERVICE_NAME"
    static let COLUMN_MOBILE_VERSION = "MOBILE_VERSION"
    
    // Columns in the table CURRENT_PORTAL
    static let COLUMN_PORTAL_ID = "PORTAL_ID"
    
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
    
    static let VALIDITY_TIME = "datetime('now','+6 hours')"
    static let CURRENT_TIME = "datetime('now')"
}

internal struct ResponsesTableStatement
{
    func insert( _ withURL : String, data : String, validity : String ) -> String
    {
        return "\(DBConstant.DML_INSERT) \(DBConstant.KEYS_INTO) \(DBConstant.TABLE_RESPONSES) (\(DBConstant.COLUMN_URL), \(DBConstant.COLUMN_DATA), \(DBConstant.COLUMN_VALIDITY)) \(DBConstant.KEYS_VALUES) (\"\(withURL)\", \"\(data)\", \"\(validity)\");"
    }
    
    func createTable() -> String
    {
        return "\(DBConstant.DML_CREATE) TABLE IF NOT EXISTS \(DBConstant.TABLE_RESPONSES)(\(DBConstant.COLUMN_URL) VARCHAR PRIMARY KEY NOT NULL, \(DBConstant.COLUMN_DATA) TEXT NOT NULL, \(DBConstant.COLUMN_VALIDITY) TEXT NOT NULL);"
    }
    
    func update(_ withURL : String, andDATA : String ) -> String
    {
        return "\(DBConstant.DML_UPDATE) \(DBConstant.TABLE_RESPONSES) SET \(DBConstant.COLUMN_DATA) = \"\(andDATA)\", \(DBConstant.COLUMN_VALIDITY) = \(DBConstant.VALIDITY_TIME) \(DBConstant.CLAUSE_WHERE) \(DBConstant.COLUMN_URL) = \"\(withURL)\";"
    }
    
    func delete(_ withURL : String ) -> String
    {
        return "\(DBConstant.DML_DELETE) \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_RESPONSES) \(DBConstant.CLAUSE_WHERE) \(DBConstant.COLUMN_URL) = \"\(withURL)\";"
    }
    
    func deleteAll() -> String
    {
        return "\(DBConstant.DML_DELETE) \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_RESPONSES);"
    }
    
    func fetchData(_ withURL : String ) -> String
    {
        return "\(DBConstant.DQL_SELECT) * \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_RESPONSES) \(DBConstant.CLAUSE_WHERE) \(DBConstant.COLUMN_URL) = \"\(withURL)\" AND \(DBConstant.COLUMN_VALIDITY) > \"\(DBConstant.CURRENT_TIME)\";"
    }
    
    func searchData(_ withURL : String ) -> String
    {
        return "\(DBConstant.DQL_SELECT) * \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_RESPONSES) \(DBConstant.CLAUSE_WHERE) \(DBConstant.COLUMN_URL) LIKE \'\(withURL)?%\' AND \(DBConstant.COLUMN_VALIDITY) > \"\(DBConstant.CURRENT_TIME)\";"
    }
}
    
internal struct PushNotificationsTableStatement
{
    func insert( nfId : String, nfChannel : String, insId : String, appId : String, apnsMode : String ) -> String
    {
        return "\(DBConstant.DML_INSERT) \(DBConstant.KEYS_INTO) \(DBConstant.TABLE_PUSH_NOTIFICATIONS) (\(DBConstant.COLUMN_NF_ID), \(DBConstant.COLUMN_NF_CHANNEL), \(DBConstant.COLUMN_INS_ID), \(DBConstant.COLUMN_APP_ID), \(DBConstant.COLUMN_APNS_MODE)) \(DBConstant.KEYS_VALUES) (\"\(nfId)\", \"\(nfChannel)\", \"\(insId)\", \"\(appId)\", \"\(apnsMode)\" );"
    }
    
    func createTable() -> String
    {
        return "\(DBConstant.DML_CREATE) TABLE IF NOT EXISTS  \(DBConstant.TABLE_PUSH_NOTIFICATIONS) (\(DBConstant.COLUMN_NF_ID) VARCHAR PRIMARY KEY NOT NULL, \(DBConstant.COLUMN_NF_CHANNEL) TEXT NOT NULL, \(DBConstant.COLUMN_INS_ID) TEXT NOT NULL, \(DBConstant.COLUMN_APP_ID) TEXT NOT NULL, \(DBConstant.COLUMN_APNS_MODE) TEXT NOT NULL );"
    }
    
    func delete() -> String
    {
        return "\(DBConstant.DML_DELETE) \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_PUSH_NOTIFICATIONS)"
    }
    
    func fetchData() -> String
    {
        return "\(DBConstant.DQL_SELECT) * \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_PUSH_NOTIFICATIONS);"
    }
}

internal struct PortalTableStatement
{
    func insert( portalId : Int64 ) -> String
    {
        return "\(DBConstant.DML_INSERT) \(DBConstant.KEYS_INTO) \(DBConstant.TABLE_CURRENT_PORTAL) (\(DBConstant.COLUMN_PORTAL_ID)) \(DBConstant.KEYS_VALUES) (\"\(portalId)\");"
    }
    
    func createTable() -> String
    {
        return "\(DBConstant.DML_CREATE) TABLE IF NOT EXISTS \(DBConstant.TABLE_CURRENT_PORTAL)(\(DBConstant.COLUMN_PORTAL_ID) VARCHAR PRIMARY KEY NOT NULL);"
    }
    
    func delete() -> String
    {
        return "\(DBConstant.DML_DELETE) \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_CURRENT_PORTAL)"
    }
    
    func fetchData() -> String
    {
        return "\(DBConstant.DQL_SELECT) * \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_CURRENT_PORTAL);"
    }
}

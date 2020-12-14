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
    case unAuthenticatedError( code : String, message : String, details : Dictionary< String, Any >? )
    case inValidError( code : String, message : String, details : Dictionary< String, Any >? )
    case maxRecordCountExceeded( code : String, message : String, details : Dictionary< String, Any >? )
    case fileSizeExceeded( code : String, message : String, details : Dictionary< String, Any >? )
    case processingError( code : String, message : String, details : Dictionary< String, Any >? )
    case sdkError( code : String, message : String, details : Dictionary< String, Any >? )
    case networkError( code : String, message : String, details : Dictionary< String, Any >? )
}

public struct ErrorCode
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
}

public struct ErrorMessage
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

public enum SortOrder : String, Codable
{
    case ascending = "asc"
    case descending = "desc"
}

public enum AccessType : String
{
    case production = "Production"
    case development = "Development"
    case sandBox = "Sandbox"
}

public enum CommunicationPreferences : String, Codable
{
    case email = "Email"
    case phone = "Phone"
    case survey = "Survey"
}

public enum ConsentThrough
{
    public enum Readable : String, Codable
    {
        case consentForm = "Consent Form"
        case customerPortal = "Portal"
        case webForm = "Web Form"
        case email = "Email"
        case call = "Call"
    }
    
    public enum Writable : String
    {
        case email = "Email"
        case call = "Call"
        
        func toReadable() -> ConsentThrough.Readable
        {
            switch self
            {
            case .email :
                return .email
            case .call :
                return .call
            }
        }
    }
}

public enum CurrencyRoundingOption : String, Codable
{
    case roundOff = "round_off"
    case roundDown = "round_down"
    case roundUp = "round_up"
    case normal = "normal"
}

public enum Trigger : String
{
    case workFlow = "workflow"
    case approval = "approval"
    case bluePrint = "blueprint"
}

internal enum CacheFlavour : String
{
    case noCache = "NO_CACHE"
    case urlVsResponse = "URL_VS_RESPONSE"
    case data = "DATA"
    case forceCache = "FORCE_CACHE"
}

public enum EventParticipantType : String, Codable
{
    case email = "email"
    case user = "user"
    case contact = "contact"
    case lead = "lead"
}

public enum DrillBy : String
{
    case user = "user"
    case role = "role"
}

internal struct FieldDataTypeConstants
{
    static var subform = "subform"
    static var userLookup = "userlookup"
    static let ownerLookup = "ownerlookup"
}

public enum EventParticipant : Equatable, Codable
{
    case email( String)
    case user( ZCRMUserDelegate )
    case record( ZCRMRecordDelegate )
    
//    enum CodingKeys: String, CodingKey
//    {
//        case name
//        case percentage
//        case value
//        case isValueSet
//    }
//    required public init(from decoder: Decoder) throws
//    {
//        let values = try! decoder.container(keyedBy: CodingKeys.self)
//
//        name = try! values.decode(String.self, forKey: .name)
//        percentage = try! values.decode(Double.self, forKey: .percentage)
//        value = try! values.decode(Double.self, forKey: .value)
//        isValueSet = try! values.decode(Bool.self, forKey: .isValueSet)
//    }
//    open func encode( to encoder : Encoder ) throws
//    {
//        var container = encoder.container( keyedBy : CodingKeys.self )
//
//        try container.encode( self.name, forKey : CodingKeys.name )
//        try container.encode( self.percentage, forKey : CodingKeys.percentage )
//        try container.encode( self.value, forKey : CodingKeys.value )
//        try container.encode( self.isValueSet, forKey : CodingKeys.isValueSet )
//    }
    
    public func getEmail() -> String?
    {
        switch self
        {
        case .email( let value ) :
            return value
            
        default:
            return nil
        }
    }
    
    public func getUser() -> ZCRMUserDelegate?
    {
        switch self
        {
        case .user( let value ) :
            return value
            
        default :
            return nil
        }
    }
    
    public func getRecord() -> ZCRMRecordDelegate?
    {
        switch self
        {
        case .record( let value ) :
            return value
            
        default :
            return nil
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

public enum AppType : String
{
    case zcrm = "zcrm"
    case solutions = "solutions"
    case bigin = "bigin"
    case zvcrm = "zvcrm"
    case zcrmcp = "zcrmcp"
}

public enum ComponentPeriod : String
{
    case day = "day"
    case week = "fiscal_week"
    case month = "month"
}

public enum PortalType : String
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
    case arrayOfStrings
    case zcrmDataProcessingBasisDetails
    case zcrmLayoutDelegate
    case arrayOfZCRMSubformRecord
    case undefined
}

public enum UserTypes : String
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

public enum TrashRecordTypes : String
{
    case all
    case recycle
    case permanent
}

internal enum MaxFileSize : Int64 {
    case notesAttachment = 20971520 // 20 MB
    case attachment = 104857600 // 100 MB
    case profilePhoto = 5242880 // 5 MB
    case entityImageAttachment = 2097152 // 2 MB
    case emailAttachment = 10485760 // 10 MB
}

public enum VariableType : String
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
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.valueNil) : \( forKey ) must not be nil, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ErrorCode.valueNil, message : "\( forKey ) must not be nil", details : nil )
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
    
    func optJSONValue(key: Key) -> JSONValue?
    {
        if( self.hasValue( forKey : key ) ), let value = self[ key ]
        {
            return JSONValue(value: value)
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
    
    func optJSONDictionary(key : Key) -> Dictionary<String, JSONValue>?
    {
        return optValue(key: key) as? Dictionary<String, JSONValue>
    }
    
    func optArray(key : Key) -> Array<Any>?
    {
        return optValue(key: key) as? Array<Any>
    }
    
    func optArrayOfDictionaries( key : Key ) -> Array< Dictionary < String, Any > >?
    {
        return ( optValue( key : key ) as? Array< Dictionary < String, Any > > )
    }
    
    func optArrayOfJSONDictionaries( key : Key ) -> Array< Dictionary < String, JSONValue > >?
    {
        return ( optValue( key : key ) as? Array< Dictionary < String, JSONValue > > )
    }
    
    func getInt( key : Key ) throws -> Int
    {
        try self.valueCheck( forKey : key )
        guard let value = optInt( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.typeCastError) : \( key ) - Expected type -> INT, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.typeCastError, message : "\( key ) - Expected type -> INT", details : nil )
        }
        return value
    }
    
    func getInt64( key : Key ) throws -> Int64
    {
        try self.valueCheck( forKey : key )
        guard let value = optInt64( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.typeCastError) : \( key ) - Expected type -> INT64, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.typeCastError, message : "\( key ) - Expected type -> INT64", details : nil )
        }
        return value
    }
    
    func getString( key : Key ) throws -> String
    {
        try self.valueCheck( forKey : key )
        guard let value = optString( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.typeCastError) : \( key ) - Expected type -> STRING, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.typeCastError, message : "\( key ) - Expected type -> STRING", details : nil )
        }
        return value
    }
    
    func getBoolean( key : Key ) throws -> Bool
    {
        try self.valueCheck( forKey : key )
        guard let value = optBoolean( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.typeCastError) : \( key ) - Expected type -> BOOLEAN, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.typeCastError, message : "\( key ) - Expected type -> BOOLEAN", details : nil )
        }
        return value
    }
    
    func getDouble( key : Key ) throws -> Double
    {
        try self.valueCheck( forKey : key )
        guard let value = optDouble( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.typeCastError) : \( key ) - Expected type -> DOUBLE, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.typeCastError, message : "\( key ) - Expected type -> DOUBLE", details : nil )
        }
        return value
    }
    
    func getArray( key : Key ) throws -> Array< Any >
    {
        try self.valueCheck( forKey : key )
        guard let value = optArray( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.typeCastError) : \( key ) - Expected type -> ARRAY< ANY >, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.typeCastError, message : "\( key ) - Expected type -> ARRAY< ANY >", details : nil )
        }
        return value
    }
    
    func getDictionary( key : Key ) throws -> Dictionary< String, Any >
    {
        try self.valueCheck( forKey : key )
        guard let value = optDictionary( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.typeCastError) : \( key ) - Expected type -> DICTIONARY< STRING, ANY >, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.typeCastError, message : "\( key ) - Expected type -> DICTIONARY< STRING, ANY >", details : nil )
        }
        return value
    }
    
    func getArrayOfDictionaries( key : Key ) throws -> Array< Dictionary < String, Any > >
    {
        try self.valueCheck( forKey : key )
        guard let value = optArrayOfDictionaries( key : key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.typeCastError) : \( key ) - Expected type -> ARRAY< DICTIONARY< STRING, ANY > >, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.typeCastError, message : "\( key ) - Expected type -> ARRAY< DICTIONARY < STRING, ANY > >", details : nil )
        }
        return value
    }
    
    func getValue( key : Key ) throws -> Any
    {
        guard let value = optValue( key: key ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.processingError) : \( key ) - Key Not found - \( key ), \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.processingError, message : "\( key ) - Key not found - \( key )", details : nil )
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
            if let key = key as? String, dictKeys.firstIndex(of: key) == nil
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


internal func fileDetailCheck( filePath : String?, fileData : Data?, maxFileSize : MaxFileSize) throws
{
    let maxFileSizeValue = maxFileSize.rawValue
    if let filePath = filePath
    {
        if ( FileManager.default.fileExists( atPath : filePath )  == false )
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : File not found at given path : \( filePath ), \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ErrorCode.mandatoryNotFound, message : "File not found at given path : \( filePath )", details : nil )
        }
        if ( getFileSize( filePath : filePath ) > maxFileSizeValue )
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.fileSizeExceeded) : Cannot upload. File size should not exceed \( maxFileSizeValue / 1048576 ) MB, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.fileSizeExceeded( code : ErrorCode.fileSizeExceeded, message : "Cannot upload. File size should not exceed \( maxFileSizeValue / 1048576) MB", details : nil )
        }
    }
    else if let fileData = fileData
    {
        if fileData.count > maxFileSizeValue
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.fileSizeExceeded) : Cannot upload. File size should not exceed \( maxFileSizeValue / 1048576) MB, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.fileSizeExceeded( code : ErrorCode.fileSizeExceeded, message : "Cannot upload. File size should not exceed \( maxFileSizeValue / 1048576) MB", details : nil )
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
            throw ZCRMError.processingError( code : ErrorCode.invalidFileType, message : ErrorMessage.invalidFileTypeMsg, details : nil )
        }
        
        guard UIImage(contentsOfFile: filePath) != nil else {
            throw ZCRMError.processingError( code : ErrorCode.invalidFileType, message : ErrorMessage.invalidFileTypeMsg, details : nil )
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
    static let CODE_SUCCESS : String = "success"
    static let INFO : String = "info"
    static let DETAILS : String = "details"
    static let PERMISSIONS : String = "permissions"
    
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
    
    static let TRIGGER : String = "trigger"
    static let DUPLICATE_CHECK_FIELDS : String = "duplicate_check_fields"
    
    static let MAX_ALLOWED_FILE_SIZE_IN_MB : Int = 20
    static let MAX_ALLOWED_FILE_SIZE : Int = 20971520
    var ENABLED_DB_CACHE : Bool = true
    
    static let EXCEPTION_LOG_MSG : String = "ZCRM SDK - "
}

public struct DefaultModuleAPINames
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
    static let lastMailIndex : String = "last_mail_index"
    static let startIndex : String = "start_index"
    static let dealsMail : String = "deals_mail"
    static let category : String = "category"
    static let criteria = "criteria"
}

var ACCOUNTSURL : String = String()
var CRM : String = "crm"
var COUNTRYDOMAIN : String = "com"
var EMAIL : String = "email"

var AUTHORIZATION : String = "Authorization"
var USER_AGENT : String = "User-Agent"
var X_CRM_ORG : String = "X-CRM-ORG"
var X_ZOHO_SERVICE : String = "X-ZOHO-SERVICE"
var X_CRM_PORTAL : String = "X-CRMPORTAL"
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
    static let STAGES : String = "stages"
    static let TAXES : String = "taxes"
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
}

//MARK:- RESULT TYPES
//MARK:  Error Type (ZCRMError) is common to every Result Type
//MARK:  Result types can be handled in 2 ways:
//MARK:  1) Handle Result Types either by calling Resolve()
//MARK:  2) on them or use the traditional switch case pattern to handle success and failure seperately
public struct ResultType {
    
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
        if error.code == NSURLErrorNotConnectedToInternet
        {
            return ZCRMError.networkError( code : ErrorCode.noInternetConnection, message : error.localizedDescription, details : nil )
        }
        else if error.code == NSURLErrorTimedOut
        {
            return ZCRMError.networkError( code : ErrorCode.requestTimeOut, message : error.localizedDescription, details : nil )
        }
        else if error.code == NSURLErrorNetworkConnectionLost
        {
            return ZCRMError.networkError( code : ErrorCode.networkConnectionLost, message : error.localizedDescription, details : nil )
        }
        else if error.code == NSURLErrorCannotFindHost
        {
            return ZCRMError.networkError(code: ErrorCode.cannotFindHost, message: error.localizedDescription, details: nil)
        }
        return ZCRMError.sdkError( code : ErrorCode.internalError, message : error.description, details : nil )
    }
}

func getUserDelegate( userJSON : [ String : Any ] ) throws -> ZCRMUserDelegate
{
    let user : ZCRMUserDelegate = ZCRMUserDelegate( id : try userJSON.getString( key : "id" ), name : try userJSON.getString( key : "name" ) )
    return user
}

func setUserDelegate( userObj : ZCRMUserDelegate ) -> [ String : Any ]
{
    var userJSON : [String:Any] = [String:Any]()
    userJSON[ "id" ] = userObj.id
    userJSON[ "name" ] = userObj.name
    return userJSON
}

func relatedModuleCheck( module : String ) throws
{
    if module == DefaultModuleAPINames.SOCIAL
    {
        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidModule) : This feature is not supported for integrated modules, \( APIConstants.DETAILS ) : -")
        throw ZCRMError.inValidError(code : ErrorCode.invalidModule, message : "This feature is not supported for integrated modules", details : nil )
    }
    else if module == DefaultModuleAPINames.NOTES || module == DefaultModuleAPINames.ATTACHMENTS
    {
        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidOperation) : Try using getNotes or getAttachments methods, \( APIConstants.DETAILS ) : -")
        throw ZCRMError.inValidError( code : ErrorCode.invalidOperation, message : "Try using getNotes or getAttachments methods", details : nil )
    }
}

func getTriggerArray( triggers : [Trigger] ) -> [String]
{
    var triggerString : [String] = [String]()
    if triggers.contains(Trigger.workFlow)
    {
        triggerString.append(Trigger.workFlow.rawValue)
    }
    if triggers.contains(Trigger.approval)
    {
        triggerString.append(Trigger.approval.rawValue)
    }
    if triggers.contains(Trigger.bluePrint)
    {
        triggerString.append(Trigger.bluePrint.rawValue)
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

func notesAttachmentLimitCheck( note : ZCRMNote, filePath : String?, fileData : Data? ) throws
{
    var attachmentSize : Int64 = 0
    
    if let notesAttachments = note.attachments
    {
        if notesAttachments.count >= 5
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.limitExceeded) : Cannot add more than 5 attachments to a note, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.limitExceeded, message : "Cannot add more than 5 attachments to a note", details : nil )
        }
        for notesAttachment in notesAttachments
        {
            if let fileSize = notesAttachment.fileSize
            {
                attachmentSize += fileSize
            }
        }
    }
    
    let availableSpaceInMB : Float = Float( MaxFileSize.notesAttachment.rawValue - attachmentSize ) / 1048576
    
    guard availableSpaceInMB > 0 else
    {
        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.fileSizeExceeded) : Cannot upload. Attachments size already reached the allowed value  - 20 MB, \( APIConstants.DETAILS ) : -")
        throw ZCRMError.fileSizeExceeded( code : ErrorCode.fileSizeExceeded, message : "Cannot upload. Attachments size already reached the allowed value  - 20 MB", details : nil )
    }
    
    if let filePath = filePath
    {
        if ( FileManager.default.fileExists( atPath : filePath )  == false )
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : File not found at given path : \( filePath ), \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ErrorCode.mandatoryNotFound, message : "File not found at given path : \( filePath )", details : nil )
        }
        let fileSize = Float( getFileSize( filePath : filePath ) ) / 1048576
        if ( fileSize > availableSpaceInMB )
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.fileSizeExceeded) : Cannot upload. Available Free Space - \( availableSpaceInMB ) MB. The Attachment Size is \( fileSize  ) MB, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.fileSizeExceeded( code : ErrorCode.fileSizeExceeded, message : "Cannot upload. Available Free Space - \( availableSpaceInMB ) MB. The Attachment Size is \( fileSize ) MB", details : nil )
        }
    }
    else if let fileData = fileData
    {
        let fileSize = Float( fileData.count ) / 1048576
        if ( fileSize > availableSpaceInMB )
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.fileSizeExceeded) : Cannot upload. Available Free Space - \( availableSpaceInMB ) MB. The Attachment Size is \( fileSize ) MB, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.fileSizeExceeded( code : ErrorCode.fileSizeExceeded, message : "Cannot upload. Available Free Space - \( availableSpaceInMB ) MB. The Attachment Size is \( fileSize ) MB", details : nil )
        }
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
    
    static let VALIDITY_TIME = "datetime('now','+\( ZCRMSDKClient.shared.cacheValidityTimeInHours ) hours')"
    static let CURRENT_TIME = "datetime('now')"
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
    
    func update(_ withURL : String, andDATA : String ) -> String
    {
        return "\(DBConstant.DML_UPDATE) \(DBConstant.TABLE_RESPONSES) SET \(DBConstant.COLUMN_DATA) = \"\(andDATA)\", \(DBConstant.COLUMN_VALIDITY) = \(DBConstant.VALIDITY_TIME) \(DBConstant.CLAUSE_WHERE) \(DBConstant.COLUMN_URL) = \"\(withURL)\";"
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
        return "\(DBConstant.DML_DELETE) \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_RESPONSES);"
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
            ZCRMLogger.logError(message: "Proprty transformation is currently not supported for keyPath \(keyPath)!")
        }
    }
    
    mutating func applyTransformation() {
        Self.keyPathAndTransformationDict.keys.forEach{ transformAndWriteBackValue($0) }
    }
}

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
    case UnAuthenticatedError( code : String, message : String )
    case InValidError( code : String, message : String )
    case MaxRecordCountExceeded( code : String, message : String )
    case FileSizeExceeded( code : String, message : String )
    case ProcessingError( code : String, message : String )
    case SDKError( code : String, message : String )
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
}

public struct ErrorMessage
{
    public static var INVALID_ID_MSG  = "The given id seems to be invalid."
    public static var API_MAX_RECORDS_MSG = "Cannot process more than 100 records at a time."
    public static var RESPONSE_NIL_MSG  = "Response is nil"
    public static var OAUTHTOKEN_NIL_MSG = "The oauth token is nil"
    public static var OAUTH_FETCH_ERROR_MSG = "There was an error in fetching oauth Token"
    public static var UNABLE_TO_CONSTRUCT_URL_MSG = "There was a problem constructing the URL"
    public static var INVALID_FILE_TYPE_MSG = "The file you have chosen is not supported. Please choose a PNG, JPG, BMP, or GIF file type."
}

public extension Error
{
    public var code : Int
    {
        return ( self as NSError ).code
    }
    
    public var description : String
    {
        return ( self as NSError ).localizedDescription
    }
    
    public var ZCRMErrordetails : ( code : String, description : String )?
    {
        guard let error = self as? ZCRMError else {
            return nil
        }
        switch error
        {
            case .UnAuthenticatedError( let code, let desc ):
                return ( code, desc )
            case .InValidError( let code, let desc ):
                return ( code, desc )
            case .MaxRecordCountExceeded( let code, let desc ):
                return ( code, desc )
            case .FileSizeExceeded( let code, let desc ):
                return ( code, desc )
            case .ProcessingError( let code, let desc ):
                return ( code, desc )
            case .SDKError( let code, let desc ):
                return ( code, desc )
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

public enum XPhotoViewPermission  : Int
{
    case zero = 0
    case one = 1
    case two = 2
    case three = 3
    case four = 4
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
    case RoundOff = "round_off"
    case RoundDown = "round_down"
    case RoundUp = "round_up"
    case Normal = "normal"
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
    
    func optValue(key: Key) -> Any?
    {
        if(self.hasValue(forKey: key))
        {
            return self[key]!
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
    
    func getInt( key : Key ) -> Int
    {
        return optInt( key : key )!
    }
    
    func getInt64( key : Key ) -> Int64
    {
        return optInt64( key : key )!
    }
    
    func getString( key : Key ) -> String
    {
        return optString( key : key )!
    }
    
    func getBoolean( key : Key ) -> Bool
    {
        return optBoolean( key : key )!
    }
    
    func getDouble( key : Key ) -> Double
    {
        return optDouble( key : key )!
    }
    
    func getArray( key : Key ) -> Array< Any >
    {
        return optArray( key : key )!
    }
    
    func getDictionary( key : Key ) -> Dictionary< String, Any >
    {
        return optDictionary( key : key )!
    }
    
    func getArrayOfDictionaries( key : Key ) -> Array< Dictionary < String, Any > >
    {
        return optArrayOfDictionaries( key : key )!
    }
    
    func convertToJSON() -> String
    {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: String.Encoding.ascii)
        return jsonString!
    }
    
    func equateKeys( dictionary : [ String : Any ] ) -> Bool
    {
        let dictKeys = dictionary.keys
        var isEqual : Bool = true
        for key in self.keys
        {
            if dictKeys.index(of: key as! String) == nil
            {
                isEqual = false
            }
        }
        return isEqual
    }
    
    
}

public extension Array
{
    func ArrayOfDictToStringArray () -> String {
        var stringArray: [String] = []
        
        self.forEach {
            let dictionary = $0 as! Dictionary<String, Any>
            stringArray.append(dictionary.convertToJSON())
        }
        
        let dup = stringArray.joined(separator: "-")
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
    
    var dateComponents : DateComponents
    {
        let date : Date = Formatter.iso8601.date( from : self )!
        return date.dateComponents
    }
    
    var millisecondsSince1970 : Double
    {
        let date : Date = Formatter.iso8601.date( from : self )!
        return date.millisecondsSince1970
    }
	
    func convertToDictionary() -> [String: String]? {
        let data = self.data(using: .utf8)
        let anyResult = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
        return anyResult as? [String: String]
    }
    
    func StringArrayToArrayOfDictionary () -> Array< Dictionary < String, Any > >
    {
        var arrayOfDic : Array< Dictionary < String, Any > > = []
        let array : [String] = self.components(separatedBy: "-")
        array.forEach {
            let json = $0
            let val = json.convertToDictionary()
            if(val != nil)
            {
                arrayOfDic.append(val!)
            }
        }
        
        return arrayOfDic
    }
    
    func toNSArray() throws -> NSArray
    {
        var nsarray = NSArray()
        if(self.isEmpty == true)
        {
            return nsarray
        }
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                nsarray = try JSONSerialization.jsonObject(with: data, options: []) as! NSArray
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
        
        let components = calender.dateComponents( [ Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.quarter, Calendar.Component.timeZone, Calendar.Component.weekOfMonth, Calendar.Component.weekOfYear, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second ], from : self )
        
        var dateComponents = DateComponents()
        
        dateComponents.day = components.day!
        dateComponents.month = components.month!
        dateComponents.year = components.year!
        dateComponents.timeZone = components.timeZone!
        dateComponents.weekOfMonth = components.weekOfMonth!
        dateComponents.quarter = components.quarter!
        dateComponents.weekOfYear = components.weekOfYear!
        dateComponents.hour = components.hour!
        dateComponents.minute = components.minute!
        dateComponents.second = components.second!
        
        return dateComponents
    }
}

internal extension Optional where Wrapped == String 
{
	var notNilandEmpty : Bool
	{
		if(self != nil && !(self?.isEmpty)!)
		{
			return true
		}
		
		return false ;
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
        print("Exception while moving file - \(err)")
    }
}

public func fileDetailCheck( filePath : String ) throws
{
    if ( FileManager.default.fileExists( atPath : filePath )  == false )
    {
        throw ZCRMError.InValidError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "File not found at given path : \( filePath )" )
    }
    if ( getFileSize( filePath : filePath ) > 2097152 )
    {
        throw ZCRMError.FileSizeExceeded( code : ErrorCode.FILE_SIZE_EXCEEDED, message : "Cannot upload. File size should not exceed to 20MB" )
    }
}

internal func getFileSize( filePath : String ) -> Int64
{
    do
    {
        let fileAttributes = try FileManager.default.attributesOfItem( atPath : filePath )
        if let fileSize = fileAttributes[ FileAttributeKey.size ]
        {
            return ( fileSize as! NSNumber ).int64Value
        }
        else
        {
            print( "Failed to get a size attribute from path : \( filePath )" )
        }
    }
    catch
    {
        print( "Failed to get file attributes for local path: \( filePath ) with error: \( error )" )
    }
    return 0
}

internal struct APIConstants
{
    static let BOUNDARY = String( format : "unique-consistent-string-%@", UUID.init().uuidString )
    static let LEADS : String = "Leads"
    static let ACCOUNTS : String = "Accounts"
    static let CONTACTS : String = "Contacts"
    static let DEALS : String = "Deals"
    static let QUOTES : String = "Quotes"
    static let SALESORDERS : String = "SalesOrders"
    static let INVOICES : String = "Invoices"
    static let PURCHASEORDERS : String = "PurchaseOrders"
    
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
    
    static let STRING_MOCK : String = "SDK_NIL"
    static let INT_MOCK : Int = -555
    static let INT64_MOCK : Int64 = -555
    static let DOUBLE_MOCK : Double = -55.5555555555555555
    static let BOOL_MOCK : Bool = false
    
    static let MAX_ALLOWED_FILE_SIZE_IN_MB : Int = 20
}

var APPTYPE : String = "ZCRM"
var APIBASEURL : String = String()
var ACCOUNTSURL : String = String()
var APIVERSION : String = String()
var COUNTRYDOMAIN : String = "com"

struct JSONRootKey {
    static let DATA : String = "data"
    static let NILL : String = "NoRootKey" // used by FileAPIResponse
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
    static let ORG_EMAILS : String = "org_emails"
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
                print("????????????????\(response.toString())")
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
} // struct ends ..

func typeCastToZCRMError(_ error:Error) -> ZCRMError {
    guard let typecastedError = error as? ZCRMError else {
        return ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: error.description)
    }
    return typecastedError
}

func getUserDelegate( userJSON : [ String : Any ] ) -> ZCRMUserDelegate
{
    let user : ZCRMUserDelegate = ZCRMUserDelegate( id : userJSON.getInt64( key : "id" ), name : userJSON.getString( key : "name" ) )
    return user
}

func setUserDelegate( userObj : ZCRMUserDelegate ) -> [ String : Any ]
{
    var userJSON : [String:Any] = [String:Any]()
    userJSON[ "id" ] = userObj.id
    userJSON[ "name" ] = userObj.name
    return userJSON
}

func idMockValueCheck( id : Int64 ) throws
{
    if id == APIConstants.INT64_MOCK
    {
        throw ZCRMError.InValidError( code : ErrorCode.INVALID_DATA, message : ErrorMessage.INVALID_ID_MSG )
    }
}

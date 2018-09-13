//
//  CommonUtil.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

import Foundation

let PhotoSupportedModules = ["Leads", "Contacts"]

public enum ZCRMSDKError : Error
{
    case UnAuthenticatedError(String)
    case InValidError(String)
    case ProcessingError(String)
    case MaxRecordCountExceeded(String)
    case FileSizeExceeded(String)
    case InternalError( String )
    case ConnectionError( String )
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

extension Error
{
    var code : Int
    {
        return ( self as NSError ).code
    }
    
    var description : String
    {
        return ( self as NSError ).localizedDescription
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

public func photoSupportedModuleCheck( moduleAPIName : String ) throws
{
    if ( !PhotoSupportedModules.contains( moduleAPIName ) )
    {
        throw ZCRMSDKError.InValidError( "Photo not supported for this module." )
    }
}

public func fileDetailCheck( filePath : String ) throws
{
    if ( FileManager.default.fileExists( atPath : filePath )  == false )
    {
        throw ZCRMSDKError.InValidError( "File not found at given path : \( filePath )" )
    }
    if ( getFileSize( filePath : filePath ) > 2097152 )
    {
        throw ZCRMSDKError.FileSizeExceeded( "Cannot upload. File size should not exceed to 20MB" )
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

var APPTYPE : String = "ZCRM"
var APIBASEURL : String = String()
var APIVERSION : String = String()
var COUNTRYDOMAIN : String = "com"
let PHOTOURL : URL = URL( string : "https://profile.zoho.com/api/v1/user/self/photo" )!

let BOUNDARY = String( format : "unique-consistent-string-%@", UUID.init().uuidString )
let LEADS : String = "Leads"
let ACCOUNTS : String = "Accounts"
let CONTACTS : String = "Contacts"
let DEALS : String = "Deals"
let QUOTES : String = "Quotes"
let SALESORDERS : String = "SalesOrders"
let INVOICES : String = "Invoices"
let PURCHASEORDERS : String = "PurchaseOrders"

let INVALID_ID_MSG : String = "The given id seems to be invalid."
let INVALID_DATA : String = "INVALID_DATA"
let API_MAX_RECORDS_MSG : String = "Cannot process more than 100 records at a time."

let ACTION : String = "action"
let DUPLICATE_FIELD : String = "duplicate_field"

let MESSAGE : String = "message"
let DATA : String = "data"
let STATUS : String = "status"
let CODE : String = "code"
let CODE_ERROR : String = "error"
let CODE_SUCCESS : String = "success"
let INFO : String = "info"
let DETAILS : String = "details"

let PER_PAGE : String = "per_page"
let PAGE : String = "page"
let COUNT : String = "count"
let MORE_RECORDS : String = "more_records"

let REMAINING_COUNT_FOR_THIS_DAY : String = "X-RATELIMIT-LIMIT"
let REMAINING_COUNT_FOR_THIS_WINDOW : String = "X-RATELIMIT-REMAINING"
let REMAINING_TIME_FOR_THIS_WINDOW_RESET : String = "X-RATELIMIT-RESET"


//
//  ZCRMSubformRecord.swift
//  Pods
//
//  Created by Sarath Kumar Rajendran on 26/04/18.
//
import ZCacheiOS

public class ZCRMSubformRecord : ZCRMEntity, ZCacheRecord
{
    enum CodingKeys: String, CodingKey
    {
        case id
        case name
        case moduleName
        case owner
        case modifiedTime
        case createdTime
        case createdBy
        case modifiedBy
        case data
        case properties
    }
    
    private struct CustomCodingKeys: CodingKey
    {
        var stringValue: String
        init?(stringValue: String)
        {
            self.stringValue = stringValue
        }
        var intValue: Int?
        init?(intValue: Int)
        {
            return nil
        }
    }
    
    required public init(from decoder: Decoder) throws
    {
        let values = try! decoder.container(keyedBy: CodingKeys.self)

        id = try! values.decode(String.self, forKey: .id)
        name = try! values.decode(String.self, forKey: .name)
        moduleName = try! values.decode(String.self, forKey: .moduleName)
    
        let dynamicValues = try! decoder.container(keyedBy: CustomCodingKeys.self)
        for key in dynamicValues.allKeys
        {
            if let customKey = key.intValue
            {
                data[String(customKey)] = try! dynamicValues.decode(JSONValue.self, forKey: key)
            }
            else
            {
                data[key.stringValue] = try! dynamicValues.decode(JSONValue.self, forKey: key)
            }
        }
        
//        properties = try! values.decode(Bool.self, forKey: .properties)

    }
    open func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        
        try container.encode( self.id, forKey : .id )
        try container.encode( self.name, forKey : .name )
        try container.encode( self.moduleName, forKey : .moduleName )
        try container.encodeIfPresent( self.owner, forKey : .owner )
        try container.encodeIfPresent( self.modifiedTime, forKey : .modifiedTime )
        try container.encodeIfPresent( self.createdTime, forKey : .createdTime )
        try container.encodeIfPresent( self.createdBy, forKey : .createdBy )
        try container.encodeIfPresent( self.modifiedBy, forKey : .modifiedBy )
        
        var customContainer = encoder.container(keyedBy: CustomCodingKeys.self)
        for (key, value) in data
        {
            if let customKey = CustomCodingKeys(stringValue: key)
            {
                try customContainer.encodeIfPresent( value, forKey : customKey )
            }
        }
        for (key, value) in properties
        {
            if let customKey = CustomCodingKeys(stringValue: key)
            {
                try customContainer.encodeIfPresent( value, forKey : customKey )
            }
        }
    }
    
    public var id : String = APIConstants.STRING_MOCK
    var name : String
    public var moduleName: String
    public var layoutId: String?
    public var owner : ZCRMUserDelegate?
    public internal( set ) var modifiedTime : String?
    public internal( set ) var createdTime : String?
    public internal( set ) var createdBy : ZCRMUserDelegate?
    public internal( set ) var modifiedBy : ZCRMUserDelegate?
    public private( set ) var data : [ String : JSONValue? ] = [ String : JSONValue? ]()
    public private( set ) var properties : [ String : JSONValue? ] = [ String : JSONValue? ]()
    public var offlineOwner: ZCacheUser?
    public var offlineCreatedTime: String?
    public var offlineCreatedBy: ZCacheUser?
    public var offlineModifiedTime: String?
    public var offlineModifiedBy: ZCacheUser?
    
    internal init( name : String , id : String )
    {
        self.name = name
        self.moduleName = name
        self.id = id
    }
    
    internal init( name : String )
    {
        self.name = name
        self.moduleName = name
    }
    
    public func setValue( ofFieldAPIName : String, value : Any? )
    {
        self.data.updateValue( JSONValue(value: value), forKey : ofFieldAPIName )
    }
    
    internal func setValue( ofProperty : String, value : Any? )
    {
        self.properties.updateValue( JSONValue(value: value), forKey : ofProperty )
    }
    
    public func getValue( ofFieldAPIName : String ) throws -> Any?
    {
        if self.data.hasKey( forKey : ofFieldAPIName )
        {
            return self.data.optValue( key : ofFieldAPIName )
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.fieldNotFound) : The given field is not present in the record. Field Name -> \( ofFieldAPIName ), \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.fieldNotFound, message : "The given field is not present in the record. Field Name -> \( ofFieldAPIName )", details : nil )
        }
    }
    
    public func getValue( ofProperty : String ) -> Any?
    {
        return self.properties.optValue( key : ofProperty )
    }
    
    public func create<T>(completion: @escaping (DataResponseCallback<ZCacheResponse, T>) -> Void)
    {
        
    }
    
    public func update<T>(completion: @escaping (DataResponseCallback<ZCacheResponse, T>) -> Void)
    {
        
    }
    
    public func delete(completion: @escaping (DataResponseCallback<ZCacheResponse, String>) -> Void)
    {
        
    }
    
    public func reset<T>(completion: @escaping (DataResponseCallback<ZCacheResponse, T>) -> Void)
    {
        
    }
}

extension ZCRMSubformRecord : NSCopying, Hashable
{
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy : ZCRMSubformRecord = ZCRMSubformRecord( name : self.name )
        copy.id = self.id
        copy.owner = self.owner
        copy.modifiedBy = self.modifiedBy
        copy.modifiedTime = self.modifiedTime
        copy.createdBy = self.createdBy
        copy.createdTime = self.createdTime
        copy.data = self.data
        copy.properties = self.properties
        return copy
    }
    
    public static func == (lhs: ZCRMSubformRecord, rhs: ZCRMSubformRecord) -> Bool {
        if lhs.data.count == rhs.data.count {
            for ( key, value ) in lhs.data
            {
                if rhs.data.hasKey( forKey : key )
                {
                    if !isEqual( lhs : value, rhs : rhs.data[ key ] as Any? )
                    {
                        return false
                    }
                }
                else
                {
                    return false
                }
            }
        }
        else
        {
            return false
        }
        if lhs.properties.count == rhs.properties.count {
            for ( key, value ) in lhs.properties
            {
                if rhs.properties.hasKey( forKey : key )
                {
                    if !isEqual( lhs : value, rhs : rhs.properties[ key ] as Any? )
                    {
                        return false
                    }
                }
                else
                {
                    return false
                }
            }
        }
        else
        {
            return false
        }
        let equals : Bool = lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.owner == rhs.owner &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.createdTime == rhs.createdTime &&
            lhs.createdBy == rhs.createdBy &&
            lhs.modifiedBy == rhs.modifiedBy
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

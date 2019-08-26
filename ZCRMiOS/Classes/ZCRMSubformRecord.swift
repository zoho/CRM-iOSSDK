//
//  ZCRMSubformRecord.swift
//  Pods
//
//  Created by Sarath Kumar Rajendran on 26/04/18.
//

public class ZCRMSubformRecord : ZCRMEntity
{
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    var name : String
    public var owner : ZCRMUserDelegate?
    public internal( set ) var modifiedTime : String?
    public internal( set ) var createdTime : String?
    public internal( set ) var createdBy : ZCRMUserDelegate?
    public internal( set ) var modifiedBy : ZCRMUserDelegate?
    public private( set ) var data : [ String : Any? ] = [ String : Any? ]()
    public private( set ) var properties : [ String : Any? ] = [ String : Any? ]()
	
	internal init( name : String , id : Int64 )
	{
		self.name = name
		self.id = id
	}
	
    internal init( name : String )
    {
		self.name = name
	}
	
    @available(*, deprecated, message: "Use the property directly" )
	public func getID() -> Int64?
	{
		return self.id
	}
	
    @available(*, deprecated, message: "Use the method 'setValue' with param 'ofFieldAPIName'" )
	public func setValue(forField : String, value : Any?)
	{
        self.data.updateValue( value, forKey : forField )
	}
    
    public func setValue( ofFieldAPIName : String, value : Any? )
    {
        self.data.updateValue( value, forKey : ofFieldAPIName )
    }
    
    internal func setValue( ofProperty : String, value : Any? )
    {
        self.properties.updateValue( value, forKey : ofProperty )
    }
    
    @available(*, deprecated, message: "Use the method 'setValue' with param 'ofProperty'" )
    public func setProperty(name : String, value : Any?)
    {
        self.properties.updateValue( value, forKey : name )
    }
    
	public func getValue( ofFieldAPIName : String ) throws -> Any?
	{
		if self.data.hasKey( forKey : ofFieldAPIName )
		{
			return self.data.optValue( key : ofFieldAPIName )
		}
		else
		{
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.FIELD_NOT_FOUND) : The given field is not present in the record. Field Name -> \( ofFieldAPIName )")
            throw ZCRMError.ProcessingError( code : ErrorCode.FIELD_NOT_FOUND, message : "The given field is not present in the record. Field Name -> \( ofFieldAPIName )", details : nil )
		}
	}
    
    public func getValue( ofProperty : String ) -> Any?
    {
        return self.properties.optValue( key : ofProperty )
    }
    
    @available(*, deprecated, message: "Use the property directly" )
    public func getData() -> [ String : Any? ]
    {
        return self.data
    }
}

extension ZCRMSubformRecord : Equatable
{
    public static func == (lhs: ZCRMSubformRecord, rhs: ZCRMSubformRecord) -> Bool {
        var isDataEqual : Bool = false
        for ( key, value ) in lhs.data
        {
            if rhs.data.hasKey( forKey : key )
            {
                if isEqual( lhs : value, rhs : rhs.data[ key ] as Any? )
                {
                    isDataEqual = true
                }
                else
                {
                    return false
                }
            }
            else
            {
                return false
            }
        }
        var isPropertiesEqual : Bool = false
        for ( key, value ) in lhs.properties
        {
            if rhs.properties.hasKey( forKey : key )
            {
                if isEqual( lhs : value, rhs : rhs.properties[ key ] as Any? )
                {
                    isPropertiesEqual = true
                }
                else
                {
                    return false
                }
            }
            else
            {
                return false
            }
        }
        let equals : Bool = lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.owner == rhs.owner &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.createdTime == rhs.createdTime &&
            lhs.createdBy == rhs.createdBy &&
            lhs.modifiedBy == rhs.modifiedBy &&
            isDataEqual &&
            isPropertiesEqual
        return equals
    }
}

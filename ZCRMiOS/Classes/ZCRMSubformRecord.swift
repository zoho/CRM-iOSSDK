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
    
    public func setValue( ofFieldAPIName : String, value : Any? )
    {
        self.data.updateValue( value, forKey : ofFieldAPIName )
    }
    
    internal func setValue( ofProperty : String, value : Any? )
    {
        self.properties.updateValue( value, forKey : ofProperty )
    }
    
	public func getValue( ofFieldAPIName : String ) throws -> Any?
	{
		if self.data.hasKey( forKey : ofFieldAPIName )
		{
			return self.data.optValue( key : ofFieldAPIName )
		}
		else
		{
            ZCRMLogger.logError(message: "\(ErrorCode.fieldNotFound) : The given field is not present in the record. Field Name -> \( ofFieldAPIName ), \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.fieldNotFound, message : "The given field is not present in the record. Field Name -> \( ofFieldAPIName )", details : nil )
		}
	}
    
    public func getValue( ofProperty : String ) -> Any?
    {
        return self.properties.optValue( key : ofProperty )
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

//
//  ZCRMSubformRecord.swift
//  Pods
//
//  Created by Sarath Kumar Rajendran on 26/04/18.
//

public class ZCRMSubformRecord : ZCRMEntity
{
	public var id : Int64
	var apiName : String
	public var owner : ZCRMUserDelegate = USER_MOCK
	public var modifiedTime : String = APIConstants.STRING_MOCK
	public var createdTime : String = APIConstants.STRING_MOCK
    var layout : ZCRMLayout?
	public var fieldNameVsValue : [String:Any] = [String:Any]()
	
	internal init( apiName : String , id : Int64 )
	{
		self.apiName = apiName
		self.id = id
	}
	
    internal init( apiName : String )
    {
		self.apiName = apiName
        self.id = APIConstants.INT64_MOCK
	}
	
	public func getID() -> Int64?
	{
		return self.id
	}
	
	public func setValue(forField : String, value : Any?)
	{
		if forField.isEmpty == false
		{
			self.fieldNameVsValue[forField] = value
		}
	}

	public func getValue(ofField : String) throws -> Any?
	{
		if self.fieldNameVsValue.hasKey( forKey : ofField )
		{
			return self.fieldNameVsValue.optValue(key: ofField )
		}
		else
		{
			throw ZCRMError.ProcessingError( code : ErrorCode.FIELD_NOT_FOUND, message : "The given field is not present in the record.")
		}
	}
    
    public func getData() -> [String:Any]
    {
        return self.fieldNameVsValue
    }
	
}

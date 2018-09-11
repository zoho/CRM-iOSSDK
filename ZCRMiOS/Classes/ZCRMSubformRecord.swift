//
//  ZCRMSubformRecord.swift
//  Pods
//
//  Created by Sarath Kumar Rajendran on 26/04/18.
//

public class ZCRMSubformRecord : ZCRMEntity
{
	private var id : Int64?
	private var apiName : String?
	private var owner : ZCRMUser?
	private var modifiedTime : String?
	private var createdTime : String?
	private var fieldNameVsValue : [String:Any?] = [String:Any?]()
	
	init( apiName : String , id : Int64 )
	{
		self.apiName = apiName
		self.id = id
	}
	
	init(){
		
	}
	
	public func getID() -> Int64?
	{
		return self.id
	}
	
	internal func setOwner( owner : ZCRMUser )
	{
		self.owner = owner
	}
	
	public func getOwner() -> ZCRMUser?
	{
		return self.owner
	}
	
	internal func setModifiedTime( modifiedTime : String )
	{
		self.modifiedTime = modifiedTime
	}
	
	public func getModifiedTime() -> String?
	{
		return self.modifiedTime
	}
	
	internal func setCreatedTime( createdTime : String )
	{
		self.createdTime = createdTime
	}
	
	public func getCreatedTime() -> String?
	{
		return self.createdTime
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
			throw ZCRMSDKError.ProcessingError("The given field is not present in the record.")
		}
	}
	
	internal func getAllValues() -> [ String : Any? ]
	{
		return self.fieldNameVsValue
	}
	
}

//
//  ZCRMProfile.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMProfile : ZCRMEntity
{
	private var id : Int64
	private var name : String
	private var isDefault : Bool?
    private var category : Bool?
    private var description : String?
    private var modifiedBy : ZCRMUser?
    private var createdBy : ZCRMUser?
    private var modifiedTime : String?
    private var createdTime : String?
	
	init(profileId : Int64, profileName : String)
	{
		self.id = profileId
		self.name = profileName
	}
	
	public func getId() -> Int64
	{
		return self.id
	}
	
	public func getName() -> String
	{
		return self.name
	}
	
	internal func setIsDefault(isDefault : Bool?)
	{
		self.isDefault = isDefault
	}
	
	public func isDefaultProfile() -> Bool?
	{
		return self.isDefault
	}
    
    public func getCategory() -> Bool?
    {
        return self.category
    }
    
    internal func setCategory( category : Bool? )
    {
        self.category = category
    }
    
    public func getDescription() -> String?
    {
        return self.description
    }
    
    internal func setDescription( description : String? )
    {
        self.description = description
    }
    
    public func getModifiedBy() -> ZCRMUser?
    {
        return self.modifiedBy
    }
    
    internal func setModifiedBy( modifiedBy : ZCRMUser? )
    {
        self.modifiedBy = modifiedBy
    }
    
    public func getCreatedBy() -> ZCRMUser?
    {
        return self.createdBy
    }
    
    internal func setCreatedBy( createdBy : ZCRMUser? )
    {
        self.createdBy = createdBy
    }
    
    public func getModifiedTime() -> String?
    {
        return self.modifiedTime
    }
    
    internal func setModifiedTime( modifiedTime : String? )
    {
        self.modifiedTime = modifiedTime
    }
    
    public func getCreatedTime() -> String?
    {
        return self.createdTime
    }
    
    internal func setCreatedTime( createdTime : String? )
    {
        self.createdTime = createdTime
    }
}

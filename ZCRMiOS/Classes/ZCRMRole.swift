//
//  ZCRMRole.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMRole : ZCRMEntity
{
	private var id : Int64
	private var name : String
	private var reportingTo : ZCRMRole?
    private var isAdminUser : Bool?
    private var label : String?
	
    init(roleId : Int64, roleName : String)
	{
		self.id = roleId
		self.name = roleName
	}
	
	public func getId() -> Int64
	{
		return self.id
	}
	
	public func getName() -> String
	{
		return self.name
	}
	
	internal func setReportingTo(reportingTo : ZCRMRole?)
	{
		self.reportingTo = reportingTo
	}
	
	public func getReportingTo() -> ZCRMRole?
	{
		return self.reportingTo
	}
    
    public func getLabel() -> String?
    {
        return self.label
    }
    
    internal func setLabel( label : String? )
    {
        self.label = label
    }
    
    public func checkAdmin() -> Bool?
    {
        return self.isAdminUser
    }
    
    internal func setAdminUser( isAdminUser : Bool? )
    {
        self.isAdminUser = isAdminUser
    }
}

//
//  ZCRMRole.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMRole : ZCRMRoleDelegate
{
    public var reportingTo : ZCRMRoleDelegate = ROLE_MOCK
    public var isAdminUser : Bool = APIConstants.BOOL_MOCK
    public var label : String = APIConstants.STRING_MOCK
	
    internal init( name : String)
	{
        super.init( roleId : APIConstants.INT64_MOCK, roleName : name )
	}
}

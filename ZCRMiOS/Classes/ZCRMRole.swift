//
//  ZCRMRole.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMRole : ZCRMRoleDelegate
{
    var name : String
    var reportingTo : ZCRMRoleDelegate = ROLE_MOCK
    public var isAdminUser : Bool = APIConstants.BOOL_MOCK
    public var label : String = APIConstants.STRING_MOCK
	
    init( name : String)
	{
        self.name = name
        super.init( roleId : APIConstants.INT64_MOCK, roleName : self.name )
	}
}

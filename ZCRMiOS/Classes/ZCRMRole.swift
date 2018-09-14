//
//  ZCRMRole.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMRole : ZCRMRoleDelegate
{
    var reportingTo : ZCRMRoleDelegate?
    var isAdminUser : Bool?
    var label : String?
	
    init(roleName : String)
	{
        super.init(roleId: INT64_NIL, roleName: roleName)
	}
}

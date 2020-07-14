//
//  ZCRMRole.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMRole : ZCRMRoleDelegate
{
    public internal( set ) var reportingTo : ZCRMRoleDelegate = ROLE_MOCK
    public internal( set ) var isAdminUser : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var label : String = APIConstants.STRING_MOCK
    
    internal init( name : String)
    {
        super.init( id : APIConstants.INT64_MOCK, name : name )
    }
}

extension ZCRMRole
{
    public static func == (lhs: ZCRMRole, rhs: ZCRMRole) -> Bool {
        let equals : Bool = lhs.reportingTo == rhs.reportingTo &&
            lhs.isAdminUser == rhs.isAdminUser &&
            lhs.label == rhs.label &&
            lhs.name == rhs.name &&
            lhs.id == rhs.id
        return equals
    }
}

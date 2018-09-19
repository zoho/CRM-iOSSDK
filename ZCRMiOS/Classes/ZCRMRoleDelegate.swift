//
//  ZCRMRoleDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 13/09/18.
//
open class ZCRMRoleDelegate : ZCRMEntity
{
    public var roleId : Int64
    public var roleName : String
    
    internal init( roleId : Int64, roleName : String )
    {
        self.roleId = roleId
        self.roleName = roleName
    }
}

let ROLE_MOCK = ZCRMRoleDelegate( roleId : APIConstants.INT64_MOCK, roleName : APIConstants.STRING_MOCK )

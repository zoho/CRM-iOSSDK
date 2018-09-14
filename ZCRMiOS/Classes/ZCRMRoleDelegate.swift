//
//  ZCRMRoleDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 13/09/18.
//
open class ZCRMRoleDelegate : ZCRMEntity
{
    var roleId : Int64
    var roleName : String
    
    init( roleId : Int64, roleName : String )
    {
        self.roleId = roleId
        self.roleName = roleName
    }
}
var ROLE_NIL = ZCRMRoleDelegate(roleId: INT64_NIL, roleName: STRING_NIL)

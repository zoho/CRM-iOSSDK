//
//  ZCRMRoleDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 13/09/18.
//
open class ZCRMRoleDelegate : ZCRMEntity
{
    public internal( set ) var id : Int64
    public internal( set ) var name : String
    
    internal init( id : Int64, name : String )
    {
        self.id = id
        self.name = name
    }
}

extension ZCRMRoleDelegate : Hashable
{
    public static func == (lhs: ZCRMRoleDelegate, rhs: ZCRMRoleDelegate) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.name == rhs.name
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

let ROLE_MOCK = ZCRMRoleDelegate( id : APIConstants.INT64_MOCK, name : APIConstants.STRING_MOCK )

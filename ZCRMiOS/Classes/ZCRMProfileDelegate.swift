//
//  ZCRMProfileDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 13/09/18.
//

open class ZCRMProfileDelegate : ZCRMEntity
{
    public internal( set ) var id : Int64
    public internal( set ) var name : String
    public internal( set ) var isDefault : Bool = APIConstants.BOOL_MOCK
    
    internal init( id : Int64, name : String, isDefault : Bool )
    {
        self.id = id
        self.name = name
        self.isDefault = isDefault
    }
    
    internal init( id : Int64, name : String )
    {
        self.id = id
        self.name = name
    }
}

extension ZCRMProfileDelegate : Hashable
{
    public static func == (lhs: ZCRMProfileDelegate, rhs: ZCRMProfileDelegate) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.isDefault == rhs.isDefault
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

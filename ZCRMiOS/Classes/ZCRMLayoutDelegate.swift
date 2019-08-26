//
//  ZCRMLayoutDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 13/09/18.
//

open class ZCRMLayoutDelegate : ZCRMEntity
{
    public internal( set ) var id : Int64
    public internal( set ) var name : String
    
    internal init( id : Int64, name : String )
    {
        self.id = id
        self.name = name
    }
}

extension ZCRMLayoutDelegate : Equatable
{
    public static func == (lhs: ZCRMLayoutDelegate, rhs: ZCRMLayoutDelegate) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.name == rhs.name
        return equals
    }
}

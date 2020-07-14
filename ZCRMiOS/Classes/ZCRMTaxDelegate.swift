//
//  ZCRMTaxDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 24/06/19.
//

open class ZCRMTaxDelegate : ZCRMEntity
{
    public var name : String
    
    init( name : String ) {
        self.name = name
    }
}

extension ZCRMTaxDelegate : Equatable
{
    public static func == (lhs: ZCRMTaxDelegate, rhs: ZCRMTaxDelegate) -> Bool {
        let equals : Bool = lhs.name == rhs.name
        return equals
    }
}

//
//  ZCRMTaxDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 24/06/19.
//

open class ZCRMTaxDelegate : ZCRMEntity
{
    public internal( set ) var id : Int64?
    public var displayName : String = APIConstants.STRING_MOCK
    
    init( displayName : String ) {
        self.displayName = displayName
    }
}

extension ZCRMTaxDelegate : Equatable
{
    public static func == (lhs: ZCRMTaxDelegate, rhs: ZCRMTaxDelegate) -> Bool {
        let equals : Bool = lhs.displayName == rhs.displayName &&
            lhs.id == rhs.id
        return equals
    }
}

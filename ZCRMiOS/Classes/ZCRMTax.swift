//
//  ZCRMTax.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 10/05/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

open class ZCRMTax : ZCRMTaxDelegate
{
    public var name : String = APIConstants.STRING_MOCK
    public var percentage : Double = APIConstants.DOUBLE_MOCK
    internal var isCreate : Bool = APIConstants.BOOL_MOCK
    
    internal init( id : Int64)
    {
        super.init(displayName: APIConstants.STRING_MOCK)
        self.id = id
    }
    
    init( name : String, percentage : Double )
    {
        self.name = name
        self.percentage = percentage
        self.isCreate = true
        super.init( displayName : "\( name ) - \( percentage ) %" )
    }
}

extension ZCRMTax : Hashable
{
    public static func == (lhs: ZCRMTax, rhs: ZCRMTax) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.percentage == rhs.percentage &&
            lhs.displayName == rhs.displayName
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

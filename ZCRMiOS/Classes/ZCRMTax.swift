//
//  ZCRMTax.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 10/05/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

open class ZCRMTax : ZCRMTaxDelegate
{
    public internal( set ) var id : Int64
    public var displayName : String = APIConstants.STRING_MOCK
    public var percentage : Double = APIConstants.DOUBLE_MOCK
    internal var isCreate : Bool = APIConstants.BOOL_MOCK
    
    internal init( id : Int64)
    {
        self.id = id
        super.init(name: APIConstants.STRING_MOCK)
    }
    
    init( id : Int64, name : String )
    {
        self.id = id
        super.init( name : name )
    }
    
    init( name : String, percentage : Double )
    {
        self.id = APIConstants.INT64_MOCK
        self.percentage = percentage
        self.isCreate = true
        super.init( name : name )
    }
    
    public func delete( _ completion : @escaping ( Result.Response< APIResponse > ) -> Void )
    {
        TaxAPIHandler().deleteTax( withId : self.id ) { result in
            completion( result )
        }
    }
}

extension ZCRMTax
{
    public static func == (lhs: ZCRMTax, rhs: ZCRMTax) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.percentage == rhs.percentage &&
            lhs.displayName == rhs.displayName
        return equals
    }
}

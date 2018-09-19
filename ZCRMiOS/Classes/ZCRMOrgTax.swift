//
//  ZCRMOrgTax.swift
//  ZCRMiOS
//
//  Created by Umashri R on 06/09/18.
//

import Foundation

open class ZCRMOrgTax : ZCRMEntity
{
    public var id : Int64
    public var name : String
    public var displayLabel : String = APIConstants.STRING_MOCK
    public var value : Double = APIConstants.DOUBLE_MOCK
    public var sequenceNumber : Int = APIConstants.INT_MOCK
    
    internal init( id : Int64, taxName : String )
    {
        self.id = id
        self.name = taxName
    }
    
    public init( name : String )
    {
        self.id = APIConstants.INT64_MOCK
        self.name = name
    }
    
}

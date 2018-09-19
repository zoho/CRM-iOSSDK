//
//  ZCRMOrgTax.swift
//  ZCRMiOS
//
//  Created by Umashri R on 06/09/18.
//

import Foundation

open class ZCRMOrgTax : ZCRMEntity
{
    private var id : Int64
    private var name : String
    private var displayLabel : String = APIConstants.STRING_MOCK
    private var value : Double = APIConstants.DOUBLE_MOCK
    private var sequenceNumber : Int = APIConstants.INT_MOCK
    
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

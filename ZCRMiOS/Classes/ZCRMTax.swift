//
//  ZCRMTax.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 10/05/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

open class ZCRMTax : ZCRMEntity
{
    public var taxName : String
    public var percentage : Double
    public var value : Double
    
    init( taxName : String, percentage : Double, value : Double )
    {
        self.percentage = percentage
        self.value = value
        self.taxName = taxName
    }
    
    init( taxName : String )
    {
        self.taxName = taxName
        self.percentage = APIConstants.DOUBLE_MOCK
        self.value = APIConstants.DOUBLE_MOCK
    }
}


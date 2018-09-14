//
//  ZCRMTax.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 10/05/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

open class ZCRMTax : ZCRMTaxDelegate
{
    var percentage : Double
    var value : Double
    
    init( taxName : String, percentage : Double, value : Double )
    {
        super.init(taxName: taxName)
        self.percentage = percentage
        self.value = value
    }
}


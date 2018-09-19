//
//  ZCRMPickListValue.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 10/05/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

open class ZCRMPickListValue
{
    public var displayName : String
    public var actualName : String
    public var sequenceNumber : Int = APIConstants.INT_MOCK
    public var maps : Array< Dictionary < String, Any > > = Array< Dictionary < String, Any > >()
    
    internal init( displayName : String, actualName : String )
    {
        self.displayName = displayName
        self.actualName = actualName
    }
}


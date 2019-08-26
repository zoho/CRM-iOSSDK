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
    public internal( set ) var displayName : String
    public internal( set ) var actualName : String
    public internal( set ) var sequenceNumber : Int?
    public internal( set ) var maps : Array< Dictionary < String, Any > > = Array< Dictionary < String, Any > >()
    
    internal init( displayName : String, actualName : String )
    {
        self.displayName = displayName
        self.actualName = actualName
    }
}

extension ZCRMPickListValue : Equatable
{
    public static func == (lhs: ZCRMPickListValue, rhs: ZCRMPickListValue) -> Bool {
        var mapsFlag : Bool = false
        var count : Int = 0
        if lhs.maps.count == rhs.maps.count
        {
            for index in 0..<lhs.maps.count
            {
                if NSDictionary(dictionary: lhs.maps[index]).isEqual(to: rhs.maps[index])
                {
                    count = count + 1
                }
            }
            if count == lhs.maps.count
            {
                mapsFlag = true
            }
        }
        let equals : Bool = lhs.displayName == rhs.displayName &&
            lhs.actualName == rhs.actualName &&
            lhs.sequenceNumber == rhs.sequenceNumber &&
        mapsFlag
        return equals
    }
}


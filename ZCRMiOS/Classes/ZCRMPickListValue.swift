//
//  ZCRMPickListValue.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 10/05/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

open class ZCRMPickListValue : ZCRMEntity
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
    
    public func copy() -> ZCRMPickListValue {
        let picklistValue = ZCRMPickListValue(displayName: displayName, actualName: actualName)
        picklistValue.sequenceNumber = sequenceNumber
        picklistValue.maps = maps
        
        return picklistValue
    }
    
}

extension ZCRMPickListValue : Equatable
{
    public static func == (lhs: ZCRMPickListValue, rhs: ZCRMPickListValue) -> Bool {
        if lhs.maps.count == rhs.maps.count
        {
            for index in 0..<lhs.maps.count
            {
                if !NSDictionary(dictionary: lhs.maps[index]).isEqual(to: rhs.maps[index])
                {
                    return false
                }
            }
        }
        else
        {
            return false
        }
        let equals : Bool = lhs.displayName == rhs.displayName &&
            lhs.actualName == rhs.actualName &&
            lhs.sequenceNumber == rhs.sequenceNumber
        return equals
    }
}


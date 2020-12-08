//
//  ZCRMPickListValue.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 10/05/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

open class ZCRMPickListValue : ZCRMEntity, Codable
{
    public internal( set ) var displayName : String
    public internal( set ) var actualName : String
    public internal( set ) var sequenceNumber : Int?
    public internal( set ) var maps : Array< Dictionary < String, JSONValue > > = Array< Dictionary < String, JSONValue > >()
    
    internal init( displayName : String, actualName : String )
    {
        self.displayName = displayName
        self.actualName = actualName
    }
    enum CodingKeys: String, CodingKey
    {
        case displayName
        case actualName
        case sequenceNumber
        case maps
    }
    required public init(from decoder: Decoder) throws {
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        
        displayName = try! container.decode(String.self, forKey: .displayName)
        actualName = try! container.decode(String.self, forKey: .actualName)
        sequenceNumber = try! container.decodeIfPresent(Int.self, forKey: .sequenceNumber)
        maps = try! container.decode([[String:JSONValue]].self, forKey: .maps)
    }
    open func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        
        try! container.encode(self.displayName, forKey: .displayName)
        try! container.encode(self.actualName, forKey: .actualName)
        try! container.encodeIfPresent(self.sequenceNumber, forKey: .sequenceNumber)
        try! container.encode(self.maps, forKey: .maps)
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


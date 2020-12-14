//
//  ZCRMPriceBookPricing.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 10/05/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//


open class ZCRMPriceBookPricing : ZCRMEntity, Codable
{
    enum CodingKeys: String, CodingKey
    {
        case id
        case toRange
        case fromRange
        case discount
    }
    required public init(from decoder: Decoder) throws
    {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        
        id = try! values.decode(Int64.self, forKey: .id)
        toRange = try! values.decode(Double.self, forKey: .toRange)
        fromRange = try! values.decode(Double.self, forKey: .fromRange)
        discount = try! values.decode(Double.self, forKey: .discount)
    }
    open func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        
        try container.encode( self.id, forKey : CodingKeys.id )
        try container.encode( self.toRange, forKey : CodingKeys.toRange )
        try container.encode( self.fromRange, forKey : CodingKeys.fromRange )
        try container.encode( self.discount, forKey : CodingKeys.discount )
    }
    
    public internal( set ) var id : Int64
    public var toRange : Double = APIConstants.DOUBLE_MOCK
    public var fromRange : Double = APIConstants.DOUBLE_MOCK
    public var discount : Double = APIConstants.DOUBLE_MOCK
    
    /// Initialise the instance of the ZCRMPriceBookePricing.
    internal init( id : Int64 )
    {
        self.id = id
    }
    
    public init( toRange : Double, fromRange : Double, discount : Double )
    {
        self.toRange = toRange
        self.fromRange = fromRange
        self.discount = discount
        self.id = APIConstants.INT64_MOCK
    }
}

extension ZCRMPriceBookPricing : Hashable
{
    public static func == (lhs: ZCRMPriceBookPricing, rhs: ZCRMPriceBookPricing) -> Bool {
        let equals : Bool = lhs.id == rhs.id  &&
            lhs.toRange == rhs.toRange &&
            lhs.fromRange == rhs.fromRange &&
            lhs.discount == rhs.discount
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}


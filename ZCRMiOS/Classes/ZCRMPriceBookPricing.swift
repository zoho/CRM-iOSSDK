//
//  ZCRMPriceBookPricing.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 10/05/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//


open class ZCRMPriceBookPricing : ZCRMEntity
{
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
    
    func copy() -> ZCRMPriceBookPricing {
        let copyObj = ZCRMPriceBookPricing(id: id)
        copyObj.toRange = toRange
        copyObj.fromRange = fromRange
        copyObj.discount = discount
        return copyObj
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


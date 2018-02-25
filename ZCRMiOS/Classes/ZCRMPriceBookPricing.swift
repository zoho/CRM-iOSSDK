//
//  ZCRMPriceBookPricing.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 10/05/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class ZCRMPriceBookPricing
{
    private var id : Int64?
    private var toRange : Double?
    private var fromRange : Double?
    private var discount : Double?
    
    /// Initialise the instance of the ZCRMPriceBookePricing.
    public init(){}
    
    /// Set id of the ZCRMPriceBookPricing.
    ///
    /// - Parameter id: id of the ZCRMPriceBookPricing
    internal func setId( id : Int64 )
    {
        self.id = id
    }
    
    /// Returns id of the ZCRMPriceBookPricing.
    ///
    /// - Returns: id of the ZCRMPriceBookPricing
    public func getId() -> Int64?
    {
        return self.id
    }
    
    /// Set to range of ZCRMPriceBookPricing.
    ///
    /// - Parameter toRange: to range of the ZCRMPriceBookPricing
    internal func setToRange( toRange : Double? )
    {
        self.toRange = toRange
    }
    
    /// Returns the to range of ZCRMPriceBookPricing.
    ///
    /// - Returns: to range of ZCRMPriceBookPricing
    public func getToRange() -> Double?
    {
        return self.toRange
    }
    
    /// Set from range of ZCRMPriceBookPricing.
    ///
    /// - Parameter fromRange: from range of ZCRMPriceBookPricing
    internal func setFromRange( fromRange : Double? )
    {
        self.fromRange = fromRange
    }
    
    /// Returns the from range of ZCRMPriceBookPricing.
    ///
    /// - Returns: from range of ZCRMPriceBookPricing
    public func getFromRange() -> Double?
    {
        return self.fromRange
    }
    
    /// Set discount of the ZCRMPriceBookPricing.
    ///
    /// - Parameter discount: discount of the ZCRMPriceBookPricing
    internal func setDiscount( discount : Double? )
    {
        self.discount = discount
    }
    
    /// Returns the discount of the ZCRMPriceBookPricing.
    ///
    /// - Returns: discount of the ZCRMPriceBookPricing
    public func getDiscount() -> Double?
    {
        return self.discount
    }
}


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
    public func setId( id : Int64 )
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
    
    /// Set the range of ZCRMPriceBookPricing.
    ///
    /// - Parameters:
    ///   - From: lower limit of the Range
    ///   - To: upper limit of the Range
    public func setRange(From lowerLimit:Double,To upperLimit:Double)
    {
        self.fromRange = lowerLimit
        self.toRange = upperLimit
    }
    
    /// Returns the range of ZCRMPriceBookPricing.
    ///
    /// - Returns: Range of ZCRMPriceBookPricing
    public func getRange() -> [String:Double?]
    {
        return ["From":fromRange,"To":toRange]
    }
    
    /// Returns the from range of ZCRMPriceBookPricing.
    ///
    /// - Returns: from range of ZCRMPriceBookPricing
    public func getFromRange() -> Double?
    {
        return self.fromRange
    }
    
    /// Returns the to range of ZCRMPriceBookPricing.
    ///
    /// - Returns: to range of ZCRMPriceBookPricing
    public func getToRange() -> Double?
    {
        return self.toRange
    }
    
    
    /// Set discount of the ZCRMPriceBookPricing.
    ///
    /// - Parameter discount: discount of the ZCRMPriceBookPricing
    public func setDiscount( discount : Double)
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


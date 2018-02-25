//
//  ZCRMTax.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 10/05/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class ZCRMTax
{
    private var taxName : String
    private var percentage : Double?
    private var value : Double?
    
    /// Initialize the instance of a ZCRMTax with the given tax name.
    ///
    /// - Parameter taxName: tax name whose associated tax is to be initialized.
    public init( taxName : String )
    {
        self.taxName = taxName
    }
    
    /// Returns name of the ZCRMTax.
    ///
    /// - Returns: name of the ZCRMTax
    public func getTaxName() -> String
    {
        return self.taxName
    }
    
    /// Set the percentage of the ZCRMTax
    ///
    /// - Parameter percentage: percentage of the ZCRMTax
    public func setTaxPercentage( percentage : Double )
    {
        self.percentage = percentage
    }
    
    /// Returns the percentage of the ZCRMTax
    ///
    /// - Returns: percentage of the ZCRMTax
    public func getTaxPercentage() -> Double?
    {
        return self.percentage
    }
    
    /// Set the value of the ZCRMTax
    ///
    /// - Parameter taxValue: value of the ZCRMTax
    public func setTaxValue( taxValue : Double? )
    {
        self.value = taxValue
    }
    
    /// Returns the value of the ZCRMTax
    ///
    /// - Returns: value of the ZCRMTax
    public func getTaxValue() -> Double?
    {
        return self.value
    }
}


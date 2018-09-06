//
//  ZCRMOrgTax.swift
//  ZCRMiOS
//
//  Created by Umashri R on 06/09/18.
//

import Foundation

public class ZCRMOrgTax : ZCRMEntity
{
    private var id : Int64?
    private var name : String?
    private var displayLabel : String?
    private var value : Double?
    private var sequenceNumber : Int?
    
    public init( taxName : String, value : Double )
    {
        self.name = taxName
        self.value = value
    }
    
    public init( id : Int64, taxName : String )
    {
        self.id = id
        self.name = taxName
    }
    
    public init( id : Int64 )
    {
        self.id = id
    }
    
    public init()
    { }
    
    internal func setId( id : Int64? )
    {
        self.id = id
    }
    
    public func getId() -> Int64?
    {
        return self.id
    }
    
    internal func setName( name : String? )
    {
        self.name = name
    }
    
    public func getName() -> String?
    {
        return self.name
    }
    
    internal func setDisplayLabel( displayLabel : String?)
    {
        self.displayLabel = displayLabel
    }
    
    public func getDisplayLabel() -> String?
    {
        return self.displayLabel
    }
    
    internal func setValue( value : Double? )
    {
        self.value = value
    }
    
    public func getValue() -> Double?
    {
        return self.value
    }
    
    internal func setSequenceNumber( sequenceNumber : Int? )
    {
        self.sequenceNumber = sequenceNumber
    }
    
    public func getSequenceNumber() -> Int?
    {
        return self.sequenceNumber
    }
}

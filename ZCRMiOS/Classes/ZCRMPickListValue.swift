//
//  ZCRMPickListValue.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 10/05/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class ZCRMPickListValue
{
    private var displayName : String?
    private var actualName : String?
    private var sequenceNumber : Int?
    private var maps : Array< Dictionary < String, Any > >?
    
    /// Set the display name of the ZCRMPickListValue.
    ///
    /// - Parameter displayName: display name of the ZCRMPickListValue
    internal func setDisplayName( displayName : String? )
    {
        self.displayName = displayName
    }
    
    /// Returns the display name of the ZCRMPickListValue.
    ///
    /// - Returns: display name of the ZCRMPickListValue
    public func getDisplayName() -> String
    {
        return self.displayName!
    }
    
    /// Set the actual name of the ZCRMPickListValue.
    ///
    /// - Parameter actualName: actual name of the ZCRMPickListValue
    internal func setActualName( actualName : String? )
    {
        self.actualName = actualName
    }
    
    /// Returns the actual name of the ZCRMPickListValue.
    ///
    /// - Returns: actual name of the ZCRMPickListValue
    public func getActualName() -> String
    {
        return self.actualName!
    }
    
    /// Set the sequence number of the ZCRMPickListValue.
    ///
    /// - Parameter number: sequence number of the ZCRMPickListValue
    internal func setSequenceNumer( number : Int? )
    {
        self.sequenceNumber = number
    }
    
    /// Returns the sequence number of the ZCRMPickListValue.
    ///
    /// - Returns: sequence number of the ZCRMPickListValue
    public func getSequenceNumber() -> Int
    {
        return self.sequenceNumber!
    }
    
    /// Set dependancy maps of the ZCRMPickListValue.
    ///
    /// - Parameter maps: dependancy maps of the ZCRMPickListValue
    internal func setMaps( maps : Array< Dictionary < String, Any > >? )
    {
        self.maps = maps
    }
    
    /// Returns the dependancy maps of the ZCRMPickListValue.
    ///
    /// - Returns: dependancy maps of the ZCRMPickListValue
    public func getMaps() -> Array< Dictionary < String, Any > >   {
        return self.maps!
    }
}


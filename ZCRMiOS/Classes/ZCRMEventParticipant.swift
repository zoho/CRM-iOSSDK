//
//  ZCRMEventParticipant.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 20/06/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class ZCRMEventParticipant
{
    private var email : String?
    private var name : String?
    private var id : Int64
    private var type : String
    private var isInvited : Bool?
    private var status : String?
    
    /// Initialise the ZCRMEventParticipant
    ///
    /// - Parameters:
    ///   - type: type of the ZCRMEventParticipant is to be initialised
    ///   - id: id of the ZCRMEventParticipant is to be initialised
    public init( type : String, id : Int64 )
    {
        self.type = type
        self.id = id
    }
    
    
    /// returns the id of the ZCRMEventParticipant.
    ///
    /// - Returns: id of the ZCRMEventParticipant
    public func getId() -> Int64
    {
        return self.id
    }
    
    
    /// returns the type of the ZCRMEventParticipant.
    ///
    /// - Returns: type of the ZCRMEventParticipant
    public func getType() -> String
    {
        return self.type
    }
    
    /// set the name of the ZCRMEventParticipant.
    ///
    /// - Parameter name: name of the ZCRMEventParticipant
    internal func setName( name : String )
    {
        self.name = name
    }
    
    /// Returns the name of the ZCRMEventParticipant.
    ///
    /// - Returns: name of the ZCRMEventParticipant
    public func getName() -> String?
    {
        return self.name
    }
    
    /// Set the email of the ZCRMEventParticipant.
    ///
    /// - Parameter email: email of the ZCRMEventParticipant
    internal func setEmail( email : String )
    {
        self.email = email
    }
    
    /// Returns the email of the ZCRMEventParticipant
    ///
    /// - Returns: email of the ZCRMEventParticipant
    public func getEmail() -> String?
    {
        return self.email
    }
    
    /// Set the status of the ZCRMEventParticipant.
    ///
    /// - Parameter status: status of the ZCRMEventParticipant
    internal func setStatus( status : String )
    {
        self.status = status
    }
    
    /// Returns the status of the ZCRMEventParticipant.
    ///
    /// - Returns: status of the ZCRMEventParticipant
    public func getStatus() -> String?
    {
        return self.status
    }
    
    /// Returns true if the ZCRMEventParticipant invited
    ///
    /// - Returns: true if the ZCRMEventParticipant invited
    public func didInvite() -> Bool?
    {
        return self.isInvited
    }
    
    /// Set true if the ZCRMEventParticipant invited
    ///
    /// - Parameter invited: true if the ZCRMEventParticipant invited
    internal func setInvited( invited : Bool )
    {
        self.isInvited = invited
    }
}

//
//  ZCRMEventParticipant.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 20/06/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

open class ZCRMEventParticipant : ZCRMEntity
{
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    public var type : `Type`
    public var isInvited : Bool = APIConstants.BOOL_MOCK
    public var status : String = APIConstants.STRING_MOCK
    
    internal var participantEmailId : String?
    internal var userParticipant : ZCRMUserDelegate?
    internal var leadParticipant : ZCRMRecordDelegate?
    internal var contactParticipant : ZCRMRecordDelegate?
    
    /// Initialise the ZCRMEventParticipant
    ///
    /// - Parameters:
    ///   - type: type of the ZCRMEventParticipant is to be initialised
    ///   - id: id of the ZCRMEventParticipant is to be initialised
    internal init( type : `Type`, id : Int64 )
    {
        self.type = type
        self.id = id
    }
    
    /**
     Initialise the ZCRMEventParticipant with an email Id
     
     - Parameter withEmailId : Email Id of the participant
     */
    public init( withEmailId emailId : String )
    {
        self.type = .email
        self.participantEmailId = emailId
    }
    
    /**
     Initialise the ZCRMEventParticipant with a valid user
     
     - Parameter withUser : UserDelegate object of the event participant
     */
    public init( withUser userParticipant : ZCRMUserDelegate )
    {
        self.type = .user
        self.userParticipant = userParticipant
    }
    
    /**
     Initialise the ZCRMEventParticipant with a lead
     
     - Parameter withLead : ZCRMRecordDelegate object of the lead
     */
    public init( withLead leadParticipant : ZCRMRecordDelegate )
    {
        self.type = .lead
        self.leadParticipant = leadParticipant
    }
    
    /**
     Initialise the ZCRMEventParticipant with a contact
     
     - Parameter withContact : ZCRMRecordDelegate object of the contact
     */
    public init( withContact contactParticipant : ZCRMRecordDelegate )
    {
        self.type = .contact
        self.contactParticipant = contactParticipant
    }
    
    public enum `Type` : String
    {
        case email = "email"
        case user = "user"
        case contact = "contact"
        case lead = "lead"
    }
    
    /// Returns email Id of the event participant
    public func getEmail() -> String?
    {
        switch type
        {
        case .email :
            return participantEmailId
            
        default:
            return nil
        }
    }
    
    /// Returns user details of the event participant
    public func getUser() -> ZCRMUserDelegate?
    {
        switch type
        {
        case .user :
            return userParticipant
            
        default :
            return nil
        }
    }
    
    /// Returns record details of the event participant
    public func getRecord() -> ZCRMRecordDelegate?
    {
        switch type
        {
        case .lead :
            return leadParticipant
        case .contact :
            return contactParticipant
        default :
            return nil
        }
    }
}

extension ZCRMEventParticipant : Hashable
{
    func copy() -> ZCRMEventParticipant {
        let copyObj = ZCRMEventParticipant(type: type, id: id)
        copyObj.isInvited = isInvited
        copyObj.status = status
        copyObj.participantEmailId = participantEmailId
        copyObj.userParticipant = userParticipant
        copyObj.leadParticipant = leadParticipant
        copyObj.contactParticipant = contactParticipant
        return copyObj
    }
    
    public static func == (lhs: ZCRMEventParticipant, rhs: ZCRMEventParticipant) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.type == rhs.type &&
            lhs.isInvited == rhs.isInvited &&
            lhs.status == rhs.status &&
            lhs.participantEmailId == rhs.participantEmailId &&
            lhs.userParticipant == rhs.userParticipant &&
            lhs.leadParticipant == rhs.leadParticipant &&
            lhs.contactParticipant == rhs.contactParticipant
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

//
//  ZCRMEventParticipant.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 20/06/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

open class ZCRMEventParticipant : ZCRMEntity, Codable
{
    enum CodingKeys: String, CodingKey
    {
        case email
        case id
        case type
        case isInvited
        case status
        case participant
        case name
    }
    required public init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        email = try values.decodeIfPresent(String.self, forKey: .email)
        id = try values.decode(Int64.self, forKey: .id)
        type = try values.decode(EventParticipantType.self, forKey: .type)
        isInvited = try values.decode(Bool.self, forKey: .isInvited)
        status = try values.decode(String.self, forKey: .status)
        
        switch type
        {
        case EventParticipantType.contact:
            do
            {
                let recordId = try! values.decode(String.self, forKey: .participant)
                let record = ZCRMRecordDelegate( id: recordId, moduleAPIName: DefaultModuleAPINames.CONTACTS )
                record.label = try! values.decode(String.self, forKey: .name)
                participant = EventParticipant.record( record )
            }
        case EventParticipantType.lead:
            do
            {
                let recordId = try! values.decode(String.self, forKey: .participant)
                let record = ZCRMRecordDelegate( id: recordId, moduleAPIName: DefaultModuleAPINames.LEADS )
                record.label = try! values.decode(String.self, forKey: .name)
                participant = EventParticipant.record( record )
            }
        case EventParticipantType.user:
            do
            {
                let userId = try! values.decode(String.self, forKey: .participant)
                let userName = try! values.decode(String.self, forKey: .name)
                let user = ZCRMUserDelegate(id: userId, name: userName)
                participant = EventParticipant.user( user )
            }
        case EventParticipantType.email:
            do
            {
                let email = try! values.decode(String.self, forKey: .participant)
                participant = EventParticipant.email( email )
            }
        }
    }
    open func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        
        try container.encodeIfPresent( self.email, forKey : CodingKeys.email )
        try container.encode( self.id, forKey : CodingKeys.id )
        try container.encode( self.type, forKey : CodingKeys.type )
        try container.encode( self.isInvited, forKey : CodingKeys.isInvited )
        try container.encode( self.status, forKey : CodingKeys.status )
        
        switch type
        {
        case EventParticipantType.contact, EventParticipantType.lead:
            try container.encodeIfPresent( self.participant.getRecord()?.id, forKey : .participant )
            try container.encodeIfPresent( self.participant.getRecord()?.label, forKey : .name )
        case EventParticipantType.user:
            try container.encodeIfPresent( self.participant.getUser()?.id, forKey : .participant )
            try container.encodeIfPresent( self.participant.getUser()?.name, forKey : .name )
        case EventParticipantType.email:
            try container.encodeIfPresent( self.participant.getEmail(), forKey : .participant )
        }
    }
    
    public var email : String?
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    public var type : EventParticipantType
    public var isInvited : Bool = APIConstants.BOOL_MOCK
    public var status : String = APIConstants.STRING_MOCK
    public var participant : EventParticipant
    
    /// Initialise the ZCRMEventParticipant
    ///
    /// - Parameters:
    ///   - type: type of the ZCRMEventParticipant is to be initialised
    ///   - id: id of the ZCRMEventParticipant is to be initialised
    internal init( type : EventParticipantType, id : Int64, participant : EventParticipant )
    {
        self.type = type
        self.id = id
        self.participant = participant
    }
    
    public init( type : EventParticipantType, participant : EventParticipant )
    {
        self.type = type
        self.participant = participant
    }
}

extension ZCRMEventParticipant : Hashable
{
    public static func == (lhs: ZCRMEventParticipant, rhs: ZCRMEventParticipant) -> Bool {
        let equals : Bool = lhs.email == rhs.email &&
            lhs.id == rhs.id &&
            lhs.type == rhs.type &&
            lhs.isInvited == rhs.isInvited &&
            lhs.status == rhs.status &&
            lhs.participant == rhs.participant
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

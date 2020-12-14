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
    }
    required public init(from decoder: Decoder) throws
    {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        
        email = try! values.decodeIfPresent(String.self, forKey: .email)
        id = try! values.decode(Int64.self, forKey: .id)
        type = try! values.decode(EventParticipantType.self, forKey: .type)
        isInvited = try! values.decode(Bool.self, forKey: .isInvited)
        status = try! values.decode(String.self, forKey: .status)
        participant = try! values.decode(EventParticipant.self, forKey: .participant)
    }
    open func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        
        try container.encodeIfPresent( self.email, forKey : CodingKeys.email )
        try container.encode( self.id, forKey : CodingKeys.id )
        try container.encode( self.type, forKey : CodingKeys.type )
        try container.encode( self.isInvited, forKey : CodingKeys.isInvited )
        try container.encode( self.status, forKey : CodingKeys.status )
        try container.encode( self.participant, forKey : CodingKeys.participant )
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

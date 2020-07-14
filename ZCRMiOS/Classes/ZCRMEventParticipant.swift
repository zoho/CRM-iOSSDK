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

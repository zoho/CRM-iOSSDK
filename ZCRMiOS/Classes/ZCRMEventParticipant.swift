//
//  ZCRMEventParticipant.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 20/06/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

open class ZCRMEventParticipant
{
    public var email : String = APIConstants.STRING_MOCK
    public var name : String = APIConstants.STRING_MOCK
    public var id : Int64
    public var type : String
    public var isInvited : Bool = APIConstants.BOOL_MOCK
    public var status : String = APIConstants.STRING_MOCK
    
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
}

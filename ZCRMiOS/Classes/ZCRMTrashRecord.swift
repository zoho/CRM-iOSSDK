//
//  ZCRMTrashRecord.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 20/06/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

open class ZCRMTrashRecord : ZCRMEntity
{
    public var entityId : Int64
    public var type : String
    public var displayName : String = APIConstants.STRING_MOCK
    public var deletedTime : String = APIConstants.STRING_MOCK
    public var deletedBy : ZCRMUserDelegate = USER_MOCK
    public var createdBy : ZCRMUserDelegate = USER_MOCK
    
    public init( type : String, entityId : Int64 )
    {
        self.entityId = entityId
        self.type = type
    }
}

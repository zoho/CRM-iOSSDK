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
    var entityId : Int64
    public var type : String
    public var displayName : String = APIConstants.STRING_MOCK
    var deletedTime : String = APIConstants.STRING_MOCK
    var deletedBy : ZCRMUserDelegate = USER_MOCK
    var createdBy : ZCRMUserDelegate = USER_MOCK
    
    internal init( type : String, entityId : Int64 )
    {
        self.entityId = entityId
        self.type = type
    }
}

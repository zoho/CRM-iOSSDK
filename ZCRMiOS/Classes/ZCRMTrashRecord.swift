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
    public internal( set ) var id : Int64
    public internal( set ) var type : String
    public internal( set ) var displayName : String?
    public internal( set ) var deletedTime : String = APIConstants.STRING_MOCK
    public internal( set ) var deletedBy : ZCRMUserDelegate?
    public internal( set ) var createdBy : ZCRMUserDelegate?
    
    internal init( type : String, id : Int64 )
    {
        self.id = id
        self.type = type
    }
}

extension ZCRMTrashRecord : Equatable
{
    public static func == (lhs: ZCRMTrashRecord, rhs: ZCRMTrashRecord) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.type == rhs.type &&
            lhs.displayName == rhs.displayName &&
            lhs.deletedTime == rhs.deletedTime &&
            lhs.deletedBy == rhs.deletedBy &&
            lhs.createdBy == rhs.createdBy
        return equals
    }
}

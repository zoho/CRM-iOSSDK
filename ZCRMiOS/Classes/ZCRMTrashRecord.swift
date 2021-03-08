//
//  ZCRMTrashRecord.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 20/06/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation
import ZCacheiOS

open class ZCRMTrashRecord : ZCRMEntity, ZCacheTrashRecord
{
    public var id: String
    public var moduleName: String = String()
    public var offlineDeletedBy: ZCacheUser?
    public var offlineDeletedTime: String?
    public var associatedDeletedRecords: [ZCacheTrashRecord]?
    public var lookUpRecords: [ZCacheLookupData]?
    
    public internal( set ) var type : String
    public internal( set ) var displayName : String?
    public internal( set ) var deletedTime : String = APIConstants.STRING_MOCK
    public internal( set ) var deletedBy : ZCRMUserDelegate?
    public internal( set ) var createdBy : ZCRMUserDelegate?
    
    internal init( type : String, id : String )
    {
        self.id = id
        self.type = type
    }
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case moduleName
    }
    
    public required init( from decoder : Decoder ) throws
    {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        id = try! values.decode(String.self, forKey: .id)
        moduleName = try! values.decode(String.self, forKey: .moduleName)
        type = "all"
    }
    
    public func encode( to encoder : Encoder ) throws
    {
        
    }
}

extension ZCRMTrashRecord : Hashable
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
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

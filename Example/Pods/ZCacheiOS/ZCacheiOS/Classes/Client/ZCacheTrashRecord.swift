//
//  ZCacheTrashRecord.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 26/11/20.
//

import Foundation

public protocol ZCacheTrashRecord: ZCacheEntity {
    var id: String { get set }
    
    var moduleName: String { get set }

    var offlineDeletedBy: ZCacheUser? { get set }

    var offlineDeletedTime: String? { get set }

    var associatedDeletedRecords: [ZCacheTrashRecord]? { get set }

//    var lookUpRecords: List<LookUpRecord>? { get set }

    func restore()
}

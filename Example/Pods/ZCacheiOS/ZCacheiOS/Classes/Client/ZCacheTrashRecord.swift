//
//  ZCacheTrashRecord.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 26/11/20.
//

import Foundation

public protocol ZCacheTrashRecord {
    var id: String { get set }
    
    var moduleName: String { get set }

    associatedtype User
    var offlineDeletedBy: User? { get set }

    var offlineDeletedTime: String? { get set }

    associatedtype TrashRecord
    var associatedDeletedRecords: [TrashRecord]? { get set }

//    var lookUpRecords: List<LookUpRecord>? { get set }

    func restore()
}

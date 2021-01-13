//
//  ZCacheResponse.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 14/12/20.
//

import Foundation

public protocol ZCacheResponse
{
    var hasMoreRecords: Bool
    {
        get
        set
    }
    var recordsCount: Int
    {
        get
        set
    }
    var json: [String: Any]
    {
        get
        set
    }
    var zCacheEntityInfo: [ZCacheEntityResponse]?
    {
        get
        set
    }
}

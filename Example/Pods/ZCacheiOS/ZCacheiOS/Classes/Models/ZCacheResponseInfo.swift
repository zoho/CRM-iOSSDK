//
//  ZCacheResponseInfo.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 04/01/21.
//

import Foundation

public struct ZCacheResponseInfo: ZCacheResponse
{
    public var hasMoreRecords = false

    public var recordsCount = 0

    public var json: [String: Any] = [:]

    public var zCacheEntityInfo: [ZCacheEntityResponse]?
}

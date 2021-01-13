//
//  ZCacheConfigs.swift
//  Pods-DataCacheTesting
//
//  Created by Rajarajan on 03/12/20.
//

import Foundation

public struct ZCacheConfigs
{
    var maxRecords = 2000
    public var perPageCount = 50
    public var isInitialDataDownloadEnabled = false
    public var isDBCachingEnabled = false
    public var isOfflineCacheEnabled = false
    var isAutoSyncOfflineData = false
    var moduleConfig = [ String: Any ]()
    var minLogLevel = LogLevels.byDefault
    var printStackTrace = false
    public var cacheableModules = [String: Int]()
    
    public var client: ZCacheClient

    public init (client: ZCacheClient)
    {
        self.client = client
    }
}

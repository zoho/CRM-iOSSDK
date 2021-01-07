//
//  ZCache.swift
//  ZCacheiOS
//
//  Created by Umashri R on 19/10/20.
//

import Foundation

@available(iOS 12.0, *)
public struct ZCache
{
    internal static var database : SQLite?
    internal static var configs = ZCacheConfigs()
    
    public static let shared = ZCache()
    private init()
    {

    }
    
    public func initialize(configs: ZCacheConfigs, completion: @escaping (VoidResult) -> Void)
    {
        do
        {
            ZCache.configs = configs
            ZCache.database = try SQLite()
            TableDBHandler().createTables()
            NetworkMonitor.shared.startMonitoring()
            ZCacheLogger.initLogger(isLogEnabled: true, minLogLevel: configs.minLogLevel)
            completion(.success)
        }
        catch
        {
            completion(.failure(ZCacheError.invalidError(code: ErrorCode.internalError, message: ErrorMessage.cacheNotInitialised, details: nil)))
        }
    }
}

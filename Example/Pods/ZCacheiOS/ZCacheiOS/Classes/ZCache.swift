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
    public static let shared = ZCache()
    
    private init() {}
    
    public func initialize(completion: @escaping (VoidResult) -> Void)
    {
        do {
            ZCache.database = try SQLite()
            NetworkMonitor.shared.startMonitoring()
            completion(.success)
            
        } catch {
            completion(.failure(ZCacheError.invalidError(code: ErrorCode.internalError, message: ErrorMessage.cacheNotInitialised, details: nil)))
        }
    }
}

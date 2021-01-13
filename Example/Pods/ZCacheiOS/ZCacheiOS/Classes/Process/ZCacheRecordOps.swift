//
//  ZCacheRecordOps.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 16/12/20.
//

import Foundation

@available(iOS 12.0, *)
public class ZCacheRecordOps: ZCacheRecord
{
    public var id: String
    
    public var moduleName: String
    
    public var layoutId: String?
    
    public var offlineOwner: ZCacheUser?
    
    public var offlineCreatedTime: String?
    
    public var offlineCreatedBy: ZCacheUser?
    
    public var offlineModifiedTime: String?
    
    public var offlineModifiedBy: ZCacheUser?
    
    var apiOps: ZCacheRecord?
    
    private var metaDbHandler: MetaDBHandler
    
    private var entityDbHandler: EntityDBHandler
    
    private var cacheableModules = ZCache.shared.configs.cacheableModules
    
    private let isDataCachingEnabled: Bool = ZCache.shared.configs.isDBCachingEnabled
    
    public func create<T>(completion: @escaping (DataResponseCallback<ZCacheResponse, T>) -> Void)
    {
        if entityDbHandler.isRecordPresent(id: self.id, moduleName: moduleName)
        {
            completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordExists, details: nil)))
        }
        else if entityDbHandler.isRecordDeleted(id: self.id)
        {
            completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordDeleted, details: nil)))
        }
        else
        {
            if !NetworkMonitor.shared.isReachable && cacheableModules.keys.contains(self.moduleName)
            {
                completion(.fromServer(info: nil, data: nil))
                entityDbHandler.createRecord(record: apiOps as! T, completion: completion)
            }
            else
            {
                apiOps?.create
                {
                    [self] (result: (DataResponseCallback<ZCacheResponse, T>)) -> Void in
                    switch result
                    {
                    case .fromServer(info: let response, data: let rec):
                        if cacheableModules.keys.contains(self.moduleName) && isDataCachingEnabled
                        {
                            do
                            {
                                try entityDbHandler.insertRecord(record: rec)
                                completion(.fromCache(info: response, data: rec, waitForServer: true))
                            }
                            catch let error
                            {
                                ZCacheLogger.logError(message: error.description)
                            }
                        }
                        completion(.fromServer(info: response, data: rec))
                    case .fromCache(info: _, data: _, waitForServer: _):
                        break
                    case .failure(error: let error):
                        ZCacheLogger.logError(message: error.description)
                        completion(.failure(error: error))
                    }
                }
            }
        }
    }
    
    public func update<T>(completion: @escaping (DataResponseCallback<ZCacheResponse, T>) -> Void)
    {
        if !entityDbHandler.isRecordPresent(id: self.id, moduleName: moduleName)
        {
            completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordNotExists, details: nil)))
        }
        else if entityDbHandler.isRecordDeleted(id: self.id)
        {
            completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordDeleted, details: nil)))
        }
        else
        {
            if !NetworkMonitor.shared.isReachable && cacheableModules.keys.contains(self.moduleName)
            {
                completion(.fromServer(info: nil, data: nil))
                entityDbHandler.updateRecord(record: apiOps as! T, completion: completion)
            }
            else
            {
                apiOps?.update
                {
                    [self] (result: (DataResponseCallback<ZCacheResponse, T>)) -> Void in
                    switch result
                    {
                    case .fromServer(info: let response, data: let rec):
                        if cacheableModules.keys.contains(self.moduleName) && isDataCachingEnabled
                        {
                            do
                            {
                                try entityDbHandler.insertRecord(record: rec)
                                completion(.fromCache(info: response, data: rec, waitForServer: true))
                            }
                            catch let error
                            {
                                ZCacheLogger.logError(message: error.description)
                            }
                        }
                        completion(.fromServer(info: response, data: rec))
                    case .fromCache(info: _, data: _, waitForServer: _):
                        break
                    case .failure(error: let error):
                        ZCacheLogger.logError(message: error.description)
                        completion(.failure(error: error))
                    }
                }
            }
        }
    }
    
    public func delete(completion: @escaping (DataResponseCallback<ZCacheResponse, String>) -> Void)
    {
        if !entityDbHandler.isRecordPresent(id: id, moduleName: moduleName)
        {
            completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordNotExists, details: nil)))
        }
        else if entityDbHandler.isRecordDeleted(id: id)
        {
            completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordDeleted, details: nil)))
        }
        else
        {
            let isServerRecord = entityDbHandler.isServerRecord(id: id)
            if !NetworkMonitor.shared.isReachable && cacheableModules.keys.contains(self.moduleName)
            {
                completion(.fromServer(info: nil, data: nil))
                entityDbHandler.deleteRecord(id: id, completion: completion)
            }
            else
            {
                if !isServerRecord
                {
                    completion(.fromServer(info: nil, data: nil))
                    entityDbHandler.deleteRecord(id: id, completion: completion)
                }
                else
                {
                    apiOps?.delete
                    {
                        [self] (result: DataResponseCallback<ZCacheResponse, String>) -> Void in
                        switch result
                        {
                        case .fromServer(info: let response, data: _):
                            if isDataCachingEnabled
                            {
                                do
                                {
                                    try entityDbHandler.deleteRecordFromCache(id: id)
                                    completion(.fromCache(info: response, data: id, waitForServer: true))
                                }
                                catch let error
                                {
                                    ZCacheLogger.logError(message: error.description)
                                    completion(.failure(error: ZCacheError.sdkError(code: ErrorCode.internalError, message: error.description, details: nil)))
                                    do
                                    {
                                       try metaDbHandler.markDataModified()
                                    }
                                    catch let error
                                    {
                                        ZCacheLogger.logError(message: error.description)
                                    }
                                }
                            }
                            completion(.fromServer(info: response, data: id))
                        case .fromCache(info: _, data: _, waitForServer: _):
                            break
                        case .failure(error: let error):
                            ZCacheLogger.logError(message: error.description)
                            completion(.failure(error: error))
                        }
                    }
                }
            }
        }
    }
    
    public func reset<T>(completion: @escaping (DataResponseCallback<ZCacheResponse, T>) -> Void)
    {
        
    }
    
    public required convenience init( from decoder : Decoder ) throws
    {
        self.init()
    }
    
    public func encode( to encoder : Encoder ) throws
    {
        
    }
    
    public init(apiOps: ZCacheRecord)
    {
        self.apiOps = apiOps
        self.id = apiOps.id
        self.moduleName = apiOps.moduleName
        self.layoutId = apiOps.layoutId
        self.entityDbHandler = EntityDBHandler(moduleName: moduleName)
        self.metaDbHandler = MetaDBHandler(moduleName: moduleName)
    }
    
    init()
    {
        self.id = String()
        self.moduleName = String()
        self.entityDbHandler = EntityDBHandler(moduleName: moduleName)
        self.metaDbHandler = MetaDBHandler(moduleName: moduleName)
    }
}

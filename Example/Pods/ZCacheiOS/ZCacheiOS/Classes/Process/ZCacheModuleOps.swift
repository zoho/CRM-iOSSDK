//
//  ZCacheModuleOps.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 27/11/20.
//

import Foundation

@available(iOS 12.0, *)
public class ZCacheModuleOps: ZCacheModule {
   
    public var id: String
    
    public var apiName: String
    
    public var isApiSupported: Bool
    
    var apiOps: ZCacheModule?
    
    private var metaDbHandler: MetaDBHandler
    
    private var entityDbHandler: EntityDBHandler
    
    private var cacheableModules = ZCache.shared.configs.cacheableModules
    
    private let isDataCachingEnabled: Bool = ZCache.shared.configs.isDBCachingEnabled

    private let isOfflineCacheEnabled: Bool = ZCache.shared.configs.isOfflineCacheEnabled

    public func getLayout<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        if ( isDataCachingEnabled )
        {
            getLayoutFromCache( id: id, completion: completion )
        }
        else
        {
            getLayoutFromServer( id: id, completion: completion )
        }
    }
    
    private func getLayoutFromCache<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        // Getting a layout from cache using id
        let layout: T? = metaDbHandler.fetchLayout(id: id)
        if let layout = layout
        {
            completion( .success( layout ) )
        }
        else
        {
            getLayoutFromServer( id: id, completion: completion )
        }
    }
    
    public func getLayoutFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion( .failure( ZCacheError.networkError( code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil ) ) )
        }
        else
        {
            apiOps?.getLayoutFromServer( id: id )
            {
                (result: Result< T, ZCacheError > ) -> Void in
                switch result
                {
                    case .success( let layout ):
                        do
                        {
                            // Inserting a layout into cache using id
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertLayout(layout: layout)
                            }
                            completion( .success( layout ) )
                        }
                    case .failure( let error ): completion( .failure( error ) )
                }
            }
        }
    }
    
    public func getLayouts<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        if ( isDataCachingEnabled )
        {
            getLayoutsFromCache( completion: completion )
        }
        else
        {
            getLayoutsFromServer( completion: completion )
        }
    }
    
    private func getLayoutsFromCache<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        // Getting layouts from cache
        let layouts: [T] = metaDbHandler.fetchLayouts()
        if layouts.isEmpty
        {
            getLayoutsFromServer( completion: completion )
        }
        else
        {
            completion( .success( layouts ) )
        }
    }
    
    public func getLayoutsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion( .failure( ZCacheError.networkError( code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil ) ) )
        }
        else
        {
            apiOps?.getLayoutsFromServer
            {
                (result: Result< [T], ZCacheError > ) -> Void in
                switch result
                {
                    case .success( let layouts ):
                        do
                        {
                            // Inserting a layout into cache using id
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertLayouts(layouts: layouts)
                            }
                            completion( .success( layouts ) )
                        }
                    case .failure( let error ): completion( .failure( error ) )
                }
            }
        }
    }
    
    public func getLayoutsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion( .failure( ZCacheError.networkError( code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil ) ) )
        }
        else
        {
            apiOps?.getLayoutsFromServer( modifiedSince: modifiedSince )
            {
                (result: Result< [T], ZCacheError > ) -> Void in
                switch result
                {
                    case .success( let layouts ):
                        do
                        {
                            // Inserting a layout into cache using id
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertLayouts(layouts: layouts)
                            }
                            completion( .success( layouts ) )
                        }
                    case .failure( let error ): completion( .failure( error ) )
                }
            }
        }
    }
    
    public func getField<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        if ( isDataCachingEnabled )
        {
            getFieldFromCache( id: id, completion: completion )
        }
        else
        {
            getFieldFromServer( id: id, completion: completion )
        }
    }
    
    private func getFieldFromCache<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        // Getting a field from cache using id
        let field: T? = metaDbHandler.fetchModuleField(id: id)
        if let field = field
        {
            completion( .success( field ) )
        }
        else
        {
            getFieldFromServer( id: id, completion: completion )
        }
    }
    
    public func getFieldFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion( .failure( ZCacheError.networkError( code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil ) ) )
        }
        else
        {
            apiOps?.getFieldFromServer( id: id )
            {
                (result: Result< T, ZCacheError > ) -> Void in
                switch result
                {
                    case .success( let field ):
                        do
                        {
                            // Inserting a layout into cache using id
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertModuleField(field: field)
                            }
                            completion( .success( field ) )
                        }
                    case .failure( let error ): completion( .failure( error ) )
                }
            }
        }
    }
    
    public func getFields<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        if ( isDataCachingEnabled )
        {
            getFieldsFromCache( completion: completion )
        }
        else
        {
            getFieldsFromServer( completion: completion )
        }
    }
    
    private func getFieldsFromCache<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        // Getting fields from cache
        let fields: [T] = metaDbHandler.fetchModuleFields()
        if fields.isEmpty
        {
            getFieldsFromServer( completion: completion )
        }
        else
        {
            completion( .success( fields ) )
        }
    }
    
    public func getFieldsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion( .failure( ZCacheError.networkError( code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil ) ) )
        }
        else
        {
            apiOps?.getFieldsFromServer
            {
                (result: Result< [T], ZCacheError > ) -> Void in
                switch result
                {
                    case .success( let fields ):
                        do
                        {
                            // Inserting a layout into cache using id
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertModuleFields(fields: fields)
                            }
                            completion( .success( fields ) )
                        }
                    case .failure( let error ): completion( .failure( error ) )
                }
            }
        }
    }
    
    public func getFieldsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion( .failure( ZCacheError.networkError( code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil ) ) )
        }
        else
        {
            apiOps?.getFieldsFromServer( modifiedSince: modifiedSince )
            {
                (result: Result< [T], ZCacheError > ) -> Void in
                switch result
                {
                    case .success( let fields ):
                        do
                        {
                            // Inserting a layout into cache using id
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertModuleFields(fields: fields)
                            }
                            completion( .success( fields ) )
                        }
                    case .failure( let error ): completion( .failure( error ) )
                }
            }
        }
    }
    
    public func execute<T>(query: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        entityDbHandler.execute(query: query, completion: completion)
    }
    
    public func getRecord<T>(id: String, completion: @escaping ((DataResponseCallback<ZCacheResponse, T>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable && isDataCachingEnabled
        {
            completion(.fromServer(info: nil, data: nil))
            getRecordFromCache(id: id, waitForServer: false, dataCompletion: completion)
        }
        else
        {
            if cacheableModules.keys.contains(apiName)
            {
                getRecordFromCache(id: id, completion: completion)
            }
            else
            {
                completion(.fromCache(info: nil, data: nil, waitForServer: true))
                getRecordFromServer(id: id, completion: completion)
            }
        }
    }
    
    private func getRecordFromCache<T>(id: String, completion: @escaping (DataResponseCallback<ZCacheResponse, T>) -> Void)
    {
        do
        {
            let hasDataChanges = try metaDbHandler.hasDataChanges()
            let isCacheAvailable = entityDbHandler.isRecordPresent(id: id, moduleName: apiName)
            if hasDataChanges && isCacheAvailable
            {
                getRecordFromCache(id: id, waitForServer: true, dataCompletion: completion)
                {
                    result in
                    switch result
                    {
                    case .success:
                        do
                        {
                            self.getRecordFromServer(id: id, completion: completion)
                        }
                    case .failure(let error):
                        do
                        {
                            ZCacheLogger.logError(message: error.description)
                            self.getRecordFromServer(id: id, completion: completion)
                        }
                    }
                }
            }
            else if !hasDataChanges && isCacheAvailable
            {
                // !true || true -> cache (avail in cache and server but served from cache)
                // !true || false -> server (not avail in cache but avail in server)
                // !false || true -> cache
                // !false || false -> cache
                getRecordFromCache(id: id, waitForServer: false, dataCompletion: completion)
            }
            else
            {
                // Requested data with the requested per_page not available in the Cache.
                completion(.fromCache(info: nil, data: nil, waitForServer: true))
                getRecordFromServer(id: id, completion: completion)
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
            completion(.fromCache(info: nil, data: nil, waitForServer: true))
            getRecordFromServer(id: id, completion: completion)
        }
    }
    
    private func getRecordFromCache<T>(id: String, waitForServer: Bool, dataCompletion: @escaping (DataResponseCallback<ZCacheResponse, T>) -> Void, voidCompletion: ((VoidResult) -> Void)? = nil)
    {
        ZCacheLogger.logInfo(message: "<<< Getting Record \(id) Response from Cache.")
        let record: T? = entityDbHandler.fetchRecord(id: id)
        if let record = record
        {
            dataCompletion(.fromCache(info: nil, data: record, waitForServer: waitForServer))
            voidCompletion?(.success)
        }
        else
        {
            ZCacheLogger.logError(message: "<<< Data not available in Cache.")
            if cacheableModules.keys.contains(apiName) && !NetworkMonitor.shared.isReachable && isDataCachingEnabled
            {
                dataCompletion(.fromCache(info: nil, data: nil, waitForServer: false))
            }
            else
            {
                dataCompletion(.fromCache(info: nil, data: nil, waitForServer: true))
                getRecordFromServer(id: id, completion: dataCompletion)
            }
            voidCompletion?(.failure(ZCacheError.sdkError(code: ErrorCode.dataNotAvailable, message: ErrorMessage.dataNotAvailableInCache, details: nil)))
        }
    }
    
    public func getRecordFromServer<T>(id: String, completion: @escaping ((DataResponseCallback<ZCacheResponse, T>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion(.failure(error: ZCacheError.networkError(code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil)))
        }
        else
        {
            apiOps?.getRecordFromServer(id: id)
            {
                (result: DataResponseCallback<ZCacheResponse, T>) -> Void in
                switch result
                {
                case .fromServer(info: let response, data: let data):
                    do
                    {
//                        do {
//                            try self.entityDbHandler.insertRecord(record: data!)
//                        } catch let error {
//                            print("<<< error: \(error)")
//                        }
                        
                        if (data != nil) && self.cacheableModules.keys.contains(self.apiName) && self.isDataCachingEnabled
                        {
                            self.metaDbHandler.hasFieldChangesInServer
                            {
                                result in
                                switch result
                                {
                                case .success(let hasFieldChanges):
                                    do
                                    {
                                        if hasFieldChanges
                                        {
                                            completion(.fromCache(info: nil, data: nil, waitForServer: true))
                                            ZCache.shared.syncMeta
                                            {
                                                result in
                                                switch result
                                                {
                                                case .success:
                                                    do
                                                    {
                                                        try self.metaDbHandler.markDataModified()
                                                    }
                                                    catch let error
                                                    {
                                                        ZCacheLogger.logError(message: error.description)
                                                    }
                                                case .failure(let error):
                                                    ZCacheLogger.logError(message: error.description)
                                                    completion(.failure(error: error))
                                                }
                                            }
                                        }
                                        else
                                        {
                                            do
                                            {
                                                try self.entityDbHandler.clearRequiredDBSpaceforInsert(for: 1)
                                                try self.entityDbHandler.insertRecord(record: data!)
                                                completion(.fromCache(info: response, data: data, waitForServer: true))
                                            }
                                            catch let error
                                            {
                                                ZCacheLogger.logError(message: error.description)
                                                do
                                                {
                                                    try self.metaDbHandler.markDataModified()
                                                }
                                                catch let error
                                                {
                                                    ZCacheLogger.logError(message: error.description)
                                                }
                                                completion(.failure(error: error as! ZCacheError))
                                            }
                                        }
                                        completion(.fromServer(info: response, data: data))
                                    }
                                case .failure(let error):
                                    do
                                    {
                                        ZCacheLogger.logError(message: error.description)
                                        completion(.fromServer(info: response, data: data))
                                    }
                                }
                            }
                        }
                        else
                        {
                            completion(.fromServer(info: response, data: data))
                        }
                    }
                case .fromCache(info: _, data: _, waitForServer: _):
                    break
                case .failure(error: let error):
                    do
                    {
                        ZCacheLogger.logError(message: error.description)
                        completion(.failure(error: error))
                    }
                }
            }
        }
    }
    
    public func createRecord<T>(record: T, completion: @escaping ((DataResponseCallback<ZCacheResponse, T>) -> Void))
    {
        if let zCacheRecord = record as? ZCacheRecord
        {
            if entityDbHandler.isRecordPresent(id: zCacheRecord.id, moduleName: apiName)
            {
                completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordExists, details: nil)))
            }
            else if entityDbHandler.isRecordDeleted(id: zCacheRecord.id)
            {
                completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordDeleted, details: nil)))
            }
            else
            {
                if !NetworkMonitor.shared.isReachable && cacheableModules.keys.contains(apiName) && isOfflineCacheEnabled
                {
                    completion(.fromServer(info: nil, data: nil))
                    entityDbHandler.createRecord(record: record, completion: completion)
                }
                else
                {
                    apiOps?.createRecord(record: record)
                    {
                        [self] result in
                        switch result
                        {
                        case .fromServer(info: let response, data: let rec):
                            if cacheableModules.keys.contains(apiName) && isDataCachingEnabled
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
        else
        {
            ZCacheLogger.logError(message: ErrorMessage.notRecordType)
            completion(.failure(error: ZCacheError.sdkError(code: ErrorCode.invalidData, message: ErrorMessage.notRecordType, details: nil)))
        }
    }
    
    public func updateRecord<T>(record: T, completion: @escaping ((DataResponseCallback<ZCacheResponse, T>) -> Void))
    {
        if let zCacheRecord = record as? ZCacheRecord
        {
            if !entityDbHandler.isRecordPresent(id: zCacheRecord.id, moduleName: apiName)
            {
                completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordNotExists, details: nil)))
            }
            else if entityDbHandler.isRecordDeleted(id: zCacheRecord.id)
            {
                completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordDeleted, details: nil)))
            }
            else
            {
                if !NetworkMonitor.shared.isReachable && cacheableModules.keys.contains(apiName) && isOfflineCacheEnabled
                {
                    completion(.fromServer(info: nil, data: nil))
                    entityDbHandler.updateRecord(record: record, completion: completion)
                }
                else
                {
                    apiOps?.updateRecord(record: record)
                    {
                        [self] result in
                        switch result
                        {
                        case .fromServer(info: let response, data: let rec):
                            if cacheableModules.keys.contains(apiName) && isDataCachingEnabled
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
        else
        {
            ZCacheLogger.logError(message: ErrorMessage.notRecordType)
            completion(.failure(error: ZCacheError.sdkError(code: ErrorCode.invalidData, message: ErrorMessage.notRecordType, details: nil)))
        }
    }
    
    public func deleteRecord(id: String, completion: @escaping ((DataResponseCallback<ZCacheResponse, String>) -> Void))
    {
        if !entityDbHandler.isRecordPresent(id: id, moduleName: apiName)
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
            if !NetworkMonitor.shared.isReachable && cacheableModules.keys.contains(apiName)
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
                    apiOps?.deleteRecord(id: id)
                    {
                        [self] result in
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
    
    public func createRecords<T>(entities: [T], completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
    {
        for entity in entities
        {
            if let zCacheRecord = entity as? ZCacheRecord
            {
                if entityDbHandler.isRecordPresent(id: zCacheRecord.id, moduleName: apiName)
                {
                    completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordExists, details: nil)))
                    return
                }
                else if entityDbHandler.isRecordDeleted(id: zCacheRecord.id)
                {
                    completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordDeleted, details: nil)))
                    return
                }
            }
            else
            {
                ZCacheLogger.logError(message: ErrorMessage.notRecordType)
                completion(.failure(error: ZCacheError.sdkError(code: ErrorCode.invalidData, message: ErrorMessage.notRecordType, details: nil)))
                break
            }
        }
        if !NetworkMonitor.shared.isReachable && cacheableModules.keys.contains(apiName) && isOfflineCacheEnabled
        {
            completion(.fromServer(info: nil, data: nil))
            entityDbHandler.createRecords(entities: entities, completion: completion)
        }
        else
        {
            apiOps?.createRecords(entities: entities)
            {
                [self] result in
                switch result
                {
                case .fromServer(info: let response, data: let records):
                    if cacheableModules.keys.contains(apiName) && isDataCachingEnabled, let records = records
                    {
                      do
                      {
                          try entityDbHandler.insertRecords(records: records)
                          completion(.fromCache(info: response, data: records, waitForServer: true))
                      }
                      catch let error
                      {
                          ZCacheLogger.logError(message: error.description)
                      }
                    }
                    completion(.fromServer(info: response, data: records))
                case .fromCache(info: let response, data: let records, waitForServer: _):
                    completion(.fromServer(info: response, data: records))
                case .failure(error: let error):
                    ZCacheLogger.logError(message: error.description)
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    public func updateRecords<T>(entities: [T], completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
    {
        for entity in entities
        {
            if let zCacheRecord = entity as? ZCacheRecord
            {
                if !entityDbHandler.isRecordPresent(id: zCacheRecord.id, moduleName: apiName)
                {
                    completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordNotExists, details: nil)))
                    return
                }
                else if entityDbHandler.isRecordDeleted(id: zCacheRecord.id)
                {
                    completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordDeleted, details: nil)))
                    return
                }
            }
            else
            {
                ZCacheLogger.logError(message: ErrorMessage.notRecordType)
                  completion(.failure(error: ZCacheError.sdkError(code: ErrorCode.invalidData, message: ErrorMessage.notRecordType, details: nil)))
            }
        }
        if !NetworkMonitor.shared.isReachable && cacheableModules.keys.contains(apiName) && isOfflineCacheEnabled
        {
            completion(.fromServer(info: nil, data: nil))
            entityDbHandler.updateRecords(entities: entities, completion: completion)
        }
        else
        {
            apiOps?.updateRecords(entities: entities)
            {
                [self] result in
                switch result
                {
                case .fromServer(info: let response, data: let records):
                    if cacheableModules.keys.contains(apiName) && isDataCachingEnabled, let records = records
                    {
                      do
                      {
                          try entityDbHandler.insertRecords(records: records)
                          completion(.fromCache(info: response, data: records, waitForServer: true))
                      }
                      catch let error
                      {
                          ZCacheLogger.logError(message: error.description)
                      }
                    }
                    completion(.fromServer(info: response, data: records))
                case .fromCache(info: let response, data: let records, waitForServer: _):
                    completion(.fromServer(info: response, data: records))
                case .failure(error: let error):
                    ZCacheLogger.logError(message: error.description)
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    public func deleteRecords<T>(entities: [T], completion: @escaping ((DataResponseCallback<ZCacheResponse, [String]>) -> Void))
    {
        var ids = [String]()
        for entity in entities
        {
            if let zCacheRecord = entity as? ZCacheRecord
            {
                ids.append(zCacheRecord.id)
            }
        }
        deleteAllRecords(ids: ids, completion: completion)
    }
    
    public func deleteAllRecords(ids: [String], completion: @escaping ((DataResponseCallback<ZCacheResponse, [String]>) -> Void))
    {
        for id in ids
        {
            if !entityDbHandler.isRecordPresent(id: id, moduleName: apiName)
            {
                completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordNotExists, details: nil)))
                return
            }
            else if entityDbHandler.isRecordDeleted(id: id)
            {
                completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.recordDeleted, details: nil)))
                return
            }
        }
        var localRecordIds = [String]()
        var serverRecordIds = [String]()
        for id in ids
        {
            let isServerRecord = entityDbHandler.isServerRecord(id: id)
            if isServerRecord
            {
                serverRecordIds.append(id)
            }
            else
            {
                localRecordIds.append(id)
            }
        }
        if !NetworkMonitor.shared.isReachable
        {
            completion(.fromServer(info: nil, data: nil))
            entityDbHandler.deleteAllRecords(ids: ids, completion:  completion)
        }
        else
        {
            if serverRecordIds.isEmpty
            {
                completion(.fromServer(info: nil, data: nil))
                entityDbHandler.deleteAllRecords(ids: localRecordIds, completion: completion)
            }
            else
            {
                apiOps?.deleteAllRecords(ids: serverRecordIds)
                {
                    [self] result in
                    switch result
                    {
                    case .fromServer(info: let response, data: let ids):
                        if isDataCachingEnabled
                        {
                            do
                            {
                                if let ids = ids
                                {
                                    for id in ids
                                    {
                                        try entityDbHandler.deleteRecordFromCache(id: id)
                                    }
                                }
                                completion(.fromCache(info: response, data: ids, waitForServer: true))
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
                        completion(.fromServer(info: response, data: ids))
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
    
    public func getRecords<T>(params: ZCacheQuery.GetRecordParams, completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable && cacheableModules.keys.contains(apiName) && isDataCachingEnabled
        {
            if params.modifiedSince != nil
            {
                completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidOperation, message: ErrorMessage.notOfflineOperation, details: nil)))
            }
            else
            {
                completion(.fromServer(info: nil, data: nil))
                getRecordsFromCache(params: params, waitForServer: false, dataCompletion: completion)
            }
        }
        else
        {
            if params.modifiedSince != nil
            {
                completion(.fromCache(info: nil, data: nil, waitForServer: true))
                getRecordsFromServer(params: params, completion: completion)
            }
            else
            {
                if cacheableModules.keys.contains(apiName)
                {
                    getRecordsFromCache(params: params, completion: completion)
                }
                else
                {
                    completion(.fromCache(info: nil, data: nil, waitForServer: true))
                    getRecordsFromServer(params: params, completion: completion)
                }
            }
        }
    }
    
    private func getRecordsFromCache<T>(params: ZCacheQuery.GetRecordParams, completion: @escaping (DataResponseCallback<ZCacheResponse, [T]>) -> Void)
    {
        do
        {
            let page = params.page ?? 1
            let perPage = params.perPage ?? 200
            let hasDataChanges = try metaDbHandler.hasDataChanges()
            let isCacheAvailable = try (page * perPage) <= entityDbHandler.getRecordsCount()
            if hasDataChanges && isCacheAvailable
            {
                getRecordsFromCache(params: params, waitForServer: true, dataCompletion: completion)
                {
                    result in
                    switch result
                    {
                    case .success:
                        do
                        {
                            self.getRecordsFromServer(params: params, completion: completion)
                        }
                    case .failure(let error):
                        do
                        {
                            ZCacheLogger.logError(message: error.description)
                            self.getRecordsFromServer(params: params, completion: completion)
                        }
                    }
                }
            }
            else if !hasDataChanges && isCacheAvailable
            {
                getRecordsFromCache(params: params, waitForServer: false, dataCompletion: completion)
            }
            else
            {
                // Requested data with the requested per_page not available in the Cache.
                completion(.fromCache(info: nil, data: nil, waitForServer: true))
                getRecordsFromServer(params: params, completion: completion)
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
            completion(.fromCache(info: nil, data: nil, waitForServer: true))
            getRecordsFromServer(params: params, completion: completion)
        }
    }
    
    private func getRecordsFromCache<T>(params: ZCacheQuery.GetRecordParams, waitForServer: Bool, dataCompletion: @escaping (DataResponseCallback<ZCacheResponse, [T]>) -> Void, voidCompletion: ((VoidResult) -> Void)? = nil)
    {
        let page = params.page ?? 1
        let perPage = params.perPage ?? 200
        ZCacheLogger.logInfo(message: "<<< Getting Records Response from Cache.")
        let records: [T] = entityDbHandler.fetchRecords(page: page, perPage: perPage, sortBy: params.sortByField, sortOrder: params.sortOrder)
        if !records.isEmpty
        {
            dataCompletion(.fromCache(info: nil, data: records, waitForServer: waitForServer))
            voidCompletion?(.success)
        }
        else
        {
            ZCacheLogger.logError(message: "<<< Data not available in Cache.")
            if cacheableModules.keys.contains(apiName) && !NetworkMonitor.shared.isReachable && isDataCachingEnabled
            {
                dataCompletion(.fromCache(info: nil, data: nil, waitForServer: false))
            }
            else
            {
                dataCompletion(.fromCache(info: nil, data: nil, waitForServer: true))
                getRecordFromServer(id: id, completion: dataCompletion)
            }
            voidCompletion?(.failure(ZCacheError.sdkError(code: ErrorCode.dataNotAvailable, message: ErrorMessage.dataNotAvailableInCache, details: nil)))
        }
    }
    
    public func getRecordsFromServer<T>(params: ZCacheQuery.GetRecordParams, completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion(.failure(error: ZCacheError.networkError(code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil)))
        }
        else
        {
            apiOps?.getRecordsFromServer(params: params)
            {
                (result: DataResponseCallback<ZCacheResponse, [T]>) -> Void in
                switch result
                {
                case .fromServer(info: let response, data: let records):
                    do
                    {
                        if (records != nil) && self.cacheableModules.keys.contains(self.apiName) && self.isDataCachingEnabled
                        {
                            self.metaDbHandler.hasFieldChangesInServer
                            {
                                result in
                                switch result
                                {
                                case .success(let hasFieldChanges):
                                    do
                                    {
                                        if hasFieldChanges
                                        {
                                            completion(.fromCache(info: nil, data: nil, waitForServer: true))
                                            ZCache.shared.syncMeta
                                            {
                                                result in
                                                switch result
                                                {
                                                case .success:
                                                    do
                                                    {
                                                        try self.metaDbHandler.markDataModified()
                                                    }
                                                    catch let error
                                                    {
                                                        ZCacheLogger.logError(message: error.description)
                                                    }
                                                case .failure(let error):
                                                    ZCacheLogger.logError(message: error.description)
                                                    completion(.failure(error: error))
                                                }
                                            }
                                        }
                                        else
                                        {
                                            do
                                            {
                                                try self.entityDbHandler.clearRequiredDBSpaceforInsert(for: 1)
                                                try self.entityDbHandler.insertRecords(records: records!)
                                                completion(.fromCache(info: response, data: records, waitForServer: true))
                                            }
                                            catch let error
                                            {
                                                ZCacheLogger.logError(message: error.description)
                                                do
                                                {
                                                    try self.metaDbHandler.markDataModified()
                                                }
                                                catch let error
                                                {
                                                    ZCacheLogger.logError(message: error.description)
                                                }
                                                completion(.failure(error: error as! ZCacheError))
                                            }
                                        }
                                        completion(.fromServer(info: response, data: records))
                                    }
                                case .failure(let error):
                                    do
                                    {
                                        ZCacheLogger.logError(message: error.description)
                                        completion(.fromServer(info: response, data: records))
                                    }
                                }
                            }
                        }
                        else
                        {
                            completion(.fromServer(info: response, data: records))
                        }
                    }
                case .fromCache(info: _, data: _, waitForServer: _):
                    break
                case .failure(error: let error):
                    do
                    {
                        ZCacheLogger.logError(message: error.description)
                        completion(.failure(error: error))
                    }
                }
            }
        }
    }
    
    public func getDeletedRecords<T>(params: ZCacheQuery.GetRecordParams, completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
    {
        
    }
    
    public func getDeletedRecordsFromServer<T>(params: ZCacheQuery.GetRecordParams, completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
    {
        
    }
    
    public func restoreRecord<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {

    }

    public func restoreRecords<T>(ids: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }

    public func resetRecord<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {

    }

    public func resetRecords<T>(ids: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }

    public func getUnSyncedRecords<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }
    
    public func getSyncFailedRecords<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }

    public func clearTrash<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }

    // Record changes/details contracts
    
    public func hasDataChangesInServer() -> Bool
    {
        return false
    }

    public func getCachedRecordsCount() -> Int
    {
        return 0
    }

    public func isUnSyncedOfflineDataAvailable() -> Bool
    {
        return false
    }
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case apiName
        case isApiSupported
    }
    
    public required convenience init( from decoder : Decoder ) throws
    {
        self.init(name: String())
    }
    
    public func encode( to encoder : Encoder ) throws
    {
        
    }
    
    // initializer
    public init(apiOps: ZCacheModule)
    {
        self.apiOps = apiOps
        self.id = apiOps.id
        self.apiName = apiOps.apiName
        self.isApiSupported = apiOps.isApiSupported
        self.entityDbHandler = EntityDBHandler(moduleName: apiName)
        self.metaDbHandler = MetaDBHandler(moduleName: apiName)
    }
    
    init()
    {
        self.id = String()
        self.apiName = String()
        self.isApiSupported = false
        self.entityDbHandler = EntityDBHandler(moduleName: apiName)
        self.metaDbHandler = MetaDBHandler(moduleName: apiName)
    }
    
    init(name: String)
    {
        self.id = String()
        self.apiName = name
        self.isApiSupported = false
        self.entityDbHandler = EntityDBHandler(moduleName: name)
        self.metaDbHandler = MetaDBHandler(moduleName: apiName)
    }
    
}

//
//  ZCache.swift
//  ZCacheiOS
//
//  Created by Umashri R on 19/10/20.
//

import Foundation

@available(iOS 12.0, *)
public class ZCache
{
    internal static var database : SQLite?
    internal var configs: ZCacheConfigs!
    
    public static var shared = ZCache()
    private init()
    {
        // get instance methods
        // podspec file
    }
    
    public func initialize(configs: ZCacheConfigs, completion: @escaping (VoidResult) -> Void)
    {
        do
        {
            ZCache.shared.configs = configs
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
    
    public func syncMeta(completion: ((VoidResult) -> Void)? = nil)
    {
        let clientOps = ZCache.getClientOpsInstance()
        clientOps.getModulesFromServer
        {
            (result: Result<[ZCacheModule], ZCacheError>) -> Void in
            switch result
            {
            case .success(let modules):
                do
                {
                    if self.configs.cacheableModules.isEmpty
                    {
                        for module in modules
                        {
                            self.configs.cacheableModules[module.apiName] = 100
                        }
                    }
                    
                    ZCacheLogger.logInfo(message: "<<< Sync meta : Get modified modules success, count - \(modules.count).")
                    clientOps.getCurrentUserFromServer
                    {
                        (result: Result<ZCacheUser, ZCacheError>) -> Void in
                        switch result
                        {
                        case .success(_):
                            do
                            {
                                ZCacheLogger.logInfo(message: "<<< Sync meta : Get current user from server success.")
                                let dg = DispatchGroup()
                                for module in modules
                                {
                                    dg.enter()
                                    self.updateSyncedModuleData(moduleName: module.apiName)
                                    {
                                        result in
                                        switch result
                                        {
                                        case .success:
                                            do
                                            {
                                                dg.leave()
                                            }
                                        case .failure(let error):
                                            do
                                            {
                                                ZCacheLogger.logError(message: error.description)
                                                completion?(.failure(error))
                                            }
                                        }
                                    }
                                }
                                dg.notify(queue: DispatchQueue.main)
                                {
                                    ZCacheLogger.logInfo(message: "<<< SyncMeta success.")
                                }
                            }
                        case .failure(let error):
                            do
                            {
                                ZCacheLogger.logInfo(message: "<<< Sync meta : Get current user failed - \(error).")
                            }
                        }
                    }
                }
            case .failure(let error):
                do
                {
                    ZCacheLogger.logError(message: "<<< Sync meta : Get modules failed - \(error).")
                }
            }
        }
    }
    
    private func updateSyncedModuleData(moduleName: String, completion: @escaping (VoidResult) -> Void)
    {
        let metaDBHandler = MetaDBHandler(moduleName: moduleName)
        let cachedFields: [ZCacheField] = metaDBHandler.fetchModuleFields()
        getLayoutsAndFields(moduleName: moduleName)
        {
            result in
            switch result
            {
            case .success:
                do
                {
                    if cachedFields.isEmpty
                    {
                        TableDBHandler().createRecordTable(moduleName: moduleName)
                        completion(.success)
                    }
                    else
                    {
                        let serverFields: [ZCacheField] = metaDBHandler.fetchModuleFields()
                        let serverFieldsMap = serverFields.reduce(into: [String: ZCacheField]() )
                        {
                            $0[$1.apiName] = $1
                        }
                        var cachedFieldsMap = cachedFields.reduce(into: [String: ZCacheField]() )
                        {
                            $0[$1.apiName] = $1
                        }
                        if serverFieldsMap.keys != cachedFieldsMap.keys
                        {
                            var unmodifiedFields = [ZCacheField]()
                            for (fieldName, field) in serverFieldsMap
                            {
                                if cachedFieldsMap.keys.contains(fieldName)
                                {
                                    unmodifiedFields.append(field)
                                    cachedFieldsMap.removeValue(forKey: fieldName)
                                }
                            }
                            ZCacheLogger.logInfo(message: "<<< Sync : Unmodified fields for alter table - \(unmodifiedFields).")
                            
                            // Altering record table
                            do
                            {
                                try EntityDBHandler(moduleName: moduleName).alterRecordTable(unmodifiedFields: unmodifiedFields)
                                completion(.success)
                            }
                            catch
                            {
                                completion(.failure(error as! ZCacheError))
                            }
                        }
                        else
                        {
                            TableDBHandler().createRecordTable(moduleName: moduleName)
                            completion(.success)
                        }
                    }
                }
            case .failure(let error):
                do
                {
                    ZCacheLogger.logError(message: error.description)
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func getLayoutsAndFields(moduleName: String, completion: @escaping (VoidResult) -> Void)
    {
        let modOps = ZCache.getModuleOpsInstance(name: moduleName)
        modOps.getFieldsFromServer
        {
            (result: Result<[ZCacheField], ZCacheError>) -> Void in
            switch result
            {
            case .success(_):
                do
                {
                    if let _ = ZCache.getLayoutInstance()
                    {
                        modOps.getLayoutsFromServer
                        {
                            (result: Result<[ZCacheLayout], ZCacheError>) -> Void in
                            switch result
                            {
                            case .success(let layouts):
                                do
                                {
                                    let dg = DispatchGroup()
                                    for layout in layouts
                                    {
                                        dg.enter()
                                        ZCacheLayoutOps(apiOps: layout).getFieldsFromServer
                                        {
                                            (result: Result<[ZCacheField], ZCacheError>) -> Void in
                                            switch result
                                            {
                                            case .success(_):
                                                do
                                                {
                                                    dg.leave()
                                                    
                                                }
                                            case .failure(let error):
                                                do
                                                {
                                                    ZCacheLogger.logError(message: error.description)
                                                    completion(.failure(error))
                                                }
                                            }
                                        }
                                        
                                        if let _ = ZCache.getSectionInstance()
                                        {
                                            dg.enter()
                                            ZCacheLayoutOps(apiOps: layout).getSectionsFromServer
                                            {
                                                (result: Result<[ZCacheSection], ZCacheError>) -> Void in
                                                switch result
                                                {
                                                case .success(let sections):
                                                    do
                                                    {
                                                        dg.leave()
                                                        for section in sections
                                                        {
                                                            dg.enter()
                                                            ZCacheSectionOps(apiOps: section).getFieldsFromServer
                                                            {
                                                                (result: Result<[ZCacheField], ZCacheError>) -> Void in
                                                                switch result
                                                                {
                                                                case .success(_):
                                                                    do
                                                                    {
                                                                        dg.leave()
                                                                    }
                                                                case .failure(let error):
                                                                    do
                                                                    {
                                                                        ZCacheLogger.logError(message: error.description)
                                                                        completion(.failure(error))
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                case .failure(let error):
                                                    do
                                                    {
                                                        ZCacheLogger.logError(message: error.description)
                                                        completion(.failure(error))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    dg.notify(queue: DispatchQueue.main)
                                    {
                                        completion(.success)
                                    }
                                }
                            case .failure(let error):
                                do
                                {
                                    ZCacheLogger.logError(message: error.description)
                                    completion(.failure(error))
                                }
                            }
                        }
                    }
                    else
                    {
                        completion(.success)
                    }
                }
            case .failure(let error):
                do
                {
                    ZCacheLogger.logError(message: error.description)
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func getClientInstance() -> ZCacheClient
    {
        return ZCache.shared.configs.clientInstance.newInstance()
    }
    
    static func getModuleInstance() -> ZCacheModule
    {
        return ZCache.shared.configs.clientInstance.getModuleInstance()
    }
    
    static func getUserInstance() -> ZCacheUser
    {
        return ZCache.shared.configs.clientInstance.getUserInstance()
    }
    
    static func getLayoutInstance() -> ZCacheLayout?
    {
        return ZCache.shared.configs.clientInstance.getLayoutInstance()
    }
    
    static func getSectionInstance() -> ZCacheSection?
    {
        return ZCache.shared.configs.clientInstance.getSectionInstance()
    }
    
    static func getFieldInstance() -> ZCacheField
    {
        return ZCache.shared.configs.clientInstance.getFieldInstance()
    }
    
    static func getRecordInstance(moduleName: String) -> ZCacheRecord
    {
        return ZCache.shared.configs.clientInstance.getRecordInstance(moduleName: moduleName)
    }
    
    static func getEntityInstance(ofType type: DataType) -> ZCacheEntity
    {
        return ZCache.shared.configs.clientInstance.getEntityInstance(ofType: type)
    }
    
    static func getClientOpsInstance() -> ZCacheClientOps
    {
        let client = ZCache.shared.configs.clientInstance.newInstance()
        return ZCacheClientOps(apiOps: client)
    }

    static func getModuleOpsInstance(name: String) -> ZCacheModuleOps
    {
        var module = ZCache.shared.configs.clientInstance.getModuleInstance()
        module.apiName = name
        return ZCacheModuleOps(apiOps: module)
    }

    static func getTrashRecordOpsInstance(trashRecord: ZCacheTrashRecord)
    {
    
    }

    static func getRecordOpsInstance(record: ZCacheRecord)
    {
//        return RecordOps(record)
    }

    static func getFieldOpsInstance(field: ZCacheField) -> ZCacheFieldOps
    {
        return ZCacheFieldOps(apiOps: field)
    }
}

extension Array where Element: Hashable
{
    func difference(from other: [Element]) -> [Element]
    {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

extension DispatchGroup
{
    func dispatchMain(_ block: @escaping () -> ()) {
        
        guard !Thread.isMainThread else {
            block()
            return
        }
        DispatchQueue.main.async(execute: block)
    }

    func dispatchMainAfter(deadline: DispatchTime, _ block: @escaping () -> ()) {
        
        guard !Thread.isMainThread else {
            block()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: deadline, execute: block)
    }
}

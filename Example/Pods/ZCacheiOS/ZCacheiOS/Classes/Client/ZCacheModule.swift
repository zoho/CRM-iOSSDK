//
//  ZCacheModule.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 25/11/20.
//

import Foundation

public protocol ZCacheModule: ZCacheEntity
{
    var id: String { get set }
    
    var apiName: String { get set }
    
    var isApiSupported: Bool { get set }
    
    // Layout contracts
    func getLayoutFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    
    func getLayoutsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))

    func getLayoutsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    // Field contracts
    func getFieldFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    
    func getFieldsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    func getFieldsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    // Record contracts
    
    func execute<T>(query: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))

    func getRecordFromServer<T>(id: String, completion: @escaping ((DataResponseCallback<ZCacheResponse, T>) -> Void))
    
    func createRecord<T>(record: T, completion: @escaping ((DataResponseCallback<ZCacheResponse, T>) -> Void))
    
    func updateRecord<T>(record: T, completion: @escaping ((DataResponseCallback<ZCacheResponse, T>) -> Void))
    
    func deleteRecord(id: String, completion: @escaping ((DataResponseCallback<ZCacheResponse, String>) -> Void))
    
    func createRecords<T>(entities: [T], completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
    
    func updateRecords<T>(entities: [T], completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
    
    func deleteRecords<T>(entities: [T], completion: @escaping ((DataResponseCallback<ZCacheResponse, [String]>) -> Void))
    
    func deleteAllRecords(ids: [String], completion: @escaping ((DataResponseCallback<ZCacheResponse, [String]>) -> Void))
    
    func getRecordsFromServer<T>(params: ZCacheQuery.GetRecordParams, completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
    
    func getDeletedRecordsFromServer<T>(params: ZCacheQuery.GetRecordParams, completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
  
}

extension ZCacheModule {
    
    // Record contracts
    
    func restoreRecord<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {

    }

    func restoreRecords<T>(ids: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }

    func resetRecord<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {

    }

    func resetRecords<T>(ids: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }

    func getUnSyncedRecords<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        
    }
    
    func getSyncFailedRecords<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }

    func clearTrash<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }

    // Record changes/details contracts
    
    func hasDataChangesInServer() -> Bool
    {
        return false
    }

    func getCachedRecordsCount() -> Int
    {
        return 0
    }

    func isUnSyncedOfflineDataAvailable() -> Bool
    {
        return false
    }
}

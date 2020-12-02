//
//  ZCacheModule.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 25/11/20.
//

import Foundation

public protocol ZCacheModule: Codable {
    var id: String { get set }
    var apiName: String { get set }
    var isApiSupported: Bool { get set }
    
    // Layout contracts
    
    func getLayout<T: ZCacheLayout>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    
    func getLayoutFromServer<T: ZCacheLayout>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    
    func getLayouts<T: ZCacheLayout>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
   
    func getLayoutsFromServer<T: ZCacheLayout>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))

    func getLayoutsFromServer<T: ZCacheLayout>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    // Field contracts
    
    func getField<T: ZCacheField>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
   
    func getFieldFromServer<T: ZCacheField>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    
    func getFields<T: ZCacheField>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    func getFieldsFromServer<T: ZCacheField>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    func getFieldsFromServer<T: ZCacheField>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    // Record contracts
    
    func execute<T: ZCacheRecord>(query: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    func getRecord<T: ZCacheRecord>(witId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))

    func getRecordFromServer<T: ZCacheRecord>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    
    func createRecord<T: ZCacheRecord>(record: ZCacheRecord, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    
    func updateRecord<T: ZCacheRecord>(record: ZCacheRecord, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    
    func deleteRecord(withId: String, completion: @escaping ((Result<String, ZCacheError>) -> Void))
    
    func createRecords<T: ZCacheRecord>(entities: [T], completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    func updateRecords<T: ZCacheRecord>(entities: [T], completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    func deleteRecords<T: ZCacheRecord>(entities: [T], completion: @escaping ((Result<[String], ZCacheError>) -> Void))
    
    func deleteAllRecords(ids: [String], completion: @escaping ((Result<[String], ZCacheError>) -> Void))
    
    func getRecords<T: ZCacheRecord>(params: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    func getRecordsFromServer<T: ZCacheRecord>(params: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    func getDeletedRecords<T: ZCacheRecord>(params: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    func getDeletedRecordsFromServer<T: ZCacheRecord>(params: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void))
  
}

extension ZCacheModule {
    
    // Record contracts
    
    func restoreRecord<T: ZCacheRecord>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {

    }

    func restoreRecords<T: ZCacheRecord>(ids: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }

    func resetRecord<T: ZCacheRecord>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {

    }

    func resetRecords<T: ZCacheRecord>(ids: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }

    func getUnSyncedRecords<T: ZCacheRecord>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }
    
    func getSyncFailedRecords<T: ZCacheRecord>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }

    func clearTrash<T: ZCacheRecord>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
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

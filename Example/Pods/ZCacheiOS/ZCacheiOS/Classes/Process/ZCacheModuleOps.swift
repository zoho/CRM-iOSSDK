//
//  ZCacheModuleOps.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 27/11/20.
//

import Foundation

public class ZCacheModuleOps: ZCacheModule {
    public var id: String
    
    public var apiName: String
    
    public var isApiSupported: Bool
    
    var apiOps: ZCacheModule?
    
    public func getLayout<T>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheLayout
    {
    
    }
    
    public func getLayoutFromServer<T>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheLayout
    {
        
    }
    
    public func getLayouts<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheLayout
    {
        
    }
    
    public func getLayoutsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheLayout
    {
        
    }
    
    public func getLayoutsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheLayout
    {
        
    }
    
    public func getField<T>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheField
    {
        
    }
    
    public func getFieldFromServer<T>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheField
    {
        
    }
    
    public func getFields<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheField
    {
        
    }
    
    public func getFieldsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheField
    {
        
    }
    
    public func getFieldsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheField
    {
        
    }
    
    public func execute<T>(query: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheRecord
    {
        
    }
    
    public func getRecord<T>(witId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheRecord
    {
        
    }
    
    public func getRecordFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheRecord
    {
        
    }
    
    public func createRecord<T>(record: ZCacheRecord, completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheRecord
    {
        
    }
    
    public func updateRecord<T>(record: ZCacheRecord, completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheRecord
    {
        
    }
    
    public func deleteRecord(withId: String, completion: @escaping ((Result<String, ZCacheError>) -> Void))
    {
        
    }
    
    public func createRecords<T>(entities: [T], completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheRecord
    {
        
    }
    
    public func updateRecords<T>(entities: [T], completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheRecord
    {
        
    }
    
    public func deleteRecords<T>(entities: [T], completion: @escaping ((Result<[String], ZCacheError>) -> Void)) where T : ZCacheRecord
    {
        
    }
    
    public func deleteAllRecords(ids: [String], completion: @escaping ((Result<[String], ZCacheError>) -> Void))
    {
        
    }
    
    public func getRecords<T>(params: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheRecord
    {
        
    }
    
    public func getRecordsFromServer<T>(params: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheRecord
    {
        
    }
    
    public func getDeletedRecords<T>(params: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheRecord
    {
        
    }
    
    public func getDeletedRecordsFromServer<T>(params: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheRecord
    {
        
    }
    
    public func restoreRecord<T: ZCacheRecord>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {

    }

    public func restoreRecords<T: ZCacheRecord>(ids: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }

    public func resetRecord<T: ZCacheRecord>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {

    }

    public func resetRecords<T: ZCacheRecord>(ids: [String], completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }

    public func getUnSyncedRecords<T: ZCacheRecord>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }
    
    public func getSyncFailedRecords<T: ZCacheRecord>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {

    }

    public func clearTrash<T: ZCacheRecord>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
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
        self.init()
    }
    
    public func encode( to encoder : Encoder ) throws
    {
        
    }
    
    // initializer
    public init(apiOps: ZCacheModule) {
        self.apiOps = apiOps
        self.id = apiOps.id
        self.apiName = apiOps.apiName
        self.isApiSupported = apiOps.isApiSupported
    }
    
    init() {
        self.id = String()
        self.apiName = String()
        self.isApiSupported = false
    }
    
}

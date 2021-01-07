//
//  ZCacheClient.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 25/11/20.
//

import Foundation

public protocol ZCacheClient {
    
    // Instance contracts
    func new() -> ZCacheClient
    func getUser() -> ZCacheUser
    func getModule() -> ZCacheModule
    func getLayout() -> ZCacheLayout?
    func getSection() -> ZCacheSection?
    func getField() -> ZCacheField
    func getRecord(moduleName: String) -> ZCacheRecord
    func getEntity(ofType type: DataType) -> ZCacheEntity

    // Module contracts
    func getModuleFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
   
    func getModuleFromServer<T>(withName: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    
    func getModulesFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    func getModulesFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
   
    // User contracts
    func getUsersFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
   
    func getUserFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
   
    func getCurrentUserFromServer<T>(completion: @escaping ((Result<T, ZCacheError>) -> Void))
    
}


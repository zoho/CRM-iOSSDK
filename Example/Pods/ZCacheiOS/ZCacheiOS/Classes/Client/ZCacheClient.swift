//
//  ZCacheClient.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 25/11/20.
//

import Foundation

public protocol ZCacheClient {
    
    // Module contracts
    
    func getModules<T: ZCacheModule>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    func getModulesFromServer<T: ZCacheModule>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    func getModulesFromServer<T: ZCacheModule>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    func getModule<T: ZCacheModule>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    
    func getModuleFromServer<T: ZCacheModule>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
   
    func getModule<T: ZCacheModule>(withName: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    
    func getModuleFromServer<T: ZCacheModule>(withName: String, modifiedSince: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
   
    // User contracts
    
    func getUsers<T: ZCacheUser>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    
    func getUsersFromServer<T: ZCacheUser>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
   
    func getUser<T: ZCacheUser>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
   
    func getUserFromServer<T: ZCacheUser>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
   
    func getCurrentUser<T: ZCacheUser>(completion: @escaping ((Result<T, ZCacheError>) -> Void))
   
    func getCurrentUserFromServer<T: ZCacheUser>(completion: @escaping ((Result<T, ZCacheError>) -> Void))
    
}


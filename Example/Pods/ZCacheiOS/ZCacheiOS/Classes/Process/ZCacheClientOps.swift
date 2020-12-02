//
//  ZCacheClientOps.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 27/11/20.
//

import Foundation

@available(iOS 12.0, *)
public class ZCacheClientOps: ZCacheClient {
    
    var apiOps: ZCacheClient
    var metaDbHandler = MetaDBHandler()
    
    public func getModules<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheModule
    {
        let modules: [T] = metaDbHandler.fetchModules()
        if modules.isEmpty {
            self.getModulesFromServer(completion: completion)
        } else {
            completion(.success(modules))
        }
    }
    
    public func getModulesFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheModule
    {
        if NetworkMonitor.shared.isReachable {
            completion(.failure(ZCacheError.networkError(code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil)))
        } else {
            apiOps.getModulesFromServer { (result: Result<[T], ZCacheError>) -> Void in
                switch result {
                    case .success(let modules): do {
                        completion(.success(modules))
                        self.metaDbHandler.insertModules(modules: modules)
                    }
                    case .failure(let error): completion(.failure(error))
                }
            }
        }
    }
    
    public func getModulesFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheModule
    {
        
    }
    
    public func getModule<T>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheModule
    {
        
    }
    
    public func getModuleFromServer<T>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheModule
    {
        
    }
    
    public func getModule<T>(withName: String, completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheModule
    {
        
    }
    
    public func getModuleFromServer<T>(withName: String, modifiedSince: String, completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheModule
    {
        
    }
    
    public func getUsers<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheUser
    {
        
    }
    
    public func getUsersFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheUser
    {
        
    }
    
    public func getUser<T>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheUser
    {
        
    }
    
    public func getUserFromServer<T>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheUser
    {
        
    }
    
    public func getCurrentUser<T>(completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheUser
    {
        
    }
    
    public func getCurrentUserFromServer<T>(completion: @escaping ((Result<T, ZCacheError>) -> Void)) where T : ZCacheUser
    {
        
    }
    
    public init(apiOps: ZCacheClient) {
        self.apiOps = apiOps
    }
        
}

//
//  ZCacheClientOps.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 27/11/20.
//

import Foundation

@available(iOS 12.0, *)
public class ZCacheClientOps: ZCacheClient
{
    var apiOps: ZCacheClient?
    
    private var metaDbHandler = MetaDBHandler()
    
    private let isDataCachingEnabled: Bool = ZCache.shared.configs.isDBCachingEnabled
    
    public func new() -> ZCacheClient {
        return ZCacheClientOps()
    }
    
    public func getUser() -> ZCacheUser {
        return ZCacheUserOps()
    }
    
    public func getModule() -> ZCacheModule {
        return ZCacheModuleOps()
    }
    
    public func getLayout() -> ZCacheLayout? {
        return ZCacheLayoutOps()
    }
    
    public func getSection() -> ZCacheSection? {
        return ZCacheSectionOps()
    }
    
    public func getField() -> ZCacheField {
        return ZCacheFieldOps()
    }
    
    public func getRecord(moduleName: String) -> ZCacheRecord
    {
        return ZCacheRecordOps()
    }
    
    public func getEntity(ofType type: DataType) -> ZCacheEntity
    {
        return ZCacheRecordOps()
    }

    public func getModules< T >( completion: @escaping ( ( Result< [T], ZCacheError > ) -> Void ) )
    {
        if ( isDataCachingEnabled )
        {
            getModulesFromCache( completion: completion )
        }
        else
        {
            getModulesFromServer( completion: completion )
        }
    }
    
    private func getModulesFromCache< T >( completion: @escaping ( ( Result< [T], ZCacheError > ) -> Void ) )
    {
        // Getting modules from cache
        let modules: [T] = metaDbHandler.fetchModules()
        if modules.isEmpty
        {
            getModulesFromServer( completion: completion )
        }
        else
        {
            completion( .success( modules ) )
        }
    }
    
    public func getModulesFromServer< T >( completion: @escaping ( ( Result< [T], ZCacheError > ) -> Void ) )
    {
        getAllModulesFromServer(modifiedSince: nil, completion: completion)
    }
    
    public func getModulesFromServer< T >(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        getAllModulesFromServer(modifiedSince: modifiedSince, completion: completion)
    }
    
    func getAllModulesFromServer< T >(modifiedSince: String?, completion: @escaping ( ( Result< [T], ZCacheError > ) -> Void ) )
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion( .failure( ZCacheError.networkError( code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil ) ) )
        }
        else
        {
            if let modifiedSince = modifiedSince
            {
                apiOps?.getModulesFromServer(modifiedSince: modifiedSince)
                {
                    (result: Result< [T], ZCacheError > ) -> Void in
                    switch result
                    {
                        case .success( let modules ):
                            do
                            {
                                // Inserting modules into cache
                                if self.isDataCachingEnabled {
                                    self.metaDbHandler.insertModules( modules: modules, isModuleModified: true )
                                }
                                completion( .success( modules ) )
                            }
                        case .failure( let error ): completion( .failure( error ) )
                    }
                }
            }
            else
            {
                apiOps?.getModulesFromServer
                {
                    (result: Result< [T], ZCacheError > ) -> Void in
                    switch result
                    {
                        case .success( let modules ):
                            do
                            {
                                // Inserting modules into cache
                                if self.isDataCachingEnabled {
                                    self.metaDbHandler.insertModules( modules: modules )
                                }
                                completion( .success( modules ) )
                            }
                        case .failure( let error ): completion( .failure( error ) )
                    }
                }
            }
        }
    }
    
    public func getModule<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        if (isDataCachingEnabled)
        {
            getModuleFromCache(id: id, completion: completion)
        }
        else
        {
            getModuleFromServer(id: id, completion: completion)
        }
    }
    
    private func getModuleFromCache<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        // Getting a module from cache using id
        let module: T? = metaDbHandler.fetchModule(id: id)
        if let module = module
        {
            completion(.success(module))
        }
        else
        {
            self.getModuleFromServer(id: id, completion: completion)
        }
    }
    
    public func getModuleFromServer< T >( id: String, completion: @escaping ( ( Result< T, ZCacheError > ) -> Void ) )
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion( .failure( ZCacheError.networkError( code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil ) ) )
        }
        else
        {
            apiOps?.getModuleFromServer( id: id )
            {
                ( result: Result< T, ZCacheError > ) -> Void in
                switch result
                {
                    case .success( let module ):
                        do
                        {
                            // Getting a module from cache using id
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertModule( module: module )
                            }
                            completion( .success( module ) )
                        }
                    case .failure( let error ): completion( .failure( error ) )
                }
            }
        }
    }
    
    public func getModule<T>(withName: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        if (isDataCachingEnabled)
        {
            getModuleFromCache(withName: withName, completion: completion)
        }
        else
        {
            getModuleFromServer(withName: withName, completion: completion)
        }
    }
    
    private func getModuleFromCache<T>(withName: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        // Getting a module from cache using name
        let module: T? = metaDbHandler.fetchModule(name: withName)
        if let module = module
        {
            completion(.success(module))
        }
        else
        {
            self.getModuleFromServer(withName: withName, completion: completion)
        }
    }
    
    public func getModuleFromServer<T>(withName: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion(.failure(ZCacheError.networkError(code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil)))
        }
        else
        {
            apiOps?.getModuleFromServer(withName: withName)
            {
                (result: Result<T, ZCacheError>) -> Void in
                switch result
                {
                    case .success(let module):
                        do
                        {
                            // Inserting a module into cache using name
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertModule(module: module)
                            }
                            completion( .success( module ) )
                        }
                    case .failure(let error): completion(.failure(error))
                }
            }
        }
    }
    
    public func getUsers< T >( completion: @escaping ( ( Result< [T], ZCacheError > ) -> Void ) )
    {
        if ( isDataCachingEnabled )
        {
            getUsersFromCache( completion: completion )
        }
        else
        {
            getUsersFromServer( completion: completion )
        }
    }
    
    private func getUsersFromCache< T >( completion: @escaping ( ( Result< [T], ZCacheError > ) -> Void ) )
    {
        // Getting users from cache
        let users: [T] = metaDbHandler.fetchUsers()
        if users.isEmpty
        {
            getUsersFromServer( completion: completion )
        }
        else
        {
            completion( .success( users ) )
        }
    }
    
    public func getUsersFromServer< T >( completion: @escaping ( ( Result< [T], ZCacheError > ) -> Void ) )
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion( .failure( ZCacheError.networkError( code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil ) ) )
        }
        else
        {
            apiOps?.getUsersFromServer
            {
                ( result: Result< [T], ZCacheError > ) -> Void in
                switch result
                {
                    case .success( let users ):
                        do
                        {
                            // Inserting user into cache
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertUsers( users: users )
                            }
                            completion( .success( users ) )
                        }
                    case .failure( let error ): completion( .failure( error ) )
                }
            }
        }
    }
    
    public func getUser<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        if ( isDataCachingEnabled )
        {
            getUserFromCache( id: id, completion: completion )
        }
        else
        {
            getUserFromServer( id: id, completion: completion )
        }
    }
    
    private func getUserFromCache<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        // Getting a user from cache using id
        let user: T? = metaDbHandler.fetchUser(id: id)
        if let user = user
        {
            completion( .success( user ) )
        }
        else
        {
            getUserFromServer( id: id, completion: completion )
        }
    }
    
    public func getUserFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion( .failure( ZCacheError.networkError( code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil ) ) )
        }
        else
        {
            apiOps?.getUserFromServer( id: id )
            {
                ( result: Result< T, ZCacheError > ) -> Void in
                switch result
                {
                    case .success( let user ):
                        do
                        {
                            // Inserting user into cache
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertUser( user: user )
                            }
                            completion( .success( user ) )
                        }
                    case .failure( let error ): completion( .failure( error ) )
                }
            }
        }
    }
    
    public func getCurrentUser<T>(completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        if ( isDataCachingEnabled )
        {
            getCurrentUserFromCache( completion: completion )
        }
        else
        {
            getCurrentUserFromServer( completion: completion )
        }
    }
    
    private func getCurrentUserFromCache<T>( completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        // Getting a user from cache using id
        let user: T? = metaDbHandler.fetchCurrentUser()
        if let user = user
        {
            completion( .success( user ) )
        }
        else
        {
            getCurrentUserFromServer( completion: completion )
        }
    }
    
    public func getCurrentUserFromServer<T>(completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion( .failure( ZCacheError.networkError( code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil ) ) )
        }
        else
        {
            apiOps?.getCurrentUserFromServer
            {
                ( result: Result< T, ZCacheError > ) -> Void in
                switch result
                {
                    case .success( let user ):
                        do
                        {
                            // Inserting user into cache
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertUser( user: user, isCurrentUser: true )
                            }
                            completion( .success( user ) )
                        }
                    case .failure( let error ): completion( .failure( error ) )
                }
            }
        }
    }
    
    public init(apiOps: ZCacheClient) {
        self.apiOps = apiOps
    }
    
    init()
    {
        
    }
    
}

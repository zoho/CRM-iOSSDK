//
//  ZCacheLayoutOps.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 26/11/20.
//

import Foundation

@available(iOS 12.0, *)
public class ZCacheLayoutOps: ZCacheLayout
{
    public var id: String
    
    var apiOps: ZCacheLayout?
    
    private var metaDbHandler = MetaDBHandler()
    
    private let isDataCachingEnabled: Bool = ZCache.shared.configs.isDBCachingEnabled
    
    public func getSection<T>(name: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        if ( isDataCachingEnabled )
        {
            getSectionFromCache( name: name, completion: completion )
        }
        else
        {
            getSectionFromServer( name: name, completion: completion )
        }
    }
    
    private func getSectionFromCache<T>(name: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        // Getting a section from cache using name
        let section: T? = metaDbHandler.fetchLayoutSection(name: name, layoutId: id)
        if let section = section
        {
            completion( .success( section ) )
        }
        else
        {
            getSectionFromServer( name: name, completion: completion )
        }
    }
    
    public func getSectionFromServer<T>(name: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion( .failure( ZCacheError.networkError( code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil ) ) )
        }
        else
        {
            apiOps?.getSectionFromServer( name: name )
            {
                (result: Result< T, ZCacheError > ) -> Void in
                switch result
                {
                    case .success( let section ):
                        do
                        {
                            completion( .success( section ) )
                            
                            // Inserting a layout section into cache using name
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertLayoutSection(layoutId: self.id, section: section)
                            }
                        }
                    case .failure( let error ): completion( .failure( error ) )
                }
            }
        }
    }
    
    public func getSections<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        if ( isDataCachingEnabled )
        {
            getSectionsFromCache( completion: completion )
        }
        else
        {
            getSectionsFromServer( completion: completion )
        }
    }
    
    private func getSectionsFromCache<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        // Getting sections from cache
        let sections: [T] = metaDbHandler.fetchLayoutSections(layoutId: id)
        if sections.isEmpty
        {
            getSectionsFromServer( completion: completion )
        }
        else
        {
            completion( .success( sections ) )
        }
    }
    
    public func getSectionsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion( .failure( ZCacheError.networkError( code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil ) ) )
        }
        else
        {
            apiOps?.getSectionsFromServer
            {
                (result: Result< [T], ZCacheError > ) -> Void in
                switch result
                {
                    case .success( let sections ):
                        do
                        {
                            completion( .success( sections ) )
                            
                            // Inserting sections into cache
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertLayoutSections(layoutId: self.id, sections: sections)
                            }
                        }
                    case .failure( let error ): completion( .failure( error ) )
                }
            }
        }
    }
    
    public func getSectionsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        if !NetworkMonitor.shared.isReachable
        {
            completion( .failure( ZCacheError.networkError( code: ErrorCode.noInternet, message: ErrorMessage.noInternet, details: nil ) ) )
        }
        else
        {
            apiOps?.getSectionsFromServer( modifiedSince: modifiedSince )
            {
                (result: Result< [T], ZCacheError > ) -> Void in
                switch result
                {
                    case .success( let sections ):
                        do
                        {
                            completion( .success( sections ) )
                            
                            // Inserting sections into cache
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertLayoutSections(layoutId: self.id, sections: sections)
                            }
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
        // Getting a layout field from cache using id
        let field: T? = metaDbHandler.fetchLayoutField(id: id, layoutId: id)
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
                            completion( .success( field ) )
                            
                            // Inserting a layout field into cache using id
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertLayoutField(layoutId: self.id, field: field)
                            }
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
        let fields: [T] = metaDbHandler.fetchLayoutFields(layoutId: id)
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
                            completion( .success( fields ) )
                            
                            // Inserting fields into cache
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertLayoutFields(layoutId: self.id, fields: fields)
                            }
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
                            completion( .success( fields ) )
                            
                            // Inserting fields into cache
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertLayoutFields(layoutId: self.id, fields: fields)
                            }
                        }
                    case .failure( let error ): completion( .failure( error ) )
                }
            }
        }
    }

    // initializer
    public init(apiOps: ZCacheLayout)
    {
        self.apiOps = apiOps
        self.id = apiOps.id
    }
    
    enum CodingKeys: String, CodingKey
    {
        case id
    }
    
    public required convenience init( from decoder : Decoder ) throws
    {
        self.init()
    }
    
    public func encode( to encoder : Encoder ) throws
    {
        
    }
    
    init()
    {
        self.id = String()
    }
    
}

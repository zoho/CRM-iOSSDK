//
//  ZCacheSectionOps.swift
//  ZCacheiOS
//
//  Created by Rajarajan K on 26/11/20.
//

import Foundation

@available(iOS 12.0, *)
public class ZCacheSectionOps: ZCacheSection {
    
    public var id: String?
    
    public var apiName: String
    
    var apiOps: ZCacheSection?
    
    private var metaDbHandler = MetaDBHandler()
    
    private let isDataCachingEnabled: Bool = ZCache.shared.configs.isDBCachingEnabled
    
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
        // Getting fields from cache
        let field: T? = metaDbHandler.fetchSectionField(id: id, sectionName: apiName)
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
                            
                            // Inserting modules into cache
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertSectionField(sectionName: self.apiName, field: field)
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
        let fields: [T] = metaDbHandler.fetchSectionFields(sectionName: apiName)
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
                            
                            // Inserting modules into cache
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertSectionFields(sectionName: self.apiName, fields: fields)
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
                            
                            // Inserting modules into cache
                            if self.isDataCachingEnabled {
                                self.metaDbHandler.insertSectionFields(sectionName: self.apiName, fields: fields)
                            }
                        }
                    case .failure( let error ): completion( .failure( error ) )
                }
            }
        }
    }
    
    // intializer
    public init(apiOps: ZCacheSection)
    {
        self.id = apiOps.id
        self.apiName = apiOps.apiName
        self.apiOps = apiOps
    }
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case apiName
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
        self.apiName = String()
    }
    
}

//
//  ZCacheLayoutOps.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 26/11/20.
//

import Foundation

public class ZCacheLayoutOps: ZCacheLayout {
    public var id: String
    
    var apiOps: ZCacheLayout
    
    public func getSection<T: ZCacheSection>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        
    }
    
    public func getSectionFromServer<T: ZCacheSection>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        
    }
    
    public func getSections<T: ZCacheSection>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        
    }
    
    public func getSectionsFromServer<T: ZCacheSection>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        
    }
    
    public func getSectionsFromServer<T: ZCacheSection>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        
    }
    
    public func getField<T: ZCacheField>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
    
    }
    
    public func getFieldFromServer<T: ZCacheField>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        
    }
    
    public func getFields<T: ZCacheField>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        
    }
    
    public func getFieldsFromServer<T: ZCacheField>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        
    }
    
    public func getFieldsFromServer<T: ZCacheField>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        
    }

    public init(apiOps: ZCacheLayout)
    {
        self.apiOps = apiOps
        self.id = apiOps.id
    }
    
}

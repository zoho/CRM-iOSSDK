//
//  ZCacheSectionOps.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 26/11/20.
//

import Foundation

public class ZCacheSectionOps: ZCacheSection {
    
    public var id: String?
    
    public var apiName: String
    
    var apiOps: ZCacheSection
    
    public func getFields<T: ZCacheField>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        
    }
    
    public func getFieldsFromServer<T: ZCacheField>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        apiOps.getFieldsFromServer { (result: Result<[T], ZCacheError>) -> Void in
            switch result {
            case .success(let fields): do {

                for field in fields {
                    let data = getDataAsDictionary(entity: field)
                    if let data = data {
                        print(data)
                    }
                }
            
            }
            case .failure(let error): do {
                print(error)
            }
            }
        }
    }
    
    public func getFieldsFromServer<T: ZCacheField>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        
    }
    
    public init(apiOps: ZCacheSection)
    {
        self.id = apiOps.id
        self.apiName = apiOps.apiName
        self.apiOps = apiOps
    }
    
}

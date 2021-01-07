//
//  ZCacheSection.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 25/11/20.
//

import Foundation

public protocol ZCacheSection: ZCacheEntity
{
    var id: String?
    {
        get
        set
    }
    
    var apiName: String
    {
        get
        set
    }
    
    func getFieldFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))

    func getFieldsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))

    func getFieldsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
}

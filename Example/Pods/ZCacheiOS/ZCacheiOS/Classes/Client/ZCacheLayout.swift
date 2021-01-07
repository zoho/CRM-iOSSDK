//
//  ZCacheLayout.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 25/11/20.
//

import Foundation

public protocol ZCacheLayout: ZCacheEntity
{
    var id: String
    {
        get
        set
    }
    
    // Section contracts
    func getSectionFromServer<T>(name: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))

    func getSectionsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))

    func getSectionsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))

    // Field contracts
    func getFieldFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))

    func getFieldsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))

    func getFieldsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
}

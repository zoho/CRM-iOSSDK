//
//  ZCacheSection.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 25/11/20.
//

import Foundation

public protocol ZCacheSection {
    
    var id: String? { get set }
    
    var apiName: String { get set }
    
    func getFields<T: ZCacheField>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))

    func getFieldsFromServer<T: ZCacheField>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))

    func getFieldsFromServer<T: ZCacheField>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
}

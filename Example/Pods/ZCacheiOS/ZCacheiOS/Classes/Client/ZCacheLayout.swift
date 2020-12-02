//
//  ZCacheLayout.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 25/11/20.
//

import Foundation

public protocol ZCacheLayout {
    var id: String { get set }
    
    // Section contracts
    func getSection<T: ZCacheSection>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))

    func getSectionFromServer<T: ZCacheSection>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))

    func getSections<T: ZCacheSection>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))

    func getSectionsFromServer<T: ZCacheSection>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))

    func getSectionsFromServer<T: ZCacheSection>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))

    // Field contracts
    
    func getField<T: ZCacheField>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))

    func getFieldFromServer<T: ZCacheField>(withId: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))

    func getFields<T: ZCacheField>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))

    func getFieldsFromServer<T: ZCacheField>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))

    func getFieldsFromServer<T: ZCacheField>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
}

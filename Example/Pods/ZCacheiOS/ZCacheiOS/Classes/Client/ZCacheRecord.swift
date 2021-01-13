//
//  ZCacheRecord.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 25/11/20.
//

import Foundation

public protocol ZCacheRecord: ZCacheEntity
{
    var id: String
    {
        get
        set
    }
    var moduleName: String
    {
        get
        set
    }
    var layoutId: String?
    {
        get
        set
    }
    var offlineOwner: ZCacheUser?
    {
        get
        set
    }
    var offlineCreatedTime: String?
    {
        get
        set
    }
    var offlineCreatedBy: ZCacheUser?
    {
        get
        set
    }
    var offlineModifiedTime: String?
    {
        get
        set
    }
    var offlineModifiedBy: ZCacheUser?
    {
        get
        set
    }
    
    //Record contracts
    func create< T >(completion: @escaping (DataResponseCallback<ZCacheResponse, T>) -> Void)
    
    func update< T >(completion: @escaping (DataResponseCallback<ZCacheResponse, T>) -> Void)
    
    func delete(completion: @escaping (DataResponseCallback<ZCacheResponse, String>) -> Void)
    
    func reset< T >(completion: @escaping (DataResponseCallback<ZCacheResponse, T>) -> Void)
    
}

//
//  ZCacheEntityInfo.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 04/01/21.
//

import Foundation

public struct ZCacheEntityInfo: ZCacheEntityResponse
{
    public var id: String
    
    public var apiStatus: Status
    
    public var code: String
    
    public var message: String
    
    public var details: [String: Any]
    
    public var zCacheEntity: ZCacheEntity?
}

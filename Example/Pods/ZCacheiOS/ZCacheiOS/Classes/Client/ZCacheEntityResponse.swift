//
//  ZCacheEntityResponse.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 04/01/21.
//

import Foundation

public protocol ZCacheEntityResponse
{
    var id: String
    {
        get
        set
    }
    var apiStatus: Status
    {
        get
        set
    }
    var code: String
    {
        get
        set
    }
    var message: String
    {
        get
        set
    }
    var details: [String: Any]
    {
        get
        set
    }
    var zCacheEntity: ZCacheEntity?
    {
        get
        set
    }
}

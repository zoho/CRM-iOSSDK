//
//  ZCacheUserOps.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 11/12/20.
//

import Foundation

class ZCacheUserOps: ZCacheUser
{
    var id: String
    
    var moduleName: String
    
    var orgId: String?
    
    public init(apiOps: ZCacheUser)
    {
        self.id = apiOps.id
        self.moduleName = apiOps.moduleName
        self.orgId = apiOps.orgId
    }
    
    init()
    {
        self.id = String()
        self.moduleName = String()
    }
}

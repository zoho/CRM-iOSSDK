//
//  ZCacheField.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 25/11/20.
//

import Foundation

public protocol ZCacheField: ZCacheEntity
{
    var id: String
    {
        get
        set
    }
    
    var apiName: String
    {
        get
        set
    }
    
    var type: DataType
    {
        get
        set
    }

    var lookupModules: [String]
    {
        get
        set
    }

    var constraintType: ConstraintType?
    {
        get
        set
    }
}

extension ZCacheField
{
//    func shouldProcessLookUps(<#parameters#>) -> <#return type#> {
//        <#function body#>
//    }
}

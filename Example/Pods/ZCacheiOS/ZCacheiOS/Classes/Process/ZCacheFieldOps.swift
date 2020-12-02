//
//  ZCacheFieldOps.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 26/11/20.
//

import Foundation

public class ZCacheFieldOps: ZCacheField {
    public var id: String

    public var apiName: String

    public var type: DataType

    public var lookupModules: [String]

    public var constraintType: ConstraintType?

    init() {
        self.id = String()
        self.apiName = String()
        self.type = DataType.text
        self.lookupModules = []
        self.constraintType = nil
    }
    
    public init(apiOps: ZCacheField) {
        self.id = apiOps.id
        self.apiName = apiOps.apiName
        self.type = apiOps.type
        self.lookupModules = apiOps.lookupModules
        self.constraintType = apiOps.constraintType
    }
    
    enum CodingKeys: String, CodingKey
    {
       case id = "id"
    }
    
    public required convenience init( from decoder : Decoder ) throws
    {
        self.init()
    }
    
    public func encode( to encoder : Encoder ) throws
    {
        
    }

}

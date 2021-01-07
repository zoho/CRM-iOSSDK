//
//  ZCacheFieldOps.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 26/11/20.
//

import Foundation

public class ZCacheFieldOps: ZCacheField
{
    public var id: String

    public var apiName: String

    public var type: DataType

    public var lookupModules: [String]

    public var constraintType: ConstraintType?
    
    func shouldIgnoreLookUp() -> Bool
    {
        var ignoreLookUp = false
        if (self.type.rawValue.contains("LOOKUP"))
        {
            ignoreLookUp = true
        }
        return ignoreLookUp
    }

    init()
    {
        self.id = String()
        self.apiName = String()
        self.type = DataType.text
        self.lookupModules = []
        self.constraintType = nil
    }
    
    public init(apiOps: ZCacheField)
    {
        self.id = apiOps.id
        self.apiName = apiOps.apiName
        self.type = apiOps.type
        self.lookupModules = apiOps.lookupModules
        self.constraintType = apiOps.constraintType
    }
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case apiName
        case type
        case lookupModules
        case constraintType
    }
    
    public required convenience init( from decoder : Decoder ) throws
    {
        self.init()
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        id = try! container.decode(String.self, forKey: .id)
        type = try! container.decode(DataType.self, forKey: .id)
        lookupModules = try! container.decode([String].self, forKey: .id)
        constraintType = try! container.decodeIfPresent(ConstraintType.self, forKey: .id)
    }
    
    public func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        try! container.encode(self.id, forKey: .id)
        try! container.encode(self.type, forKey: .type)
        try! container.encode(self.lookupModules, forKey: .lookupModules)
        try! container.encodeIfPresent(self.constraintType, forKey: .constraintType)
        try! container.encode(self.apiName, forKey: .apiName)
    }

}

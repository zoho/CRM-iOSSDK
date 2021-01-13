//
//  ZCacheEntity.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 09/12/20.
//

import Foundation

public protocol ZCacheEntity: Codable {
    
}

extension ZCacheEntity {
    
    public func toDicitionary() -> [String : Any]?
    {
        var dicitionary: [String : Any]?
        do {
            let data = try JSONEncoder().encode(self)
            dicitionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [ String : Any ]
        } catch let error {
            ZCacheLogger.logError(message: error.description)
        }
        return dicitionary
    }
    
    public func toData( jsonString : String ) -> Self? {
        do {
            return try JSONDecoder().decode(Self.self, from: Data(jsonString.utf8))
        } catch let error {
            ZCacheLogger.logError(message: error.description)
            return nil
        }
    }
}

extension Data
{
    func decode<T: Decodable>(type: T.Type = T.self) -> T?
    {
        return try? JSONDecoder().decode(T.self, from: self)
    }
}

//
//  ZCRMLayoutDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 13/09/18.
//
import ZCacheiOS

open class ZCRMLayoutDelegate : ZCRMEntity, ZCacheLayout
{
    public var id: String
    public internal( set ) var name : String
    
    internal init( id : String, name : String )
    {
        self.id = id
        self.name = name
    }
    
    enum Keys: String, CodingKey
    {
        case id
        case name
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
    open func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : Keys.self )
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
    }
    
    public func getSectionFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        
    }
    
    public func getSectionsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        
    }
    
    public func getSectionsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
       
    }
    
    public func getFieldFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        
    }
    
    public func getFieldsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        
    }
    
    public func getFieldsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        
    }
}

extension ZCRMLayoutDelegate : Hashable
{
    public static func == (lhs: ZCRMLayoutDelegate, rhs: ZCRMLayoutDelegate) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.name == rhs.name
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

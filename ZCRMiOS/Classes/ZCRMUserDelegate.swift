//
//  ZCRMUserDelegate.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 16/09/18.
//
import ZCacheiOS

open class ZCRMUserDelegate : ZCRMEntity, ZCacheUser
{
    enum Keys: String, CodingKey
    {
        case name
        case id
    }
    required public init(from decoder: Decoder) throws {
        let container = try! decoder.container(keyedBy: Keys.self)
        id = try! container.decode(String.self, forKey: .id)
        name = try! container.decode(String.self, forKey: .name)
    }
    open func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : Keys.self )
        try! container.encode(self.id, forKey: .id)
        try! container.encode(self.name, forKey: .name)
    }
    
    public var id: String
    
    public var moduleName: String = "USERS"
    
    public var orgId: String?
    
    public var name : String
    
    internal init( id : String, name : String )
    {
        self.id = id
        self.name = name
    }
    
    public func delete( completion : @escaping( ResultType.Response< APIResponse > ) -> () )
    {
        UserAPIHandler().deleteUser( userId : self.id ) { ( result ) in
            completion( result )
        }
    }
    
}

extension ZCRMUserDelegate : Hashable
{
    public static func == (lhs: ZCRMUserDelegate, rhs: ZCRMUserDelegate) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.name == rhs.name
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

let USER_MOCK : ZCRMUserDelegate = ZCRMUserDelegate( id : APIConstants.STRING_MOCK, name : APIConstants.STRING_MOCK )

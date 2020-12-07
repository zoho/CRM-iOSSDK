//
//  ZCRMProfileDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 13/09/18.
//

open class ZCRMProfileDelegate : ZCRMEntity, Codable
{
    public internal( set ) var id : Int64
    public internal( set ) var name : String
    public internal( set ) var isDefault : Bool = APIConstants.BOOL_MOCK
    
    internal init( id : Int64, name : String, isDefault : Bool )
    {
        self.id = id
        self.name = name
        self.isDefault = isDefault
    }
    
    internal init( id : Int64, name : String )
    {
        self.id = id
        self.name = name
    }
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case name
        case isDefault
    }
    
    public required init( from decoder : Decoder ) throws
    {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        id = try! values.decode(Int64.self, forKey: .id)
        name = try! values.decode(String.self, forKey: .name)
        isDefault = try! values.decode(Bool.self, forKey: .isDefault)
    }
    
    public func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        try! container.encode(self.id, forKey: .id)
        try! container.encode(self.name, forKey: .name)
        try! container.encode(self.isDefault, forKey: .isDefault)
    }
}

extension ZCRMProfileDelegate : Hashable
{
    public static func == (lhs: ZCRMProfileDelegate, rhs: ZCRMProfileDelegate) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.isDefault == rhs.isDefault
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

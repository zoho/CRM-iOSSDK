//
//  ZCRMTax.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 10/05/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

open class ZCRMTax : ZCRMTaxDelegate
{
    public internal( set ) var id : Int64
    public var displayName : String = APIConstants.STRING_MOCK
    public var percentage : Double = APIConstants.DOUBLE_MOCK
    internal var isCreate : Bool = APIConstants.BOOL_MOCK
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case displayName
        case percentage
        case isCreate
    }
    
    required public init(from decoder: Decoder) throws
    {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        id = try! values.decode(Int64.self, forKey: .id)
        displayName = try! values.decode(String.self, forKey: .displayName)
        percentage = try! values.decode(Double.self, forKey: .percentage)
        isCreate = try! values.decode(Bool.self, forKey: .isCreate)
        try super.init(from: decoder)
    }
    
    open override func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        try container.encode( self.id, forKey : .id )
        try container.encode( self.displayName, forKey : .displayName )
        try container.encode( self.percentage, forKey : .percentage )
        try container.encode( self.isCreate, forKey : .isCreate )
    }
    
    internal init( id : Int64)
    {
        self.id = id
        super.init(name: APIConstants.STRING_MOCK)
    }
    
    init( id : Int64, name : String )
    {
        self.id = id
        super.init( name : name )
    }
    
    init( name : String, percentage : Double )
    {
        self.id = APIConstants.INT64_MOCK
        self.percentage = percentage
        self.isCreate = true
        super.init( name : name )
    }
}

extension ZCRMTax : Hashable
{
    public static func == (lhs: ZCRMTax, rhs: ZCRMTax) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.percentage == rhs.percentage &&
            lhs.displayName == rhs.displayName
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

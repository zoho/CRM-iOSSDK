//
//  ZCRMLineTax.swift
//  ZCRMiOS
//
//  Created by Umashri R on 20/06/19.
//

open class ZCRMLineTax : ZCRMEntity, Codable
{
    enum CodingKeys: String, CodingKey
    {
        case name
        case percentage
        case value
        case isValueSet
    }
    required public init(from decoder: Decoder) throws
    {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        
        name = try! values.decode(String.self, forKey: .name)
        percentage = try! values.decode(Double.self, forKey: .percentage)
        value = try! values.decode(Double.self, forKey: .value)
        isValueSet = try! values.decode(Bool.self, forKey: .isValueSet)
    }
    open func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        
        try container.encode( self.name, forKey : CodingKeys.name )
        try container.encode( self.percentage, forKey : CodingKeys.percentage )
        try container.encode( self.value, forKey : CodingKeys.value )
        try container.encode( self.isValueSet, forKey : CodingKeys.isValueSet )
    }
    
    public var name : String
    public var percentage : Double
    public var value : Double = APIConstants.DOUBLE_MOCK{
        didSet
        {
            self.isValueSet = true
        }
    }
    internal var isValueSet : Bool = APIConstants.BOOL_MOCK
    
    public init( name : String, percentage : Double )
    {
        self.name = name
        self.percentage = percentage
    }
}

extension ZCRMLineTax : Hashable
{
    public static func == (lhs: ZCRMLineTax, rhs: ZCRMLineTax) -> Bool {
        let equals : Bool = lhs.name == rhs.name &&
            lhs.percentage == rhs.percentage &&
            lhs.value == rhs.value
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( name )
        hasher.combine( percentage )
    }
}

//
//  ZCRMTaxDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 24/06/19.
//

open class ZCRMTaxDelegate : ZCRMEntity, Codable
{
    enum CodingKeys: String, CodingKey
    {
        case name
    }
    required public init(from decoder: Decoder) throws
    {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        name = try! values.decode(String.self, forKey: .name)
    }
    open func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        try container.encode( self.name, forKey : CodingKeys.name )
    }
    
    public var name : String
    
    init( name : String ) {
        self.name = name
    }
}

extension ZCRMTaxDelegate : Equatable
{
    public static func == (lhs: ZCRMTaxDelegate, rhs: ZCRMTaxDelegate) -> Bool {
        let equals : Bool = lhs.name == rhs.name
        return equals
    }
}

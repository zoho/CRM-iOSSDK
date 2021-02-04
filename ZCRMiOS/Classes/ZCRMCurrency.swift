//
//  ZCRMCurrency.swift
//  ZCRMiOS
//
//  Created by Umashri R on 12/08/19.
//

open class ZCRMCurrency : ZCRMEntity
{
    public var symbol : String
    public internal( set ) var createdTime : String?
    public var isActive : Bool = true
    public var exchangeRate : Double?
    public var format : Format?
    public internal( set ) var createdBy : ZCRMUserDelegate?
    public var prefixSymbol : Bool?
    public internal( set ) var isBase : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var modifiedTime : String?
    public internal( set ) var name : String
    public internal( set ) var modifiedBy : ZCRMUserDelegate?
    public internal( set ) var id : Int64?
    public internal( set ) var isoCode : String
    
    internal init( name : String, symbol : String, isoCode : String )
    {
        self.name = name
        self.symbol = symbol
        self.isoCode = isoCode
    }
    
    
    public struct Format : Hashable
    {
        public internal( set ) var decimalSeparator : String
        public internal( set ) var thousandSeparator : String
        public internal( set ) var decimalPlaces : Int
    }
    
    
    internal enum Separator: String {
        case comma = "Comma"
        case period = "Period"
        case space = "Space"
        
        static func get(forValue value : String) throws -> String {
            guard let symbol = Separator(rawValue: value)?.getSymbol else {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : The Given Value Seems To Be Invalid")
                throw ZCRMError.inValidError( code : ErrorCode.invalidData, message : "The Given Value Seems To Be Invalid", details : nil )
            }
            return symbol
        }
        
        var getSymbol : String {
            switch self {
            case .comma:
                return ","
            case .period:
                return "."
            case .space:
                return " "
            }
        }
    }
    
    public func add( completion : @escaping ( CRMResultType.DataResponse< ZCRMCurrency, APIResponse > ) -> ())
    {
        OrgAPIHandler().addCurrency( self ) { result in
            completion( result )
        }
    }
    
    public func update( completion : @escaping ( CRMResultType.DataResponse< ZCRMCurrency, APIResponse > ) -> () )
    {
        if isBase == true
        {
            OrgAPIHandler().updateBaseCurrency( self ) { result in
                completion( result )
            }
        }
        else
        {
            OrgAPIHandler().updateCurrency( self ) { result in
                completion( result )
            }
        }
    }
}

extension ZCRMCurrency : Hashable
{
    public static func == (lhs: ZCRMCurrency, rhs: ZCRMCurrency) -> Bool {
        return lhs.createdBy == rhs.createdBy &&
            lhs.createdTime == rhs.createdTime &&
            lhs.exchangeRate == rhs.exchangeRate &&
            lhs.format == rhs.format &&
            lhs.id == rhs.id &&
            lhs.isActive == rhs.isActive &&
            lhs.isBase == rhs.isBase &&
            lhs.isoCode == rhs.isoCode &&
            lhs.modifiedBy == rhs.modifiedBy &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.symbol == rhs.symbol &&
            lhs.prefixSymbol == rhs.prefixSymbol &&
            lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
        hasher.combine( isoCode )
    }
}

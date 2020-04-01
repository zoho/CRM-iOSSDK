//
//  ZCRMCurrency.swift
//  ZCRMiOS
//
//  Created by Umashri R on 12/08/19.
//

open class ZCRMCurrency : ZCRMEntity
{
    public internal( set ) var symbol : String
    public internal( set ) var createdTime : String?
    public internal( set ) var isActive : Bool?
    public internal( set ) var exchangeRate : Double?
    public internal( set ) var format : Format?
    public internal( set ) var createdBy : ZCRMUserDelegate?
    public internal( set ) var prefixSymbol : Bool?
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
    
    
    public struct Format
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
}

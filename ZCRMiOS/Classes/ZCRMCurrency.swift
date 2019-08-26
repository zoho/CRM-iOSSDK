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
}

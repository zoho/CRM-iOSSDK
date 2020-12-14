//
//  ZCRMInventoryLineItem.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 16/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMInventoryLineItem : ZCRMEntity, Codable
{
    enum CodingKeys: String, CodingKey
    {
        case id
        case product
        case listPrice
        case isListPriceSet
        case unitPrice
        case quantity
        case description
        case total
        case discount
        case discountPercentage
        case totalAfterDiscount
        case tax
        case lineTaxes
        case netTotal
        case deleteFlag
        case priceBookId
        case quantityInStock
    }
    required public init(from decoder: Decoder) throws
    {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        
        id = try! values.decode(Int64.self, forKey: .id)
        product = try! values.decode(ZCRMRecordDelegate.self, forKey: .product)
        listPrice = try! values.decode(Double.self, forKey: .listPrice)
        isListPriceSet = try! values.decode(Bool.self, forKey: .isListPriceSet)
        unitPrice = try! values.decode(Double.self, forKey: .unitPrice)
        quantity = try! values.decode(Double.self, forKey: .quantity)
        description = try! values.decodeIfPresent(String.self, forKey: .description)
        total = try! values.decode(Double.self, forKey: .total)
        discount = try! values.decode(Double.self, forKey: .discount)
        discountPercentage = try! values.decodeIfPresent(Double.self, forKey: .discountPercentage)
        totalAfterDiscount = try! values.decode(Double.self, forKey: .totalAfterDiscount)
        tax = try! values.decode(Double.self, forKey: .tax)
        lineTaxes = try! values.decode([ ZCRMLineTax ].self, forKey: .lineTaxes)
        netTotal = try! values.decode(Double.self, forKey: .netTotal)
        deleteFlag = try! values.decode(Bool.self, forKey: .deleteFlag)
        priceBookId = try! values.decodeIfPresent(Int64.self, forKey: .priceBookId)
        quantityInStock = try! values.decode(Double.self, forKey: .quantityInStock)
    }
    open func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        
        try container.encode( self.id, forKey : CodingKeys.id )
        try container.encode( self.product, forKey : CodingKeys.product )
        try container.encode( self.listPrice, forKey : CodingKeys.listPrice )
        try container.encode( self.isListPriceSet, forKey : CodingKeys.isListPriceSet )
        try container.encode( self.unitPrice, forKey : CodingKeys.unitPrice )
        try container.encode( self.quantity, forKey : CodingKeys.quantity )
        try container.encode( self.description, forKey : CodingKeys.description )
        try container.encode( self.total, forKey : CodingKeys.total )
        try container.encode( self.discount, forKey : CodingKeys.discount )
        try container.encode( self.discountPercentage, forKey : CodingKeys.discountPercentage )
        try container.encode( self.totalAfterDiscount, forKey : CodingKeys.totalAfterDiscount )
        try container.encode( self.tax, forKey : CodingKeys.tax )
        try container.encode( self.lineTaxes, forKey : CodingKeys.lineTaxes )
        try container.encode( self.netTotal, forKey : CodingKeys.netTotal )
        try container.encode( self.deleteFlag, forKey : CodingKeys.deleteFlag )
        try container.encode( self.priceBookId, forKey : CodingKeys.priceBookId )
        try container.encode( self.quantityInStock, forKey : CodingKeys.quantityInStock )
    }
    
    public var product : ZCRMRecordDelegate = RECORD_MOCK
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    public var listPrice : Double = APIConstants.DOUBLE_MOCK{
        didSet
        {
            self.isListPriceSet = true
        }
    }
    internal var isListPriceSet : Bool = APIConstants.BOOL_MOCK
    public var unitPrice : Double = APIConstants.DOUBLE_MOCK
    public var quantity : Double = APIConstants.DOUBLE_MOCK
    public var description : String?
    public var total : Double = APIConstants.DOUBLE_MOCK
    public var discount : Double = 0.0
    public var discountPercentage : Double?
    public var totalAfterDiscount : Double = APIConstants.DOUBLE_MOCK
    public var tax : Double = APIConstants.DOUBLE_MOCK
    public var lineTaxes : [ ZCRMLineTax ] = [ ZCRMLineTax ]()
    public var netTotal : Double = APIConstants.DOUBLE_MOCK
    public var deleteFlag : Bool = APIConstants.BOOL_MOCK
    public var priceBookId : Int64?
    public var quantityInStock : Double = APIConstants.DOUBLE_MOCK
    
    
    /// Initialise the instance of a ZCRMInventoryLineItem with the given record.
    ///
    /// - Parameter product: record for which ZCRMInventoryLineItem instance is to be initialised
    public init( product : ZCRMRecordDelegate, quantity : Double )
    {
        self.product = product
        self.quantity = quantity
    }
    
    /// Initialise the instance of a ZCRMInventoryLineItem with the given record and line item ID.
    ///
    /// - Parameters:
    ///   - lineItemId: Id to get that ZCRMInventoryLineItem instance
    internal init(id : Int64)
    {
        self.id = id
    }
    
    /// Add tax to the ZCRMInventoryLineItem.
    ///
    /// - Parameter tax: ZCRMTax for the ZCRMInventoryLineItem
    public func addLineTax(tax : ZCRMLineTax)
    {
        self.lineTaxes.append( tax )
    }
}

extension ZCRMInventoryLineItem : Hashable
{
    public static func == (lhs: ZCRMInventoryLineItem, rhs: ZCRMInventoryLineItem) -> Bool {
        let equals : Bool = lhs.product == rhs.product &&
            lhs.id == rhs.id &&
            lhs.listPrice == rhs.listPrice &&
            lhs.quantity == rhs.quantity &&
            lhs.description == rhs.description &&
            lhs.total == rhs.total &&
            lhs.discount == rhs.discount &&
            lhs.discountPercentage == rhs.discountPercentage &&
            lhs.totalAfterDiscount == rhs.totalAfterDiscount &&
            lhs.tax == rhs.tax  &&
            lhs.lineTaxes == rhs.lineTaxes &&
            lhs.netTotal == rhs.netTotal &&
            lhs.unitPrice == rhs.unitPrice
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

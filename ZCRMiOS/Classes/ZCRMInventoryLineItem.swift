//
//  ZCRMInventoryLineItem.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 16/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMInventoryLineItem : ZCRMEntity
{
	public var product : ZCRMRecordDelegate = RECORD_DELEGATE_MOCK
	public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    public var listPrice : Double = APIConstants.DOUBLE_MOCK{
        didSet
        {
            self.isListPriceSet = true
        }
    }
    internal var isListPriceSet : Bool = APIConstants.BOOL_MOCK
    public var unitPrice : Double?
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
    public var quantityInStock : Double?
    
    func copy() -> ZCRMInventoryLineItem
    {
        let copyObj = ZCRMInventoryLineItem(id: id)
        copyObj.product = product.copy()
        copyObj.listPrice = listPrice
        copyObj.isListPriceSet = isListPriceSet
        copyObj.unitPrice = unitPrice
        copyObj.quantity = quantity
        copyObj.description = description
        copyObj.total = total
        copyObj.discount = discount
        copyObj.discountPercentage = discountPercentage
        copyObj.totalAfterDiscount = totalAfterDiscount
        copyObj.tax = tax
        copyObj.lineTaxes = lineTaxes.copy()
        copyObj.netTotal = netTotal
        copyObj.deleteFlag = deleteFlag
        copyObj.priceBookId = priceBookId
        copyObj.quantityInStock = quantityInStock
        return copyObj
    }
	
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
            lhs.unitPrice == rhs.unitPrice &&
            lhs.quantityInStock == rhs.quantityInStock &&
            lhs.deleteFlag == rhs.deleteFlag &&
            lhs.isListPriceSet == rhs.isListPriceSet &&
            lhs.priceBookId == rhs.priceBookId
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

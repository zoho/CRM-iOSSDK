//
//  ZCRMInventoryLineItem.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 16/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMInventoryLineItem
{
	private var product : ZCRMRecord
	private var id : Int64?
	private var listPrice : Double = 0.0
	private var quantity : Double = 1.0
	private var description : String?
	private var total : Double = 0.0
	private var discount : Double = 0.0
	private var discountPercentage : Double = 0.0
	private var totalAfterDiscount : Double = 0.0
	private var tax : Double = 0.0
	private var lineTaxes : [String:ZCRMTax] = [String:ZCRMTax]()
	private var netTotal : Double = 0.0
	private var deleteFlag : Bool = false
	
    /// Initialise the instance of a ZCRMInventoryLineItem with the given record.
    ///
    /// - Parameter product: record for which ZCRMInventoryLineItem instance is to be initialised
	public init(product : ZCRMRecord)
	{
		self.product = product
	}
	
    /// Initialise the instance of a ZCRMInventoryLineItem with the given record and line item ID.
    ///
    /// - Parameters:
    ///   - lineItemId: Id to get that ZCRMInventoryLineItem instance
    ///   - product: record for which ZCRMInventoryLineItem instance is to be initialised
	public init(lineItemId : Int64, product : ZCRMRecord)
	{
		self.product = product
		self.id = lineItemId
	}
	
    /// Returns record of the ZCRMInventoryLineItem.
    ///
    /// - Returns: record of the ZCRMInventoryLineItem
	public func getProduct() -> ZCRMRecord
	{
		return self.product
	}
	
    /// Returns Id of the ZCRMInventoryLineItem.
    ///
    /// - Returns: Id of the ZCRMInventoryLineItem
	public func getId() -> Int64?
	{
		return self.id
	}
	
    /// Set the list price of the Product.
    ///
    /// - Parameter listPrice: list price of the product
	public func setListPrice(listPrice : Double)
	{
		self.listPrice = listPrice
	}
	
    /// Returns the list price of the Product.
    ///
    /// - Returns: the list price of the Product
	public func getListPrice() -> Double
	{
		return self.listPrice
	}
	
    /// Set the list quantity of the Product.
    ///
    /// - Parameter quantity: the list quantity of the Product
	public func setQuantity(quantity : Double)
	{
		self.quantity = quantity
	}
	
    /// Returns the list quantity of the Product.
    ///
    /// - Returns: the list quantity of the Product
	public func getQuantity() -> Double
	{
		return self.quantity
	}
	
    /// Set the description of the ZCRMInventoryLineItem.
    ///
    /// - Parameter description: description of the ZCRMInventoryLineItem
	public func setDescription(description : String?)
	{
		self.description = description
	}
	
    /// Retruns the description of the ZCRMInventoryLineItem.
    ///
    /// - Returns: the description of the ZCRMInventoryLineItem
	public func getDescription() -> String?
	{
		return self.description
	}
	
    /// Set the total amount of ZCRMInventoryLineItem.
    ///
    /// - Parameter total: total amount of ZCRMInventoryLineItem
	internal func setTotal(total : Double)
	{
		self.total = total
	}
	
    /// Returns the total amount of ZCRMInventoryLineItem.
    ///
    /// - Returns: the total amount of ZCRMInventoryLineItem
	public func getTotal() -> Double
	{
		return self.total
	}
	
    /// Set the discount for the ZCRMInventoryLineItem.
    ///
    /// - Parameter discount: discount for the ZCRMInventoryLineItem
	public func setDiscount(discount : Double)
	{
		self.discount = discount
		self.discountPercentage = 0.0
	}
	
    /// Returns the discount for the ZCRMInventoryLineItem.
    ///
    /// - Returns: the discount for the ZCRMInventoryLineItem
	public func getDiscount() -> Double
	{
		return self.discount
	}
	
    /// Set the discount percentage of the ZCRMInventoryLineItem.
    ///
    /// - Parameter discount: discount percentage of the ZCRMInventoryLineItem
	public func setDiscountPercentage(discPc : Double)
	{
		self.discountPercentage = discPc
		self.discount = 0.0
	}
	
    /// Returns the discount percentage of the ZCRMInventoryLineItem.
    ///
    /// - Returns: the discount percentage of the ZCRMInventoryLineItem
	public func getDiscountPercentage() -> Double
	{
		return self.discountPercentage
	}
	
    /// Set the total amount of the ZCRMInventoryLineItem after discount.
    ///
    /// - Parameter totAftDisc: total amount of the ZCRMInventoryLineItem after discount
	internal func setTotalAfterDiscount(totAftDisc : Double)
	{
		self.totalAfterDiscount = totAftDisc
	}
	
    /// Returns the total amount of the ZCRMInventoryLineItem after discount.
    ///
    /// - Returns: the total amount of the ZCRMInventoryLineItem after discount
	public func getTotalAfterDiscount() -> Double
	{
		return self.totalAfterDiscount
	}
	
    /// Set the list of line tax to the ZCRMInventoryLineItem.
    ///
    /// - Parameter allTaxes: list of line tax
	internal func setLineTaxDetails(allTaxes : [String:ZCRMTax])
	{
		self.lineTaxes = allTaxes
	}
	
    /// Returns the list of ZCRMTax for the ZCRMInventoryLineItem.
    ///
    /// - Returns: the list of ZCRMTax for the ZCRMInventoryLineItem
	public func getLineTaxDetails() -> [ZCRMTax]
	{
		return Array(self.lineTaxes.values)
	}
	
    /// Add tax to the ZCRMInventoryLineItem.
    ///
    /// - Parameter tax: ZCRMTax for the ZCRMInventoryLineItem
	public func addLineTax(tax : ZCRMTax)
	{
		self.lineTaxes[tax.getTaxName()] = tax
	}
	
    /// Set the tax amount.
    ///
    /// - Parameter tax: tax amount
	internal func setTaxValue(tax : Double)
	{
		self.tax = tax
	}
	
    /// Retruns the tax amount.
    ///
    /// - Returns: the tax amount
	public func getTaxValue() -> Double
	{
		return self.tax
	}
	
    /// Set the net total of ZCRMInventoryLineItem.
    ///
    /// - Parameter netTotal: net total of ZCRMInventoryLineItem
	internal func setNetTotal(netTotal : Double)
	{
		self.netTotal = netTotal
	}
	
    /// Returns the net total of ZCRMInventoryLineItem.
    ///
    /// - Returns: the net total of ZCRMInventoryLineItem
	public func getNetTotal() -> Double
	{
		return self.netTotal
	}
	
	internal func delete()
	{
		self.deleteFlag = true
	}
	
	internal func isDeleted() -> Bool
	{
		return self.deleteFlag
	}
}

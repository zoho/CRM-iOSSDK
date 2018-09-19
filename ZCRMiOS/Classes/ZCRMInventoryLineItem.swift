//
//  ZCRMInventoryLineItem.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 16/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMInventoryLineItem
{
	public var product : ZCRMRecordDelegate = RECORD_MOCK
	public var id : Int64 = APIConstants.INT64_MOCK
	public var listPrice : Double = APIConstants.DOUBLE_MOCK
	public var quantity : Double = APIConstants.DOUBLE_MOCK
	public var description : String?
	public var total : Double = APIConstants.DOUBLE_MOCK
	public var discount : Double = APIConstants.DOUBLE_MOCK
	public var discountPercentage : Double = APIConstants.DOUBLE_MOCK
	public var totalAfterDiscount : Double = APIConstants.DOUBLE_MOCK
	public var tax : Double = APIConstants.DOUBLE_MOCK
	public var lineTaxes : [ZCRMTax] = [ ZCRMTax ]()
	public var netTotal : Double = APIConstants.DOUBLE_MOCK
	public var deleteFlag : Bool = APIConstants.BOOL_MOCK
	
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
	internal init(lineItemId : Int64)
	{
		self.id = lineItemId
	}
	
    /// Add tax to the ZCRMInventoryLineItem.
    ///
    /// - Parameter tax: ZCRMTax for the ZCRMInventoryLineItem
	public func addLineTax(tax : ZCRMTax)
	{
		self.lineTaxes.append( tax )
	}
}

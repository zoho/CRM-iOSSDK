//
//  ZCRMField.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMField : ZCRMEntity
{
	public var apiName : String
	public var id : Int64 = APIConstants.INT64_MOCK
	public var displayLabel : String = APIConstants.STRING_MOCK
	public var type : String = APIConstants.STRING_MOCK
	public var readOnly : Bool = APIConstants.BOOL_MOCK
	public var visible : Bool = APIConstants.BOOL_MOCK
	public var mandatory : Bool?
	public var customField : Bool = APIConstants.BOOL_MOCK
	public var defaultValue : Any?
	public var maxLength : Int = APIConstants.INT_MOCK
	public var precision : Int?
	public var sequenceNo : Int?
	public var subLayoutsPresent : [String]?
	public var pickListValues : [ ZCRMPickListValue ]?
	public var formulaReturnType : String?
	public var formulaExpression : String?
    
    public var tooltip : String?
    public var webhook : Bool = APIConstants.BOOL_MOCK
    public var isRestricted : Bool?
    public var restrictedType : String?
    public var isSupportExport : Bool?
    public var createdSource : String = APIConstants.STRING_MOCK
    public var bussinessCardSupported : Bool?
    
    public var roundingOption : CurrencyRoundingOption?
    public var decimalPlace : Int?
    public var lookup : [String : Any]?
    public var multiSelectLookup : [String : Any]?
    public var subFormTabId : Int64?
    public var subForm : [String : Any]?
    
    init( apiName : String )
    {
        self.apiName = apiName
    }
	    
    /// Add the pick list value to the ZCRMField.
    ///
    /// - Parameter pickListValue: value to be added
    internal func addPickListValue( pickListValue : ZCRMPickListValue )
    {
        if self.pickListValues == nil
        {
            self.pickListValues = [ ZCRMPickListValue ]()
        }
        self.pickListValues?.append( pickListValue )
    }
	
    /// Returns true if view type includes "create".
    ///
    /// - Returns: true if view type includes "create"
	public func isPresentInCreateLayout() -> Bool?
	{
		return self.subLayoutsPresent?.contains("CREATE")
	}
	
    /// Returns true if view type includes "view".
    ///
    /// - Returns: true if view type includes "view"
	public func isPresentInViewLayout() -> Bool?
	{
		return self.subLayoutsPresent?.contains("VIEW")
	}
	
    /// Returns true if view type includes "quick create".
    ///
    /// - Returns: true if view type includes "quick create"
	public func isPresentInQuickCreateLayout() -> Bool?
	{
		return self.subLayoutsPresent?.contains("QUICK_CREATE")
	}
    
    /// Returns true if view type includes "edit".
    ///
    /// - Returns: true if view type includes "edit"
    public func isPresentInEditLayout() -> Bool?
    {
        return self.subLayoutsPresent?.contains("EDIT")
    }
}

//
//  ZCRMField.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMFieldDelegate : ZCRMEntity
{
    public internal( set ) var id : Int64
    public internal( set ) var displayLabel : String
    public internal( set ) var dataType : String
    public internal( set ) var isMandatory : Bool
    public internal( set ) var apiName : String
    public internal( set ) var module : ZCRMModuleDelegate = MODULE_DELEGATE_MOCK
    public internal( set ) var lookupModule : String?
    public internal( set ) var lookupDetail : ZCRMModuleRelationDelegate?
    public internal( set ) var pickListValues : [ ZCRMPickListValue ]?
    public internal( set ) var relatedDetails : ZCRMModuleRelationDelegate?
    public internal( set ) var criteria : ZCRMQuery.ZCRMCriteria?
    public internal( set ) var data : [ String : Any ] = [:]
    
    init( id : Int64, displayLabel : String, dataType : String, isMandatory : Bool, apiName : String = APIConstants.STRING_MOCK )
    {
        self.id = id
        self.displayLabel = displayLabel
        self.dataType = dataType
        self.isMandatory = isMandatory
        self.apiName = apiName
    }
    
    public func copy() -> ZCRMFieldDelegate {
        let fieldDelegate = ZCRMFieldDelegate(id: id, displayLabel: displayLabel, dataType: dataType, isMandatory: isMandatory)
        fieldDelegate.apiName = apiName
        fieldDelegate.module = module.copy()
        fieldDelegate.lookupModule = lookupModule
        fieldDelegate.lookupDetail = lookupDetail?.copy()
        fieldDelegate.pickListValues = pickListValues?.copy()
        fieldDelegate.relatedDetails = relatedDetails?.copy()
        fieldDelegate.criteria = criteria?.copy()
        fieldDelegate.data = data
        
        return fieldDelegate
    }
}

open class ZCRMField : ZCRMFieldDelegate
{
    public internal( set ) var isReadOnly : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isVisible : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isCustomField : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isHipaaComplianceEnabled : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isHippaExportRestricted : Bool = APIConstants.BOOL_MOCK
	public internal( set ) var defaultValue : Any?
    public internal( set ) var maxLength : Int?
	public internal( set ) var currencyPrecision : Int?
	public internal( set ) var sequenceNo : Int?
	public internal( set ) var subLayoutsPresent : [String]?
	public internal( set ) var formulaReturnType : String?
	public internal( set ) var formulaExpression : String?
    
    public internal( set ) var tooltip : String?
    public internal( set ) var webhook : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isRestricted : Bool?
    public internal( set ) var restrictedType : String?
    public internal( set ) var isExportable : Bool?
    public internal( set ) var createdSource : String = APIConstants.STRING_MOCK
    public internal( set ) var isBusinessCardSupported : Bool?
    
    public internal( set ) var roundingOption : ZCRMCurrencyRoundingOption?
    public internal( set ) var precision : Int?
    public internal( set ) var multiSelectLookup : [String : Any]?
    public internal( set ) var subFormTabId : Int64?
    public internal( set ) var subForm : [String : Any]?
    @available(*, deprecated, renamed: "isHyperlink")
    public internal( set ) var isDisplayField : Bool?
    public internal( set ) var isHyperlink : Bool?
    public internal( set ) var isSortable : Bool?
    public internal( set ) var isFilterable : Bool?
    public internal( set ) var isEncrypted : Bool = false
    init( apiName : String )
    {
        super.init(id: APIConstants.INT64_MOCK, displayLabel: APIConstants.STRING_MOCK, dataType: APIConstants.STRING_MOCK, isMandatory: APIConstants.BOOL_MOCK, apiName: apiName)
    }
    
    public override func copy() -> ZCRMFieldDelegate {
        let field = ZCRMField(apiName: apiName)
        field.id = id
        field.displayLabel = displayLabel
        field.dataType = dataType
        field.isMandatory = isMandatory
        field.apiName = apiName
        field.module = module.copy()
        field.lookupModule = lookupModule
        field.lookupDetail = lookupDetail?.copy()
        field.pickListValues = pickListValues?.copy()
        field.relatedDetails = relatedDetails?.copy()
        field.criteria = criteria?.copy()
        field.isReadOnly = isReadOnly
        field.isVisible = isVisible
        field.isCustomField = isCustomField
        field.isHipaaComplianceEnabled = isHipaaComplianceEnabled
        field.isHippaExportRestricted = isHippaExportRestricted
        field.defaultValue = defaultValue
        field.maxLength = maxLength
        field.currencyPrecision = currencyPrecision
        field.sequenceNo = sequenceNo
        field.subLayoutsPresent = subLayoutsPresent
        field.formulaReturnType = formulaReturnType
        field.formulaExpression = formulaExpression
        field.tooltip = tooltip
        field.webhook = webhook
        field.isRestricted = isRestricted
        field.restrictedType = restrictedType
        field.isExportable = isExportable
        field.createdSource = createdSource
        field.isBusinessCardSupported = isBusinessCardSupported
        field.roundingOption = roundingOption
        field.precision = precision
        field.multiSelectLookup = multiSelectLookup
        field.subForm = subForm
        field.isDisplayField = isDisplayField
        field.isHyperlink = isHyperlink
        field.isSortable = isSortable
        field.isFilterable = isFilterable
        field.isEncrypted = isEncrypted
        field.data = data
        
        return field
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

extension ZCRMField
{
    public static func == (lhs: ZCRMField, rhs: ZCRMField) -> Bool {
        var multiSelectLookupFlag : Bool
        var subformFlag : Bool
        if lhs.multiSelectLookup == nil && rhs.multiSelectLookup == nil
        {
            multiSelectLookupFlag = true
        }
        else if let lhsMultiSelectLookup = lhs.multiSelectLookup, let rhsMultiSelectLookup = rhs.multiSelectLookup
        {
            multiSelectLookupFlag = NSDictionary(dictionary: lhsMultiSelectLookup).isEqual(to: rhsMultiSelectLookup)
        }
        else
        {
            return false
        }
        if lhs.subForm == nil && rhs.subForm == nil
        {
            subformFlag = true
        }
        else if let lhsSubForm = lhs.subForm, let rhsSubForm = rhs.subForm
        {
            subformFlag = NSDictionary(dictionary: lhsSubForm).isEqual(to: rhsSubForm)
        }
        else
        {
            return false
        }
        let equals : Bool = lhs.apiName == rhs.apiName &&
            lhs.id == rhs.id &&
            lhs.displayLabel == rhs.displayLabel &&
            lhs.dataType == rhs.dataType &&
            lhs.isReadOnly == rhs.isReadOnly &&
            lhs.isVisible == rhs.isVisible &&
            lhs.isMandatory == rhs.isMandatory &&
            lhs.isCustomField == rhs.isCustomField &&
            lhs.maxLength == rhs.maxLength &&
            lhs.currencyPrecision == rhs.currencyPrecision &&
            lhs.sequenceNo == rhs.sequenceNo &&
            lhs.subLayoutsPresent == rhs.subLayoutsPresent &&
            lhs.pickListValues == rhs.pickListValues &&
            lhs.formulaReturnType == rhs.formulaReturnType &&
            lhs.formulaExpression == rhs.formulaExpression &&
            lhs.tooltip == rhs.tooltip &&
            lhs.webhook == rhs.webhook &&
            lhs.isRestricted == rhs.isRestricted &&
            lhs.restrictedType == rhs.restrictedType &&
            lhs.isExportable == rhs.isExportable &&
            lhs.createdSource == rhs.createdSource &&
            lhs.isBusinessCardSupported == rhs.isBusinessCardSupported &&
            lhs.roundingOption == rhs.roundingOption &&
            lhs.precision == rhs.precision &&
            lhs.lookupModule == rhs.lookupModule &&
            lhs.lookupDetail == rhs.lookupDetail &&
            lhs.relatedDetails == rhs.relatedDetails &&
            multiSelectLookupFlag &&
            lhs.subFormTabId == rhs.subFormTabId &&
            subformFlag &&
            isEqual( lhs : lhs.defaultValue, rhs : rhs.defaultValue ) &&
            lhs.isHipaaComplianceEnabled == rhs.isHipaaComplianceEnabled &&
            lhs.isHippaExportRestricted == rhs.isHippaExportRestricted &&
            lhs.module == rhs.module &&
            lhs.isDisplayField == rhs.isDisplayField &&
            lhs.isSortable == rhs.isSortable &&
            lhs.isFilterable == rhs.isFilterable &&
            lhs.isEncrypted == rhs.isEncrypted &&
            lhs.isHyperlink == rhs.isHyperlink
        return equals
    }
}

extension ZCRMFieldDelegate : Hashable
{
    public static func == (lhs: ZCRMFieldDelegate, rhs: ZCRMFieldDelegate) -> Bool {
        
        let equals : Bool = lhs.apiName == rhs.apiName &&
            lhs.id == rhs.id &&
        
            lhs.displayLabel == rhs.displayLabel &&
            lhs.dataType == rhs.dataType &&
            lhs.isMandatory == rhs.isMandatory &&
            lhs.pickListValues == rhs.pickListValues &&
            lhs.lookupModule == rhs.lookupModule &&
            lhs.lookupDetail == rhs.lookupDetail &&
            lhs.relatedDetails == rhs.relatedDetails &&
            lhs.module == rhs.module
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

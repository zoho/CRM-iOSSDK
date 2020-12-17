//
//  ZCRMField.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//
import ZCacheiOS

open class ZCRMField : ZCRMEntity, ZCacheField
{
    public var id: String = APIConstants.STRING_MOCK
    public var type: DataType = DataType.text
    public var lookupModules: [String] = []
    public var constraintType: ConstraintType?
    public var apiName : String
    
    public internal( set ) var displayLabel : String = APIConstants.STRING_MOCK
    public internal( set ) var dataType : String = APIConstants.STRING_MOCK
    public internal( set ) var isReadOnly : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isVisible : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isMandatory : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isCustomField : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var defaultValue : JSONValue?
    public internal( set ) var maxLength : Int?
    public internal( set ) var currencyPrecision : Int?
    public internal( set ) var sequenceNo : Int?
    public internal( set ) var subLayoutsPresent : [String]?
    public internal( set ) var pickListValues : [ ZCRMPickListValue ]?
    public internal( set ) var formulaReturnType : String?
    public internal( set ) var formulaExpression : String?
    
    public internal( set ) var tooltip : String?
    public internal( set ) var webhook : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isRestricted : Bool?
    public internal( set ) var restrictedType : String?
    public internal( set ) var isExportable : Bool?
    public internal( set ) var createdSource : String = APIConstants.STRING_MOCK
    public internal( set ) var isBusinessCardSupported : Bool?
    
    public internal( set ) var roundingOption : CurrencyRoundingOption?
    public internal( set ) var precision : Int?
    public internal( set ) var lookup : [String : JSONValue]?
    public internal( set ) var multiSelectLookup : [String : JSONValue]?
    public internal( set ) var subFormTabId : Int64?
    public internal( set ) var subForm : [String : JSONValue]?
    
    init( apiName : String )
    {
        self.apiName = apiName
    }
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case type
        case lookupModules
        case constraintType
        case apiName
        case displayLabel
        case dataType
        case isReadOnly
        case isVisible
        case isMandatory
        case isCustomField
        case defaultValue
        case maxLength
        case currencyPrecision
        case subLayoutsPresent
        case pickListValues
        case sequenceNo
        case formulaReturnType
        case formulaExpression
        case tooltip
        case webhook
        case isRestricted
        case restrictedType
        case isExportable
        case createdSource
        case isBusinessCardSupported
        case roundingOption
        case precision
        case lookup
        case multiSelectLookup
        case subFormTabId
        case subForm
    }
    required public init(from decoder: Decoder) throws {
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        
        id = try! container.decode(String.self, forKey: .id)
        type = try! container.decode(DataType.self, forKey: .type)
        lookupModules = try! container.decode([String].self, forKey: .lookupModules)
        constraintType = try! container.decodeIfPresent(ConstraintType.self, forKey: .constraintType)
        apiName = try! container.decode(String.self, forKey: .apiName)
        
        displayLabel = try! container.decode(String.self, forKey: .displayLabel)
        dataType = try! container.decode(String.self, forKey: .dataType)
        isReadOnly = try! container.decode(Bool.self, forKey: .isReadOnly)
        isVisible = try! container.decode(Bool.self, forKey: .isVisible)
        isMandatory = try! container.decode(Bool.self, forKey: .isMandatory)
        isCustomField = try! container.decode(Bool.self, forKey: .isCustomField)
        defaultValue = try! container.decodeIfPresent(JSONValue.self, forKey: .defaultValue)
        maxLength = try! container.decodeIfPresent(Int.self, forKey: .maxLength)
        currencyPrecision = try! container.decodeIfPresent(Int.self, forKey: .currencyPrecision)
        subLayoutsPresent = try! container.decodeIfPresent([String].self, forKey: .subLayoutsPresent)
        pickListValues = try! container.decodeIfPresent([ZCRMPickListValue].self, forKey: .pickListValues)
        sequenceNo = try! container.decodeIfPresent(Int.self, forKey: .sequenceNo)
        formulaReturnType = try! container.decodeIfPresent(String.self, forKey: .formulaReturnType)
        formulaExpression = try! container.decodeIfPresent(String.self, forKey: .formulaExpression)
        tooltip = try! container.decodeIfPresent(String.self, forKey: .tooltip)
        webhook = try! container.decode(Bool.self, forKey: .webhook)
        isRestricted = try! container.decodeIfPresent(Bool.self, forKey: .isRestricted)
        restrictedType = try! container.decodeIfPresent(String.self, forKey: .restrictedType)
        isExportable = try! container.decodeIfPresent(Bool.self, forKey: .isExportable)
        createdSource = try! container.decode(String.self, forKey: .createdSource)
        isBusinessCardSupported = try! container.decodeIfPresent(Bool.self, forKey: .isBusinessCardSupported)
        roundingOption = try! container.decodeIfPresent(CurrencyRoundingOption.self, forKey: .roundingOption)
        precision = try! container.decodeIfPresent(Int.self, forKey: .precision)
        lookup = try! container.decodeIfPresent([String: JSONValue].self, forKey: .lookup)
        multiSelectLookup = try! container.decodeIfPresent([String: JSONValue].self, forKey: .multiSelectLookup)
        subFormTabId = try! container.decodeIfPresent(Int64.self, forKey: .subFormTabId)
        subForm = try! container.decodeIfPresent([String: JSONValue].self, forKey: .subForm)
    }
    open func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
      
        try! container.encode(self.id, forKey: .id)
        try! container.encode(self.type, forKey: .type)
        try! container.encode(self.lookupModules, forKey: .lookupModules)
        try! container.encodeIfPresent(self.constraintType, forKey: .constraintType)
        try! container.encode(self.apiName, forKey: .apiName)
        try! container.encode(self.displayLabel, forKey: .displayLabel)
        try! container.encode(self.dataType, forKey: .dataType)
        try! container.encode(self.isReadOnly, forKey: .isReadOnly)
        try! container.encode(self.isVisible, forKey: .isVisible)
        try! container.encode(self.isMandatory, forKey: .isMandatory)
        try! container.encode(self.isCustomField, forKey: .isCustomField)
        try! container.encodeIfPresent(self.defaultValue, forKey: .defaultValue)
        try! container.encodeIfPresent(self.maxLength, forKey: .maxLength)
        try! container.encodeIfPresent(self.currencyPrecision, forKey: .currencyPrecision)
        try! container.encodeIfPresent(self.subLayoutsPresent, forKey: .subLayoutsPresent)
        try! container.encodeIfPresent(self.pickListValues, forKey: .pickListValues)
        try! container.encodeIfPresent(self.sequenceNo, forKey: .sequenceNo)
        try! container.encodeIfPresent(self.formulaReturnType, forKey: .formulaReturnType)
        try! container.encodeIfPresent(self.formulaExpression, forKey: .formulaExpression)
        try! container.encodeIfPresent(self.tooltip, forKey: .tooltip)
        try! container.encode(self.webhook, forKey: .webhook)
        try! container.encodeIfPresent(self.isRestricted, forKey: .isRestricted)
        try! container.encodeIfPresent(self.restrictedType, forKey: .restrictedType)
        try! container.encodeIfPresent(self.isExportable, forKey: .isExportable)
        try! container.encode(self.createdSource, forKey: .createdSource)
        try! container.encodeIfPresent(self.isBusinessCardSupported, forKey: .isBusinessCardSupported)
        try! container.encodeIfPresent(self.roundingOption, forKey: .roundingOption)
        try! container.encodeIfPresent(self.precision, forKey: .precision)
        try! container.encodeIfPresent(self.multiSelectLookup, forKey: .multiSelectLookup)
        try! container.encodeIfPresent(self.subFormTabId, forKey: .subFormTabId)
        try! container.encodeIfPresent(self.subForm, forKey: .subForm)
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

extension ZCRMField : Hashable
{
    public static func == (lhs: ZCRMField, rhs: ZCRMField) -> Bool {
        var lookupFlag : Bool
        var multiSelectLookupFlag : Bool
        var subformFlag : Bool
        if lhs.lookup == nil && rhs.lookup == nil
        {
            lookupFlag = true
        }
        else if let lhsLookup = lhs.lookup, let rhsLookup = rhs.lookup
        {
            lookupFlag = NSDictionary(dictionary: lhsLookup).isEqual(to: rhsLookup)
        }
        else
        {
            return false
        }
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
            lookupFlag &&
            multiSelectLookupFlag &&
            lhs.subFormTabId == rhs.subFormTabId &&
            subformFlag &&
            isEqual( lhs : lhs.defaultValue, rhs : rhs.defaultValue )
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

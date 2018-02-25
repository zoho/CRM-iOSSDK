//
//  ZCRMField.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMField : ZCRMEntity
{
	private var apiName : String
	private var id : Int64?
	private var displayLabel : String?
	private var dataType : String?
	private var readOnly : Bool?
	private var visible : Bool?
	private var mandatory : Bool?
	private var customField : Bool?
	private var defaultValue : Any?
	private var maxLength : Int?
	private var precision : Int?
	private var sequenceNo : Int?
	private var subLayoutsPresent : [String] = [String]()
	private var pickListValues : [ ZCRMPickListValue ]?
	private var formulaReturnType : String?
	private var formulaExpression : String?
	
    /// Initialise the instance of ZCRMField with given field API name.
    ///
    /// - Parameter fieldAPIName : field API name whose associated ZCRMField is to be initialised
	init(fieldAPIName : String)
	{
		self.apiName = fieldAPIName
	}
	
    /// Returns the API name of ZCRMField.
    ///
    /// - Returns : the API name of ZCRMField
	public func getAPIName() -> String
	{
		return self.apiName
	}
	
    /// Set the id of the ZCRMField.
    ///
    /// - Parameter fieldId : Id of the ZCRMField
	internal func setId(fieldId : Int64?)
	{
		self.id = fieldId
	}
	
    /// Returns the id of the ZCRMField.
    ///
    /// - Returns : the id of the ZCRMField
	public func getId() -> Int64?
	{
		return self.id
	}
	
    /// Set the display label of the ZCRMField.
    ///
    /// - Parameter displayLabel : display label of the ZCRMField
	internal func setDisplayLabel(displayLabel : String?)
	{
		self.displayLabel = displayLabel
	}
	
    /// Returns the display label of the ZCRMField.
    ///
    /// - Returns : the display label of the ZCRMField
	public func getDisplayLabel() -> String?
	{
		return self.displayLabel
	}
	
    /// Set the data type of the ZCRMField.
    ///
    /// - Parameter dataType : data type of the ZCRMField
	internal func setDataType(dataType : String?)
	{
		self.dataType = dataType
	}
	
    /// Returns the data type of the ZCRMField.
    ///
    /// - Returns: the data type of the ZCRMField
	public func getDataType() -> String?
	{
		return self.dataType
	}
	
    /// Set true if the ZCRMField is read only.
    ///
    /// - Parameter isReadOnly: true if the ZCRMField is read only
	internal func setReadOnly(isReadOnly : Bool?)
	{
		self.readOnly = isReadOnly
	}
	
    /// Returns true if the ZCRMField is read only.
    ///
    /// - Returns: true if the ZCRMField is read only
	public func isReadOnly() -> Bool?
	{
		return self.readOnly
	}
	
    /// Set true if the ZCRMField is visible.
    ///
    /// - Parameter isVisible: true if the ZCRMField is visible
	internal func setVisible(isVisible : Bool?)
	{
		self.visible = isVisible
	}
	
    /// Returns true if the ZCRMField is visible.
    ///
    /// - Returns: true if the ZCRMField is visible
	public func isVisible() -> Bool?
	{
		return self.visible
	}
	
    /// Set true if the ZCRMField is mandatory.
    ///
    /// - Parameter isMandatory: true if the ZCRMField is mandatory
	internal func setMandatory(isMandatory : Bool?)
	{
		self.mandatory = isMandatory
	}
	
    /// Returns true if the ZCRMField is mandatory.
    ///
    /// - Returns: true if the ZCRMField is mandatory
	public func isMandatory() -> Bool?
	{
		return self.mandatory
	}
    
    /// Set true if the ZCRMField is customizable.
    ///
    /// - Parameter isMandatory: true if the ZCRMField is customizable
	internal func setCustomField(isCustomField : Bool?)
	{
		self.customField = isCustomField
	}
	
    /// Retruns true if the ZCRMField is customizable.
    ///
    /// - Parameter isMandatory: true if the ZCRMField is customizable
	public func isCustomField() -> Bool?
	{
		return self.customField
	}
	
    /// Set the default value of the ZCRMField.
    ///
    /// - Parameter defaultValue: the default value of the ZCRMField
	internal func setDefaultValue(defaultValue : Any?)
	{
		self.defaultValue = defaultValue
	}
	
    /// Returns the default value of the ZCRMField.
    ///
    /// - Returns: the default value of the ZCRMField
	public func getDefaultValue() -> Any?
	{
		return self.defaultValue
	}
	
    /// Set the sequence number of the ZCRMField.
    ///
    /// - Parameter sequenceNo: the sequence number of the ZCRMField
	internal func setSequenceNumber(sequenceNo : Int?)
	{
		self.sequenceNo = sequenceNo
	}
	
    /// Returns the sequence number of the ZCRMField.
    ///
    /// - Returns: the sequence number of the ZCRMField
	public func getSequenceNo() -> Int?
	{
		return self.sequenceNo
	}
	    
    /// Add the pick list value to the ZCRMField.
    ///
    /// - Parameter pickListValue: value to be added
    internal func addPickListValue( pickListValue : ZCRMPickListValue )
    {
        if self.pickListValues != nil
        {
            self.pickListValues?.append( pickListValue )
        }
        else
        {
            self.pickListValues = [ pickListValue ]
        }
    }
	
    /// Returns all the pick list value to the ZCRMField.
    ///
    /// - Returns: all the pick list value to the ZCRMField
	public func getPickListValues() -> [ZCRMPickListValue]?
	{
		return self.pickListValues
	}
	
    /// Set the max length of the ZCRMField.
    ///
    /// - Parameter maxLen: max length of the ZCRMField
	internal func setMaxLength(maxLen : Int?)
	{
		self.maxLength = maxLen
	}
	
    /// Retruns the max length of the ZCRMField.
    ///
    /// - Returns: the max length of the ZCRMField
	public func getMaxLength() -> Int?
	{
		return self.maxLength
	}
	
    /// Set the no of decimal places allowed for the ZCRMField value
    ///
    /// - Parameter precision: no of decimal places
	internal func setPrecision(precision : Int?)
	{
		self.precision = precision
	}
	
    /// Returns the no of decimal places allowed for the ZCRMField value
    ///
    /// - Returns: no of decimal places allowed for the ZCRMField value
	public func getPrecision() -> Int?
	{
		return self.precision
	}
	
    /// Set the view type of the ZCRMField. It includes "create, quick create, view and edit" only if all four are true or else it includes only true layouts.
    ///
    /// - Parameter subLayoutsPresent: view type of the field
	internal func setSubLayoutsPresent(subLayoutsPresent : [String])
	{
		self.subLayoutsPresent = subLayoutsPresent
	}
	
    /// Returns true if view type includes "create".
    ///
    /// - Returns: true if view type includes "create"
	public func isPresentInCreateLayout() -> Bool?
	{
		return self.subLayoutsPresent.contains("CREATE")
	}
	
    /// Returns true if view type includes "view".
    ///
    /// - Returns: true if view type includes "view"
	public func isPresentInViewLayout() -> Bool?
	{
		return self.subLayoutsPresent.contains("VIEW")
	}
	
    /// Returns true if view type includes "quick create".
    ///
    /// - Returns: true if view type includes "quick create"
	public func isPresentInQuickCreateLayout() -> Bool?
	{
		return self.subLayoutsPresent.contains("QUICK_CREATE")
	}
    
    /// Returns true if view type includes "edit".
    ///
    /// - Returns: true if view type includes "edit"
    public func isPresentInEditLayout() -> Bool?
    {
        return self.subLayoutsPresent.contains("EDIT")
    }
	
    /// Set the return type of the formula.
    ///
    /// - Parameter formulaReturnType: formula return type
	internal func setFormulaReturnType(formulaReturnType : String?)
	{
		self.formulaReturnType = formulaReturnType
	}
	
    /// Returns formula return type.
    ///
    /// - Returns: formula return type
	public func getForumulaReturnType() -> String?
	{
		return self.formulaReturnType
	}
	
    /// Set the formula.
    ///
    /// - Parameter formulaReturnType: formula
	internal func setFormula(formulaExpression : String?)
	{
		self.formulaExpression = formulaExpression
	}
	
    /// Returns formula.
    ///
    /// - Returns: formula
	public func getForumula() -> String?
	{
		return self.formulaExpression
	}
}

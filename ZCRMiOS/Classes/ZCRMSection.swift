//
//  ZCRMSection.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMSection : ZCRMEntity
{
	private var name : String
	private var displayName : String?
	private var columnCount : Int?
	private var sequence : Int?
	private var fields : [ZCRMField]?
	
    /// Initialise the instance of a section with the given section name.
    ///
    /// - Parameter sectionName: section name whose associated section is to be initialised
	init(sectionName : String)
	{
		self.name = sectionName
	}
	
    /// Returns the name of the section.
    ///
    /// - Returns: Section's name
	public func getName() -> String
	{
		return self.name
	}
	
    /// Set the display name of the section.
    ///
    /// - Parameter displayName: display name of the section
	internal func setDisplayName(displayName : String?)
	{
		self.displayName = displayName
	}
	
    /// Returns display name of the section.
    ///
    /// - Returns: Sections's display name
	public func getDisplayName() -> String?
	{
		return self.displayName
	}
	
    /// Set the column count of the section ie. no of column separation for the section.
    ///
    /// - Parameter colCount: column count of the section
	internal func setColumnCount(colCount : Int?)
	{
		self.columnCount = colCount
	}
	
    /// Returns column count of the section.
    ///
    /// - Returns: column count of the section.
	public func getColumnCount() -> Int?
	{
		return self.columnCount
	}
	
    /// Set the sequence number of the section.
    ///
    /// - Parameter sequence: sequence number
	internal func setSequence(sequence : Int?)
	{
		self.sequence = sequence
	}
	
    /// Returns sequence number of the section.
    ///
    /// - Returns: sequence number of the section
	public func getSequence() -> Int?
	{
		return self.sequence
	}
	
    /// Add given ZCRMFields to the sections.
    ///
    /// - Parameter field: ZCRMField to be added
	internal func addField(field : ZCRMField?)
	{
        if( self.fields != nil )
        {
            self.fields?.append(field!)
        }
        else
        {
            self.fields = [ field! ]
        }
	}
	
    /// Set given list of fields to the section.
    ///
    /// - Parameter allFields: list of ZCRMFields
	internal func setFields(allFields : [ZCRMField])
	{
		self.fields = allFields
	}
	
    /// Returns list of fields of the section.
    ///
    /// - Returns: list of fields of the section
	public func getAllFields() -> [ZCRMField]?
	{
		return self.fields
	}
}

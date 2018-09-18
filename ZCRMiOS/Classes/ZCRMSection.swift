//
//  ZCRMSection.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMSection : ZCRMEntity
{
	public var name : String
	public var displayName : String = APIConstants.STRING_MOCK
	public var columnCount : Int = APIConstants.INT_MOCK
	public var sequence : Int = APIConstants.INT_MOCK
	public var fields : [ZCRMField] = [ ZCRMField ]()
    public var isSubformSection : Bool = APIConstants.BOOL_MOCK
	
    /// Initialise the instance of a section with the given section name.
    ///
    /// - Parameter sectionName: section name whose associated section is to be initialised
	init(sectionName : String)
	{
		self.name = sectionName
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
	internal func addField(field : ZCRMField)
	{
        self.fields.append( field )
	}
	
    /// Add given list of fields to the section.
    ///
    /// - Parameter allFields: list of ZCRMFields
	internal func addFields(allFields : [ZCRMField])
	{
		self.fields = allFields
	}
}

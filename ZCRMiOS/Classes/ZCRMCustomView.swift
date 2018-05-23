//
//  ZCRMCustomView.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 17/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMCustomView : ZCRMEntity
{
    private var moduleAPIName : String
	private var id : Int64
	private var sysName : String?
	private var name : String?
	private var displayName : String?
	private var isDefault : Bool = true
	private var fields : [String]?
	private var favouriteSequence : Int = -1
	private var sortByCol : String?
	private var sortOrder : SortOrder?
	private var category : String?
	
    /// Initialise the instance of a custom view with the given custom view Id.
    ///
    /// - Parameters:
    ///   - cvId: custom view Id whose associated custom view is to be initialised
    ///   - moduleAPIName: module API name of a custom view is to be initialised
	public init(cvId: Int64, moduleAPIName: String)
	{
		self.id = cvId
		self.moduleAPIName = moduleAPIName
	}
	
    /// Returns Id of the custom view.
    ///
    /// - Returns: Id of the custom view
	public func getId() -> Int64
	{
		return self.id
	}
    
    /// Returns the module API name of the CustomView.
    ///
    /// - Returns: the module API name of the CustomView
    public func getModuleAPIName() -> String
    {
        return self.moduleAPIName
    }
    
    /// Set the name of the custom view.
    ///
    /// - Parameter name: name of the custom view
    internal func setName( name : String )
    {
        self.name = name
    }
	
    /// Returns the custom view name.
    ///
    /// - Returns: the custom view name
	public func getName() -> String
	{
		return self.name!
	}
	
    /// Set the system name of the custom view.
    ///
    /// - Parameter systemName: system name of the custom view
	internal func setSystemName(systemName: String?)
	{
		self.sysName = systemName
	}
	
    /// Returns system name of the custom view.
    ///
    /// - Returns: system name of the custom view
	public func getSystemName() -> String?
	{
		return self.sysName
	}
	
    /// Set the display name of the custom view.
    ///
    /// - Parameter displayName: display name of the custom view
	internal func setDisplayName(displayName: String)
	{
		self.displayName = displayName
	}
	
    /// Set the display name of the custom view.
    ///
    /// - Returns: display name of the custom view
	public func getDisplayName() -> String
	{
		return self.displayName!
	}
	
    /// Set true if it is the default custom view.
    ///
    /// - Parameter isDefault: true if it is the default custom view
	internal func setIsDefault(isDefault: Bool)
	{
		self.isDefault = isDefault
	}
	
    /// Returns true if it is the default custom view.
    ///
    /// - Returns: true if it is the default custom view
	public func isDefaultCV() -> Bool
	{
		return self.isDefault
	}
	
    /// Set category of the custom view(shared_with_me or created_by_me).
    ///
    /// - Parameter category: category of the custom view
	internal func setCategory(category: String)
	{
		self.category = category
	}
	
    /// Returns category of the custom view(shared_with_me or created_by_me).
    ///
    /// - Returns: category of the custom view
	public func getCategory() -> String?
	{
		return self.category
	}
	
    /// Set 1 if is a favorite custom view otherwise returns nil.
    ///
    /// - Parameter favourite: 1 if is a favorite custom view
	internal func setFavouriteSequence(favourite: Int?)
	{
		if(favourite != nil)
		{
			self.favouriteSequence = favourite!
		}
	}
	
    /// Return 1 if is a favorite custom view otherwise returns nil.
    ///
    /// - Returns: 1 if is a favorite custom view
	public func getFavouriteSequence() -> Int
	{
		return self.favouriteSequence
	}
	
    /// Set list of fields in the custom view's column.
    ///
    /// - Parameter fieldsAPINames: list of fields to be set in custom view's column
	internal func setDisplayFields(fieldsAPINames: [String]?)
	{
		self.fields = fieldsAPINames
	}
	
    /// Returns list of fields in the custom view's column.
    ///
    /// - Returns: list of fields in the custom view's column
	public func getDisplayFieldsAPINames() -> [String]?
	{
		return self.fields
	}
	
    /// Set field by which the custom view records get sorted.
    ///
    /// - Parameter fieldAPIName: field by which the custom view records get sorted
	internal func setSortByCol(fieldAPIName: String?)
	{
		self.sortByCol = fieldAPIName
	}
	
    /// Returns field by which the custom view records get sorted
    ///
    /// - Returns: field by which the custom view records get sorted
	public func getSortByCol() -> String?
	{
		return self.sortByCol
	}
	
    /// Set sort order (asc, desc) to the custom view.
    ///
    /// - Parameter sortOrder: sort order (asc, desc)
	internal func setSortOrder(sortOrder: String?)
	{
		if(sortOrder != nil)
		{
			self.sortOrder = SortOrder(rawValue: sortOrder!)
		}
	}
	
    /// Returns sort order (asc, desc) of the custom view.
    ///
    /// - Returns: sort order (asc, desc) of the custom view.
	public func getSortOrder() -> SortOrder?
	{
		return self.sortOrder
	}
    
    /// Returns List of all records of the CustomView(BulkAPIResponse).
    ///
    /// - Returns: List of all records of the CustomView
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords() throws -> BulkAPIResponse
    {
        return try self.getRecords( page : 1, perPage : 200 )
    }
    
    /// Returns list of all records of the CustomView of a requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - page:  page number of the CustomView
    ///   - perPage: no of records to be given for a single page.
    /// - Returns: list of all records of the CustomView of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords( page : Int, perPage : Int ) throws -> BulkAPIResponse
    {
        return try self.getRecords( sortByField : nil, sortOrder : nil, startIndex : page, endIndex: perPage, modifiedSince : nil )
    }
    
    /// Returns list of all records of the CustomView, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    /// - Returns: sorted list of records of the CustomView
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords( sortByField : String, sortOrder : SortOrder ) throws -> BulkAPIResponse
    {
        return try self.getRecords( sortByField : sortByField, sortOrder : sortOrder, startIndex : 1, endIndex: 200, modifiedSince : nil )
    }
    
    /// Returns list of all records of the CustomView of a requested page number with records of per_page count, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - startIndex: records start index
    ///   - endIndex: records end index
    ///   - modifiedSince: modified time
    /// - Returns: sorted list of records of the CustomView
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords( sortByField : String?, sortOrder : SortOrder?, startIndex : Int, endIndex : Int, modifiedSince : String? ) throws -> BulkAPIResponse
    {
        return try ZCRMModule( moduleAPIName : self.moduleAPIName ).getRecords( cvId : self.id, sortByField : sortByField, sortOrder : sortOrder, page: startIndex, per_page: endIndex, modifiedSince : modifiedSince )
    }
	
}

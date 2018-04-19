//
//  ZCRMModule.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMModule : ZCRMEntity
{
	private var apiName : String
	private var systemName : String?
	private var singularLabel : String?
	private var pluralLabel : String?
	private var id : Int64?
	
	private var customModule : Bool?
	private var creatable : Bool?
	private var viewable : Bool?
	private var convertible : Bool?
	private var editable : Bool?
	private var deletable : Bool?
	
	private var modifiedBy : ZCRMUser?
	private var modifiedTime : String?
	
	private var allowedProfiles : [ZCRMProfile]?
	private var layouts : [ZCRMLayout]?
	private var fields : [ZCRMField]?
	private var businessCardFields : [ZCRMField]?
	private var relatedLists : [ZCRMModuleRelation]?
    private var accessibleProfiles : [ ZCRMProfile ]?
	
    /// Initialize the instance of a module with the given module API name.
    ///
    /// - Parameter moduleAPIName: apiName whose associated module is to be initialized
	public init(moduleAPIName : String) {
		self.apiName = moduleAPIName
	}
	
    /// Returns the API name of the module.
    ///
    /// - Returns: API name of the module
	public func getAPIName() -> String
	{
		return self.apiName
	}
	
    /// Set module's ID.
    ///
    /// - Parameter moduleId: module's ID
	internal func setId(moduleId : Int64?)
	{
		self.id = moduleId
	}
	
    /// Returns module's ID
    ///
    /// - Returns: module's ID
	public func getId() -> Int64?
	{
		return self.id
	}
	
    /// Set the display name of the module.
    ///
    /// - Parameter sysName: display name of the module
	internal func setSystemName(sysName : String?)
	{
		self.systemName = sysName
	}
	
    /// Retunrs the display name of the module
    ///
    /// - Returns: display name of the module
	public func getSystemName() -> String?
	{
		return self.systemName
	}
	
    /// Set the singular label of the module.
    ///
    /// - Parameter singularLabel: singular label of the module
	internal func setSingularLabel(singularLabel : String?)
	{
		self.singularLabel = singularLabel
	}
	
    /// Returns the singular label of the module
    ///
    /// - Returns: singular label of the module
	public func getSingularLabel() -> String?
	{
		return self.singularLabel
	}
	
    /// Set plural label of the module.
    ///
    /// - Parameter pluralLabel: plural label of the module
	internal func setPluralLabel(pluralLabel : String?)
	{
		self.pluralLabel = pluralLabel
	}
	
    /// Returns plural label of the module
    ///
    /// - Returns: plural label of the module
	public func getPluralLabel() -> String?
	{
		return self.pluralLabel
	}
	
    /// Set true if the module is custom module
    ///
    /// - Parameter isCustomModule: true if the module is custom module
	internal func setIsCustomModule(isCustomModule : Bool?)
	{
		self.customModule = isCustomModule
	}
	
    /// Returns true if the module is custom module
    ///
    /// - Returns: true if the module is custom module
	public func isCustomModule() -> Bool?
	{
		return self.customModule
	}
    
    /// Set true if the module is convertible.
    ///
    /// - Parameter isConvertible: true if the module is convertible
    internal func setIsConvertible( isConvertible : Bool? )
    {
        self.convertible = isConvertible
    }
    
    /// Returns true if the module is convertible
    ///
    /// - Returns: true if the module is convertible
    public func isConvertible() -> Bool?
    {
        return self.convertible
    }
    
    /// Set true if the module is creatable.
    ///
    /// - Parameter isCreatable: true if the module is creatable
    internal func setIsCreatable( isCreatable : Bool? )
    {
        self.creatable = isCreatable
    }
    
    /// Returns true if the module is creatable
    ///
    /// - Returns: true if the module is creatable
    public func isCreatable() -> Bool?
    {
        return self.creatable
    }
    
    /// Set true if the module is editable.
    ///
    /// - Parameter isEditable: true if the module is editable
    internal func setIsEditable( isEditable : Bool? )
    {
        self.editable = isEditable
    }
    
    /// Returns true if the module is editable
    ///
    /// - Returns: true if the module is editable
    public func isEditable() -> Bool?
    {
        return self.editable
    }
    
    /// Set true if the module is viewable.
    ///
    /// - Parameter isViewable: true if the module is viewable
    internal func setIsViewable( isViewable : Bool? )
    {
        self.viewable = isViewable
    }
    
    /// Returns true if the module is viewable.
    ///
    /// - Returns: true if the module is viewable
    public func isViewable() -> Bool?
    {
        return self.viewable
    }
    
    /// Set true if the module is deletable.
    ///
    /// - Parameter isDeletable: true if the module is deletable
    internal func setIsDeletable( isDeletable : Bool? )
    {
        self.deletable = isDeletable
    }
    
    /// Returns true if the module is deletable
    ///
    /// - Returns: true if the module is deletable
    public func isDeletable() -> Bool?
    {
        return self.deletable
    }
	
    /// Set ZCRMUser who recently modified the module(last modification of the module).
    ///
    /// - Parameter modifiedByUser: ZCRMUser who modified the module
	internal func setLastModifiedBy(modifiedByUser : ZCRMUser?)
	{
		self.modifiedBy = modifiedByUser
	}
	
    /// Returns ZCRMUser who recently modified the module(last modification of the module).
    ///
    /// - Returns: ZCRMUser who recently modified the module
	public func getLastModifiedBy() -> ZCRMUser?
	{
		return self.modifiedBy
	}
	
    /// Set last modified time of the module.
    ///
    /// - Parameter lastModifiedTime: the time at which the module is modified
	internal func setLastModifiedTime(lastModifiedTime : String?)
	{
		self.modifiedTime = lastModifiedTime
	}
	
    /// Returns last modified time of the module
    ///
    /// - Returns: the time at which the module is modified
	public func getLastModifiedTime() -> String?
	{
		return self.modifiedTime
	}
	
    /// Set the profiles who all are allowd in the ZCRMRecord
    ///
    /// - Parameter allowedProfiles: Profiles who has permission in the ZCRMRecord
	internal func setAllowedProfiles(allowedProfiles : [ZCRMProfile]?)
	{
		self.allowedProfiles = allowedProfiles
	}
	
    /// Returns all the allowed profiles of the ZCRMRecord
    ///
    /// - Returns: allowed profiles of the ZCRMRecord
	public func getAllowedProfiles() -> [ZCRMProfile]?
	{
		return self.allowedProfiles
	}
	
    /// Set related list to the module.
    ///
    /// - Parameter allRelatedLists: related list of the module
	internal func setRelatedLists(allRelatedLists : [ZCRMModuleRelation]?)
	{
		self.relatedLists = allRelatedLists
	}
	
    /// Returns related list to the module.
    ///
    /// - Returns: related list to the module.
	public func getAllRelatedLists() -> [ZCRMModuleRelation]?
	{
		return self.relatedLists
	}
	
    /// Set list of business card fields to the module.
    ///
    /// - Parameter businessCardFields: list of business card fields
	internal func setBusinessCardFields(businessCardFields : [ZCRMField]?)
	{
		self.businessCardFields = businessCardFields
	}
	
    /// Returns list of business card fields of the module.
    ///
    /// - Returns: list of business card fields of the module
	public func getAllBusinessCardFields() -> [ZCRMField]?
	{
		return self.businessCardFields
	}
	
    /// Set List of ZCRMLayouts to the module.
    ///
    /// - Parameter allLayouts: List of ZCRMLayouts
	internal func setLayouts(allLayouts : [ZCRMLayout]?)
	{
		self.layouts = allLayouts
	}
	
    /// Set list of ZCRMFields to the module.
    ///
    /// - Parameter allFields: list of ZCRMFields
	internal func setFields(allFields : [ZCRMField]?)
	{
		self.fields = allFields
	}
    
    /// Set the accessible ZCRMProfile
    ///
    /// - Parameter profile: ZCRMProfile
    internal func addAccessibleProfile( profile : ZCRMProfile )
    {
        if( self.accessibleProfiles != nil )
        {
            self.accessibleProfiles?.append( profile )
        }
        else
        {
            self.accessibleProfiles = [ profile ]
        }
    }
    
    /// Returns list of accessible ZCRMProfiles.
    ///
    /// - Returns: list of accessible ZCRMProfiles
    public func getAccessibleProfiles() -> [ ZCRMProfile ]?
    {
        return self.accessibleProfiles
    }
	
    /// Returns all the layouts of the module(BulkAPIResponse).
    ///
    /// - Returns: all the layouts of the module
    /// - Throws: ZCRMSDKError if failed to get all layouts
    public func getAllLayouts() throws -> BulkAPIResponse
    {
        return try ModuleAPIHandler(module: self).getAllLayouts( modifiedSince : nil )
    }
    
    /// Returns all the layouts of the module with the given modified since time(BulkAPIResponse).
    ///
    /// - Parameter modifiedSince: modified time
    /// - Returns: all the layouts of the module with the given modified since time
    /// - Throws: ZCRMSDKError if failed to get all layouts
    public func getAllLayouts( modifiedSince : String? ) throws -> BulkAPIResponse
	{
		return try ModuleAPIHandler(module: self).getAllLayouts( modifiedSince : modifiedSince )
	}
	
    /// Returns a layout with given layout id
    ///
    /// - Parameter layoutId: layout id
    /// - Returns: layout with given layout id
    /// - Throws: ZCRMSDKError if failed to get a layout
	public func getLayout(layoutId : Int64) throws -> APIResponse
	{
		return try ModuleAPIHandler(module: self).getLayout(layoutId: layoutId)
	}
    
    ///  Returns list of ZCRMFields of the module(BulkAPIResponse).
    ///
    /// - Parameter modifiedSince: modified time
    /// - Returns: list of ZCRMFields of the module
    /// - Throws: ZCRMSDKError if failed to get all fields
    public func getAllFields( modifiedSince : String? ) throws -> BulkAPIResponse
    {
        return try ModuleAPIHandler(module: self).getAllFields( modifiedSince : modifiedSince )
    }
	
    /// Returns the custom views of the module(BulkAPIResponse).
    ///
    /// - Returns: custom views of the module
    /// - Throws: ZCRMSDKError if failed to get the custom views
    public func getAllCustomViews() throws -> BulkAPIResponse
    {
        return try ModuleAPIHandler(module: self).getAllCustomViews( modifiedSince : nil )
    }
    
    /// Returns the custom views of the module(BulkAPIResponse) modified after the given time.
    ///
    /// - Parameter modifiedSince: modified time
    /// - Returns: custom views of the module
    /// - Throws: ZCRMSDKError if failed to get the custom views
	public func getAllCustomViews( modifiedSince : String? ) throws -> BulkAPIResponse
	{
		return try ModuleAPIHandler(module: self).getAllCustomViews( modifiedSince : modifiedSince )
	}
    
    /// Returns custom view with the given cvID of the module(APIResponse).
    ///
    /// - Parameter cvId: Id of the custom view to be returned
    /// - Returns: custom view with the given cvID of the module
    /// - Throws: ZCRMSDKError if failed to get the custom view
    public func getCustomView( cvId : Int64 ) throws -> APIResponse
    {
        return try ModuleAPIHandler( module : self ).getCustomView( cvId : cvId )
    }
	
    /// Returns ZCRMRecord with the given ID of the module(APIResponse).
    ///
    /// - Parameter recordId: Id of the record to be returned
    /// - Returns: ZCRMRecord with the given ID of the module
    /// - Throws: ZCRMSDKError if failed to get the record
	public func getRecord(recordId : Int64) throws -> APIResponse
	{
		let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.getAPIName(), recordId: recordId)
		return try EntityAPIHandler(record: record).getRecord()
	}
	
    /// Returns List of all records of the module(BulkAPIResponse).
    ///
    /// - Returns: List of all records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
	public func getRecords() throws -> BulkAPIResponse
	{
		return try self.getRecords(cvId: nil)
	}
	
    /// Returns list of all records of the module of a requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - page: page number of the module
    ///   - per_page: number of records to be given for a single page.
    /// - Returns: list of all records of the module of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
	public func getRecords(page : Int, per_page : Int) throws -> BulkAPIResponse
	{
		return try self.getRecords(cvId: nil, page: page, per_page: per_page)
	}
	
    /// Returns List of all records of the module with the given cvID(BulkAPIResponse).
    ///
    /// - Parameter cvId: custom view ID
    /// - Returns: List of all records of the module with the given cvID
    /// - Throws: ZCRMSDKError if failed to get the records
	public func getRecords(cvId : Int64?) throws -> BulkAPIResponse
	{
		return try self.getRecords(cvId: cvId, page: 1, per_page: 100)
	}
	
    /// Returns list of all records of the module of a requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - cvId: custom view ID
    ///   - page: page number of the module
    ///   - per_page: number of records to be given for a single page.
    /// - Returns: list of all records of the module of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
	public func getRecords(cvId : Int64?, page : Int, per_page : Int) throws -> BulkAPIResponse
	{
		return try self.getRecords(cvId: cvId, sortByField: nil, sortOrder: nil, page: page, per_page: per_page, modifiedSince : nil)
	}
	
    /// Returns list of all records of the module, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - cvId: custom view ID
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    /// - Returns: sorted list of records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
	public func getRecords(cvId : Int64?, sortByField : String?, sortOrder : SortOrder?) throws -> BulkAPIResponse
	{
        return try self.getRecords(cvId: cvId, sortByField: sortByField, sortOrder: sortOrder, page: 1, per_page: 100, modifiedSince : nil )
	}
	
    /// Returns list of all records of the module of a requested page number with records of per_page count, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - cvId: custom view ID
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - page: page number of the module
    ///   - per_page: page number of the module
    ///   - modifiedSince: modified time
    /// - Returns: sorted list of records of the module of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords(cvId : Int64?, sortByField : String?, sortOrder : SortOrder?, page : Int, per_page : Int, modifiedSince : String? ) throws -> BulkAPIResponse
	{
		return try self.getRecords(cvId: cvId, fields: nil , sortByField: sortByField, sortOrder: sortOrder, converted: nil , approved: nil , page: page, per_page: per_page , modifiedSince: modifiedSince)
	}
	/// Returns list of all records of the module which matches the requested params, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
	///
	/// - Parameters:
	///   - cvId: custom view ID
	///   - fields : field apiNames
	///   - sortByField: field by which the records get sorted
	///   - sortOrder: sort order (asc, desc)
	///   - converted: specifies converted type or not
	///   - approved: specifies approved type or not
	///   - page: page number of the module
	///   - per_page: page number of the module
	///   - modifiedSince: modified time
	/// - Returns: sorted list of records of the module  matches the requested params
	/// - Throws: ZCRMSDKError if failed to get the records
	public func getRecords( cvId : Int64?, fields : [String]? , sortByField : String? , sortOrder : SortOrder? , converted : Bool? , approved : Bool? , page : Int , per_page : Int , modifiedSince : String? ) throws -> BulkAPIResponse
	{
		return try MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : converted , approved : approved, page : page, per_page : per_page, modifiedSince : modifiedSince)
	}
	/// Returns list of all approved records of the module which matches the requested params, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
	///
	/// - Parameters:
	///   - cvId: custom view ID
	///   - fields : field apiNames
	///   - sortByField: field by which the records get sorted
	///   - sortOrder: sort order (asc, desc)
	///   - page: page number of the module
	///   - per_page: page number of the module
	/// - Returns: sorted list of records of the module matches the requested params
	/// - Throws: ZCRMSDKError if failed to get the records
	public func getApprovedRecords( cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int ) throws -> BulkAPIResponse
	{
		return try self.getRecords( cvId : cvId , fields : fields , sortByField : sortByField , sortOrder : sortOrder , converted : nil , approved : true , page : page , per_page : per_page , modifiedSince : nil )
	}
	/// Returns list of all unapproved records of the module which matches the requested params, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
	///
	/// - Parameters:
	///   - cvId: custom view ID
	///   - fields : field apiNames
	///   - sortByField: field by which the records get sorted
	///   - sortOrder: sort order (asc, desc)
	///   - page: page number of the module
	///   - per_page: page number of the module
	/// - Returns: sorted list of records of the module matches the requested params
	/// - Throws: ZCRMSDKError if failed to get the records
	public func getUnApprovedRecords( cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int ) throws -> BulkAPIResponse
	{
		return try self.getRecords( cvId : cvId , fields : fields , sortByField : sortByField , sortOrder : sortOrder , converted : nil , approved : false , page : page , per_page : per_page , modifiedSince : nil )
	}
	/// Returns list of all converted records of the module which matches the requested params, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
	///
	/// - Parameters:
	///   - fields : field apiNames
	///   - sortByField: field by which the records get sorted
	///   - sortOrder: sort order (asc, desc)
	///   - page: page number of the module
	///   - per_page: page number of the module
	/// - Returns: sorted list of records of the module matches the requested params
	/// - Throws: ZCRMSDKError if failed to get the records
	public func getConvertedRecords(cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int) throws -> BulkAPIResponse
	{
		return try self.getRecords(cvId : cvId, fields : fields , sortByField : sortByField , sortOrder : sortOrder , converted : true , approved : nil, page : page , per_page : per_page , modifiedSince : nil )
	}
	/// Returns list of all unconverted records of the module which matches the requested params, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
	///
	/// - Parameters:
	///   - cvId: custom view ID
	///   - fields : fields apiNames
	///   - sortByField: field by which the records get sorted
	///   - sortOrder: sort order (asc, desc)
	///   - page: page number of the module
	///   - per_page: page number of the module
	/// - Returns: sorted list of records of the module matches the requested params
	/// - Throws: ZCRMSDKError if failed to get the records
	public func getUnConvertedRecords(cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int) throws -> BulkAPIResponse
	{
		return try self.getRecords(cvId : cvId, fields : fields , sortByField : sortByField , sortOrder : sortOrder , converted : false , approved : nil, page : page , per_page : per_page , modifiedSince : nil )
	}
	/// Returns list of all approved records of the module which the given fields.
	///
	/// - Parameters:
	///   - fields : fields apiNames
	/// - Returns: sorted list of records of the module matches the given fields
	/// - Throws: ZCRMSDKError if failed to get the records
	public func getRecordByFields( fields : [String] ) throws -> BulkAPIResponse
	{
		return try self.getRecords(cvId : nil, fields : fields , sortByField : nil , sortOrder : nil , converted : nil , approved : nil, page : 1 , per_page : 200 , modifiedSince : nil )
	}
    /// Returns List of all deleted records of the module(BulkAPIResponse).
    ///
    /// - Returns: List of all deleted records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getAllDeletedRecords() throws -> BulkAPIResponse
    {
        return try MassEntityAPIHandler( module : self ).getAllDeletedRecords()
    }
    
    /// Returns List of recycle bin records of the module(BulkAPIResponse).
    ///
    /// - Returns: List of recycle bin records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecycleBinRecords() throws -> BulkAPIResponse
    {
        return try MassEntityAPIHandler( module : self ).getRecycleBinRecords()
    }
    
    /// Returns List of permanently deleted records of the module(BulkAPIResponse).
    ///
    /// - Returns: List of permanently records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getPermanentlyDeletedRecords() throws -> BulkAPIResponse
    {
        return try MassEntityAPIHandler( module : self ).getPermanentlyDeletedRecords()
    }
	
    /// Returns list of records which contains the given search text as substring(BulkAPIResponse).
    ///
    /// - Parameter searchText: text to be searched
    /// - Returns: list of records which contains the given search text as substring
    /// - Throws: ZCRMSDKError if failed to get the records
	public func searchRecords(searchText: String) throws -> BulkAPIResponse
	{
		return try self.searchRecords( searchText : searchText, page : 1, per_page : 200 )
	}
	
    /// Returns list of records of the module which contains the given search text as substring, with requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - searchText: text to be searched
    ///   - page: page number of the module
    ///   - per_page: number of records to be given for a single page.
    /// - Returns: list of records of the module which contains the given search text as substring, with requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
	public func searchRecords(searchText: String, page: Int, per_page: Int) throws -> BulkAPIResponse
	{
		return try MassEntityAPIHandler(module: self).searchByText(searchText: searchText, page: page, perPage: per_page)
	}
    
    /// Returns list of records which satisfies the given criteria(BulkAPIResponse).
    ///
    /// - Parameter criteria: criteria to be searched
    /// - Returns: list of records which satisfies the given criteria
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByCriteria( criteria : String ) throws -> BulkAPIResponse
    {
        return try self.searchByCriteria( criteria : criteria, page : 1, perPage : 200 )
    }
    
    /// Returns list of records of the module which satisfies the given criteria, with requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - criteria: criteria to be searched
    ///   - page: page number of the module
    ///   - perPage: number of records to be given for a single page
    /// - Returns: list of records of the module which satisfies the given criteria, with requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByCriteria( criteria : String, page : Int, perPage : Int ) throws -> BulkAPIResponse
    {
        return try MassEntityAPIHandler( module : self ).searchByCriteria( searchCriteria : criteria, page : page, perPage : perPage )
    }
    
    /// Returns list of records of the module which satisfies the given value(BulkAPIResponse).
    ///
    /// - Parameter searchValue: value to be searched
    /// - Returns: list of records of the module which satisfies the given value
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByPhone( searchValue : String ) throws -> BulkAPIResponse
    {
        return try self.searchByPhone( searchValue : searchValue, page : 1, perPage : 200 )
    }
    
    /// Returns list of records of the module which satisfies the given value, with requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - searchValue: value to be searched
    ///   - page: page number of the module
    ///   - perPage: number of records to be given for a single page
    /// - Returns: list of records of the module which satisfies the given value, with requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByPhone( searchValue : String, page : Int, perPage : Int ) throws -> BulkAPIResponse
    {
        return try MassEntityAPIHandler( module : self ).searchByPhone( searchValue : searchValue, page : page, perPage : perPage )
    }
    
    /// Returns list of records of the module which satisfies the given value(BulkAPIResponse).
    ///
    /// - Parameter searchValue: value to be searched
    /// - Returns: list of records of the module which satisfies the given value
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByEmail( searchValue : String ) throws -> BulkAPIResponse
    {
        return try self.searchByEmail( searchValue : searchValue, page : 1, perPage : 200 )
    }
    
    /// Returns list of records of the module which satisfies the given value, with requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - searchValue: value to be searched
    ///   - page: page number of the module
    ///   - perPage: number of records to be given for a single page
    /// - Returns: list of records of the module which satisfies the given value, with requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByEmail( searchValue : String, page : Int, perPage : Int ) throws -> BulkAPIResponse
    {
        return try MassEntityAPIHandler( module : self ).searchByEmail( searchValue : searchValue, page : page, perPage : perPage )
    }
    
    /// Returns the mass create results of the set of records of the module(BulkAPIResponse).
    ///
    /// - Parameter records: list of ZCRMRecord objects to be created
    /// - Returns: mass create response of the records
    /// - Throws: ZCRMSDKError if failed to create records
    public func createRecords(records: [ZCRMRecord]) throws -> BulkAPIResponse
    {
        return try MassEntityAPIHandler(module: self).createRecords(records: records)
    }
	
    /// Returns the mass update results of the set of records of the module(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - recordIds: id's of the record to be updated
    ///   - fieldAPIName: fieldAPIName to which the field value is updated
    ///   - value: field value to be updated
    /// - Returns: mass update response of the records
    /// - Throws: ZCRMSDKError if failed to update records
	public func updateRecords(recordIds: [Int64], fieldAPIName: String, value: Any?) throws -> BulkAPIResponse
	{
		return try MassEntityAPIHandler(module: self).updateRecords(ids: recordIds, fieldAPIName: fieldAPIName, value: value)
	}
    
    /// Returns the upsert results of the set of records of the module(BulkAPIResponse).
    ///
    /// - Parameter records: list of ZCRMRecord objects to be upserted
    /// - Returns: upsert response of the records
    /// - Throws: ZCRMSDKError if failed to upsert records
    public func upsertRecords( records : [ ZCRMRecord ] ) throws -> BulkAPIResponse
    {
        return try MassEntityAPIHandler( module : self ).upsertRecords( records : records )
    }
    
    /// Returns the mass delete results of the set of records of the module(BulkAPIResponse).
    ///
    /// - Parameter recordIds: id's of the record to be deleted
    /// - Returns: mass delete response of the record
    /// - Throws: ZCRMSDKError if failed to delete records
    public func deleteRecords(recordIds: [Int64]) throws -> BulkAPIResponse
    {
        return try MassEntityAPIHandler(module: self).deleteRecords(ids: recordIds)
    }
}

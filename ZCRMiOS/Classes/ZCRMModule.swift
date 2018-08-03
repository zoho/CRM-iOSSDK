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
    
    private var creatable : Bool?
    private var viewable : Bool?
    private var convertible : Bool?
    private var editable : Bool?
    private var deletable : Bool?
    
    private var modifiedBy : ZCRMUser?
    private var modifiedTime : String?
    
    private var allowedProfiles : [ZCRMProfile]?
    private var relatedLists : [ZCRMModuleRelation]?

    
    private var globalSearchSupported : Bool?
    private var visibility : Int?
    private var apiSupported : Bool?
    private var quickCreate : Bool?
    private var scoringSupported : Bool?
    private var sequenceNumber : Int?
    private var generatedType : String?
    private var businessCardFieldLimit : Int?
    private var webLink : String?
    
    private var arguments : [ String : Any ]?
    private var properties : [ String ]?
    
    private var displayField : String?
    private var searchLayoutFields : [ String ]?
    private var parentModule : ZCRMModule?
    private var customView : ZCRMCustomView?
    
	
    /// Initialize the instance of a module with the given module API name.
    ///
    /// - Parameter moduleAPIName: apiName whose associated module is to be initialized
	public init(moduleAPIName : String)
    {
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
    
    internal func setIsGlobalSearchSupported( isSupport : Bool? )
    {
        self.globalSearchSupported = isSupport
    }
    
    public func getIsGlobalSearchSupported() -> Bool?
    {
        return self.globalSearchSupported
    }
    
    internal func setVisibility( visible : Int? )
    {
        self.visibility = visible
    }
    
    public func getVisibility() -> Int?
    {
        return self.visibility
    }
    
    internal func setIsAPISupported( isSupport : Bool? )
    {
        self.apiSupported = isSupport
    }
    
    public func getIsAPISupported() -> Bool?
    {
        return self.apiSupported
    }
    
    internal func setGeneratedType( type : String )
    {
        self.generatedType = type
    }
    
    public func getGeneratedType() -> String
    {
        return self.generatedType!
    }
    
    internal func setIsQuickCreate( isQuick : Bool? )
    {
        self.quickCreate = isQuick
    }
    
    public func getIsQuickCreate() -> Bool?
    {
        return self.quickCreate
    }
    
    internal func setIsScoringSupported( isSupport : Bool? )
    {
        self.scoringSupported = isSupport
    }
    
    public func getIsScoringSupported() -> Bool?
    {
        return self.scoringSupported
    }
    
    internal func setWebLink( link : String? )
    {
        self.webLink = link
    }
    
    public func getWebLink() -> String?
    {
        return self.webLink
    }
    
    internal func setSequenceNumber( number : Int? )
    {
        self.sequenceNumber = number
    }
    
    public func getSequenceNumber() -> Int?
    {
        return self.sequenceNumber
    }
    
    internal func setBusinessCardFieldLimit( limit : Int? )
    {
        self.businessCardFieldLimit = limit
    }
    
    public func getBusinessCardFiledLimit() -> Int?
    {
        return self.businessCardFieldLimit
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
    public func getAllRelatedLists( completion : @escaping( [ ZCRMModuleRelation ]?, BulkAPIResponse?, Error? ) -> () )
	{
        ModuleAPIHandler( module : self ).getAllRelatedLists { ( moduleRealtionList, response, error ) in
            completion(  moduleRealtionList, response, error )
        }
	}
    
    internal func setArguments( arguments : [ String : Any ]? )
    {
        self.arguments = arguments
    }
    
    public func getArguments() -> [ String : Any ]?
    {
        return self.arguments
    }
    
    internal func setProperties( properties : [ String ]? )
    {
        self.properties = properties
    }
    
    public func getProperties() -> [ String ]?
    {
        return self.properties
    }
    
    internal func setDisplayField( displayField : String? )
    {
        self.displayField = displayField
    }
    
    public func getDisplayField() -> String?
    {
        return self.displayField
    }
    
    internal func setSearchLayoutFields(searchLayoutFields : [String]? )
    {
        self.searchLayoutFields = searchLayoutFields
    }
    
    public func getSearchLayoutFields() -> [String]?
    {
        return self.searchLayoutFields
    }
    
    internal func setParentModule( parentModule : ZCRMModule? )
    {
        self.parentModule = parentModule
    }
    
    public func getParentModule() -> ZCRMModule?
    {
        return self.parentModule
    }
    
    internal func setCustomView( customView : ZCRMCustomView? )
    {
        self.customView = customView
    }
    
    public func getCustomView() -> ZCRMCustomView?
    {
        return self.customView
    }
		
    /// Returns all the layouts of the module(BulkAPIResponse).
    ///
    /// - Returns: all the layouts of the module
    /// - Throws: ZCRMSDKError if failed to get all layouts
    public func getAllLayouts( completion : @escaping( [ ZCRMLayout ]?, BulkAPIResponse?, Error? ) -> () )
    {
        ModuleAPIHandler(module: self).getAllLayouts( modifiedSince : nil) { ( layoutList, response, error ) in
            completion( layoutList, response, error )
        }
    }
    
    /// Returns all the layouts of the module with the given modified since time(BulkAPIResponse).
    ///
    /// - Parameter modifiedSince: modified time
    /// - Returns: all the layouts of the module with the given modified since time
    /// - Throws: ZCRMSDKError if failed to get all layouts
    public func getAllLayouts( modifiedSince : String, completion : @escaping( [ ZCRMLayout ]?, BulkAPIResponse?, Error? ) -> () )
	{
        ModuleAPIHandler(module: self).getAllLayouts( modifiedSince : modifiedSince) { ( layoutList, response, error ) in
            completion( layoutList, response, error )
        }
	}
	
    /// Returns a layout with given layout id
    ///
    /// - Parameter layoutId: layout id
    /// - Returns: layout with given layout id
    /// - Throws: ZCRMSDKError if failed to get a layout
    public func getLayout( layoutId : Int64, completion : @escaping( ZCRMLayout?, APIResponse?, Error? ) -> () )
	{
        ModuleAPIHandler( module : self ).getLayout( layoutId : layoutId) { ( layout, response, error ) in
            completion( layout, response, error )
        }
	}
    
    public func getAllFields( completion : @escaping( [ ZCRMField ]?, BulkAPIResponse?, Error? ) -> () )
    {
        ModuleAPIHandler( module : self ).getAllFields( modifiedSince : nil) { ( allFields, response, error ) in
            completion( allFields, response, error )
        }
    }
    
    ///  Returns list of ZCRMFields of the module(BulkAPIResponse).
    ///
    /// - Parameter modifiedSince: modified time
    /// - Returns: list of ZCRMFields of the module
    /// - Throws: ZCRMSDKError if failed to get all fields
    public func getAllFields( modifiedSince : String, completion : @escaping( [ ZCRMField ]?, BulkAPIResponse?, Error? ) -> () )
    {
        ModuleAPIHandler( module : self ).getAllFields( modifiedSince : modifiedSince) { ( allFields, response, error ) in
            completion( allFields, response, error )
        }
    }
	
    /// Returns the custom views of the module(BulkAPIResponse).
    ///
    /// - Returns: custom views of the module
    /// - Throws: ZCRMSDKError if failed to get the custom views
    public func getAllCustomViews( completion : @escaping( [ ZCRMCustomView ]?, BulkAPIResponse?, Error? ) -> () )
    {
        ModuleAPIHandler(module: self).getAllCustomViews( modifiedSince : nil) { ( allCVs, response, error ) in
            completion( allCVs, response, error )
        }
    }
    
    /// Returns the custom views of the module(BulkAPIResponse) modified after the given time.
    ///
    /// - Parameter modifiedSince: modified time
    /// - Returns: custom views of the module
    /// - Throws: ZCRMSDKError if failed to get the custom views
    public func getAllCustomViews( modifiedSince : String, completion : @escaping( [ ZCRMCustomView ]?, BulkAPIResponse?, Error? ) -> () )
	{
        ModuleAPIHandler(module: self).getAllCustomViews( modifiedSince : modifiedSince ) { ( allCVs, response, error ) in
            completion( allCVs, response, error )
        }
	}
    
    /// Returns custom view with the given cvID of the module(APIResponse).
    ///
    /// - Parameter cvId: Id of the custom view to be returned
    /// - Returns: custom view with the given cvID of the module
    /// - Throws: ZCRMSDKError if failed to get the custom view
    public func getCustomView( cvId : Int64, completion : @escaping( ZCRMCustomView?, APIResponse?, Error? ) -> () )
    {
        ModuleAPIHandler( module : self ).getCustomView( cvId : cvId) { ( customView, response, error ) in
            completion( customView, response, error )
        }
    }
	
    /// Returns ZCRMRecord with the given ID of the module(APIResponse).
    ///
    /// - Parameter recordId: Id of the record to be returned
    /// - Returns: ZCRMRecord with the given ID of the module
    /// - Throws: ZCRMSDKError if failed to get the record
    public func getRecord( recordId : Int64, completion : @escaping( ZCRMRecord?, APIResponse?, Error? ) -> () )
	{
		let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.getAPIName(), recordId: recordId)
        EntityAPIHandler(record: record).getRecord( withPrivateFields : false, completion : { ( rec, response, error ) in
            completion( rec, response, error )
        } )
	}
    
    public func getRecordWithPrivateFields( recordId : Int64, completion : @escaping( ZCRMRecord?, APIResponse?, Error? ) -> () )
    {
        let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.getAPIName(), recordId: recordId)
        EntityAPIHandler(record: record).getRecord( withPrivateFields : true, completion : { ( rec, response, error ) in
            completion( rec, response, error )
        } )
    }
	
    /// Returns List of all records of the module(BulkAPIResponse).
    ///
    /// - Returns: List of all records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords( completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
	{
        MassEntityAPIHandler(module: self).getRecords( cvId : nil, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : false, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
	}
    
    public func getRecordsWithPrivateFields( completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : nil, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : true, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
    }
	
    /// Returns list of all records of the module of a requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - page: page number of the module
    ///   - per_page: number of records to be given for a single page.
    /// - Returns: list of all records of the module of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords(page : Int, per_page : Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> ())
	{
        MassEntityAPIHandler(module: self).getRecords( cvId : nil, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : false, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
	}
    
    public func getRecordsWithPrivateFields(page : Int, per_page : Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> ())
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : nil, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : true, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
    }
	
    /// Returns List of all records of the module with the given cvID(BulkAPIResponse).
    ///
    /// - Parameter cvId: custom view ID
    /// - Returns: List of all records of the module with the given cvID
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords(cvId : Int64, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
	{
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : false, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
	}
    
    public func getRecordsWithPrivateFields(cvId : Int64, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : true, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
    }
	
    /// Returns list of all records of the module of a requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - cvId: custom view ID
    ///   - page: page number of the module
    ///   - per_page: number of records to be given for a single page.
    /// - Returns: list of all records of the module of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords(cvId : Int64, page : Int, per_page : Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> ())
	{
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : false, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
	}
    
    public func getRecordsWithPrivateFields(cvId : Int64, page : Int, per_page : Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> ())
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : true, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
    }
	
    /// Returns list of all records of the module, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - cvId: custom view ID
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    /// - Returns: sorted list of records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords(cvId : Int64, sortByField : String, sortOrder : SortOrder, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> ())
	{
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : false, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
	}
    
    public func getRecordsWithPrivateFields(cvId : Int64, sortByField : String, sortOrder : SortOrder, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> ())
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : true, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
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
    public func getRecords(cvId : Int64, sortByField : String, sortOrder : SortOrder, page : Int, per_page : Int, modifiedSince : String, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
	{
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : nil, page : page, per_page : per_page, modifiedSince : modifiedSince, includePrivateFields : false, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
	}
    
    public func getRecordsWithPrivateFields(cvId : Int64, sortByField : String, sortOrder : SortOrder, page : Int, per_page : Int, modifiedSince : String, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : nil, page : page, per_page : per_page, modifiedSince : modifiedSince, includePrivateFields : true, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
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
    public func getRecords( cvId : Int64?, fields : [String]? , sortByField : String? , sortOrder : SortOrder? , converted : Bool? , approved : Bool? , page : Int , per_page : Int , modifiedSince : String?, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
	{
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : converted , approved : approved, page : page, per_page : per_page, modifiedSince : modifiedSince, includePrivateFields : false, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
	}
    
    public func getRecordsWithPrivateFields( cvId : Int64?, fields : [String]? , sortByField : String? , sortOrder : SortOrder? , converted : Bool? , approved : Bool? , page : Int , per_page : Int , modifiedSince : String?, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : converted , approved : approved, page : page, per_page : per_page, modifiedSince : modifiedSince, includePrivateFields : true, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
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
    public func getApprovedRecords( cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
	{
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : true, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : false, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
	}
    
    public func getApprovedRecordsWithPrivateFields( cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : true, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : true, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
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
    public func getUnApprovedRecords( cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
	{
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : false, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : false, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
	}
    
    public func getUnApprovedRecordsWithPrivateFields( cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : false, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : true, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
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
    public func getConvertedRecords(cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> ())
	{
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : true , approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : false, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
	}
    
    public func getConvertedRecordsWithPrivateFields(cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> ())
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : true , approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : true, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
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
    public func getUnConvertedRecords(cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> ())
	{
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : false, approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : false, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
	}
    
    public func getUnConvertedRecordsWithPrivateFields(cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> ())
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : false, approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : true, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
    }
    
	/// Returns list of all approved records of the module which the given fields.
	///
	/// - Parameters:
	///   - fields : fields apiNames
	/// - Returns: sorted list of records of the module matches the given fields
	/// - Throws: ZCRMSDKError if failed to get the records
    public func getRecordByFields( fields : [String], completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
	{
        MassEntityAPIHandler(module: self).getRecords( cvId : nil, fields : fields , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : false, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
	}
    
    public func getRecordByFieldsWithPrivateFields( fields : [String], completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : nil, fields : fields , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : true, completion : { ( records, response, error ) in
            completion( records, response, error )
        } )
    }
    
    /// Returns List of all deleted records of the module(BulkAPIResponse).
    ///
    /// - Returns: List of all deleted records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getAllDeletedRecords( completion : @escaping( [ ZCRMTrashRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler( module : self ).getAllDeletedRecords { ( trashRecords, response, error ) in
            completion( trashRecords, response, error )
        }
    }
    
    /// Returns List of recycle bin records of the module(BulkAPIResponse).
    ///
    /// - Returns: List of recycle bin records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecycleBinRecords( completion : @escaping( [ ZCRMTrashRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler( module : self ).getRecycleBinRecords { ( trashRecords, response, error ) in
            completion( trashRecords, response, error )
        }
    }
    
    /// Returns List of permanently deleted records of the module(BulkAPIResponse).
    ///
    /// - Returns: List of permanently records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getPermanentlyDeletedRecords( completion : @escaping( [ ZCRMTrashRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler( module : self ).getPermanentlyDeletedRecords { ( trashRecords, response, error ) in
            completion( trashRecords, response, error )
        }
    }
	
    /// Returns list of records which contains the given search text as substring(BulkAPIResponse).
    ///
    /// - Parameter searchText: text to be searched
    /// - Returns: list of records which contains the given search text as substring
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchRecords(searchText: String, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
	{
        MassEntityAPIHandler(module: self).searchByText( searchText: searchText, page: 1, perPage: 200 ) { ( records, response, error ) in
            completion( records, response, error )
        }
	}
	
    /// Returns list of records of the module which contains the given search text as substring, with requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - searchText: text to be searched
    ///   - page: page number of the module
    ///   - per_page: number of records to be given for a single page.
    /// - Returns: list of records of the module which contains the given search text as substring, with requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchRecords(searchText: String, page: Int, per_page: Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> ())
	{
        MassEntityAPIHandler(module: self).searchByText( searchText: searchText, page: page, perPage: per_page) { ( records, response, error ) in
            completion( records, response, error )
        }
	}
    
    /// Returns list of records which satisfies the given criteria(BulkAPIResponse).
    ///
    /// - Parameter criteria: criteria to be searched
    /// - Returns: list of records which satisfies the given criteria
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByCriteria( criteria : String, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByCriteria( searchCriteria : criteria, page : 1, perPage : 200) { ( records, response, error ) in
            completion( records, response, error )
        }
    }
    
    /// Returns list of records of the module which satisfies the given criteria, with requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - criteria: criteria to be searched
    ///   - page: page number of the module
    ///   - perPage: number of records to be given for a single page
    /// - Returns: list of records of the module which satisfies the given criteria, with requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByCriteria( criteria : String, page : Int, perPage : Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByCriteria( searchCriteria : criteria, page : page, perPage : perPage) { ( records, response, error ) in
            completion( records, response, error )
        }
    }
    
    /// Returns list of records of the module which satisfies the given value(BulkAPIResponse).
    ///
    /// - Parameter searchValue: value to be searched
    /// - Returns: list of records of the module which satisfies the given value
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByPhone( searchValue : String, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByPhone( searchValue : searchValue, page : 1, perPage : 200 ) { ( records, response, error ) in
            completion( records, response, error )
        }
    }
    
    /// Returns list of records of the module which satisfies the given value, with requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - searchValue: value to be searched
    ///   - page: page number of the module
    ///   - perPage: number of records to be given for a single page
    /// - Returns: list of records of the module which satisfies the given value, with requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByPhone( searchValue : String, page : Int, perPage : Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByPhone( searchValue : searchValue, page : page, perPage : perPage) { ( records, response, error ) in
            completion( records, response, error )
        }
    }
    
    /// Returns list of records of the module which satisfies the given value(BulkAPIResponse).
    ///
    /// - Parameter searchValue: value to be searched
    /// - Returns: list of records of the module which satisfies the given value
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByEmail( searchValue : String, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByEmail( searchValue : searchValue, page : 1, perPage : 200 ) { ( records, response, error ) in
            completion( records, response, error )
        }
    }
    
    /// Returns list of records of the module which satisfies the given value, with requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - searchValue: value to be searched
    ///   - page: page number of the module
    ///   - perPage: number of records to be given for a single page
    /// - Returns: list of records of the module which satisfies the given value, with requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByEmail( searchValue : String, page : Int, perPage : Int, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByEmail( searchValue : searchValue, page : page, perPage : perPage) { ( records, response, error ) in
            completion( records, response, error )
        }
    }
    
    /// Returns the mass create results of the set of records of the module(BulkAPIResponse).
    ///
    /// - Parameter records: list of ZCRMRecord objects to be created
    /// - Returns: mass create response of the records
    /// - Throws: ZCRMSDKError if failed to create records
    public func createRecords(records: [ZCRMRecord], completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> ())
    {
        MassEntityAPIHandler(module: self).createRecords( records: records) { ( records, response, error ) in
            completion( records, response, error )
        }
    }
	
    /// Returns the mass update results of the set of records of the module(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - recordIds: id's of the record to be updated
    ///   - fieldAPIName: fieldAPIName to which the field value is updated
    ///   - value: field value to be updated
    /// - Returns: mass update response of the records
    /// - Throws: ZCRMSDKError if failed to update records
    public func updateRecords(recordIds: [Int64], fieldAPIName: String, value: Any?, completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> ())
	{
        MassEntityAPIHandler(module: self).updateRecords( ids: recordIds, fieldAPIName: fieldAPIName, value: value) { ( records, response, error ) in
            completion( records, response, error )
        }
	}
    
    /// Returns the upsert results of the set of records of the module(BulkAPIResponse).
    ///
    /// - Parameter records: list of ZCRMRecord objects to be upserted
    /// - Returns: upsert response of the records
    /// - Throws: ZCRMSDKError if failed to upsert records
    public func upsertRecords( records : [ ZCRMRecord ], completion : @escaping( [ ZCRMRecord ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler( module : self ).upsertRecords( records : records) { ( records, response, error ) in
            completion( records, response, error )
        }
    }
    
    /// Returns the mass delete results of the set of records of the module(BulkAPIResponse).
    ///
    /// - Parameter recordIds: id's of the record to be deleted
    /// - Returns: mass delete response of the record
    /// - Throws: ZCRMSDKError if failed to delete records
    public func deleteRecords(recordIds: [Int64], completion : @escaping( BulkAPIResponse?, Error? ) -> () )
    {
        MassEntityAPIHandler(module: self).deleteRecords( ids : recordIds) { ( response, error ) in
            completion( response, error )
        }
    }
    
    public func getTags( completion : @escaping ( [ZCRMTag]?, BulkAPIResponse?, Error? ) -> () )
    {
        TagAPIHandler(module: self).getTags(completion: { ( tags, response, error ) in
            completion( tags, response, error )
        } )
    }
    
    public func createTags( tags : [ZCRMTag], completion : @escaping ( [ZCRMTag]?, BulkAPIResponse?, Error? ) -> () )
    {
        TagAPIHandler(module: self).createTags(tags: tags, completion: { ( tags, response, error ) in
            completion( tags, response, error )
        } )
    }
    
    public func updateTags(tags : [ZCRMTag], completion : @escaping ( [ZCRMTag]?, BulkAPIResponse?, Error? ) -> () )
    {
        TagAPIHandler(module: self).updateTags(tags: tags, completion: { ( tags, response, error ) in
            completion( tags, response, error )
        } )
    }
    
    public func deleteTag( tag : ZCRMTag, completion : @escaping ( APIResponse?, Error? ) -> () )
    {
        TagAPIHandler(tag: tag).deleteTag(completion: { ( response, error ) in
            completion( response, error )
        } )
    }

    public func addTags( recordIds : [Int64], tagNames : [String], completion : @escaping( [ZCRMTag]?, BulkAPIResponse?, Error? ) -> () )
    {
        TagAPIHandler(module: self).addTags(recordIds: recordIds, tagNames: tagNames, overWrite: nil) { (tags, response, error) in
            completion( tags, response, error )
        }
    }
    
    public func addTags( recordIds : [Int64], tagNames : [String], overWrite : Bool?, completion : @escaping( [ZCRMTag]?, BulkAPIResponse?, Error? ) -> () )
    {
        TagAPIHandler(module: self).addTags(recordIds: recordIds, tagNames: tagNames, overWrite: overWrite) { (tags, response, error) in
            completion( tags, response, error )
        }
    }
    
    public func removeTags( recordIds: [Int64], tagNames : [String], completion : @escaping( [ZCRMTag]?, BulkAPIResponse?, Error? ) -> () )
    {
        TagAPIHandler(module: self).removeTags(recordIds: recordIds, tagNames: tagNames) { (tag, response, error) in
            completion( tag, response, error )
        }
    }
}

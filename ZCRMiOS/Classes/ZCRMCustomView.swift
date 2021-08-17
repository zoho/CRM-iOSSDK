//
//  ZCRMCustomView.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 17/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMCustomView : ZCRMEntity
{
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    var moduleAPIName : String
    public internal( set ) var sysName : String?
    public internal( set ) var isDefault : Bool = APIConstants.BOOL_MOCK
    /**
     Name of the custom view
     
     - Note: Cannot update name of system defined custom views
     */
    public var name : String
    {
        didSet
        {
            if oldValue != name
            {
                upsertJSON.updateValue( name, forKey: ModuleAPIHandler.ResponseJSONKeys.name )
            }
        }
    }
    public internal( set ) var displayName : String = APIConstants.STRING_MOCK
    public var fields : [String] = [String]()
    {
        didSet
        {
            var fieldsList : [ [ String : Any ] ] = []
            for fieldName in fields
            {
                fieldsList.append( [ ModuleAPIHandler.ResponseJSONKeys.apiName : fieldName ] )
            }
            if oldValue != fields
            {
                upsertJSON.updateValue( fieldsList, forKey: ModuleAPIHandler.ResponseJSONKeys.fields )
            }
        }
    }
    public internal( set ) var favouriteSequence : Int?
    public internal( set ) var sortByCol : String?
    public internal( set ) var sortOrder : SortOrder?
    public internal( set ) var category : String = APIConstants.STRING_MOCK
    public internal( set ) var isOffline : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isSystemDefined : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var sharedType : SharedUsersCategory.Readable?
    /**
        Criteria of the custom view
     
      - Note : Cannot update the criteria of system defined custom views
     */
    public var criteria : ZCRMQuery.ZCRMCriteria?
    {
        didSet
        {
            upsertJSON.updateValue( criteria?.filterJSON, forKey: ModuleAPIHandler.ResponseJSONKeys.criteria )
        }
    }
    public internal( set ) var sharedDetails : [ SharedDetails ]?
    public internal( set ) var createdBy : ZCRMUserDelegate?
    public internal( set ) var modifiedBy : ZCRMUserDelegate?
    public internal( set ) var modifiedTime : String?
    public internal( set ) var lastAccessedTime : String?
    internal var data : [ String : Any? ] = [:]
    internal var upsertJSON : [ String : Any? ] = [:]
	
    /// Initialise the instance of a custom view with the given custom view Id.
    ///
    /// - Parameters:
    ///   - cvName: custom view Name whose associated custom view is to be initialised
    ///   - moduleAPIName: module API name of a custom view is to be initialised
    init ( name : String, moduleAPIName : String )
    {
        self.name = name
        self.moduleAPIName = moduleAPIName
    }
    
    public func getFilters( completion: @escaping( Result.DataResponse< [ ZCRMFilter ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler( module : ZCRMModuleDelegate( apiName : self.moduleAPIName ), cacheFlavour : .urlVsResponse ).getFilters( cvId : self.id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getFiltersFromServer( completion: @escaping( Result.DataResponse< [ ZCRMFilter ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler( module : ZCRMModuleDelegate( apiName : self.moduleAPIName ), cacheFlavour : .noCache ).getFilters( cvId : self.id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getRecords( recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : ZCRMModuleDelegate( apiName : self.moduleAPIName ) ).getRecords(cvId: self.id, filterId: nil, recordParams: recordParams) { ( result ) in
            completion( result )
        }
    }
}

public extension ZCRMCustomView
{
    struct SharedDetails : Equatable
    {
        public var id : Int64
        public var name : String
        public var type : SelectedUsersType
        public var subordinates : Bool?
    }
}

extension ZCRMCustomView : Hashable
{
    public static func == (lhs: ZCRMCustomView, rhs: ZCRMCustomView) -> Bool {
        var criteriaFlag : Bool = false
        if lhs.criteria == nil && rhs.criteria == nil
        {
            criteriaFlag = true
        }
        else
        {
            return false
        }
        let equals : Bool = lhs.moduleAPIName == rhs.moduleAPIName &&
            lhs.sysName == rhs.sysName &&
            lhs.isDefault == rhs.isDefault &&
            lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.displayName == rhs.displayName &&
            lhs.fields == rhs.fields &&
            lhs.favouriteSequence == rhs.favouriteSequence &&
            lhs.sortByCol == rhs.sortByCol &&
            lhs.sortOrder == rhs.sortOrder &&
            lhs.category == rhs.category &&
            lhs.isOffline == rhs.isOffline &&
            lhs.isSystemDefined == rhs.isSystemDefined &&
            lhs.sharedType == rhs.sharedType &&
            lhs.sharedDetails == rhs.sharedDetails &&
            lhs.criteria == rhs.criteria &&
            lhs.createdBy == rhs.createdBy &&
            lhs.modifiedBy == rhs.modifiedBy &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.lastAccessedTime == rhs.lastAccessedTime &&
            criteriaFlag
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

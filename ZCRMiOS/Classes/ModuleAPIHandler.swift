//
//  ModuleAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 15/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//
import ZCacheiOS

internal struct CriteriaHandling
{
    
    /**
      To set the criteria if the response has a dictionary as criteria
     
     - Parameter criteriaJSON : The response JSON to be parsed to set criteria
     
     - Returns: A ZCRMCriteria object
     */
    static func setCriteria( criteriaJSON : [ String : Any ] ) throws -> ZCRMQuery.ZCRMCriteria?
    {
        var criteriaGroup : ZCRMQuery.ZCRMCriteria?
        if let groups : [ [ String : Any ] ] = criteriaJSON.optArrayOfDictionaries( key : ResponseJSONKeys.group )
        {
            for group in groups
            {
                if group.hasValue( forKey : ResponseJSONKeys.groupOperator )
                {
                    if let criteriaGroup = criteriaGroup, let criteria = try setCriteria( criteriaJSON : group )
                    {
                        let groupOperator = try criteriaJSON.getString(key: ResponseJSONKeys.groupOperator).lowercased()
                        if groupOperator == RequestParamKeys.or
                        {
                            criteriaGroup.or( criteria : criteria )
                        }
                        else
                        {
                            criteriaGroup.and(criteria: criteria)
                        }
                    }
                    else
                    {
                        if let criteria = try setCriteria( criteriaJSON : group )
                        {
                            criteriaGroup = criteria
                        }
                    }
                }
                else
                {
                    let criteria = try ZCRMQuery.ZCRMCriteria( apiName : group.optDictionary( key : ResponseJSONKeys.field )?.getString( key : ResponseJSONKeys.apiName ) ?? group.getString(key: ResponseJSONKeys.field), comparator : group.getString( key : ResponseJSONKeys.comparator ), value : group.getValue(key: ResponseJSONKeys.value ) )
                    if let criteriaGroup = criteriaGroup
                    {
                        let groupOperator = try criteriaJSON.getString(key: ResponseJSONKeys.groupOperator).lowercased()
                        if groupOperator == RequestParamKeys.or
                        {
                            criteriaGroup.or( criteria : criteria )
                        }
                        else
                        {
                            criteriaGroup.and( criteria : criteria )
                        }
                    }
                    else
                    {
                        criteriaGroup = criteria
                    }
                }
            }
        }
        else
        {
            let criteria = try  ZCRMQuery.ZCRMCriteria( apiName : criteriaJSON.optDictionary( key : ResponseJSONKeys.field )?.getString( key : ResponseJSONKeys.apiName ) ?? criteriaJSON.getString(key: ResponseJSONKeys.field), comparator : criteriaJSON.getString( key : ResponseJSONKeys.comparator ), value : criteriaJSON.getValue(key: ResponseJSONKeys.value ) )
            if let criteriaGroup = criteriaGroup
            {
                criteriaGroup.and( criteria : criteria )
            }
            else
            {
                criteriaGroup = criteria
            }
        }
        return criteriaGroup
    }
    
    static func setCriteria( criteriaArray : [ Any ] ) throws -> ZCRMQuery.ZCRMCriteria?
    {
        var criteriaGroup : ZCRMQuery.ZCRMCriteria?
        var groupOperator : String = String()
        for criteriaJSON in criteriaArray
        {
            if let criteria = criteriaJSON as? [ Any ]
            {
                if let criteriaGroup = criteriaGroup, let criteriaObj = try setCriteria(criteriaArray: criteria)
                {
                    if groupOperator == RequestParamKeys.or
                    {
                        criteriaGroup.or(criteria: criteriaObj)
                    }
                    else
                    {
                        criteriaGroup.and( criteria : criteriaObj )
                    }
                }
                else
                {
                    if let criteria = try setCriteria(criteriaArray: criteria)
                    {
                        criteriaGroup = criteria
                    }
                }
            }
            else if let group = criteriaJSON as? [ String : Any ]
            {
                let criteria = try  ZCRMQuery.ZCRMCriteria( apiName : group.optDictionary( key : ResponseJSONKeys.field )?.getString( key : ResponseJSONKeys.apiName ) ?? group.getString(key: ResponseJSONKeys.field), comparator : group.getString( key : ResponseJSONKeys.comparator ), value : group.getValue(key: ResponseJSONKeys.value ) )
                if let criteriaGroup = criteriaGroup
                {
                    if groupOperator == RequestParamKeys.or
                    {
                        criteriaGroup.or(criteria: criteria)
                    }
                    else
                    {
                        criteriaGroup.and( criteria : criteria )
                    }
                }
                else
                {
                    criteriaGroup = criteria
                }
            }
            else if let groupOp = criteriaJSON as? String
            {
                groupOperator = groupOp
            }
        }
        return criteriaGroup
    }
    
    struct ResponseJSONKeys
    {
        static let apiName = "api_name"
        static let groupOperator = "group_operator"
        static let group = "group"
        static let comparator = "comparator"
        static let field = "field"
        static let value = "value"
    }
}

internal class ModuleAPIHandler : CommonAPIHandler
{
    internal let module : ZCRMModuleDelegate
    internal let cache : CacheFlavour
    
    init( module : ZCRMModuleDelegate, cacheFlavour : CacheFlavour )
    {
        self.module = module
        self.cache = cacheFlavour
    }
	
    override func setModuleName() {
        self.requestedModule = module.apiName
    }
    
	// MARK: - Handler functions
    internal func getAllLayouts( modifiedSince : String?, completion: @escaping( CRMResultType.DataResponse< [ ZCRMLayout ], BulkAPIResponse > ) -> () )
    {
        setIsCacheable(true)
		setJSONRootKey( key : JSONRootKey.LAYOUTS )
        var layouts : [ZCRMLayout] = [ZCRMLayout]()
		setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.layouts )")
		setRequestMethod(requestMethod: .get )
        addRequestParam( param : RequestParamKeys.module, value : self.module.apiName )
		if modifiedSince.notNilandEmpty, let modifiedSince = modifiedSince
		{ 
			addRequestHeader( header : RequestParamKeys.ifModifiedSince , value : modifiedSince )
		}
		let request : APIRequest = APIRequest( handler : self, cacheFlavour : self.cache )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
		
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    layouts = try self.getAllLayouts( layoutsList : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) )
                    if layouts.isEmpty == true
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                }
                bulkResponse.setData( data : layouts )
                completion( .success( layouts, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getLayout( layoutId : String, completion: @escaping( CRMResultType.DataResponse< ZCRMLayout, APIResponse > ) -> () )
    {
        setIsCacheable(true)
        setJSONRootKey( key : JSONRootKey.LAYOUTS )
		setUrlPath(urlPath:  "\( URLPathConstants.settings )/\( URLPathConstants.layouts )/\(layoutId)")
		setRequestMethod(requestMethod: .get )
		addRequestParam( param : RequestParamKeys.module, value : self.module.apiName )
		let request : APIRequest = APIRequest( handler : self, cacheFlavour : self.cache )
		ZCRMLogger.logDebug(message: "Request : \(request.toString())")
		
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let layoutsList : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let layout = try self.getZCRMLayout( layoutDetails : layoutsList[ 0 ] )
                response.setData(data: layout )
                completion( .success( layout, response ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getAllFields( modifiedSince : String?, completion: @escaping( CRMResultType.DataResponse< [ ZCRMField ], BulkAPIResponse > ) -> () )
    {
        setIsCacheable( true )
        setJSONRootKey( key : JSONRootKey.FIELDS )
        var fields : [ZCRMField] = [ZCRMField]()
        setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.fields )")
        setRequestMethod(requestMethod: .get )
		addRequestParam( param : RequestParamKeys.module, value : self.module.apiName )
        if modifiedSince.notNilandEmpty, let modifiedSince = modifiedSince
        {
            addRequestHeader( header : RequestParamKeys.ifModifiedSince , value : modifiedSince )
        }
		let request : APIRequest = APIRequest( handler : self, cacheFlavour : self.cache )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
		
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    fields = try self.getAllFields( allFieldsDetails : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) )
                    if fields.isEmpty == true
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                }
                bulkResponse.setData( data : fields )
                completion( .success( fields, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getField( fieldId : String, completion: @escaping( CRMResultType.DataResponse< ZCRMField, APIResponse > ) -> () )
    {
        setIsCacheable(true)
        setJSONRootKey( key : JSONRootKey.FIELDS )
        setUrlPath( urlPath : "\( URLPathConstants.settings )/\( URLPathConstants.fields )/\( fieldId )" )
        setRequestMethod( requestMethod : .get )
        addRequestParam( param : RequestParamKeys.module, value : self.module.apiName )
        let request : APIRequest = APIRequest( handler : self, cacheFlavour : self.cache )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let fieldsList : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let field = try self.getZCRMField( fieldDetails : fieldsList[ 0 ] )
                response.setData( data : field )
                completion( .success( field, response ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getAllCustomViews( modifiedSince : String?, completion: @escaping( CRMResultType.DataResponse< [ ZCRMCustomView ], BulkAPIResponse > ) -> () )
    {
        setIsCacheable(true)
        setJSONRootKey( key : JSONRootKey.CUSTOM_VIEWS )
		setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.customViews )")
		setRequestMethod(requestMethod: .get )
		addRequestParam( param : RequestParamKeys.module, value : self.module.apiName )
        if modifiedSince.notNilandEmpty, let modifiedSince = modifiedSince
        {
            addRequestHeader( header : RequestParamKeys.ifModifiedSince , value : modifiedSince )
        }
		let request : APIRequest = APIRequest( handler : self, cacheFlavour : self.cache )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
		
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                var allCVs : [ZCRMCustomView] = [ZCRMCustomView]()
                if responseJSON.isEmpty == false
                {
                    let allCVsList : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    if allCVsList.isEmpty == true
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    for cvDetails in allCVsList
                    {
                        allCVs.append(try self.getZCRMCustomView(cvDetails: cvDetails))
                    }
                }
                bulkResponse.setData(data: allCVs)
                completion( .success( allCVs, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getRelatedList( id : Int64, completion: @escaping( CRMResultType.DataResponse< ZCRMModuleRelation, APIResponse > ) -> () )
    {
        setIsCacheable(true)
        setJSONRootKey( key : JSONRootKey.RELATED_LISTS )
        setUrlPath( urlPath : "\( URLPathConstants.settings )/\( URLPathConstants.relatedLists )/\(id)" )
        setRequestMethod( requestMethod : .get )
        addRequestParam( param : RequestParamKeys.module, value : self.module.apiName )
        let request : APIRequest = APIRequest( handler : self, cacheFlavour : self.cache )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.responseJSON
                let relatedList = try self.getAllRelatedLists( relatedListsDetails : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) )[ 0 ]
                response.setData( data : relatedList )
                completion( .success( relatedList, response ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getAllRelatedLists( completion: @escaping( CRMResultType.DataResponse< [ ZCRMModuleRelation ], BulkAPIResponse > ) -> () )
    {
        setIsCacheable(true)
        setJSONRootKey( key : JSONRootKey.RELATED_LISTS )
        var relatedLists : [ZCRMModuleRelation] = [ZCRMModuleRelation]()
        setUrlPath( urlPath : "\( URLPathConstants.settings )/\( URLPathConstants.relatedLists )" )
        setRequestMethod( requestMethod : .get )
        addRequestParam( param : RequestParamKeys.module, value : self.module.apiName )
        let request : APIRequest = APIRequest( handler : self, cacheFlavour : self.cache )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    relatedLists = try self.getAllRelatedLists( relatedListsDetails : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) )
                    if relatedLists.isEmpty == true
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                }
                bulkResponse.setData( data : relatedLists )
                completion( .success( relatedLists, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getCustomView( cvId : Int64, completion: @escaping( CRMResultType.DataResponse< ZCRMCustomView, APIResponse > ) -> () )
    {
        setIsCacheable(true)
        setJSONRootKey( key :  JSONRootKey.CUSTOM_VIEWS )
		setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.customViews )/\(cvId)" )
		setRequestMethod(requestMethod: .get )
		addRequestParam( param : RequestParamKeys.module, value : self.module.apiName )
		let request : APIRequest = APIRequest( handler : self, cacheFlavour : self.cache )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let cvArray : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let customView = try self.getZCRMCustomView( cvDetails : cvArray[ 0 ] )
                response.setData( data : customView )
                completion( .success( customView, response ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getFilters( cvId : Int64, completion: @escaping( CRMResultType.DataResponse< [ ZCRMFilter ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.FILTERS )
        setUrlPath( urlPath : "\( URLPathConstants.settings )/\( URLPathConstants.customViews )/\( cvId )/\( URLPathConstants.filters )" )
        setRequestMethod( requestMethod : .get )
        addRequestParam( param : RequestParamKeys.module, value : self.module.apiName )
        let request : APIRequest = APIRequest( handler : self, cacheFlavour : self.cache )
        ZCRMLogger.logDebug( message : "Request : \(request.toString())" )
        
        request.getBulkAPIResponse { ( resultType ) in
            do
            {
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                var filters : [ ZCRMFilter ] = [ ZCRMFilter ]()
                if responseJSON.isEmpty == false
                {
                    let filtersDetails : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    if filtersDetails.isEmpty == true
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.responseNil ) : \( ErrorMessage.responseJSONNilMsg ), \( APIConstants.DETAILS ) : -" )
                        completion( .failure( ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    filters = try self.getZCRMFilters( filtersDetails : filtersDetails, cvId : cvId )
                }
                bulkResponse.setData( data : filters )
                completion( .success( filters, bulkResponse ) )
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
	
	// MARK: - Utility functions
    private func getAllRelatedLists( relatedListsDetails : [ [ String : Any ] ] ) throws -> [ ZCRMModuleRelation ]
    {
        var relatedLists : [ ZCRMModuleRelation ] = [ ZCRMModuleRelation ]()
        for relatedListDetials in relatedListsDetails
        {
            relatedLists.append( try self.getZCRMModuleRelation( relationListDetails : relatedListDetials ) )
        }
        return relatedLists
    }
    
	internal func getZCRMCustomView(cvDetails: [String:Any]) throws -> ZCRMCustomView
    {
        let customView : ZCRMCustomView = ZCRMCustomView( name : try cvDetails.getString( key : ResponseJSONKeys.name ), moduleAPIName : self.module.apiName )
        customView.id = try cvDetails.getInt64( key : ResponseJSONKeys.id )
        if( cvDetails.hasValue(forKey: ResponseJSONKeys.systemName))
        {
            customView.sysName = try cvDetails.getString( key : ResponseJSONKeys.systemName )
        }
        if( cvDetails.hasValue(forKey: ResponseJSONKeys.displayValue))
        {
            customView.displayName = try cvDetails.getString( key : ResponseJSONKeys.displayValue )
        }
        if( cvDetails.hasValue(forKey: ResponseJSONKeys.defaultString))
        {
            customView.isDefault = try cvDetails.getBoolean( key : ResponseJSONKeys.defaultString )
        }
        if( cvDetails.hasValue(forKey: ResponseJSONKeys.category))
        {
            customView.category = try cvDetails.getString( key : ResponseJSONKeys.category )
        }
        if( cvDetails.hasValue(forKey: ResponseJSONKeys.favorite))
        {
            customView.favouriteSequence = try cvDetails.getInt( key : ResponseJSONKeys.favorite )
        }
        if cvDetails.hasValue( forKey : ResponseJSONKeys.fields ), let fields = try cvDetails.getArray( key : ResponseJSONKeys.fields ) as? [ String ]
        {
            customView.fields = fields
        }
        else if cvDetails.hasValue( forKey : ResponseJSONKeys.fields ), let fields = try cvDetails.getArrayOfDictionaries( key : ResponseJSONKeys.fields ) as? [ [ String : String ] ]
        {
            for field in fields
            {
                customView.fields.append( try field.getString( key: ResponseJSONKeys.apiName ) )
            }
        }
        if(cvDetails.hasValue(forKey: ResponseJSONKeys.sortBy))
        {
            customView.sortByCol = cvDetails.optString(key: ResponseJSONKeys.sortBy)
        }
        if let sortOrder = cvDetails.optString(key: ResponseJSONKeys.sortOrder).map({ SortOrder(rawValue: $0) })
        {
            customView.sortOrder = sortOrder
        }
        if cvDetails.hasValue( forKey : ResponseJSONKeys.offline )
        {
            customView.isOffline = try cvDetails.getBoolean(key: ResponseJSONKeys.offline)
        }
        if( cvDetails.hasValue(forKey: ResponseJSONKeys.systemDefined))
        {
            customView.isSystemDefined = try cvDetails.getBoolean( key : ResponseJSONKeys.systemDefined )
        }
        if cvDetails.hasValue(forKey: ResponseJSONKeys.sharedType)
        {
            customView.sharedType = try cvDetails.getString(key: ResponseJSONKeys.sharedType)
        }
        if cvDetails.hasValue(forKey: ResponseJSONKeys.criteria)
        {
            if let criteriaJSON = cvDetails.optDictionary(key: ResponseJSONKeys.criteria)
            {
                if let criteria = try CriteriaHandling.setCriteria(criteriaJSON: criteriaJSON )
                {
                    customView.criteria = criteria
                }
            }
            else
            {
                if let criteria = try CriteriaHandling.setCriteria(criteriaArray: cvDetails.getArray(key: ResponseJSONKeys.criteria))
                {
                    customView.criteria = criteria
                }
            }
        }
        if cvDetails.hasValue(forKey: ResponseJSONKeys.sharedDetails)
        {
            customView.sharedDetails = try cvDetails.getString(key: ResponseJSONKeys.sharedDetails)
        }
        return customView
    }
    
    internal func getAllLayouts(layoutsList : [[String : Any]]) throws -> [ZCRMLayout]
    {
        var allLayouts : [ZCRMLayout] = [ZCRMLayout]()
        for layout in layoutsList
        {
            allLayouts.append( try self.getZCRMLayout(layoutDetails: layout))
        }
        return allLayouts
    }
    
    internal func getZCRMLayout(layoutDetails : [String : Any]) throws -> ZCRMLayout
    {
        let layout : ZCRMLayout = ZCRMLayout( name : try layoutDetails.getString( key : ResponseJSONKeys.name ) )
        if( layoutDetails.hasValue(forKey: ResponseJSONKeys.id))
        {
            layout.id = try layoutDetails.getString(key: ResponseJSONKeys.id)
        }
        if( layoutDetails.hasValue(forKey: ResponseJSONKeys.visible))
        {
            layout.isVisible = try layoutDetails.getBoolean(key: ResponseJSONKeys.visible)
        }
        if ( layoutDetails.hasValue(forKey: ResponseJSONKeys.status))
        {
            layout.status = try layoutDetails.getInt( key : ResponseJSONKeys.status )
        }
        if(layoutDetails.hasValue(forKey: ResponseJSONKeys.createdBy))
        {
            let createdByObj : [ String : Any ] = try layoutDetails.getDictionary( key : ResponseJSONKeys.createdBy )
            layout.createdBy = try getUserDelegate(userJSON : createdByObj)
            layout.createdTime = try layoutDetails.getString( key : ResponseJSONKeys.createdTime )
        }
        if( layoutDetails.hasValue( forKey : ResponseJSONKeys.modifiedBy ) )
        {
            let modifiedByObj : [ String : Any ] = try layoutDetails.getDictionary( key : ResponseJSONKeys.modifiedBy )
            layout.modifiedBy = try getUserDelegate(userJSON : modifiedByObj)
            layout.modifiedTime = try layoutDetails.getString( key : ResponseJSONKeys.modifiedTime )
        }
        let profilesDetails : [ [ String : Any ] ] = try layoutDetails.getArrayOfDictionaries( key : ResponseJSONKeys.profiles )
        for profileDetails in profilesDetails
        {
            let profile : ZCRMProfileDelegate = ZCRMProfileDelegate( id : try profileDetails.getInt64( key : ResponseJSONKeys.id ), name : try profileDetails.getString( key : ResponseJSONKeys.name ), isDefault : try profileDetails.getBoolean( key : ResponseJSONKeys.defaultString ) )
            layout.accessibleProfiles.append( profile )
        }
        let sectionDetails : [ [ String : Any ] ] = try layoutDetails.getArrayOfDictionaries( key : ResponseJSONKeys.sections )
        let sections : [ZCRMSection] = try self.getAllSectionsOfLayout(allSectionsDetails: sectionDetails)
        layout.sections = sections
        return layout
    }
    
    internal func getAllSectionsOfLayout(allSectionsDetails : [[String:Any]]) throws -> [ZCRMSection]
    {
        var allSections : [ZCRMSection] = [ZCRMSection]()
        for sectionDetails in allSectionsDetails
        {
            allSections.append( try self.getZCRMSection(sectionDetails: sectionDetails))
        }
        return allSections
    }
    
    internal func getZCRMSection(sectionDetails : [String:Any]) throws -> ZCRMSection
    {
        let section : ZCRMSection = ZCRMSection( apiName : self.module.apiName )
        section.name = try sectionDetails.getString( key : ResponseJSONKeys.name )
        section.displayName = try sectionDetails.getString( key : ResponseJSONKeys.displayLabel )
        section.columnCount = try sectionDetails.getInt( key : ResponseJSONKeys.columnCount )
        section.sequence = try sectionDetails.getInt( key : ResponseJSONKeys.sequenceNumber )
        section.fields = try self.getAllFields(allFieldsDetails: sectionDetails.getArrayOfDictionaries(key: ResponseJSONKeys.fields) )
        section.isSubformSection = try sectionDetails.getBoolean( key : ResponseJSONKeys.isSubformSection )
        if sectionDetails.hasValue(forKey: ResponseJSONKeys.properties)
        {
            let properties = try sectionDetails.getDictionary(key: ResponseJSONKeys.properties)
            if sectionDetails.hasValue(forKey: ResponseJSONKeys.reorderRows)
            {
                section.reorderRows = try properties.getBoolean(key: ResponseJSONKeys.reorderRows)
            }
            section.tooltip = properties.optString(key: ResponseJSONKeys.tooltip)
            section.maximumRows = properties.optInt(key: ResponseJSONKeys.maximumRows)
        }
        return section
    }
    
    internal func getAllFields(allFieldsDetails : [[String : Any]]) throws -> [ZCRMField]
    {
        var allFields : [ZCRMField] = [ZCRMField]()
        for fieldDetails in allFieldsDetails
        {
            allFields.append(try self.getZCRMField(fieldDetails: fieldDetails))
        }
        return allFields
    }
    
    internal func getZCRMField(fieldDetails : [String:Any]) throws -> ZCRMField
    {
        let field : ZCRMField = ZCRMField( apiName : try fieldDetails.getString( key : ResponseJSONKeys.apiName ) )
        field.id = try fieldDetails.getString( key : ResponseJSONKeys.id )
        field.displayLabel = try fieldDetails.getString( key : ResponseJSONKeys.fieldLabel )
        if fieldDetails.hasValue(forKey: ResponseJSONKeys.length)
        {
            field.maxLength = try fieldDetails.getInt( key : ResponseJSONKeys.length )
        }
        field.dataType = try fieldDetails.getString(key: ResponseJSONKeys.dataType)
        field.isVisible = try fieldDetails.getBoolean(key: ResponseJSONKeys.visible)
        field.precision = fieldDetails.optInt(key: ResponseJSONKeys.decimalPlace)
        field.isReadOnly = try fieldDetails.getBoolean(key: ResponseJSONKeys.readOnly)
        field.isCustomField = try fieldDetails.getBoolean(key: ResponseJSONKeys.customField)
        if let anyValue = fieldDetails.optValue(key: ResponseJSONKeys.defaultValue) {
            field.defaultValue = JSONValue(value: anyValue)
        }
        if fieldDetails.hasValue( forKey : ResponseJSONKeys.required )
        {
            field.isMandatory = try fieldDetails.getBoolean( key : ResponseJSONKeys.required )
        }
        else
        {
            field.isMandatory = try fieldDetails.getBoolean( key : ResponseJSONKeys.systemMandatory )
        }
        field.sequenceNo = fieldDetails.optInt(key: ResponseJSONKeys.sequenceNumber)
        field.tooltip = fieldDetails.optString(key: ResponseJSONKeys.toolTip)
        field.webhook = try fieldDetails.getBoolean( key : ResponseJSONKeys.webhook )
        field.createdSource = try fieldDetails.getString( key : ResponseJSONKeys.createdSource )
        
        let lookUpDict = fieldDetails.optDictionary(key: ResponseJSONKeys.lookup)
        var newLookUpDict: [String: JSONValue] = [:]
        if let lookUpDict = lookUpDict {
            for (key, value) in lookUpDict {
                newLookUpDict[key] = JSONValue(value: value)
            }
        }
        field.lookup = newLookUpDict
        
        let multiSelectLookupDict = fieldDetails.optDictionary(key: ResponseJSONKeys.multiSelectLookup)
        var newMultiSelectLookupDict: [String: JSONValue] = [:]
        if let multiSelectLookupDict = multiSelectLookupDict {
            for (key, value) in multiSelectLookupDict {
                newMultiSelectLookupDict[key] = JSONValue(value: value)
            }
        }
        field.multiSelectLookup = newMultiSelectLookupDict
        
        field.subFormTabId = fieldDetails.optInt64(key: ResponseJSONKeys.subformTabId)
        
        let subFormDict = fieldDetails.optDictionary(key: ResponseJSONKeys.subform)
        var newSubFormDict: [String: JSONValue] = [:]
        if let subFormDict = subFormDict {
            for (key, value) in subFormDict {
                newSubFormDict[key] = JSONValue(value: value)
            }
        }
        field.subForm = newSubFormDict
        
        if(fieldDetails.hasValue(forKey: ResponseJSONKeys.currency))
        {
            let currencyDetails : [ String : Any ] = try fieldDetails.getDictionary( key : ResponseJSONKeys.currency )
            field.currencyPrecision = currencyDetails.optInt(key: ResponseJSONKeys.precision)
            if let roundingOption = currencyDetails.optString(key: ResponseJSONKeys.roundingOption)
            {
                guard let rounding = CurrencyRoundingOption(rawValue: roundingOption) else
                {
                    throw ZCRMError.inValidError( code : ErrorCode.invalidData, message : "\(ResponseJSONKeys.roundingOption) has invalid value", details : nil )
                }
                field.roundingOption = rounding
            }
        }
        field.isBusinessCardSupported = fieldDetails.optBoolean(key: ResponseJSONKeys.businessCardSupported)
        if ( fieldDetails.hasValue( forKey : ResponseJSONKeys.pickListValues ) )
        {
            let pickListValues = try fieldDetails.getArrayOfDictionaries( key : ResponseJSONKeys.pickListValues )
            for pickListValueDict in pickListValues
            {
                if let displayValue = pickListValueDict.optString( key : ResponseJSONKeys.displayValue ), let actualValue = pickListValueDict.optString( key : ResponseJSONKeys.actualValue )
                {
                    let pickListValue = ZCRMPickListValue(displayName: displayValue, actualName: actualValue  )
                    
                    var newPickListArr: [[String:JSONValue]] = [[:]]
                    if let pickListArr = pickListValueDict.optArrayOfDictionaries( key : ResponseJSONKeys.maps ) {
                        
                        for item in pickListArr {
                            var newPickListDict: [String:JSONValue] = [:]
                            for (key, value) in item {
                                newPickListDict[key] = JSONValue(value: value)
                            }
                            newPickListArr.append(newPickListDict)
                        }
                    }
                    pickListValue.maps = newPickListArr
                    
                    if pickListValueDict.hasValue( forKey : ResponseJSONKeys.sequenceNumber )
                    {
                        pickListValue.sequenceNumber = try pickListValueDict.getInt( key : ResponseJSONKeys.sequenceNumber )
                    }
                    field.addPickListValue( pickListValue : pickListValue )
                }
            }
        }
        if fieldDetails.hasValue( forKey : ResponseJSONKeys.formula ), let formulaDetails : [ String : String ] = try fieldDetails.getDictionary( key : ResponseJSONKeys.formula ) as? [ String : String ]
        {
            field.formulaReturnType = formulaDetails.optString(key: ResponseJSONKeys.returnType)
            field.formulaExpression = formulaDetails.optString(key: ResponseJSONKeys.expression)
        }
        if(fieldDetails.hasValue(forKey: ResponseJSONKeys.currency))
        {
            let currencyDetails : [ String : Any ] = try fieldDetails.getDictionary( key : ResponseJSONKeys.currency )
            field.currencyPrecision = currencyDetails.optInt(key: ResponseJSONKeys.precision)
        }
        if fieldDetails.hasValue( forKey : ResponseJSONKeys.viewType ), let subLayouts : [ String : Bool ] = try fieldDetails.getDictionary( key : ResponseJSONKeys.viewType ) as? [ String : Bool ]
        {
            var layoutsPresent : [String] = [String]()
            if( try subLayouts.getBoolean( key : ResponseJSONKeys.create ) )
            {
                layoutsPresent.append(SubLayoutViewType.create.rawValue)
            }
            if( try subLayouts.getBoolean( key : ResponseJSONKeys.edit ) )
            {
                layoutsPresent.append(SubLayoutViewType.edit.rawValue)
            }
            if( try subLayouts.getBoolean( key : ResponseJSONKeys.view ) )
            {
                layoutsPresent.append(SubLayoutViewType.view.rawValue)
            }
            if( try subLayouts.getBoolean( key : ResponseJSONKeys.quickCreate ) )
            {
                layoutsPresent.append(SubLayoutViewType.quickCreate.rawValue)
            }
            field.subLayoutsPresent = layoutsPresent
        }
        if( fieldDetails.hasValue( forKey : ResponseJSONKeys.privateString ) )
        {
            let privateDetails : [ String : Any ] = try fieldDetails.getDictionary( key : ResponseJSONKeys.privateString )
            field.isRestricted = privateDetails.optBoolean( key : ResponseJSONKeys.restricted )
            field.isExportable = privateDetails.optBoolean( key : ResponseJSONKeys.export )
            field.restrictedType = privateDetails.optString( key : ResponseJSONKeys.type )
        }
        
        // Setting config in field for caching
        if field.dataType == "ownerlookup" || field.dataType == "userlookup" || field.dataType == "multiuserlookup"
        {
            field.lookupModules = ["USERS"]
            field.type = DataType.user_lookup
        }
        else if field.dataType == "picklist"
        {
            field.type = DataType.picklist
        }
        else if field.dataType == "multiselectpicklist" && field.apiName == "Tax"
        {
            field.type = DataType.multi_select_picklist
        }
        else if (field.apiName == "Tag" && field.dataType == "text") || (field.dataType == "multiselectpicklist")
        {
            if field.dataType == "text"
            {
                field.type = DataType.text
            }
            else
            {
                field.type = DataType.multi_select_picklist
            }
        }
        else if (field.dataType == "text" && field.apiName == "Product_Details") || field.dataType == "text" || field.dataType == "email" || field.dataType == "phone" || field.dataType == "date" || field.dataType == "datetime" || field.dataType == "profileimage" || field.dataType == "fileupload" || field.dataType == "multiselectlookup" || field.dataType == "consent_lookup"
        {
            field.type = DataType.text
        }
        else if field.dataType == "lookup"
        {
            field.type = DataType.lookup
            if let value = field.lookup?["module"], let module = value.value
            {
                let moduleName = String(describing: module)
                if (moduleName != "se_module")
                {
                    field.lookupModules = [moduleName]
                }
            }
            if !field.lookupModules.isEmpty && field.lookupModules[0] == "Accounts"
            {
                field.constraintType = ConstraintType.on_delete_cascade
            }
            else if field.apiName == "What_Id"
            {
                field.constraintType = ConstraintType.on_delete_cascade
            }
            else
            {
                field.constraintType = ConstraintType.on_delete_set_null
            }
        }
        else if field.dataType == "bigint"
        {
            field.type = DataType.bigint
        }
        else if field.dataType == "boolean"
        {
            field.type = DataType.bool
        }
        else if field.dataType == "currency" || field.dataType == "double" || field.dataType == "formula"
        {
            field.type = DataType.double
        }
        else if field.dataType == "subform"
        {
            field.type = DataType.subform
            if let value = field.subForm?["module"], let module = value.value
            {
                let moduleName = String(describing: module)
                if (moduleName != "se_module")
                {
                    field.lookupModules = [moduleName]
                }
            }
        }
        
        return field
    }
    
    internal func getZCRMModuleRelation( relationListDetails : [ String : Any ] ) throws -> ZCRMModuleRelation
    {
        let moduleRelation : ZCRMModuleRelation = ZCRMModuleRelation( parentModuleAPIName : module.apiName, relatedListId : try relationListDetails.getInt64( key : ResponseJSONKeys.id ) )
        moduleRelation.apiName = try relationListDetails.getString( key : ResponseJSONKeys.apiName )
        moduleRelation.label = try relationListDetails.getString( key : ResponseJSONKeys.displayLabel )
        if relationListDetails.hasValue( forKey : ResponseJSONKeys.module )
        {
            moduleRelation.module = try relationListDetails.getString( key : ResponseJSONKeys.module )
        }
        moduleRelation.name = try relationListDetails.getString( key : ResponseJSONKeys.name)
        moduleRelation.type = try relationListDetails.getString( key : ResponseJSONKeys.type )
        if let seqNo = Int( try relationListDetails.getString( key : ResponseJSONKeys.sequenceNumber ) )
        {
            moduleRelation.sequenceNo = seqNo
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.typeCastError) : Expected type -> INT, \( APIConstants.DETAILS ) : nil")
            throw ZCRMError.processingError( code : ErrorCode.typeCastError, message : "Expected type -> INT", details : nil )
        }
        if relationListDetails.hasValue( forKey : ResponseJSONKeys.href )
        {
            moduleRelation.href = try relationListDetails.getString( key : ResponseJSONKeys.href )
        }
        moduleRelation.action = relationListDetails.optString(key: ResponseJSONKeys.action)
        return moduleRelation
    }
    
    private func getZCRMFilters( filtersDetails : [ [ String : Any ] ], cvId : Int64 ) throws -> [ ZCRMFilter ]
    {
        var filters : [ ZCRMFilter ] = [ ZCRMFilter ]()
        for filterDetails in filtersDetails
        {
            filters.append( try self.getZCRMFilter( filterDetails : filterDetails, cvId : cvId ) )
        }
        return filters
    }
    
    private func getZCRMFilter( filterDetails : [ String : Any ], cvId : Int64 ) throws -> ZCRMFilter
    {
        let filter : ZCRMFilter = ZCRMFilter( id : try filterDetails.getInt64( key : ResponseJSONKeys.id ), name : try filterDetails.getString( key : ResponseJSONKeys.name ), parentCvId : cvId, moduleAPIName : self.module.apiName )
        if filterDetails.hasValue( forKey : ResponseJSONKeys.criteria )
        {
            filter.criteria = try CriteriaHandling.setCriteria( criteriaJSON : filterDetails.getDictionary( key : ResponseJSONKeys.criteria ) )
        }
        return filter
    }
}

internal extension ModuleAPIHandler
{
    struct ResponseJSONKeys
    {
        static let id = "id"
        static let name = "name"
        static let systemName = "system_name"
        static let displayValue = "display_value"
        static let defaultString = "default"
        static let category = "category"
        static let favorite = "favorite"
        static let fields = "fields"
        static let sortBy = "sort_by"
        static let sortOrder = "sort_order"
        static let offline = "offline"
        static let systemDefined = "system_defined"
        
        static let visible = "visible"
        static let status = "status"
        static let createdBy = "created_by"
        static let createdTime = "created_time"
        static let modifiedBy = "modified_by"
        static let modifiedTime = "modified_time"
        static let profiles = "profiles"
        static let sections = "sections"
        
        static let displayLabel = "display_label"
        static let columnCount = "column_count"
        static let sequenceNumber = "sequence_number"
        static let isSubformSection = "isSubformSection"
        
        static let apiName = "api_name"
        static let fieldLabel = "field_label"
        static let length = "length"
        static let dataType = "data_type"
        static let decimalPlace = "decimal_place"
        static let readOnly = "read_only"
        static let customField = "custom_field"
        static let defaultValue = "default_value"
        static let systemMandatory = "system_mandatory"
        static let toolTip = "tooltip"
        static let webhook = "webhook"
        static let createdSource = "created_source"
        static let lookup = "lookup"
        static let multiSelectLookup = "multiselectlookup"
        static let subformTabId = "subformtabid"
        static let subform = "subform"
        static let currency = "currency"
        static let precision = "precision"
        static let roundingOption = "rounding_option"
        static let businessCardSupported = "businesscard_supported"
        static let pickListValues = "pick_list_values"
        static let maps = "maps"
        static let actualValue = "actual_value"
        static let formula = "formula"
        static let returnType = "return_type"
        static let expression = "expression"
        static let viewType = "view_type"
        static let create = "create"
        static let edit = "edit"
        static let view = "view"
        static let quickCreate = "quick_create"
        static let privateString = "private"
        static let restricted = "restricted"
        static let export = "export"
        static let type = "type"
        static let action = "action"
        static let module = "module"
        
        static let criteria = "criteria"
        
        static let sharedType = "shared_type"
        static let sharedDetails = "shared_details"
        static let href = "href"
        
        static let reorderRows = "reorder_rows"
        static let tooltip = "tooltip"
        static let maximumRows = "maximum_rows"
        static let properties = "properties"
        static let required = "required"
        
        static let count = "count"
    }
    
    struct URLPathConstants {
        static let settings = "settings"
        static let layouts = "layouts"
        static let fields = "fields"
        static let customViews = "custom_views"
        static let relatedLists = "related_lists"
        static let stages = "stages"
        static let __internal = "__internal"
        static let ignite = "ignite"
        static let activities = "activities"
        static let filters = "filters"
    }

    enum SubLayoutViewType : String
    {
        case create = "CREATE"
        case edit = "EDIT"
        case view = "VIEW"
        case quickCreate = "QUICK_CREATE"
    }
}


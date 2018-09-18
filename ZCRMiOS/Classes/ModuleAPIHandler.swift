//
//  ModuleAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 15/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class ModuleAPIHandler : CommonAPIHandler
{
    private let module : ZCRMModuleDelegate
    
    init(module : ZCRMModuleDelegate)
    {
        self.module = module
    }
	
	// MARK: - Handler functions
    internal func getAllLayouts( modifiedSince : String?, completion: @escaping( Result.DataResponse< [ ZCRMLayout ], BulkAPIResponse > ) -> () )
    {
		setJSONRootKey( key : JSONRootKey.LAYOUTS )
		setUrlPath(urlPath: "/settings/layouts")
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param: "module" , value: self.module.apiName)
		if modifiedSince.notNilandEmpty
		{ 
			addRequestHeader(header: "If-Modified-Since" , value: modifiedSince! )
			
		}
		let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
		
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let layouts = self.getAllLayouts( layoutsList : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) )
                    bulkResponse.setData( data : self.getAllLayouts( layoutsList : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) ) )
                    completion( .success( layouts, bulkResponse ) )
                }
                else
                {
                    completion( .failure( ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message : ErrorMessage.RESPONSE_NIL_MSG ) ) )
                }
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getLayout( layoutId : Int64, completion: @escaping( Result.DataResponse< ZCRMLayout, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.LAYOUTS )
		setUrlPath(urlPath:  "/settings/layouts/\(layoutId)")
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param: "module" , value: self.module.apiName)
		let request : APIRequest = APIRequest(handler: self )
		print( "Request : \( request.toString() )" )
		
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let layoutsList:[[String : Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let layout = self.getZCRMLayout( layoutDetails : layoutsList[ 0 ] )
                response.setData(data: layout )
                completion( .success( layout, response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getAllFields( modifiedSince : String?, completion: @escaping( Result.DataResponse< [ ZCRMField ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.FIELDS )
		setUrlPath(urlPath: "/settings/fields")
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param: "module" , value: self.module.apiName)
		if modifiedSince.notNilandEmpty
		{
			addRequestHeader(header: "If-Modified-Since" , value: modifiedSince! )
			
		}
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
		
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let fields = self.getAllFields( allFieldsDetails : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) )
                    bulkResponse.setData( data : fields )
                    completion( .success( fields, bulkResponse ) )
                }
                else
                {
                    completion( .failure( ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message : ErrorMessage.RESPONSE_NIL_MSG ) ) )
                }
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getField( fieldId : Int64, completion: @escaping( Result.DataResponse< ZCRMField, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.FIELDS )
        setUrlPath( urlPath : "/settings/fields/\( fieldId )" )
        setRequestMethod( requestMethod : .GET )
        addRequestParam( param : "module", value : self.module.apiName )
        let request : APIRequest = APIRequest( handler : self )
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let fieldsList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let field = self.getZCRMField( fieldDetails : fieldsList[ 0 ] )
                response.setData( data : field )
                completion( .success( field, response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getAllCustomViews( modifiedSince : String?, completion: @escaping( Result.DataResponse< [ ZCRMCustomView ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.CUSTOM_VIEWS )
		setUrlPath(urlPath: "/settings/custom_views")
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param: "module" , value: self.module.apiName)
		if modifiedSince.notNilandEmpty
		{
			addRequestHeader(header: "If-Modified-Since" , value: modifiedSince! )
		}
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
		
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                var allCVs : [ZCRMCustomView] = [ZCRMCustomView]()
                let allCVsList : [[String:Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                for cvDetails in allCVsList
                {
                    allCVs.append(self.getZCRMCustomView(cvDetails: cvDetails))
                }
                bulkResponse.setData(data: allCVs)
                completion( .success( allCVs, bulkResponse ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getRelatedList( id : Int64, completion: @escaping( Result.DataResponse< ZCRMModuleRelation, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.RELATED_LISTS )
        setUrlPath( urlPath : "/settings/related_lists/\(id)" )
        setRequestMethod( requestMethod : .GET )
        addRequestParam( param : "module", value : self.module.apiName )
        let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.responseJSON
                let relatedList = self.getAllRelatedLists( relatedListsDetails : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) )[ 0 ]
                response.setData( data : relatedList )
                completion( .success( relatedList, response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getAllRelatedLists( completion: @escaping( Result.DataResponse< [ ZCRMModuleRelation ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.RELATED_LISTS )
        setUrlPath( urlPath : "/settings/related_lists" )
        setRequestMethod( requestMethod : .GET )
        addRequestParam( param : "module", value : self.module.apiName )
        let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                let relatedLists = self.getAllRelatedLists( relatedListsDetails : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) )
                bulkResponse.setData( data : relatedLists )
                completion( .success( relatedLists, bulkResponse ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getCustomView( cvId : Int64, completion: @escaping( Result.DataResponse< ZCRMCustomView, APIResponse > ) -> () )
    {
        setJSONRootKey( key :  JSONRootKey.CUSTOM_VIEWS )
		setUrlPath(urlPath: "/settings/custom_views/\(cvId)" )
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param: "module" , value: self.module.apiName )
		let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let cvArray : [ [ String : Any ] ] = response.getResponseJSON().getArrayOfDictionaries( key : self.getJSONRootKey() )
                let customView = self.getZCRMCustomView( cvDetails : cvArray[ 0 ] )
                response.setData( data : customView )
                completion( .success( customView, response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getStages( completion: @escaping( Result.DataResponse< [ ZCRMStage ], BulkAPIResponse > ) -> () )
    {
        var stages : [ ZCRMStage ] = [ ZCRMStage ]()
        setJSONRootKey( key : JSONRootKey.STAGES )
        setUrlPath(urlPath: "/settings/stages")
        setRequestMethod(requestMethod: .GET)
        addRequestParam(param: "module", value: self.module.apiName)
        let request : APIRequest = APIRequest( handler: self )
        print( "Request : \( request.toString() )" )
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let stagesList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    for stageList in stagesList
                    {
                        stages.append( self.getZCRMStage( stageDetails : stageList ) )
                    }
                    bulkResponse.setData( data : stages )
                   completion( .success( stages, bulkResponse ) )
                }
                else
                {
                    completion( .failure( ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message : ErrorMessage.RESPONSE_NIL_MSG ) ) )
                }
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
	
	// MARK: - Utility functions
    private func getAllRelatedLists( relatedListsDetails : [ [ String : Any ] ] ) -> [ ZCRMModuleRelation ]
    {
        var relatedLists : [ ZCRMModuleRelation ] = [ ZCRMModuleRelation ]()
        for relatedListDetials in relatedListsDetails
        {
            relatedLists.append( self.getZCRMModuleRelation( relationListDetails : relatedListDetials ) )
        }
        return relatedLists
    }
    
	internal func getZCRMCustomView(cvDetails: [String:Any]) -> ZCRMCustomView
    {
        let customView : ZCRMCustomView = ZCRMCustomView(cvName: cvDetails.getString( key : ResponseJSONKeys.name ), moduleAPIName: self.module.apiName)
        customView.cvId = cvDetails.getInt64( key : ResponseJSONKeys.id )
        if( cvDetails.hasValue(forKey: ResponseJSONKeys.systemName))
        {
            customView.sysName = cvDetails.getString(key: ResponseJSONKeys.systemName)
        }
        if( cvDetails.hasValue(forKey: ResponseJSONKeys.displayValue))
        {
            customView.displayName = cvDetails.getString(key: ResponseJSONKeys.displayValue)
        }
        if( cvDetails.hasValue(forKey: ResponseJSONKeys.defaultString))
        {
            customView.isDefault = cvDetails.getBoolean(key: ResponseJSONKeys.defaultString)
        }
        if( cvDetails.hasValue(forKey: ResponseJSONKeys.category))
        {
            customView.category = cvDetails.getString(key: ResponseJSONKeys.category)
        }
        if( cvDetails.hasValue(forKey: ResponseJSONKeys.favorite))
        {
            customView.favouriteSequence = cvDetails.getInt(key: ResponseJSONKeys.favorite)
        }
        if( cvDetails.hasValue(forKey: ResponseJSONKeys.fields))
        {
            customView.fields = (cvDetails.getArray(key: ResponseJSONKeys.fields) as? [String])!
        }
        if(cvDetails.hasValue(forKey: ResponseJSONKeys.sortBy))
        {
            customView.sortByCol = cvDetails.optString(key: ResponseJSONKeys.sortBy)
        }
        if( cvDetails.hasValue(forKey: ResponseJSONKeys.sortOrder))
        {
            customView.sortOrder = cvDetails.optString(key: ResponseJSONKeys.sortOrder).map { SortOrder(rawValue: $0) }!
        }
        if( cvDetails.hasValue(forKey: ResponseJSONKeys.offline))
        {
            customView.isOffline = cvDetails.getBoolean(key: ResponseJSONKeys.offline)
        }
        if( cvDetails.hasValue(forKey: ResponseJSONKeys.systemDefined))
        {
            customView.isSystemDefined = cvDetails.getBoolean(key: ResponseJSONKeys.systemDefined)
        }
        return customView
    }
    
    internal func getAllLayouts(layoutsList : [[String : Any]]) -> [ZCRMLayout]
    {
        var allLayouts : [ZCRMLayout] = [ZCRMLayout]()
        for layout in layoutsList
        {
            allLayouts.append(self.getZCRMLayout(layoutDetails: layout))
        }
        return allLayouts
    }
    
    internal func getZCRMLayout(layoutDetails : [String : Any]) -> ZCRMLayout
    {
        let layout : ZCRMLayout = ZCRMLayout(name: layoutDetails.getString(key: ResponseJSONKeys.name))
        if( layoutDetails.hasValue(forKey: ResponseJSONKeys.id))
        {
            layout.layoutId = layoutDetails.getInt64(key: ResponseJSONKeys.id)
        }
        if( layoutDetails.hasValue(forKey: ResponseJSONKeys.visible))
        {
            layout.visible = layoutDetails.getBoolean(key: ResponseJSONKeys.visible)
        }
        if ( layoutDetails.hasValue(forKey: ResponseJSONKeys.status))
        {
            layout.status = layoutDetails.getInt(key: ResponseJSONKeys.status)
        }
        if(layoutDetails.hasValue(forKey: ResponseJSONKeys.createdBy))
        {
            let createdByObj : [String:Any] = layoutDetails.getDictionary(key: ResponseJSONKeys.createdBy)
            layout.createdBy = getUserDelegate(userJSON : createdByObj)
            layout.createdTime = layoutDetails.getString(key: ResponseJSONKeys.createdTime)
        }
        if(layoutDetails.hasValue(forKey: ResponseJSONKeys.createdBy))
        {
            let modifiedByObj : [String:Any] = layoutDetails.getDictionary(key: ResponseJSONKeys.createdBy)
            layout.modifiedBy = getUserDelegate(userJSON : modifiedByObj)
            layout.modifiedTime = layoutDetails.getString(key: ResponseJSONKeys.modifiedTime)
        }
        let profilesDetails : [[String:Any]] = layoutDetails.getArrayOfDictionaries(key: ResponseJSONKeys.profiles)
        for profileDetails in profilesDetails
        {
            let profile : ZCRMProfileDelegate = ZCRMProfileDelegate(profileId: profileDetails.getInt64(key: ResponseJSONKeys.id), profileName: profileDetails.getString(key: ResponseJSONKeys.name), isDefault: profileDetails.getBoolean(key: ResponseJSONKeys.defaultString))
            layout.addAccessibleProfile(profile: profile)
        }
        let sectionDetails : [[String:Any]] = layoutDetails.getArrayOfDictionaries(key: ResponseJSONKeys.sections)
        for sectionDetail in sectionDetails
        {
            let section : ZCRMSection = ZCRMSection(sectionName: sectionDetail.getString(key: ResponseJSONKeys.name))
            layout.addSection(section: section)
        }
        return layout
    }
    
    internal func getAllSectionsOfLayout(allSectionsDetails : [[String:Any]]) -> [ZCRMSection]
    {
        var allSections : [ZCRMSection] = [ZCRMSection]()
        for sectionDetails in allSectionsDetails
        {
            allSections.append(self.getZCRMSection(sectionDetails: sectionDetails))
        }
        return allSections
    }
    
    internal func getZCRMSection(sectionDetails : [String:Any]) -> ZCRMSection
    {
        let section : ZCRMSection = ZCRMSection(sectionName: sectionDetails.getString(key: ResponseJSONKeys.name))
        section.displayName = sectionDetails.optString(key: ResponseJSONKeys.displayLabel) ?? APIConstants.STRING_MOCK
        section.columnCount = sectionDetails.optInt(key: ResponseJSONKeys.columnCount) ?? APIConstants.INT_MOCK
        section.sequence = sectionDetails.optInt(key: ResponseJSONKeys.sequenceNumber) ?? APIConstants.INT_MOCK
        section.addFields(allFields: self.getAllFields(allFieldsDetails: sectionDetails.getArrayOfDictionaries(key: ResponseJSONKeys.fields) ))
        section.isSubformSection = sectionDetails.getBoolean( key : ResponseJSONKeys.isSubformSection )
        return section
    }
    
    internal func getAllFields(allFieldsDetails : [[String : Any]]) -> [ZCRMField]
    {
        var allFields : [ZCRMField] = [ZCRMField]()
        for fieldDetails in allFieldsDetails
        {
            allFields.append(self.getZCRMField(fieldDetails: fieldDetails))
        }
        return allFields
    }
    
    internal func getZCRMField(fieldDetails : [String:Any]) -> ZCRMField
    {
        let field : ZCRMField = ZCRMField(apiName: fieldDetails.getString(key: ResponseJSONKeys.apiName))
        field.id = fieldDetails.optInt64(key: ResponseJSONKeys.id) ?? APIConstants.INT64_MOCK
        field.displayLabel = fieldDetails.optString(key: ResponseJSONKeys.fieldLabel) ?? APIConstants.STRING_MOCK
        field.maxLength = fieldDetails.optInt(key: ResponseJSONKeys.length) ?? APIConstants.INT_MOCK
        field.type = fieldDetails.optString(key: ResponseJSONKeys.dataType) ?? APIConstants.STRING_MOCK
        field.visible = fieldDetails.optBoolean(key: ResponseJSONKeys.visible) ?? APIConstants.BOOL_MOCK
        field.decimalPlace = fieldDetails.optInt(key: ResponseJSONKeys.decimalPlace) ?? APIConstants.INT_MOCK
        field.readOnly = fieldDetails.optBoolean(key: ResponseJSONKeys.readOnly) ?? APIConstants.BOOL_MOCK
        field.customField = fieldDetails.optBoolean(key: ResponseJSONKeys.customField) ?? APIConstants.BOOL_MOCK
        field.defaultValue = fieldDetails.optValue(key: ResponseJSONKeys.defaultValue) ?? APIConstants.BOOL_MOCK
        field.mandatory = fieldDetails.optBoolean(key: ResponseJSONKeys.required) ?? APIConstants.BOOL_MOCK
        field.sequenceNo = fieldDetails.optInt(key: ResponseJSONKeys.sequenceNumber) ?? APIConstants.INT_MOCK
        field.tooltip = fieldDetails.optString(key: ResponseJSONKeys.toolTip) ?? APIConstants.STRING_MOCK
        field.webhook = fieldDetails.optBoolean(key: ResponseJSONKeys.webhook) ?? APIConstants.BOOL_MOCK
        field.createdSource = fieldDetails.getString(key: ResponseJSONKeys.createdSource)
        field.lookup = fieldDetails.optDictionary(key: ResponseJSONKeys.lookup) ?? [ String : Any ]()
        field.multiSelectLookup = fieldDetails.optDictionary(key: ResponseJSONKeys.multiSelectLookup) ?? [ String : Any ]()
        field.subFormTabId = fieldDetails.optInt64(key: ResponseJSONKeys.subformTabId)
        field.subForm = fieldDetails.optDictionary(key: ResponseJSONKeys.subform) ?? [ String : Any ]()
        if(fieldDetails.hasValue(forKey: ResponseJSONKeys.currency))
        {
            let currencyDetails : [String:Any] = fieldDetails.getDictionary(key: ResponseJSONKeys.currency)
            field.precision = currencyDetails.optInt(key: ResponseJSONKeys.precision) ?? APIConstants.INT_MOCK
            if (currencyDetails.optString(key: ResponseJSONKeys.roundingOption) == CurrencyRoundingOption.RoundOff.rawValue)
            {
                field.roundingOption = CurrencyRoundingOption.RoundOff
            }
            else if (currencyDetails.optString(key: ResponseJSONKeys.roundingOption) == CurrencyRoundingOption.RoundDown.rawValue)
            {
                field.roundingOption = CurrencyRoundingOption.RoundDown
            }
            else if (currencyDetails.optString(key: ResponseJSONKeys.roundingOption) == CurrencyRoundingOption.RoundUp.rawValue)
            {
                field.roundingOption = CurrencyRoundingOption.RoundUp
            }
            else if (currencyDetails.optString(key: ResponseJSONKeys.roundingOption) == CurrencyRoundingOption.Normal.rawValue)
            {
                field.roundingOption = CurrencyRoundingOption.Normal
            }
        }
        
        field.bussinessCardSupported = fieldDetails.optBoolean(key: ResponseJSONKeys.businessCardSupported) ?? APIConstants.BOOL_MOCK
        if ( fieldDetails.hasValue( forKey : ResponseJSONKeys.pickListValues ) )
        {
            let pickListValues = fieldDetails.getArrayOfDictionaries( key : ResponseJSONKeys.pickListValues )
            for pickListValueDict in pickListValues
            {
                let pickListValue = ZCRMPickListValue(displayName: pickListValueDict.optString( key : ResponseJSONKeys.displayValue ) ?? APIConstants.STRING_MOCK, actualName: pickListValueDict.optString( key : ResponseJSONKeys.actualValue ) ?? APIConstants.STRING_MOCK )
                print( "pickListValueDict : \( pickListValueDict)" )
                pickListValue.maps = pickListValueDict.optArrayOfDictionaries( key : ResponseJSONKeys.maps ) ?? Array< [ String : Any ] >()
                pickListValue.sequenceNumber = pickListValueDict.optInt(key : ResponseJSONKeys.sequenceNumber ) ?? APIConstants.INT_MOCK
                field.addPickListValue( pickListValue : pickListValue )
            }
        }
        if(fieldDetails.hasValue(forKey: ResponseJSONKeys.formula))
        {
            let formulaDetails : [String:String] = fieldDetails.getDictionary(key: ResponseJSONKeys.formula) as! [String:String]
            field.formulaReturnType = formulaDetails.optString(key: ResponseJSONKeys.returnType)
            field.formulaExpression = formulaDetails.optString(key: ResponseJSONKeys.expression)
        }
        if(fieldDetails.hasValue(forKey: ResponseJSONKeys.currency))
        {
            let currencyDetails : [String:Any] = fieldDetails.getDictionary(key: ResponseJSONKeys.currency)
            field.precision = currencyDetails.optInt(key: ResponseJSONKeys.precision) ?? APIConstants.INT_MOCK
        }
        if(fieldDetails.hasValue(forKey: ResponseJSONKeys.viewType))
        {
            let subLayouts : [String:Bool] = fieldDetails.getDictionary(key: ResponseJSONKeys.viewType) as! [String : Bool]
            var layoutsPresent : [String] = [String]()
            if(subLayouts.optBoolean(key: ResponseJSONKeys.create)!)
            {
                layoutsPresent.append(SubLayoutViewType.CREATE.rawValue)
            }
            if(subLayouts.optBoolean(key: ResponseJSONKeys.edit)!)
            {
                layoutsPresent.append(SubLayoutViewType.EDIT.rawValue)
            }
            if(subLayouts.optBoolean(key: ResponseJSONKeys.view)!)
            {
                layoutsPresent.append(SubLayoutViewType.VIEW.rawValue)
            }
            if(subLayouts.optBoolean(key: ResponseJSONKeys.quickCreate)!)
            {
                layoutsPresent.append(SubLayoutViewType.QUICK_CREATE.rawValue)
            }
            field.subLayoutsPresent = layoutsPresent
        }
        if( fieldDetails.hasValue( forKey : ResponseJSONKeys.privateString ) )
        {
            let privateDetails : [ String : Any ] = fieldDetails.getDictionary( key : ResponseJSONKeys.privateString )
            field.isRestricted = privateDetails.optBoolean( key : ResponseJSONKeys.restricted )
            field.isSupportExport = privateDetails.optBoolean( key : ResponseJSONKeys.export )
            field.restrictedType = privateDetails.optString( key : ResponseJSONKeys.type )
        }
        return field
    }
    
    internal func getZCRMModuleRelation( relationListDetails : [ String : Any ] ) -> ZCRMModuleRelation
    {
        let moduleRelation : ZCRMModuleRelation = ZCRMModuleRelation( parentModuleAPIName : module.apiName, relatedListId : relationListDetails.getInt64( key : ResponseJSONKeys.id ) )
        moduleRelation.apiName = relationListDetails.optString( key : ResponseJSONKeys.apiName ) ?? APIConstants.STRING_MOCK
        moduleRelation.label = relationListDetails.optString( key : ResponseJSONKeys.displayLabel ) ?? APIConstants.STRING_MOCK
        moduleRelation.module = relationListDetails.optString( key : ResponseJSONKeys.module ) ?? APIConstants.STRING_MOCK
        moduleRelation.name = relationListDetails.optString( key : ResponseJSONKeys.name) ?? APIConstants.STRING_MOCK
        moduleRelation.type = relationListDetails.optString( key : ResponseJSONKeys.type ) ?? APIConstants.STRING_MOCK
        return moduleRelation
    }
    
    internal func getZCRMStage( stageDetails : [ String : Any ] ) -> ZCRMStage
    {
        let stage : ZCRMStage = ZCRMStage( stageId : stageDetails.getInt64( key : ResponseJSONKeys.id ) )
        stage.setName(name: stageDetails.optString(key: ResponseJSONKeys.name))
        stage.setDisplayLabel(displayLabel: stageDetails.optString(key: ResponseJSONKeys.displayLabel))
        stage.setProbability(probability: stageDetails.optInt(key: ResponseJSONKeys.probability))
        stage.setForecastCategory(forecastCategory: stageDetails.optDictionary(key: ResponseJSONKeys.forecastCategory))
        stage.setForecastType(forecastType: stageDetails.optString(key: ResponseJSONKeys.forecastType))
        return stage
    }
}

fileprivate extension ModuleAPIHandler
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
        static let required = "required"
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
 
        static let module = "module"
        static let probability = "probability"
        static let forecastCategory = "forecast_category"
        static let forecastType = "forecast_type"
    }
    
    enum SubLayoutViewType : String
    {
        case CREATE = "CREATE"
        case EDIT = "EDIT"
        case VIEW = "VIEW"
        case QUICK_CREATE = "QUICK_CREATE"
    }
}


//
//  ModuleAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 15/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class ModuleAPIHandler : CommonAPIHandler
{
    private let module : ZCRMModule
    
    init(module : ZCRMModule)
    {
        self.module = module
    }
	
	// MARK: - Handler functions
	
    internal func getAllLayouts( modifiedSince : String?, completion: @escaping( [ ZCRMLayout ]?, BulkAPIResponse?, Error? ) -> () )
    {
		setJSONRootKey( key : JSONRootKey.LAYOUTS )
		setUrlPath(urlPath: "/settings/layouts")
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param: "module" , value: self.module.getAPIName())
		if modifiedSince.notNilandEmpty
		{ 
			addRequestHeader(header: "If-Modified-Since" , value: modifiedSince! )
			
		}
		let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
		
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            if let bulkResponse = response
            {
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let layouts = self.getAllLayouts( layoutsList : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) )
                    bulkResponse.setData( data : self.getAllLayouts( layoutsList : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) ) )
                    completion( layouts, bulkResponse, nil )
                }
            }
        }
    }
    
    internal func getLayout( layoutId : Int64, completion: @escaping( ZCRMLayout?, APIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.LAYOUTS )
		setUrlPath(urlPath:  "/settings/layouts/\(layoutId)")
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param: "module" , value: self.module.getAPIName())
		let request : APIRequest = APIRequest(handler: self )
		print( "Request : \( request.toString() )" )
		
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            if let response = resp
            {
                let responseJSON = response.getResponseJSON()
                let layoutsList:[[String : Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let layout = self.getZCRMLayout( layoutDetails : layoutsList[ 0 ] )
                response.setData(data: layout )
                completion( layout, response, nil )
            }
        }
    }
    
    internal func getAllFields( modifiedSince : String?, completion: @escaping( [ ZCRMField ]?, BulkAPIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.FIELDS )
		setUrlPath(urlPath: "/settings/fields")
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param: "module" , value: self.module.getAPIName())
		if modifiedSince.notNilandEmpty
		{
			addRequestHeader(header: "If-Modified-Since" , value: modifiedSince! )
			
		}
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
		
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            if let bulkResponse = response
            {
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let fields = self.getAllFields( allFieldsDetails : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) )
                    bulkResponse.setData( data : fields )
                    completion( fields, bulkResponse, nil )
                }
            }
        }
    }
    
    internal func getField( fieldId : Int64, completion: @escaping( ZCRMField?, APIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.FIELDS )
        setUrlPath( urlPath : "/settings/fields/\( fieldId )" )
        setRequestMethod( requestMethod : .GET )
        addRequestParam( param : "module", value : self.module.getAPIName() )
        let request : APIRequest = APIRequest( handler : self )
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            if let response = resp
            {
                let responseJSON = response.getResponseJSON()
                let fieldsList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let field = self.getZCRMField( fieldDetails : fieldsList[ 0 ] )
                response.setData( data : field )
                completion( field, response, nil )
            }
        }
    }

    internal func getAllCustomViews( modifiedSince : String?, completion: @escaping( [ ZCRMCustomView ]?, BulkAPIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.CUSTOM_VIEWS )
		setUrlPath(urlPath: "/settings/custom_views")
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param: "module" , value: self.module.getAPIName())
		if modifiedSince.notNilandEmpty
		{
			addRequestHeader(header: "If-Modified-Since" , value: modifiedSince! )
			
		}
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
		
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            if let bulkResponse = response
            {
                let responseJSON = bulkResponse.getResponseJSON()
                var allCVs : [ZCRMCustomView] = [ZCRMCustomView]()
                let allCVsList : [[String:Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                for cvDetails in allCVsList
                {
                    allCVs.append(self.getZCRMCustomView(cvDetails: cvDetails))
                }
                bulkResponse.setData(data: allCVs)
                completion( allCVs, bulkResponse, nil )
            }
        }
    }
    
    internal func getRelatedList( id : Int64, completion: @escaping( ZCRMModuleRelation?, APIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.RELATED_LISTS )
        setUrlPath( urlPath : "settings/related_lists/\(id)" )
        setRequestMethod( requestMethod : .GET )
        addRequestParam( param : "module", value : self.module.getAPIName() )
        let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            if let response = resp
            {
                let responseJSON = response.responseJSON
                let relatedList = self.getAllRelatedLists( relatedListsDetails : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) )[ 0 ]
                response.setData( data : relatedList )
                completion( relatedList, response, nil )
            }
        }
    }
    
    internal func getAllRelatedLists( completion: @escaping( [ ZCRMModuleRelation ]?, BulkAPIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.RELATED_LISTS )
        setUrlPath( urlPath : "settings/related_lists" )
        setRequestMethod( requestMethod : .GET )
        addRequestParam( param : "module", value : self.module.getAPIName() )
        let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let bulkResponse = response
            {
                let responseJSON = bulkResponse.getResponseJSON()
                let relatedLists = self.getAllRelatedLists( relatedListsDetails : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) )
                bulkResponse.setData( data : relatedLists )
                completion( relatedLists, bulkResponse, nil )
            }
        }
    }
    
    private func getAllRelatedLists( relatedListsDetails : [ [ String : Any ] ] ) -> [ ZCRMModuleRelation ]
    {
        var relatedLists : [ ZCRMModuleRelation ] = [ ZCRMModuleRelation ]()
        for relatedListDetials in relatedListsDetails
        {
            relatedLists.append( self.getZCRMModuleRelation( relationListDetails : relatedListDetials ) )
        }
        return relatedLists
    }
    
    internal func getCustomView( cvId : Int64, completion: @escaping( ZCRMCustomView?, APIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key :  JSONRootKey.CUSTOM_VIEWS )
		setUrlPath(urlPath: "/settings/custom_views/\(cvId)" )
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param: "module" , value: self.module.getAPIName() )
		let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let response = resp
            {
                let cvArray : [ [ String : Any ] ] = response.getResponseJSON().getArrayOfDictionaries( key : self.getJSONRootKey() )
                let customView = self.getZCRMCustomView( cvDetails : cvArray[ 0 ] )
                response.setData( data : customView )
                completion( customView, response, nil )
            }
        }
    }
	
	// MARK: - Utility functions
	
    internal func getZCRMCustomView(cvDetails: [String:Any]) -> ZCRMCustomView
    {
        let customView : ZCRMCustomView = ZCRMCustomView( cvId : cvDetails.getInt64( key : ResponseParamKeys.id ), moduleAPIName : self.module.getAPIName() )
        customView.setName( name : cvDetails.getString( key : ResponseParamKeys.name ) )
        customView.setSystemName(systemName: cvDetails.optString(key: ResponseParamKeys.systemName))
        customView.setDisplayName(displayName: cvDetails.optString(key: ResponseParamKeys.displayValue)!)
        customView.setIsDefault(isDefault: cvDetails.optBoolean(key: ResponseParamKeys.defaultString)!)
        customView.setCategory(category: cvDetails.optString(key: ResponseParamKeys.category)!)
        customView.setFavouriteSequence(favourite: cvDetails.optInt(key: ResponseParamKeys.favorite))
        customView.setDisplayFields(fieldsAPINames: cvDetails.optArray(key: ResponseParamKeys.fields) as? [String])
        customView.setSortByCol(fieldAPIName: cvDetails.optString(key: ResponseParamKeys.sortBy))
        customView.setSortOrder(sortOrder: cvDetails.optString(key: ResponseParamKeys.sortOrder))
        customView.setIsOffline(isOffline: cvDetails.optBoolean(key: ResponseParamKeys.offline))
        customView.setIsSystemDefined(isSystemDefined: cvDetails.optBoolean(key: ResponseParamKeys.systemDefined))
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
        let layout : ZCRMLayout = ZCRMLayout(layoutId: layoutDetails.getInt64(key: ResponseParamKeys.id))
        layout.setName(name: layoutDetails.optString(key: ResponseParamKeys.name))
        layout.setVisibility(isVisible: layoutDetails.optBoolean(key: ResponseParamKeys.visible))
        layout.setStatus(status: layoutDetails.optInt(key: ResponseParamKeys.status))
        if(layoutDetails.hasValue(forKey: ResponseParamKeys.createdBy))
        {
            let createdByObj : [String:Any] = layoutDetails.getDictionary(key: ResponseParamKeys.createdBy)
            let createdBy : ZCRMUser = ZCRMUser(userId: createdByObj.getInt64(key: ResponseParamKeys.id), userFullName: createdByObj.getString(key: ResponseParamKeys.name))
            layout.setCreatedBy(createdByUser: createdBy)
            layout.setCreatedTime(createdTime: layoutDetails.optString(key: ResponseParamKeys.createdTime))
        }
        if(layoutDetails.hasValue(forKey: ResponseParamKeys.modifiedBy))
        {
            let modifiedByObj : [String:Any] = layoutDetails.getDictionary(key: ResponseParamKeys.modifiedBy)
            let modifiedBy : ZCRMUser = ZCRMUser(userId: modifiedByObj.getInt64(key: ResponseParamKeys.id), userFullName: modifiedByObj.getString(key: ResponseParamKeys.name))
            layout.setModifiedBy(modifiedByUser: modifiedBy)
            layout.setModifiedTime(modifiedTime: layoutDetails.optString(key: ResponseParamKeys.modifiedTime))
        }
        let profilesDetails : [[String:Any]] = layoutDetails.getArrayOfDictionaries(key: ResponseParamKeys.profiles)
        for profileDetails in profilesDetails
        {
            let profile : ZCRMProfile = ZCRMProfile(profileId: profileDetails.getInt64(key: ResponseParamKeys.id), profileName: profileDetails.getString(key: ResponseParamKeys.name))
            profile.setIsDefault(isDefault: profileDetails.getBoolean(key: ResponseParamKeys.defaultString))
            layout.addAccessibleProfile(profile: profile)
        }
        layout.setSections(allSections: self.getAllSectionsOfLayout(allSectionsDetails: layoutDetails.getArrayOfDictionaries(key: ResponseParamKeys.sections)))
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
        let section : ZCRMSection = ZCRMSection(sectionName: sectionDetails.getString(key: ResponseParamKeys.name))
        section.setDisplayName(displayName: sectionDetails.optString(key: ResponseParamKeys.displayLabel))
        section.setColumnCount(colCount: sectionDetails.optInt(key: ResponseParamKeys.columnCount))
        section.setSequence(sequence: sectionDetails.optInt(key: ResponseParamKeys.sequenceNumber))
        section.setFields(allFields: self.getAllFields(allFieldsDetails: sectionDetails.getArrayOfDictionaries(key: ResponseParamKeys.fields) ))
        section.setIsSubformSection( isSubformSection : sectionDetails.getBoolean( key : ResponseParamKeys.isSubformSection ) )
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
        let field : ZCRMField = ZCRMField(fieldAPIName: fieldDetails.getString(key: ResponseParamKeys.apiName))
        field.setId(fieldId: fieldDetails.optInt64(key: ResponseParamKeys.id))
        field.setDisplayLabel(displayLabel: fieldDetails.optString(key: ResponseParamKeys.fieldLabel))
        field.setMaxLength(maxLen: fieldDetails.optInt(key: ResponseParamKeys.length))
        field.setDataType(dataType: fieldDetails.optString(key: ResponseParamKeys.dataType))
        field.setVisible(isVisible: fieldDetails.optBoolean(key: ResponseParamKeys.visible))
        field.setDecimalPlace(decimalPlace: fieldDetails.optInt(key: ResponseParamKeys.decimalPlace))
        field.setReadOnly(isReadOnly: fieldDetails.optBoolean(key: ResponseParamKeys.readOnly))
        field.setCustomField(isCustomField: fieldDetails.optBoolean(key: ResponseParamKeys.customField))
        field.setDefaultValue(defaultValue: fieldDetails.optValue(key: ResponseParamKeys.defaultValue))
        field.setMandatory(isMandatory: fieldDetails.optBoolean(key: ResponseParamKeys.required))
        field.setSequenceNumber(sequenceNo: fieldDetails.optInt(key: ResponseParamKeys.sequenceNumber))
        field.setTooltip(tooltip: fieldDetails.optString(key: ResponseParamKeys.toolTip))
        field.setWebhook(webhook: fieldDetails.optBoolean(key: ResponseParamKeys.webhook))
        field.setCreatedSource(createdSource: fieldDetails.getString(key: ResponseParamKeys.createdSource))
        field.setLookup(lookup: fieldDetails.optDictionary(key: ResponseParamKeys.lookup))
        field.setMultiSelectLookup(multiSelectLookup: fieldDetails.optDictionary(key: ResponseParamKeys.multiSelectLookup))
        field.setSubFormTabId(subFormTabId: fieldDetails.optInt64(key: ResponseParamKeys.subformTabId))
        field.setSubForm(subForm: fieldDetails.optDictionary(key: ResponseParamKeys.subform))
        if(fieldDetails.hasValue(forKey: ResponseParamKeys.currency))
        {
            let currencyDetails : [String:Any] = fieldDetails.getDictionary(key: ResponseParamKeys.currency)
            field.setPrecision(precision: currencyDetails.optInt(key: ResponseParamKeys.precision))
            if (currencyDetails.optString(key: ResponseParamKeys.roundingOption) == CurrencyRoundingOption.RoundOff.rawValue)
            {
                field.setRoundingOption(roundingOption: CurrencyRoundingOption.RoundOff)
            }
            else if (currencyDetails.optString(key: ResponseParamKeys.roundingOption) == CurrencyRoundingOption.RoundDown.rawValue)
            {
                field.setRoundingOption(roundingOption: CurrencyRoundingOption.RoundDown)
            }
            else if (currencyDetails.optString(key: ResponseParamKeys.roundingOption) == CurrencyRoundingOption.RoundUp.rawValue)
            {
                field.setRoundingOption(roundingOption: CurrencyRoundingOption.RoundUp)
            }
            else if (currencyDetails.optString(key: ResponseParamKeys.roundingOption) == CurrencyRoundingOption.Normal.rawValue)
            {
                field.setRoundingOption(roundingOption: CurrencyRoundingOption.Normal)
            }
        }
        
        field.setBussinessCardSupported(bussinessCardSupported: fieldDetails.optBoolean(key: ResponseParamKeys.businessCardSupported))
        if ( fieldDetails.hasValue( forKey : ResponseParamKeys.pickListValues ) )
        {
            let pickListValues = fieldDetails.getArrayOfDictionaries( key : ResponseParamKeys.pickListValues )
            for pickListValueDict in pickListValues
            {
                let pickListValue = ZCRMPickListValue()
                print( "pickListValueDict : \( pickListValueDict)" )
                pickListValue.setMaps( maps : pickListValueDict.optArrayOfDictionaries( key : ResponseParamKeys.maps ) )
                pickListValue.setSequenceNumer( number : pickListValueDict.optInt(key : ResponseParamKeys.sequenceNumber ) )
                pickListValue.setActualName( actualName : pickListValueDict.optString( key : ResponseParamKeys.actualValue ) )
                pickListValue.setDisplayName( displayName : pickListValueDict.optString( key : ResponseParamKeys.displayValue ) )
                field.addPickListValue( pickListValue : pickListValue )
            }
        }
        if(fieldDetails.hasValue(forKey: ResponseParamKeys.formula))
        {
            let formulaDetails : [String:String] = fieldDetails.getDictionary(key: ResponseParamKeys.formula) as! [String:String]
            field.setFormulaReturnType(formulaReturnType: formulaDetails.optString(key: ResponseParamKeys.returnType))
            field.setFormula(formulaExpression: formulaDetails.optString(key: ResponseParamKeys.expression))
        }
        if(fieldDetails.hasValue(forKey: ResponseParamKeys.currency))
        {
            let currencyDetails : [String:Any] = fieldDetails.getDictionary(key: ResponseParamKeys.currency)
            field.setPrecision(precision: currencyDetails.optInt(key: ResponseParamKeys.precision))
        }
        if(fieldDetails.hasValue(forKey: ResponseParamKeys.viewType))
        {
            let subLayouts : [String:Bool] = fieldDetails.getDictionary(key: ResponseParamKeys.viewType) as! [String : Bool]
            var layoutsPresent : [String] = [String]()
            if(subLayouts.optBoolean(key: ResponseParamKeys.create)!)
            {
                layoutsPresent.append(SubLayoutViewType.CREATE.rawValue)
            }
            if(subLayouts.optBoolean(key: ResponseParamKeys.edit)!)
            {
                layoutsPresent.append(SubLayoutViewType.EDIT.rawValue)
            }
            if(subLayouts.optBoolean(key: ResponseParamKeys.view)!)
            {
                layoutsPresent.append(SubLayoutViewType.VIEW.rawValue)
            }
            if(subLayouts.optBoolean(key: ResponseParamKeys.quickCreate)!)
            {
                layoutsPresent.append(SubLayoutViewType.QUICK_CREATE.rawValue)
            }
            field.setSubLayoutsPresent(subLayoutsPresent: layoutsPresent)
        }
        if( fieldDetails.hasValue( forKey : ResponseParamKeys.privateString ) )
        {
            let privateDetails : [ String : Any ] = fieldDetails.getDictionary( key : ResponseParamKeys.privateString )
            field.setIsRestricted( isRestricted : privateDetails.optBoolean( key : ResponseParamKeys.restricted ) )
            field.setIsSupportExport( exportSupported : privateDetails.optBoolean( key : ResponseParamKeys.export ) )
            field.setRestrictedType( type : privateDetails.optString( key : ResponseParamKeys.type )  )
        }
        return field
    }
    
    internal func getZCRMModuleRelation( relationListDetails : [ String : Any ] ) -> ZCRMModuleRelation
    {
        let moduleRelation : ZCRMModuleRelation = ZCRMModuleRelation( parentModuleAPIName : module.getAPIName(), relatedListId : relationListDetails.getInt64( key : ResponseParamKeys.id ) )
        moduleRelation.setAPIName( apiName : relationListDetails.optString( key : ResponseParamKeys.apiName ) )
        moduleRelation.setLabel( label : relationListDetails.optString( key : ResponseParamKeys.displayLabel ) )
        moduleRelation.setModule( module : relationListDetails.optString( key : ResponseParamKeys.module ) )
        moduleRelation.setName( name : relationListDetails.optString( key : ResponseParamKeys.name) )
        moduleRelation.setType( type : relationListDetails.optString( key : ResponseParamKeys.type ) )
        return moduleRelation
    }
    
    internal func getStages( completion: @escaping( [ ZCRMStage ]?, BulkAPIResponse?, Error? ) -> () )
    {
        var stages : [ ZCRMStage ] = [ ZCRMStage ]()
        setJSONRootKey( key : JSONRootKey.STAGES )
        setUrlPath(urlPath: "/settings/stages")
        setRequestMethod(requestMethod: .GET)
        addRequestParam(param: "module", value: self.module.getAPIName())
        let request : APIRequest = APIRequest( handler: self )
        print( "Request : \( request.toString() )" )
        
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            guard let bulkResponse = response else
            {
                completion( nil, nil, ZCRMSDKError.ResponseNil("Response is nil") )
                return
            }
            let responseJSON = bulkResponse.getResponseJSON()
            if responseJSON.isEmpty == false
            {
                let stagesList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                for stageList in stagesList
                {
                    stages.append( self.getZCRMStage( stageDetails : stageList ) )
                }
                bulkResponse.setData( data : stages )
                completion( stages, bulkResponse, nil )
            }
        }
    }
    
    internal func getZCRMStage( stageDetails : [ String : Any ] ) -> ZCRMStage
    {
        let stage : ZCRMStage = ZCRMStage( stageId : stageDetails.getInt64( key : ResponseParamKeys.id ) )
        stage.setName(name: stageDetails.optString(key: ResponseParamKeys.name))
        stage.setDisplayLabel(displayLabel: stageDetails.optString(key: ResponseParamKeys.displayLabel))
        stage.setProbability(probability: stageDetails.optInt(key: ResponseParamKeys.probability))
        stage.setForecastCategory(forecastCategory: stageDetails.optDictionary(key: ResponseParamKeys.forecastCategory))
        stage.setForecastType(forecastType: stageDetails.optString(key: ResponseParamKeys.forecastType))
        return stage
    }
}

fileprivate extension ModuleAPIHandler
{
    struct ResponseParamKeys
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


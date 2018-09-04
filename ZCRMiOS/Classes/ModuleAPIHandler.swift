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
        let customView : ZCRMCustomView = ZCRMCustomView( cvId : cvDetails.getInt64( key : ResponseJSONKeys.id ), moduleAPIName : self.module.getAPIName() )
        customView.setName( name : cvDetails.getString( key : ResponseJSONKeys.name ) )
        customView.setSystemName(systemName: cvDetails.optString(key: ResponseJSONKeys.systemName))
        customView.setDisplayName(displayName: cvDetails.optString(key: ResponseJSONKeys.displayValue)!)
        customView.setIsDefault(isDefault: cvDetails.optBoolean(key: ResponseJSONKeys.defaultString)!)
        customView.setCategory(category: cvDetails.optString(key: ResponseJSONKeys.category)!)
        customView.setFavouriteSequence(favourite: cvDetails.optInt(key: ResponseJSONKeys.favorite))
        customView.setDisplayFields(fieldsAPINames: cvDetails.optArray(key: ResponseJSONKeys.fields) as? [String])
        customView.setSortByCol(fieldAPIName: cvDetails.optString(key: ResponseJSONKeys.sortBy))
        customView.setSortOrder(sortOrder: cvDetails.optString(key: ResponseJSONKeys.sortOrder))
        customView.setIsOffline(isOffline: cvDetails.optBoolean(key: ResponseJSONKeys.offline))
        customView.setIsSystemDefined(isSystemDefined: cvDetails.optBoolean(key: ResponseJSONKeys.systemDefined))
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
        let layout : ZCRMLayout = ZCRMLayout(layoutId: layoutDetails.getInt64(key: ResponseJSONKeys.id))
        layout.setName(name: layoutDetails.optString(key: ResponseJSONKeys.name))
        layout.setVisibility(isVisible: layoutDetails.optBoolean(key: ResponseJSONKeys.visible))
        layout.setStatus(status: layoutDetails.optInt(key: ResponseJSONKeys.status))
        if(layoutDetails.hasValue(forKey: ResponseJSONKeys.createdBy))
        {
            let createdByObj : [String:Any] = layoutDetails.getDictionary(key: ResponseJSONKeys.createdBy)
            let createdBy : ZCRMUser = ZCRMUser(userId: createdByObj.getInt64(key: ResponseJSONKeys.id), userFullName: createdByObj.getString(key: ResponseJSONKeys.name))
            layout.setCreatedBy(createdByUser: createdBy)
            layout.setCreatedTime(createdTime: layoutDetails.optString(key: ResponseJSONKeys.createdTime))
        }
        if(layoutDetails.hasValue(forKey: ResponseJSONKeys.modifiedBy))
        {
            let modifiedByObj : [String:Any] = layoutDetails.getDictionary(key: ResponseJSONKeys.modifiedBy)
            let modifiedBy : ZCRMUser = ZCRMUser(userId: modifiedByObj.getInt64(key: ResponseJSONKeys.id), userFullName: modifiedByObj.getString(key: ResponseJSONKeys.name))
            layout.setModifiedBy(modifiedByUser: modifiedBy)
            layout.setModifiedTime(modifiedTime: layoutDetails.optString(key: ResponseJSONKeys.modifiedTime))
        }
        let profilesDetails : [[String:Any]] = layoutDetails.getArrayOfDictionaries(key: ResponseJSONKeys.profiles)
        for profileDetails in profilesDetails
        {
            let profile : ZCRMProfile = ZCRMProfile(profileId: profileDetails.getInt64(key: ResponseJSONKeys.id), profileName: profileDetails.getString(key: ResponseJSONKeys.name))
            profile.setIsDefault(isDefault: profileDetails.getBoolean(key: ResponseJSONKeys.defaultString))
            layout.addAccessibleProfile(profile: profile)
        }
        layout.setSections(allSections: self.getAllSectionsOfLayout(allSectionsDetails: layoutDetails.getArrayOfDictionaries(key: ResponseJSONKeys.sections)))
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
        section.setDisplayName(displayName: sectionDetails.optString(key: ResponseJSONKeys.displayLabel))
        section.setColumnCount(colCount: sectionDetails.optInt(key: ResponseJSONKeys.columnCount))
        section.setSequence(sequence: sectionDetails.optInt(key: ResponseJSONKeys.sequenceNumber))
        section.setFields(allFields: self.getAllFields(allFieldsDetails: sectionDetails.getArrayOfDictionaries(key: ResponseJSONKeys.fields) ))
        section.setIsSubformSection( isSubformSection : sectionDetails.getBoolean( key : ResponseJSONKeys.isSubformSection ) )
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
        let field : ZCRMField = ZCRMField(fieldAPIName: fieldDetails.getString(key: ResponseJSONKeys.apiName))
        field.setId(fieldId: fieldDetails.optInt64(key: ResponseJSONKeys.id))
        field.setDisplayLabel(displayLabel: fieldDetails.optString(key: ResponseJSONKeys.fieldLabel))
        field.setMaxLength(maxLen: fieldDetails.optInt(key: ResponseJSONKeys.length))
        field.setDataType(dataType: fieldDetails.optString(key: ResponseJSONKeys.dataType))
        field.setVisible(isVisible: fieldDetails.optBoolean(key: ResponseJSONKeys.visible))
        field.setDecimalPlace(decimalPlace: fieldDetails.optInt(key: ResponseJSONKeys.decimalPlace))
        field.setReadOnly(isReadOnly: fieldDetails.optBoolean(key: ResponseJSONKeys.readOnly))
        field.setCustomField(isCustomField: fieldDetails.optBoolean(key: ResponseJSONKeys.customField))
        field.setDefaultValue(defaultValue: fieldDetails.optValue(key: ResponseJSONKeys.defaultValue))
        field.setMandatory(isMandatory: fieldDetails.optBoolean(key: ResponseJSONKeys.required))
        field.setSequenceNumber(sequenceNo: fieldDetails.optInt(key: ResponseJSONKeys.sequenceNumber))
        field.setTooltip(tooltip: fieldDetails.optString(key: ResponseJSONKeys.toolTip))
        field.setWebhook(webhook: fieldDetails.optBoolean(key: ResponseJSONKeys.webhook))
        field.setCreatedSource(createdSource: fieldDetails.getString(key: ResponseJSONKeys.createdSource))
        field.setLookup(lookup: fieldDetails.optDictionary(key: ResponseJSONKeys.lookup))
        field.setMultiSelectLookup(multiSelectLookup: fieldDetails.optDictionary(key: ResponseJSONKeys.multiSelectLookup))
        field.setSubFormTabId(subFormTabId: fieldDetails.optInt64(key: ResponseJSONKeys.subformTabId))
        field.setSubForm(subForm: fieldDetails.optDictionary(key: ResponseJSONKeys.subform))
        if(fieldDetails.hasValue(forKey: ResponseJSONKeys.currency))
        {
            let currencyDetails : [String:Any] = fieldDetails.getDictionary(key: ResponseJSONKeys.currency)
            field.setPrecision(precision: currencyDetails.optInt(key: ResponseJSONKeys.precision))
            if (currencyDetails.optString(key: ResponseJSONKeys.roundingOption) == CurrencyRoundingOption.RoundOff.rawValue)
            {
                field.setRoundingOption(roundingOption: CurrencyRoundingOption.RoundOff)
            }
            else if (currencyDetails.optString(key: ResponseJSONKeys.roundingOption) == CurrencyRoundingOption.RoundDown.rawValue)
            {
                field.setRoundingOption(roundingOption: CurrencyRoundingOption.RoundDown)
            }
            else if (currencyDetails.optString(key: ResponseJSONKeys.roundingOption) == CurrencyRoundingOption.RoundUp.rawValue)
            {
                field.setRoundingOption(roundingOption: CurrencyRoundingOption.RoundUp)
            }
            else if (currencyDetails.optString(key: ResponseJSONKeys.roundingOption) == CurrencyRoundingOption.Normal.rawValue)
            {
                field.setRoundingOption(roundingOption: CurrencyRoundingOption.Normal)
            }
        }
        
        field.setBussinessCardSupported(bussinessCardSupported: fieldDetails.optBoolean(key: ResponseJSONKeys.businessCardSupported))
        if ( fieldDetails.hasValue( forKey : ResponseJSONKeys.pickListValues ) )
        {
            let pickListValues = fieldDetails.getArrayOfDictionaries( key : ResponseJSONKeys.pickListValues )
            for pickListValueDict in pickListValues
            {
                let pickListValue = ZCRMPickListValue()
                print( "pickListValueDict : \( pickListValueDict)" )
                pickListValue.setMaps( maps : pickListValueDict.optArrayOfDictionaries( key : ResponseJSONKeys.maps ) )
                pickListValue.setSequenceNumer( number : pickListValueDict.optInt(key : ResponseJSONKeys.sequenceNumber ) )
                pickListValue.setActualName( actualName : pickListValueDict.optString( key : ResponseJSONKeys.actualValue ) )
                pickListValue.setDisplayName( displayName : pickListValueDict.optString( key : ResponseJSONKeys.displayValue ) )
                field.addPickListValue( pickListValue : pickListValue )
            }
        }
        if(fieldDetails.hasValue(forKey: ResponseJSONKeys.formula))
        {
            let formulaDetails : [String:String] = fieldDetails.getDictionary(key: ResponseJSONKeys.formula) as! [String:String]
            field.setFormulaReturnType(formulaReturnType: formulaDetails.optString(key: ResponseJSONKeys.returnType))
            field.setFormula(formulaExpression: formulaDetails.optString(key: ResponseJSONKeys.expression))
        }
        if(fieldDetails.hasValue(forKey: ResponseJSONKeys.currency))
        {
            let currencyDetails : [String:Any] = fieldDetails.getDictionary(key: ResponseJSONKeys.currency)
            field.setPrecision(precision: currencyDetails.optInt(key: ResponseJSONKeys.precision))
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
            field.setSubLayoutsPresent(subLayoutsPresent: layoutsPresent)
        }
        if( fieldDetails.hasValue( forKey : ResponseJSONKeys.privateString ) )
        {
            let privateDetails : [ String : Any ] = fieldDetails.getDictionary( key : ResponseJSONKeys.privateString )
            field.setIsRestricted( isRestricted : privateDetails.optBoolean( key : ResponseJSONKeys.restricted ) )
            field.setIsSupportExport( exportSupported : privateDetails.optBoolean( key : ResponseJSONKeys.export ) )
            field.setRestrictedType( type : privateDetails.optString( key : ResponseJSONKeys.type )  )
        }
        return field
    }
    
    internal func getZCRMModuleRelation( relationListDetails : [ String : Any ] ) -> ZCRMModuleRelation
    {
        let moduleRelation : ZCRMModuleRelation = ZCRMModuleRelation( parentModuleAPIName : module.getAPIName(), relatedListId : relationListDetails.getInt64( key : ResponseJSONKeys.id ) )
        moduleRelation.setAPIName( apiName : relationListDetails.optString( key : ResponseJSONKeys.apiName ) )
        moduleRelation.setLabel( label : relationListDetails.optString( key : ResponseJSONKeys.displayLabel ) )
        moduleRelation.setModule( module : relationListDetails.optString( key : ResponseJSONKeys.module ) )
        moduleRelation.setName( name : relationListDetails.optString( key : ResponseJSONKeys.name) )
        moduleRelation.setType( type : relationListDetails.optString( key : ResponseJSONKeys.type ) )
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


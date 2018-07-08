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
	
    internal func getAllLayouts( modifiedSince : String?, completion: @escaping( BulkAPIResponse?, Error? ) -> () )
    {
		setJSONRootKey( key : LAYOUTS )
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
                completion( nil, error )
            }
            if let bulkResponse = response
            {
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    bulkResponse.setData( data : self.getAllLayouts( layoutsList : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) ) )
                }
                completion( bulkResponse, nil )
            }
        }
    }
    
    internal func getLayout( layoutId : Int64, completion: @escaping( APIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : LAYOUTS )
		setUrlPath(urlPath:  "/settings/layouts/\(layoutId)")
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param: "module" , value: self.module.getAPIName())
		let request : APIRequest = APIRequest(handler: self )
		print( "Request : \( request.toString() )" )
		
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, error )
            }
            if let response = resp
            {
                let responseJSON = response.getResponseJSON()
                let layoutsList:[[String : Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                response.setData(data: self.getZCRMLayout(layoutDetails: layoutsList[0]))
                completion( response, nil )
            }
        }
    }
    
    internal func getAllFields( modifiedSince : String?, completion: @escaping( BulkAPIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : FIELDS )
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
                completion( nil, error )
            }
            if let bulkResponse = response
            {
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    bulkResponse.setData( data : self.getAllFields( allFieldsDetails : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) ) )
                }
                completion( bulkResponse, nil )
            }
        }
    }

    internal func getAllCustomViews( modifiedSince : String?, completion: @escaping( BulkAPIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : CUSTOM_VIEWS )
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
                completion( nil, error )
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
                completion( bulkResponse, nil )
            }
        }
    }
    
    internal func getRelatedList( id : Int64, completion: @escaping( APIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : "related_lists" )
        setUrlPath( urlPath : "settings/related_lists/\(id)" )
        setRequestMethod( requestMethod : .GET )
        addRequestParam( param : "module", value : self.module.getAPIName() )
        let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, error )
            }
            if let response = resp
            {
                let responseJSON = response.responseJSON
                response.setData( data : self.getAllRelatedLists( relatedListsDetails : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) )[ 0 ] )
                completion( response, nil )
            }
        }
    }
    
    internal func getAllRelatedLists( completion: @escaping( BulkAPIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : "related_lists" )
        setUrlPath( urlPath : "settings/related_lists" )
        setRequestMethod( requestMethod : .GET )
        addRequestParam( param : "module", value : self.module.getAPIName() )
        let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, error )
            }
            if let bulkResponse = response
            {
                let responseJSON = bulkResponse.getResponseJSON()
                bulkResponse.setData( data : self.getAllRelatedLists( relatedListsDetails : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) ) )
                completion( bulkResponse, nil )
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
    
    internal func getCustomView( cvId : Int64, completion: @escaping( APIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : CUSTOM_VIEWS )
		setUrlPath(urlPath: "/settings/custom_views/\(cvId)" )
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param: "module" , value: self.module.getAPIName() )
		let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, error )
            }
            if let response = resp
            {
                let cvArray : [ [ String : Any ] ] = response.getResponseJSON().getArrayOfDictionaries( key : self.getJSONRootKey() )
                response.setData( data : self.getZCRMCustomView( cvDetails : cvArray[ 0 ] ) )
                completion( response, nil )
            }
        }
    }
	
	// MARK: - Utility functions
	
    internal func getZCRMCustomView(cvDetails: [String:Any]) -> ZCRMCustomView
    {
        let customView : ZCRMCustomView = ZCRMCustomView( cvId : cvDetails.getInt64( key : "id" ), moduleAPIName : self.module.getAPIName() )
        customView.setName( name : cvDetails.getString( key : "name" ) )
        customView.setSystemName(systemName: cvDetails.optString(key: "system_name"))
        customView.setDisplayName(displayName: cvDetails.optString(key: "display_value")!)
        customView.setIsDefault(isDefault: cvDetails.optBoolean(key: "default")!)
        customView.setCategory(category: cvDetails.optString(key: "category")!)
        customView.setFavouriteSequence(favourite: cvDetails.optInt(key: "favorite"))
        customView.setDisplayFields(fieldsAPINames: cvDetails.optArray(key: "fields") as? [String])
        customView.setSortByCol(fieldAPIName: cvDetails.optString(key: "sort_by"))
        customView.setSortOrder(sortOrder: cvDetails.optString(key: "sort_order"))
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
        let layout : ZCRMLayout = ZCRMLayout(layoutId: layoutDetails.getInt64(key: "id"))
        layout.setName(name: layoutDetails.optString(key: "name"))
        layout.setVisibility(isVisible: layoutDetails.optBoolean(key: "visible"))
        layout.setStatus(status: layoutDetails.optInt(key: "status"))
        if(layoutDetails.hasValue(forKey: "created_by"))
        {
            let createdByObj : [String:Any] = layoutDetails.getDictionary(key: "created_by")
            let createdBy : ZCRMUser = ZCRMUser(userId: createdByObj.getInt64(key: "id"), userFullName: createdByObj.getString(key: "name"))
            layout.setCreatedBy(createdByUser: createdBy)
            layout.setCreatedTime(createdTime: layoutDetails.optString(key: "created_time"))
        }
        if(layoutDetails.hasValue(forKey: "modified_by"))
        {
            let modifiedByObj : [String:Any] = layoutDetails.getDictionary(key: "modified_by")
            let modifiedBy : ZCRMUser = ZCRMUser(userId: modifiedByObj.getInt64(key: "id"), userFullName: modifiedByObj.getString(key: "name"))
            layout.setModifiedBy(modifiedByUser: modifiedBy)
            layout.setModifiedTime(modifiedTime: layoutDetails.optString(key: "modified_time"))
        }
        let profilesDetails : [[String:Any]] = layoutDetails.getArrayOfDictionaries(key: "profiles")
        for profileDetails in profilesDetails
        {
            let profile : ZCRMProfile = ZCRMProfile(profileId: profileDetails.getInt64(key: "id"), profileName: profileDetails.getString(key: "name"))
            profile.setIsDefault(isDefault: profileDetails.getBoolean(key: "default"))
            layout.addAccessibleProfile(profile: profile)
        }
        layout.setSections(allSections: self.getAllSectionsOfLayout(allSectionsDetails: layoutDetails.getArrayOfDictionaries(key: "sections")))
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
        let section : ZCRMSection = ZCRMSection(sectionName: sectionDetails.getString(key: "name"))
        section.setDisplayName(displayName: sectionDetails.optString(key: "display_label"))
        section.setColumnCount(colCount: sectionDetails.optInt(key: "column_count"))
        section.setSequence(sequence: sectionDetails.optInt(key: "sequence_number"))
        section.setFields(allFields: self.getAllFields(allFieldsDetails: sectionDetails.getArrayOfDictionaries(key: "fields") ))
        section.setIsSubformSection( isSubformSection : sectionDetails.getBoolean( key : "isSubformSection" ) )
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
        let field : ZCRMField = ZCRMField(fieldAPIName: fieldDetails.getString(key: "api_name"))
        field.setId(fieldId: fieldDetails.optInt64(key: "id"))
        field.setDisplayLabel(displayLabel: fieldDetails.optString(key: "field_label"))
        field.setMaxLength(maxLen: fieldDetails.optInt(key: "length"))
        field.setDataType(dataType: fieldDetails.optString(key: "data_type"))
        field.setVisible(isVisible: fieldDetails.optBoolean(key: "visible"))
        field.setPrecision(precision: fieldDetails.optInt(key: "decimal_place"))
        field.setReadOnly(isReadOnly: fieldDetails.optBoolean(key: "read_only"))
        field.setCustomField(isCustomField: fieldDetails.optBoolean(key: "custom_field"))
        field.setDefaultValue(defaultValue: fieldDetails.optValue(key: "default_value"))
        field.setMandatory(isMandatory: fieldDetails.optBoolean(key: "required"))
        field.setSequenceNumber(sequenceNo: fieldDetails.optInt(key: "sequence_number"))
        field.setReadOnly(isReadOnly: fieldDetails.optBoolean(key: "read_only"))
        field.setTooltip(tooltip: fieldDetails.optString(key: "tooltip"))
        field.setWebHook(webhook: fieldDetails.optBoolean(key: "webhook"))
        field.setCreatedSource(createdSource: fieldDetails.getString(key: "created_source"))
        field.setBussinessCardSupported(bussinessCardSupported: fieldDetails.optBoolean(key: "businesscard_supported"))
        if ( fieldDetails.hasValue( forKey : "pick_list_values" ) )
        {
            let pickListValues = fieldDetails.getArrayOfDictionaries( key : "pick_list_values" )
            for pickListValueDict in pickListValues
            {
                let pickListValue = ZCRMPickListValue()
                print( "pickListValueDict : \( pickListValueDict)" )
                pickListValue.setMaps( maps : pickListValueDict.optArrayOfDictionaries( key : "maps" ) )
                pickListValue.setSequenceNumer( number : pickListValueDict.optInt(key : "sequence_number" ) )
                pickListValue.setActualName( actualName : pickListValueDict.optString( key : "actual_value" ) )
                pickListValue.setDisplayName( displayName : pickListValueDict.optString( key : "display_value" ) )
                field.addPickListValue( pickListValue : pickListValue )
            }
        }
        if(fieldDetails.hasValue(forKey: "formula"))
        {
            let formulaDetails : [String:String] = fieldDetails.getDictionary(key: "formula") as! [String:String]
            field.setFormulaReturnType(formulaReturnType: formulaDetails.optString(key: "return_type"))
            field.setFormula(formulaExpression: formulaDetails.optString(key: "expression"))
        }
        if(fieldDetails.hasValue(forKey: "currency"))
        {
            let currencyDetails : [String:Any] = fieldDetails.getDictionary(key: "currency")
            field.setPrecision(precision: currencyDetails.optInt(key: "precision"))
        }
        if(fieldDetails.hasValue(forKey: "view_type"))
        {
            let subLayouts : [String:Bool] = fieldDetails.getDictionary(key: "view_type") as! [String : Bool]
			var layoutsPresent : [String] = [String]()
            if(subLayouts.optBoolean(key: "create")!)
			{
                layoutsPresent.append("CREATE")
            }
            if(subLayouts.optBoolean(key: "edit")!)
            {
                layoutsPresent.append("EDIT")
            }
            if(subLayouts.optBoolean(key: "view")!)
            {
                layoutsPresent.append("VIEW")
            }
            if(subLayouts.optBoolean(key: "quick_create")!)
            {
                layoutsPresent.append("QUICK_CREATE")
            }
            field.setSubLayoutsPresent(subLayoutsPresent: layoutsPresent)
        }
        if( fieldDetails.hasValue( forKey : "private" ) )
        {
            let privateDetails : [ String : Any ] = fieldDetails.getDictionary( key : "private" ) 
            field.setIsRestricted( isRestricted : privateDetails.optBoolean( key : "restricted" ) )
            field.setIsSupportExport( exportSupported : privateDetails.optBoolean( key : "export" ) )
            field.setRestrictedType( type : privateDetails.optString( key : "type" )  )
        }
        return field
    }
    
    internal func getZCRMModuleRelation( relationListDetails : [ String : Any ] ) -> ZCRMModuleRelation
    {
        let moduleRelation : ZCRMModuleRelation = ZCRMModuleRelation( parentModuleAPIName : module.getAPIName(), relatedListId : relationListDetails.getInt64( key : "id" ) )
        moduleRelation.setAPIName( apiName : relationListDetails.optString( key : "api_name" ) )
        moduleRelation.setLabel( label : relationListDetails.optString( key : "display_label" ) )
        moduleRelation.setModule( module : relationListDetails.optString( key : "module" ) )
        moduleRelation.setName( name : relationListDetails.optString( key : "name" ) )
        moduleRelation.setType( type : relationListDetails.optString( key : "type" ) )
        return moduleRelation
    }
	
}


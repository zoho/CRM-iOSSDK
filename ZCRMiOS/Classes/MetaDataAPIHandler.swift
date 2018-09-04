//
//  MetaDataAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class MetaDataAPIHandler : CommonAPIHandler
{
    internal func getAllModules( modifiedSince : String?, completion: @escaping( [ ZCRMModule ]?, BulkAPIResponse?, Error? ) -> () )
	{
		var allModules : [ZCRMModule] = [ZCRMModule]()
		setUrlPath(urlPath: "/settings/modules" )
		setRequestMethod(requestMethod: .GET )
        if ( modifiedSince.notNilandEmpty)
        {
			addRequestHeader(header: "If-Modified-Since" , value: modifiedSince! )
        }
		let request : APIRequest = APIRequest(handler : self ) 
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
                    let modulesList:[[String:Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                    for module in modulesList
                    {
                        allModules.append(self.getZCRMModule(moduleDetails: module))
                    }
                    bulkResponse.setData(data: allModules)
                }
                completion( allModules, bulkResponse, nil )
            }
        }
	}
	
    internal func getModule( apiName : String, completion: @escaping( ZCRMModule?, APIResponse?, Error? ) -> () )
	{
		setUrlPath(urlPath: "/settings/modules/\(apiName)" )
		setRequestMethod(requestMethod: .GET )
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
                let responseJSON = response.getResponseJSON()
                let modulesList:[[String : Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                let moduleDetails : [String : Any] = modulesList[0]
                let module = self.getZCRMModule( moduleDetails : moduleDetails )
                response.setData( data : module )
                completion( module, response, nil )
            }
        }
        
	}
	
	private func getZCRMModule(moduleDetails : [String:Any]) -> ZCRMModule
	{
        let module : ZCRMModule = ZCRMModule(moduleAPIName: moduleDetails.getString(key: ResponseParamKeys.apiName))
        module.setId(moduleId: moduleDetails.optInt64(key: ResponseParamKeys.id))
        module.setSystemName(sysName: moduleDetails.optString(key: ResponseParamKeys.moduleName))
        module.setSingularLabel(singularLabel: moduleDetails.optString(key: ResponseParamKeys.singularLabel))
        module.setPluralLabel(pluralLabel: moduleDetails.optString(key: ResponseParamKeys.pluralLabel))
        module.setGeneratedType(type: moduleDetails.getString(key: ResponseParamKeys.generatedType))
        module.setIsCreatable(isCreatable: moduleDetails.optBoolean(key: ResponseParamKeys.creatable))
        module.setIsViewable(isViewable: moduleDetails.optBoolean(key: ResponseParamKeys.viewable))
        module.setIsConvertible(isConvertible: moduleDetails.optBoolean(key: ResponseParamKeys.convertable))
        module.setIsEditable(isEditable: moduleDetails.optBoolean(key: ResponseParamKeys.editable))
        module.setIsDeletable(isDeletable: moduleDetails.optBoolean(key: ResponseParamKeys.deletable))
        module.setVisibility(visible: moduleDetails.optInt(key: ResponseParamKeys.visibility))
        module.setIsGlobalSearchSupported( isSupport : moduleDetails.optBoolean(key: ResponseParamKeys.globalSearchSupported))
        module.setIsAPISupported(isSupport: moduleDetails.optBoolean(key: ResponseParamKeys.apiSupported))
        module.setIsQuickCreate(isQuick: moduleDetails.optBoolean(key: ResponseParamKeys.quickCreate))
        module.setIsScoringSupported(isSupport: moduleDetails.optBoolean(key: ResponseParamKeys.scoringSupported))
        module.setSequenceNumber(number: moduleDetails.optInt(key: ResponseParamKeys.sequenceNumber))
        module.setBusinessCardFieldLimit(limit: moduleDetails.optInt(key: ResponseParamKeys.businessCardFieldLimit))
        module.setWebLink(link: moduleDetails.optString(key: ResponseParamKeys.webLink))
        if(moduleDetails.hasValue(forKey: ResponseParamKeys.modifiedBy))
        {
            let modifiedByObj : [String:Any] = moduleDetails.getDictionary(key: ResponseParamKeys.modifiedBy)
            let modifiedBy : ZCRMUser = ZCRMUser(userId: modifiedByObj.getInt64(key: ResponseParamKeys.id), userFullName: modifiedByObj.getString(key: ResponseParamKeys.name))
            module.setLastModifiedBy(modifiedByUser: modifiedBy)
            module.setLastModifiedTime(lastModifiedTime: moduleDetails.getString(key: ResponseParamKeys.modifiedTime))
        }
        if(moduleDetails.hasValue(forKey: ResponseParamKeys.profiles))
        {
            var profiles : [ZCRMProfile] = [ZCRMProfile]()
            let profilesDetails : [[String:Any]] = moduleDetails.getArrayOfDictionaries(key: ResponseParamKeys.profiles)
            for profileDetails in profilesDetails
            {
                let profile : ZCRMProfile = ZCRMProfile(profileId: profileDetails.getInt64(key: ResponseParamKeys.id), profileName: profileDetails.getString(key: ResponseParamKeys.name))
                profiles.append(profile)
            }
            module.setAllowedProfiles(allowedProfiles: profiles)
        }
        if(moduleDetails.hasValue(forKey : ResponseParamKeys.relatedLists))
        {
            var relatedLists : [ZCRMModuleRelation] = [ZCRMModuleRelation]()
            let relatedListsDetails : [[String:Any]] = moduleDetails.getArrayOfDictionaries(key: ResponseParamKeys.relatedLists)
            for relatedListDetails in relatedListsDetails
            {
                let relatedList : ZCRMModuleRelation = ZCRMModuleRelation(relatedListAPIName: relatedListDetails.getString(key: ResponseParamKeys.apiName), parentModuleAPIName: module.getAPIName())
                setRelatedListProperties(relatedList: relatedList, relatedListDetails: relatedListDetails)
                relatedLists.append(relatedList)
            }
            module.setRelatedLists(allRelatedLists: relatedLists)
        }
        module.setArguments(arguments: moduleDetails.optArrayOfDictionaries(key: ResponseParamKeys.arguments))
        if(moduleDetails.hasValue(forKey: ResponseParamKeys.properties))
        {
            let dollarProperties = moduleDetails.optArray(key: ResponseParamKeys.properties) as! [String]
            var properties : [String] = [String]()
            for dollarProperty in dollarProperties
            {
                var property = dollarProperty
                property.removeFirst()
                properties.append(property)
            }
            module.setProperties(properties: properties)
        }
        module.setDisplayField(displayField: moduleDetails.optString(key: ResponseParamKeys.displayField))
        module.setSearchLayoutFields(searchLayoutFields: moduleDetails.optArray(key: ResponseParamKeys.searchLayoutFields) as? [String])
        if(moduleDetails.hasValue(forKey: ResponseParamKeys.parentModule))
        {
            let parentModuleDetails = moduleDetails.getDictionary(key: ResponseParamKeys.parentModule)
            if parentModuleDetails.hasValue(forKey: ResponseParamKeys.apiName)
            {
                let parentModule : ZCRMModule = ZCRMModule(moduleAPIName: parentModuleDetails.getString( key : ResponseParamKeys.apiName ) )
                parentModule.setId(moduleId: parentModuleDetails.getInt64(key: ResponseParamKeys.id))
                module.setParentModule(parentModule: parentModule)
            }
        }
        if(moduleDetails.hasValue(forKey: ResponseParamKeys.customView))
        {
            module.setCustomView(customView: ModuleAPIHandler(module: module).getZCRMCustomView(cvDetails: moduleDetails.getDictionary(key: ResponseParamKeys.customView)))
        }
        module.setIsKanbanView(isKanbanView: moduleDetails.optBoolean(key: ResponseParamKeys.kanbanView))
        module.setFilterStatus(filterStatus: moduleDetails.optBoolean(key: ResponseParamKeys.filterStatus))
        module.setIsSubMenuPresent(isSubMenuPresent: moduleDetails.optBoolean(key: ResponseParamKeys.presenceSubMenu))
        module.setPerPage(perPage: moduleDetails.optInt(key: ResponseParamKeys.perPage))
        module.setIsFilterSupported(isFilterSupported: moduleDetails.optBoolean(key: ResponseParamKeys.filterSupported))
        module.setIsFeedsRequired(isFeedsRequired: moduleDetails.optBoolean(key: ResponseParamKeys.feedsRequired))
        return module
	}
	
	private func setRelatedListProperties(relatedList : ZCRMModuleRelation, relatedListDetails : [String : Any])
	{
		relatedList.setLabel(label: relatedListDetails.optString(key: ResponseParamKeys.displayLabel))
		relatedList.setChildModuleAPIName(childModuleAPIName: relatedListDetails.optString(key: ResponseParamKeys.module))
		relatedList.setId(relatedListId: relatedListDetails.optInt64(key: ResponseParamKeys.id))
		relatedList.setVisibility(isVisible: relatedListDetails.optBoolean(key: ResponseParamKeys.visible))
		relatedList.setIsDefaultRelatedList(isDefault : (ResponseParamKeys.defaultString == relatedListDetails.optString(key: ResponseParamKeys.type)))
	}
    
    internal override func getJSONRootKey() -> String {
        return MODULES
    }
}

extension MetaDataAPIHandler
{
    internal struct ResponseParamKeys
    {
        static let apiName = "api_name"
        static let id = "id"
        static let moduleName = "module_name"
        static let singularLabel = "singular_label"
        static let pluralLabel = "plural_label"
        static let generatedType = "generated_type"
        static let creatable = "creatable"
        static let viewable = "viewable"
        static let convertable = "convertable"
        static let editable = "editable"
        static let deletable = "deletable"
        static let visibility = "visibility"
        static let globalSearchSupported = "global_search_supported"
        static let apiSupported = "api_supported"
        static let quickCreate = "quick_create"
        static let scoringSupported = "scoring_supported"
        static let sequenceNumber = "sequence_number"
        static let businessCardFieldLimit = "business_card_field_limit"
        static let webLink = "web_link"
        static let modifiedBy = "modified_by"
        static let name = "name"
        static let modifiedTime = "modified_time"
        static let profiles = "profiles"
        static let relatedLists = "related_lists"
        static let arguments = "arguments"
        static let properties = "$properties"
        static let displayField = "display_field"
        static let searchLayoutFields = "search_layout_fields"
        static let parentModule = "parent_module"
        static let customView = "custom_view"
        static let kanbanView = "kanban_view"
        static let filterStatus = "filter_status"
        static let presenceSubMenu = "presence_sub_menu"
        static let perPage = "per_page"
        static let filterSupported = "filter_supported"
        static let feedsRequired = "feeds_required"
        
        static let displayLabel = "display_label"
        static let module = "module"
        static let visible = "visible"
        static let defaultString = "default"
        static let type = "type"
    }
}

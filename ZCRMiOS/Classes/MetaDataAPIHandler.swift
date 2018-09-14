//
//  MetaDataAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class MetaDataAPIHandler : CommonAPIHandler
{
    internal func getAllModules( modifiedSince : String?, completion: @escaping( Result.DataResponse< [ ZCRMModule ], BulkAPIResponse > ) -> () )
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
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
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
                completion( .success( allModules, bulkResponse ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
	}

    internal func getModule( apiName : String, completion: @escaping( Result.DataResponse< ZCRMModule, APIResponse > ) -> () )
	{
		setUrlPath(urlPath: "/settings/modules/\(apiName)" )
		setRequestMethod(requestMethod: .GET )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let modulesList:[[String : Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                let moduleDetails : [String : Any] = modulesList[0]
                let module = self.getZCRMModule( moduleDetails : moduleDetails )
                response.setData( data : module )
                completion( .success( module, response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
	
	private func getZCRMModule(moduleDetails : [String:Any]) -> ZCRMModule
	{
        let module : ZCRMModule = ZCRMModule(moduleAPIName: moduleDetails.getString(key: ResponseJSONKeys.apiName))
        module.setId(moduleId: moduleDetails.optInt64(key: ResponseJSONKeys.id))
        module.setSystemName(sysName: moduleDetails.optString(key: ResponseJSONKeys.moduleName))
        module.setSingularLabel(singularLabel: moduleDetails.optString(key: ResponseJSONKeys.singularLabel))
        module.setPluralLabel(pluralLabel: moduleDetails.optString(key: ResponseJSONKeys.pluralLabel))
        module.setGeneratedType(type: moduleDetails.getString(key: ResponseJSONKeys.generatedType))
        module.setIsCreatable(isCreatable: moduleDetails.optBoolean(key: ResponseJSONKeys.creatable))
        module.setIsViewable(isViewable: moduleDetails.optBoolean(key: ResponseJSONKeys.viewable))
        module.setIsConvertible(isConvertible: moduleDetails.optBoolean(key: ResponseJSONKeys.convertable))
        module.setIsEditable(isEditable: moduleDetails.optBoolean(key: ResponseJSONKeys.editable))
        module.setIsDeletable(isDeletable: moduleDetails.optBoolean(key: ResponseJSONKeys.deletable))
        module.setVisibility(visible: moduleDetails.optInt(key: ResponseJSONKeys.visibility))
        module.setIsGlobalSearchSupported( isSupport : moduleDetails.optBoolean(key: ResponseJSONKeys.globalSearchSupported))
        module.setIsAPISupported(isSupport: moduleDetails.optBoolean(key: ResponseJSONKeys.apiSupported))
        module.setIsQuickCreate(isQuick: moduleDetails.optBoolean(key: ResponseJSONKeys.quickCreate))
        module.setIsScoringSupported(isSupport: moduleDetails.optBoolean(key: ResponseJSONKeys.scoringSupported))
        module.setSequenceNumber(number: moduleDetails.optInt(key: ResponseJSONKeys.sequenceNumber))
        module.setBusinessCardFieldLimit(limit: moduleDetails.optInt(key: ResponseJSONKeys.businessCardFieldLimit))
        module.setWebLink(link: moduleDetails.optString(key: ResponseJSONKeys.webLink))
        if(moduleDetails.hasValue(forKey: ResponseJSONKeys.modifiedBy))
        {
            let modifiedByObj : [String:Any] = moduleDetails.getDictionary(key: ResponseJSONKeys.modifiedBy)
            let modifiedBy : ZCRMUser = ZCRMUser(userId: modifiedByObj.getInt64(key: ResponseJSONKeys.id), userFullName: modifiedByObj.getString(key: ResponseJSONKeys.name))
            module.setLastModifiedBy(modifiedByUser: modifiedBy)
            module.setLastModifiedTime(lastModifiedTime: moduleDetails.getString(key: ResponseJSONKeys.modifiedTime))
        }
        if(moduleDetails.hasValue(forKey: ResponseJSONKeys.profiles))
        {
            var profiles : [ZCRMProfile] = [ZCRMProfile]()
            let profilesDetails : [[String:Any]] = moduleDetails.getArrayOfDictionaries(key: ResponseJSONKeys.profiles)
            for profileDetails in profilesDetails
            {
//                let profile : ZCRMProfile = ZCRMProfile(profileId: profileDetails.getInt64(key: ResponseJSONKeys.id), profileName: profileDetails.getString(key: ResponseJSONKeys.name))
                let profile : ZCRMProfileDelegate = ZCRMProfileDelegate(profileId: profileDetails.getInt64(key: ResponseJSONKeys.id), profileName: profileDetails.getString(key: ResponseJSONKeys.name))
                profiles.append(profile)
            }
            module.setAllowedProfiles(allowedProfiles: profiles)
        }
        if(moduleDetails.hasValue(forKey : ResponseJSONKeys.relatedLists))
        {
            var relatedLists : [ZCRMModuleRelation] = [ZCRMModuleRelation]()
            let relatedListsDetails : [[String:Any]] = moduleDetails.getArrayOfDictionaries(key: ResponseJSONKeys.relatedLists)
            for relatedListDetails in relatedListsDetails
            {
                let relatedList : ZCRMModuleRelation = ZCRMModuleRelation(relatedListAPIName: relatedListDetails.getString(key: ResponseJSONKeys.apiName), parentModuleAPIName: module.getAPIName())
                setRelatedListProperties(relatedList: relatedList, relatedListDetails: relatedListDetails)
                relatedLists.append(relatedList)
            }
            module.setRelatedLists(allRelatedLists: relatedLists)
        }
        module.setArguments(arguments: moduleDetails.optArrayOfDictionaries(key: ResponseJSONKeys.arguments))
        if(moduleDetails.hasValue(forKey: ResponseJSONKeys.properties))
        {
            let dollarProperties = moduleDetails.optArray(key: ResponseJSONKeys.properties) as! [String]
            var properties : [String] = [String]()
            for dollarProperty in dollarProperties
            {
                var property = dollarProperty
                property.removeFirst()
                properties.append(property)
            }
            module.setProperties(properties: properties)
        }
        module.setDisplayField(displayField: moduleDetails.optString(key: ResponseJSONKeys.displayField))
        module.setSearchLayoutFields(searchLayoutFields: moduleDetails.optArray(key: ResponseJSONKeys.searchLayoutFields) as? [String])
        if(moduleDetails.hasValue(forKey: ResponseJSONKeys.parentModule))
        {
            let parentModuleDetails = moduleDetails.getDictionary(key: ResponseJSONKeys.parentModule)
            if parentModuleDetails.hasValue(forKey: ResponseJSONKeys.apiName)
            {
                let parentModule : ZCRMModule = ZCRMModule(moduleAPIName: parentModuleDetails.getString( key : ResponseJSONKeys.apiName ) )
                parentModule.setId(moduleId: parentModuleDetails.getInt64(key: ResponseJSONKeys.id))
                module.setParentModule(parentModule: parentModule)
            }
        }
        if(moduleDetails.hasValue(forKey: ResponseJSONKeys.customView))
        {
            module.setCustomView(customView: ModuleAPIHandler(module: module).getZCRMCustomView(cvDetails: moduleDetails.getDictionary(key: ResponseJSONKeys.customView)))
        }
        module.setIsKanbanView(isKanbanView: moduleDetails.optBoolean(key: ResponseJSONKeys.kanbanView))
        module.setFilterStatus(filterStatus: moduleDetails.optBoolean(key: ResponseJSONKeys.filterStatus))
        module.setIsSubMenuPresent(isSubMenuPresent: moduleDetails.optBoolean(key: ResponseJSONKeys.presenceSubMenu))
        module.setPerPage(perPage: moduleDetails.optInt(key: ResponseJSONKeys.perPage))
        module.setIsFilterSupported(isFilterSupported: moduleDetails.optBoolean(key: ResponseJSONKeys.filterSupported))
        module.setIsFeedsRequired(isFeedsRequired: moduleDetails.optBoolean(key: ResponseJSONKeys.feedsRequired))
        return module
	}
	
	private func setRelatedListProperties(relatedList : ZCRMModuleRelation, relatedListDetails : [String : Any])
	{
		relatedList.setLabel(label: relatedListDetails.optString(key: ResponseJSONKeys.displayLabel))
		relatedList.setChildModuleAPIName(childModuleAPIName: relatedListDetails.optString(key: ResponseJSONKeys.module))
		relatedList.setId(relatedListId: relatedListDetails.optInt64(key: ResponseJSONKeys.id))
		relatedList.setVisibility(isVisible: relatedListDetails.optBoolean(key: ResponseJSONKeys.visible))
		relatedList.setIsDefaultRelatedList(isDefault : (ResponseJSONKeys.defaultString == relatedListDetails.optString(key: ResponseJSONKeys.type)))
	}
    
    internal override func getJSONRootKey() -> String {
        return MODULES
    }
}

fileprivate extension MetaDataAPIHandler
{
    struct ResponseJSONKeys
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

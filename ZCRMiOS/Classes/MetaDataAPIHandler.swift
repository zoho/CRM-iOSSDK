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
	
	internal func getZCRMModule(moduleDetails : [String:Any]) -> ZCRMModule
	{
        let module : ZCRMModule = ZCRMModule(moduleAPIName: moduleDetails.getString(key: "api_name"))
        module.setId(moduleId: moduleDetails.optInt64(key: "id"))
        module.setSystemName(sysName: moduleDetails.optString(key: "module_name"))
        module.setSingularLabel(singularLabel: moduleDetails.optString(key: "singular_label"))
        module.setPluralLabel(pluralLabel: moduleDetails.optString(key: "plural_label"))
        module.setGeneratedType(type: moduleDetails.getString(key: "generated_type"))
        module.setIsCreatable(isCreatable: moduleDetails.optBoolean(key: "creatable"))
        module.setIsViewable(isViewable: moduleDetails.optBoolean(key: "viewable"))
        module.setIsConvertible(isConvertible: moduleDetails.optBoolean(key: "convertable"))
        module.setIsEditable(isEditable: moduleDetails.optBoolean(key: "editable"))
        module.setIsDeletable(isDeletable: moduleDetails.optBoolean(key: "deletable"))
        module.setVisibility(visible: moduleDetails.optInt(key: "visibility"))
        module.setIsGlobalSearchSupported( isSupport : moduleDetails.optBoolean(key: "global_search_supported"))
        module.setIsAPISupported(isSupport: moduleDetails.optBoolean(key: "api_supported"))
        module.setIsQuickCreate(isQuick: moduleDetails.optBoolean(key: "quick_create"))
        module.setIsScoringSupported(isSupport: moduleDetails.optBoolean(key: "scoring_supported"))
        module.setSequenceNumber(number: moduleDetails.optInt(key: "sequence_number"))
        module.setBusinessCardFieldLimit(limit: moduleDetails.optInt(key: "business_card_field_limit"))
        module.setWebLink(link: moduleDetails.optString(key: "web_link"))
        if(moduleDetails.hasValue(forKey: "modified_by"))
        {
            let modifiedByObj : [String:Any] = moduleDetails.getDictionary(key: "modified_by")
            let modifiedBy : ZCRMUser = ZCRMUser(userId: modifiedByObj.getInt64(key: "id"), userFullName: modifiedByObj.getString(key: "name"))
            module.setLastModifiedBy(modifiedByUser: modifiedBy)
            module.setLastModifiedTime(lastModifiedTime: moduleDetails.getString(key: "modified_time"))
        }
        if(moduleDetails.hasValue(forKey: "profiles"))
        {
            var profiles : [ZCRMProfile] = [ZCRMProfile]()
            let profilesDetails : [[String:Any]] = moduleDetails.getArrayOfDictionaries(key: "profiles")
            for profileDetails in profilesDetails
            {
                let profile : ZCRMProfile = ZCRMProfile(profileId: profileDetails.getInt64(key: "id"), profileName: profileDetails.getString(key: "name"))
                profiles.append(profile)
            }
            module.setAllowedProfiles(allowedProfiles: profiles)
        }
        if(moduleDetails.hasValue(forKey : "related_lists"))
        {
            var relatedLists : [ZCRMModuleRelation] = [ZCRMModuleRelation]()
            let relatedListsDetails : [[String:Any]] = moduleDetails.getArrayOfDictionaries(key: "related_lists")
            for relatedListDetails in relatedListsDetails
            {
                let relatedList : ZCRMModuleRelation = ZCRMModuleRelation(relatedListAPIName: relatedListDetails.getString(key: "api_name"), parentModuleAPIName: module.getAPIName())
                setRelatedListProperties(relatedList: relatedList, relatedListDetails: relatedListDetails)
                relatedLists.append(relatedList)
            }
            module.setRelatedLists(allRelatedLists: relatedLists)
        }
        module.setArguments(arguments: moduleDetails.optDictionary(key: "arguments"))
        if(moduleDetails.hasValue(forKey: "$properties"))
        {
            let dollarProperties = moduleDetails.optArray(key: "$properties") as! [String]
            var properties : [String] = [String]()
            for dollarProperty in dollarProperties
            {
                dollarProperty.replacingOccurrences(of: "$", with: "")
                properties.append(dollarProperty)
            }
            module.setProperties(properties: properties)
        }
        module.setDisplayField(displayField: moduleDetails.optString(key: "display_field"))
        module.setSearchLayoutFields(searchLayoutFields: moduleDetails.optArray(key: "search_layout_fields") as? [String])
        if(moduleDetails.hasValue(forKey: "parent_module"))
        {
            module.setParentModule(parentModule: MetaDataAPIHandler().getZCRMModule(moduleDetails: moduleDetails.getDictionary(key: "parent_module")))
        }
        if(moduleDetails.hasValue(forKey: "custom_view"))
        {
            module.setCustomView(customView: ModuleAPIHandler(module: module).getZCRMCustomView(cvDetails: moduleDetails.getDictionary(key: "custom_view")))
        }
        return module
	}
	
	private func setRelatedListProperties(relatedList : ZCRMModuleRelation, relatedListDetails : [String : Any])
	{
		relatedList.setLabel(label: relatedListDetails.optString(key: "display_label"))
		relatedList.setChildModuleAPIName(childModuleAPIName: relatedListDetails.optString(key: "module"))
		relatedList.setId(relatedListId: relatedListDetails.optInt64(key: "id"))
		relatedList.setVisibility(isVisible: relatedListDetails.optBoolean(key: "visible"))
		relatedList.setIsDefaultRelatedList(isDefault : ("default" == relatedListDetails.optString(key: "type")))
	}
    
    internal override func getJSONRootKey() -> String {
        return MODULES
    }
	
}

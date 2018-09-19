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
                        allModules.append(try self.getZCRMModule(moduleDetails: module))
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
                let module = try self.getZCRMModule( moduleDetails : moduleDetails )
                response.setData( data : module )
                completion( .success( module, response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
	
	private func getZCRMModule(moduleDetails : [String:Any]) throws -> ZCRMModule
	{
        let module : ZCRMModule = ZCRMModule( apiName : moduleDetails.getString(key: ResponseJSONKeys.apiName), singularLabel: moduleDetails.getString(key: ResponseJSONKeys.singularLabel), pluralLabel: moduleDetails.getString(key: ResponseJSONKeys.pluralLabel))
        module.id = moduleDetails.getInt64(key: ResponseJSONKeys.id)
        module.systemName = moduleDetails.getString(key: ResponseJSONKeys.moduleName)
        module.generatedType = moduleDetails.getString(key: ResponseJSONKeys.generatedType)
        module.creatable = moduleDetails.getBoolean(key: ResponseJSONKeys.creatable)
        module.viewable = moduleDetails.getBoolean(key: ResponseJSONKeys.viewable)
        module.convertible = moduleDetails.getBoolean(key: ResponseJSONKeys.convertable)
        module.editable = moduleDetails.getBoolean(key: ResponseJSONKeys.editable)
        module.deletable = moduleDetails.getBoolean(key: ResponseJSONKeys.deletable)
        module.visibility = moduleDetails.getInt(key: ResponseJSONKeys.visibility)
        module.globalSearchSupported = moduleDetails.getBoolean(key: ResponseJSONKeys.globalSearchSupported)
        module.apiSupported = moduleDetails.getBoolean(key: ResponseJSONKeys.apiSupported)
        module.quickCreate = moduleDetails.getBoolean(key: ResponseJSONKeys.quickCreate)
        module.scoringSupported = moduleDetails.getBoolean(key: ResponseJSONKeys.scoringSupported)
        module.sequenceNumber = moduleDetails.getInt(key: ResponseJSONKeys.sequenceNumber)
        module.businessCardFieldLimit = moduleDetails.getInt(key: ResponseJSONKeys.businessCardFieldLimit)
        module.webLink = moduleDetails.optString(key: ResponseJSONKeys.webLink)
        if(moduleDetails.hasValue(forKey: ResponseJSONKeys.modifiedBy))
        {
            let modifiedByObj : [String:Any] = moduleDetails.getDictionary(key: ResponseJSONKeys.modifiedBy)
            let modifiedBy : ZCRMUserDelegate = ZCRMUserDelegate(id: modifiedByObj.getInt64(key: ResponseJSONKeys.id), name: modifiedByObj.getString(key: ResponseJSONKeys.name))
            module.modifiedBy = modifiedBy
            module.modifiedTime = moduleDetails.getString(key: ResponseJSONKeys.modifiedTime)
        }
        if(moduleDetails.hasValue(forKey: ResponseJSONKeys.profiles))
        {
            var profiles : [ZCRMProfileDelegate] = [ZCRMProfileDelegate]()
            let profilesDetails : [[String:Any]] = moduleDetails.getArrayOfDictionaries(key: ResponseJSONKeys.profiles)
            for profileDetails in profilesDetails
            {
                let profile : ZCRMProfileDelegate = ZCRMProfileDelegate(profileId: profileDetails.getInt64(key: ResponseJSONKeys.id), profileName: profileDetails.getString(key: ResponseJSONKeys.name))
                profiles.append(profile)
            }
            module.allowedProfiles = profiles
        }
        if(moduleDetails.hasValue(forKey : ResponseJSONKeys.relatedLists))
        {
            var relatedLists : [ZCRMModuleRelation] = [ZCRMModuleRelation]()
            let relatedListsDetails : [[String:Any]] = moduleDetails.getArrayOfDictionaries(key: ResponseJSONKeys.relatedLists)
            for relatedListDetails in relatedListsDetails
            {
                let relatedList : ZCRMModuleRelation = ZCRMModuleRelation(relatedListAPIName: relatedListDetails.getString(key: ResponseJSONKeys.apiName), parentModuleAPIName: module.apiName)
                try setRelatedListProperties(relatedList: relatedList, relatedListDetails: relatedListDetails)
                relatedLists.append(relatedList)
            }
            module.relatedLists = relatedLists
        }
        module.arguments = moduleDetails.optArrayOfDictionaries(key: ResponseJSONKeys.arguments)
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
            module.properties = properties
        }
        module.displayField = moduleDetails.getString(key: ResponseJSONKeys.displayField)
        module.searchLayoutFields = moduleDetails.getArray(key: ResponseJSONKeys.searchLayoutFields) as? [String]
        if(moduleDetails.hasValue(forKey: ResponseJSONKeys.parentModule))
        {
            let parentModuleDetails = moduleDetails.getDictionary(key: ResponseJSONKeys.parentModule)
            if parentModuleDetails.hasValue(forKey: ResponseJSONKeys.apiName)
            {
                let parentModule : ZCRMModuleDelegate = ZCRMModuleDelegate(apiName: parentModuleDetails.getString( key : ResponseJSONKeys.apiName ) )
                module.parenModule = parentModule
            }
        }
        if(moduleDetails.hasValue(forKey: ResponseJSONKeys.customView))
        {
            module.customView = ModuleAPIHandler(module: module).getZCRMCustomView(cvDetails: moduleDetails.getDictionary(key: ResponseJSONKeys.customView))
        }
        if moduleDetails.hasValue( forKey : ResponseJSONKeys.kanbanView ) == false
        {
            module.isKanbanView = moduleDetails.getBoolean(key: ResponseJSONKeys.kanbanView)
        }
        if moduleDetails.hasValue( forKey : ResponseJSONKeys.filterStatus ) == false
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\( ResponseJSONKeys.filterStatus ) is must not be nil" )
        }
        module.filterStatus = moduleDetails.getBoolean(key: ResponseJSONKeys.filterStatus)
        if moduleDetails.hasValue( forKey : ResponseJSONKeys.presenceSubMenu ) == false
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\( ResponseJSONKeys.presenceSubMenu ) is must not be nil" )
        }
        module.isSubMenuPresent = moduleDetails.getBoolean(key: ResponseJSONKeys.presenceSubMenu)
        if moduleDetails.hasValue( forKey : ResponseJSONKeys.perPage ) == false
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\( ResponseJSONKeys.perPage ) is must not be nil" )
        }
        module.perPage = moduleDetails.getInt(key: ResponseJSONKeys.perPage)
        if moduleDetails.hasValue( forKey : ResponseJSONKeys.filterSupported ) == false
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\( ResponseJSONKeys.filterSupported ) is must not be nil" )
        }
        module.filterStatus = moduleDetails.getBoolean(key: ResponseJSONKeys.filterSupported)
        if moduleDetails.hasValue( forKey : ResponseJSONKeys.feedsRequired ) == false
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\( ResponseJSONKeys.feedsRequired ) is must not be nil" )
        }
        module.isFeedsRequired = moduleDetails.getBoolean(key: ResponseJSONKeys.feedsRequired)
        return module
	}
	
	private func setRelatedListProperties(relatedList : ZCRMModuleRelation, relatedListDetails : [String : Any]) throws
	{
        if relatedListDetails.hasValue( forKey : ResponseJSONKeys.displayLabel ) == false
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\( ResponseJSONKeys.displayLabel ) is must not be nil" )
        }
        relatedList.label = relatedListDetails.getString(key: ResponseJSONKeys.displayLabel)
        if relatedListDetails.hasValue( forKey : ResponseJSONKeys.module ) == false
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\( ResponseJSONKeys.module ) is must not be nil" )
        }
		relatedList.childModuleAPIName = relatedListDetails.getString(key: ResponseJSONKeys.module)
        if relatedListDetails.hasValue( forKey : ResponseJSONKeys.id ) == false
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\( ResponseJSONKeys.id ) is must not be nil" )
        }
		relatedList.id = relatedListDetails.getInt64(key: ResponseJSONKeys.id)
        if relatedListDetails.hasValue( forKey : ResponseJSONKeys.visible ) == false
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\( ResponseJSONKeys.visible ) is must not be nil" )
        }
		relatedList.visible = relatedListDetails.getBoolean(key: ResponseJSONKeys.visible)
        relatedList.isDefault = (ResponseJSONKeys.defaultString == relatedListDetails.optString(key: ResponseJSONKeys.type)) 
	}
    
    internal override func getJSONRootKey() -> String {
        return APIConstants.MODULES
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

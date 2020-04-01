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
        setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.modules )" )
        setRequestMethod(requestMethod: .get )
        if ( modifiedSince.notNilandEmpty)
        {
            addRequestHeader(header: RequestParamKeys.ifModifiedSince , value: modifiedSince! )
        }
        let request : APIRequest = APIRequest(handler : self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let modulesList:[ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    if modulesList.isEmpty == true
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.processingError( code: ErrorCode.responseNil, message: ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    for module in modulesList
                    {
                        allModules.append(try self.getZCRMModule(moduleDetails: module))
                    }
                }
                bulkResponse.setData(data: allModules)
                completion( .success( allModules, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getModule( apiName : String, completion: @escaping( Result.DataResponse< ZCRMModule, APIResponse > ) -> () )
    {
        setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.modules )/\(apiName)" )
        setRequestMethod(requestMethod: .get )
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let modulesList : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let moduleDetails : [String : Any] = modulesList[0]
                let module = try self.getZCRMModule( moduleDetails : moduleDetails )
                response.setData( data : module )
                completion( .success( module, response ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    private func getZCRMModule(moduleDetails : [String:Any]) throws -> ZCRMModule
    {
        let module : ZCRMModule = ZCRMModule( apiName : try moduleDetails.getString( key : ResponseJSONKeys.apiName ), singularLabel : try moduleDetails.getString( key : ResponseJSONKeys.singularLabel ), pluralLabel : try moduleDetails.getString( key : ResponseJSONKeys.pluralLabel ) )
        module.id = try moduleDetails.getInt64( key : ResponseJSONKeys.id )
        module.name = try moduleDetails.getString( key : ResponseJSONKeys.moduleName )
        module.generatedType = try moduleDetails.getString( key : ResponseJSONKeys.generatedType )
        module.isCreatable = try moduleDetails.getBoolean( key : ResponseJSONKeys.creatable )
        module.isViewable = try moduleDetails.getBoolean( key : ResponseJSONKeys.viewable )
        module.isConvertible = try moduleDetails.getBoolean( key : ResponseJSONKeys.convertable )
        module.isEditable = try moduleDetails.getBoolean( key : ResponseJSONKeys.editable )
        module.isDeletable = try moduleDetails.getBoolean( key : ResponseJSONKeys.deletable )
        module.visibility = try moduleDetails.getInt( key : ResponseJSONKeys.visibility )
        module.isGlobalSearchSupported = try moduleDetails.getBoolean( key : ResponseJSONKeys.globalSearchSupported )
        module.isAPISupported = try moduleDetails.getBoolean( key : ResponseJSONKeys.apiSupported )
        module.isQuickCreateAvailable = try moduleDetails.getBoolean( key : ResponseJSONKeys.quickCreate )
        module.isScoringSupported = try moduleDetails.getBoolean( key : ResponseJSONKeys.scoringSupported )
        module.sequenceNumber = try moduleDetails.getInt( key : ResponseJSONKeys.sequenceNumber )
        module.businessCardFieldLimit = try moduleDetails.getInt( key : ResponseJSONKeys.businessCardFieldLimit )
        module.webLink = moduleDetails.optString(key: ResponseJSONKeys.webLink)
        if(moduleDetails.hasValue(forKey: ResponseJSONKeys.modifiedBy))
        {
            let modifiedByObj : [ String : Any ] = try moduleDetails.getDictionary( key : ResponseJSONKeys.modifiedBy )
            let modifiedBy = try getUserDelegate(userJSON: modifiedByObj)
            module.modifiedBy = modifiedBy
            module.modifiedTime = try moduleDetails.getString( key : ResponseJSONKeys.modifiedTime )
        }
        if(moduleDetails.hasValue(forKey: ResponseJSONKeys.profiles))
        {
            var profiles : [ZCRMProfileDelegate] = [ZCRMProfileDelegate]()
            let profilesDetails : [ [ String : Any ] ] = try moduleDetails.getArrayOfDictionaries( key : ResponseJSONKeys.profiles )
            for profileDetails in profilesDetails
            {
                let profile : ZCRMProfileDelegate = ZCRMProfileDelegate( id : try profileDetails.getInt64( key : ResponseJSONKeys.id ), name : try profileDetails.getString( key : ResponseJSONKeys.name ) )
                profiles.append(profile)
            }
            module.accessibleProfiles = profiles
        }
        if(moduleDetails.hasValue(forKey : ResponseJSONKeys.relatedLists))
        {
            var relatedLists : [ZCRMModuleRelation] = [ZCRMModuleRelation]()
            let relatedListsDetails : [ [ String : Any ] ] = try moduleDetails.getArrayOfDictionaries( key : ResponseJSONKeys.relatedLists )
            for relatedListDetails in relatedListsDetails
            {
                let relatedList : ZCRMModuleRelation = ZCRMModuleRelation( relatedListAPIName : try relatedListDetails.getString( key : ResponseJSONKeys.apiName ), parentModuleAPIName : module.apiName )
                try setRelatedListProperties(relatedList: relatedList, relatedListDetails: relatedListDetails)
                relatedLists.append(relatedList)
            }
            module.relatedLists = relatedLists
        }
        module.arguments = moduleDetails.optArrayOfDictionaries(key: ResponseJSONKeys.arguments)
        if( moduleDetails.hasValue(forKey: ResponseJSONKeys.displayField))
        {
            module.displayField = try moduleDetails.getString( key : ResponseJSONKeys.displayField )
        }
        if( moduleDetails.hasValue(forKey: ResponseJSONKeys.searchLayoutFields))
        {
            module.searchLayoutFields = try moduleDetails.getArray( key : ResponseJSONKeys.searchLayoutFields ) as? [ String ]
        }
        if(moduleDetails.hasValue(forKey: ResponseJSONKeys.parentModule))
        {
            let parentModuleDetails = try moduleDetails.getDictionary( key : ResponseJSONKeys.parentModule )
            if parentModuleDetails.hasValue(forKey: ResponseJSONKeys.apiName)
            {
                let parentModule : ZCRMModuleDelegate = ZCRMModuleDelegate( apiName : try parentModuleDetails.getString( key : ResponseJSONKeys.apiName ) )
                module.parentModule = parentModule
            }
        }
        if(moduleDetails.hasValue(forKey: ResponseJSONKeys.customView))
        {
            module.customView = try ModuleAPIHandler(module: module, cacheFlavour : .noCache).getZCRMCustomView(cvDetails: moduleDetails.getDictionary(key: ResponseJSONKeys.customView))
        }
        if (moduleDetails.hasValue( forKey : ResponseJSONKeys.kanbanView ))
        {
            module.isKanbanViewEnabled = try moduleDetails.getBoolean(key: ResponseJSONKeys.kanbanView)
        }
        if moduleDetails.hasValue( forKey : ResponseJSONKeys.filterStatus )
        {
            module.filterStatus = try moduleDetails.getBoolean( key : ResponseJSONKeys.filterStatus )
        }
        if moduleDetails.hasValue( forKey : ResponseJSONKeys.presenceSubMenu )
        {
            module.isSubMenuPresent = try moduleDetails.getBoolean( key : ResponseJSONKeys.presenceSubMenu )
        }
        if moduleDetails.hasValue( forKey : ResponseJSONKeys.perPage )
        {
            module.perPage = try moduleDetails.getInt( key : ResponseJSONKeys.perPage )
        }
        module.filterStatus = try moduleDetails.getBoolean(key: ResponseJSONKeys.filterSupported)
        module.isFeedsRequired = try moduleDetails.getBoolean(key: ResponseJSONKeys.feedsRequired)
        if moduleDetails.hasValue(forKey: ResponseJSONKeys.emailTemplateSupported)
        {
            module.isEmailTemplateSupported = try moduleDetails.getBoolean(key: ResponseJSONKeys.emailTemplateSupported)
        }
        return module
    }
    
    private func setRelatedListProperties(relatedList : ZCRMModuleRelation, relatedListDetails : [String : Any]) throws
    {
        relatedList.label = try relatedListDetails.getString(key: ResponseJSONKeys.displayLabel)
        relatedList.module = try relatedListDetails.getString(key: ResponseJSONKeys.module)
        relatedList.id = try relatedListDetails.getInt64(key: ResponseJSONKeys.id)
        relatedList.isVisible = try relatedListDetails.getBoolean(key: ResponseJSONKeys.visible)
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
        static let emailTemplateSupported = "emailTemplate_support"
        
        static let displayLabel = "display_label"
        static let module = "module"
        static let visible = "visible"
        static let defaultString = "default"
        static let type = "type"
    }
    
    struct URLPathConstants {
        static let settings = "settings"
        static let modules = "modules"
    }
}

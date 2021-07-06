//
//  ZCRMRestClient.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 06/09/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class ZCRMSDKUtil
{
    public static func getModuleDelegate( apiName : String ) -> ZCRMModuleDelegate
    {
        return ZCRMModuleDelegate(apiName: apiName)
    }
    
    public static func getCompanyInfoDelegate() -> ZCRMCompanyInfoDelegate
    {
        return ZCRMCompanyInfoDelegate()
    }
    
    @available(*, deprecated, message: "Use getCompanyInfoDelegate method instead")
    public static func getOrgDelegate() -> ZCRMOrgDelegate
    {
        return ZCRMOrgDelegate()
    }
    
    public static func newVariableGroup( name : String ) -> ZCRMVariableGroup
    {
        return ZCRMVariableGroup(name: name)
    }
    
    @available(*, deprecated, message: "Use the method newVariable wih param - type as VariableType instead of String" )
    public static func newVariable( name : String, apiName : String, type : String, variableGroup : ZCRMVariableGroup ) -> ZCRMVariable
    {
        return ZCRMVariable(name: name, apiName: apiName, type: type, variableGroup: variableGroup)
    }
    
    public static func newVariable( name : String, apiName : String, type : VariableType, variableGroup : ZCRMVariableGroup ) -> ZCRMVariable
    {
        return ZCRMVariable(name: name, apiName: apiName, type: type.rawValue, variableGroup: variableGroup)
    }
    
    public static func getCompanyDetails( completion : @escaping( Result.DataResponse< ZCRMCompanyInfo, APIResponse > ) -> () )
    {
        OrgAPIHandler(cacheFlavour: CacheFlavour.forceCache).getCompanyDetails(completion: completion)
    }
    
    public static func getCompanyDetailsFromServer( completion : @escaping( Result.DataResponse< ZCRMCompanyInfo, APIResponse > ) -> () )
    {
        OrgAPIHandler(cacheFlavour: CacheFlavour.noCache).getCompanyDetails(completion: completion)
    }
    
    public static func getCompanyDetails( forId id : Int64, completion : @escaping( Result.DataResponse< ZCRMCompanyInfo, APIResponse > ) -> () )
    {
        OrgAPIHandler(cacheFlavour: CacheFlavour.forceCache).getCompanyDetails(id, completion: completion)
    }
    
    public static func getCompanyDetailsFromServer( forId id : Int64, completion : @escaping( Result.DataResponse< ZCRMCompanyInfo, APIResponse > ) -> () )
    {
        OrgAPIHandler(cacheFlavour: CacheFlavour.noCache).getCompanyDetails(id, completion: completion)
    }
    
    @available(*, deprecated, message: "Use getCompanyDetails(completion:) method instead")
    public static func getOrgDetails( completion : @escaping( Result.DataResponse< ZCRMOrg, APIResponse > ) -> () )
    {
        OrgAPIHandler(cacheFlavour: CacheFlavour.forceCache).getOrgDetails(completion : completion)
    }
    
    @available(*, deprecated, message: "Use getCompanyDetailsFromServer(completion:) method instead")
    public static func getOrgDetailsFromServer( completion : @escaping( Result.DataResponse< ZCRMOrg, APIResponse > ) -> () )
    {
        OrgAPIHandler(cacheFlavour: CacheFlavour.noCache).getOrgDetails(completion : completion)
    }
    
    @available(*, deprecated, message: "Use getCompanyDetails(forId:, completion:) method instead")
    public static func getOrgDetails( forId id : Int64, completion : @escaping( Result.DataResponse< ZCRMOrg, APIResponse > ) -> () )
    {
        OrgAPIHandler(cacheFlavour: CacheFlavour.forceCache).getOrgDetails( id, completion: completion )
    }
    
    @available(*, deprecated, message: "Use getCompanyDetailsFromServer(forId:, completion:) method instead")
    public static func getOrgDetailsFromServer( forId id : Int64, completion : @escaping( Result.DataResponse< ZCRMOrg, APIResponse > ) -> () )
    {
        OrgAPIHandler(cacheFlavour: CacheFlavour.noCache).getOrgDetails( id, completion: completion )
    }
    
    public static func getModule( moduleAPIName : String, completion : @escaping( Result.DataResponse< ZCRMModule, APIResponse > ) -> () )
    {
        MetaDataAPIHandler().getModule( apiName : moduleAPIName ) { ( result ) in
            completion( result )
        }
    }
    
    public static func getModules( completion : @escaping( Result.DataResponse< [ ZCRMModule ], BulkAPIResponse > ) -> () )
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public static func getModules( modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMModule ], BulkAPIResponse > ) -> () )
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : modifiedSince ) { ( result ) in
            completion( result )
        }
    }
    
    public static func getCurrentUser( completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler(cacheFlavour: CacheFlavour.forceCache).getCurrentUser() { ( result ) in
            completion( result )
        }
    }
    
    public static func getCurrentUserFromServer( completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler(cacheFlavour: .noCache).getCurrentUser { ( result ) in
            completion( result )
        }
    }
    
    public static func createVariables( variables : [ZCRMVariable], completion : @escaping( Result.DataResponse< [ZCRMVariable], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().createVariables(variables: variables) { ( result ) in
            completion( result )
        }
    }
    
    public static func updateVariables( variables : [ZCRMVariable], completion : @escaping( Result.DataResponse< [ZCRMVariable], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().updateVariables(variables: variables) { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariableGroups( completion : @escaping( Result.DataResponse< [ZCRMVariableGroup], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().getVariableGroups { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariableGroup( id : Int64, completion : @escaping( Result.DataResponse< ZCRMVariableGroup, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariableGroup(id: id, apiName: nil) { ( result ) in
            completion(result)
        }
    }
    
    public static func getVariableGroup( apiName : String, completion : @escaping( Result.DataResponse< ZCRMVariableGroup, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariableGroup(id: nil, apiName: apiName) { ( result ) in
            completion(result)
        }
    }
    
    public static func getVariables( completion : @escaping( Result.DataResponse< [ZCRMVariable], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().getVariables { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariable( variableId : Int64, variableGroupId : Int64, completion : @escaping( Result.DataResponse< ZCRMVariable, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariable(variableId: variableId, variableAPIName: nil, variableGroupId: variableGroupId, variableGroupAPIName: nil) { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariable( variableId : Int64, variableGroupAPIName : String, completion : @escaping( Result.DataResponse< ZCRMVariable, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariable(variableId: variableId, variableAPIName: nil, variableGroupId: nil, variableGroupAPIName:  variableGroupAPIName) { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariable( variableAPIName : String, variableGroupId : Int64, completion : @escaping( Result.DataResponse< ZCRMVariable, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariable(variableId: nil, variableAPIName: variableAPIName, variableGroupId: variableGroupId, variableGroupAPIName: nil) { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariable( variableAPIName : String, variableGroupAPIName : String, completion : @escaping( Result.DataResponse< ZCRMVariable, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariable(variableId: nil, variableAPIName: variableAPIName, variableGroupId: nil, variableGroupAPIName: variableGroupAPIName) { ( result ) in
            completion( result )
        }
    }
    
    public static func deleteVariables( ids : [Int64], completion : @escaping( Result.Response< BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().deleteVariables(ids: ids) { ( result ) in
            completion( result )
        }
    }
    
    public static func getCompanyDetails( _ id : Int64, completion : @escaping ( Result.DataResponse< ZCRMCompanyInfo, APIResponse > ) -> Void )
    {
        OrgAPIHandler().getCompanyDetails(id, completion: completion)
    }
    
    @available(*, deprecated, message: "Use getCompanyDetails(id:, completion:) method instead")
    public static func getOrgDetails( _ id : Int64, completion : @escaping ( Result.DataResponse< ZCRMOrg, APIResponse > ) -> Void )
    {
        OrgAPIHandler().getOrgDetails( id, completion: completion )
    }
    
    @available(*, deprecated, message: "Use the method makeRequest with param requestBody instead" )
    public static func makeRequest(withURL url : URL, _ requestMethod : RequestMethod , headers : [ String : String ]?, completion : @escaping ( Result.DataURLResponse<Data, HTTPURLResponse> ) -> Void )
    {
        APIRequest(absoluteURL: url, requestMethod: requestMethod).initialiseRequest( headers, nil ) { result in
            completion( result )
        }
    }
    
    public static func makeRequest(withURL url : URL, _ requestMethod : RequestMethod , headers : [ String : String ]?, requestBody : [ String : Any ]?, completion : @escaping ( Result.DataURLResponse<Data, HTTPURLResponse> ) -> Void )
    {
        APIRequest(absoluteURL: url, requestMethod: requestMethod).initialiseRequest( headers, requestBody ) { result in
            completion( result )
        }
    }
    
    /**
      To get the details of all the territories
     
     - Parameters:
        - completion :
            - Success : Returns an array of ZCRMTerritory objects and a bulkAPIResponse
            - Failure : Returns error
     */
    public static func getZCRMTerritories( completion : @escaping ( Result.DataResponse< [ ZCRMTerritory ], BulkAPIResponse > ) -> ())
    {
        OrgAPIHandler().getZCRMTerritories() { result in
            completion( result )
        }
    }
    
    /**
      To get the details of a territory by its ID
     
     - Parameters:
        - byId : Id of the territory whose details has to be fetched
        - completion :
            - success : Returns a ZCRMTerritory object and an APIResponse
            - Failure : Returns error
     */
    public static func getZCRMTerritory( byId id : Int64, completion : @escaping ( Result.DataResponse< ZCRMTerritory, APIResponse > ) -> ())
    {
        OrgAPIHandler().getZCRMTerritory( byId : id ) { result in
            completion( result )
        }
    }
}

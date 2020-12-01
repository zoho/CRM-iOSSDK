//
//  ZCRMRestClient.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 06/09/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation
import ZCacheiOS

public class ZCRMSDKUtil: ZCacheClient
{
    public func getModules<T>(completion: ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheModule {
        
    }
    
    public func getModulesFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheModule {
        MetaDataAPIHandler().getAllModules( modifiedSince : nil ) { ( result ) in
            switch result {
            case .success(let modules, _): do {
                completion(.success(modules as! [T]))
            }
            case .failure(let error): do {
//                completion(.failure(error))
            }
            }
        }
    }
    
    public func getModulesFromServer<T>(modifiedSince: String, completion: ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheModule {
        
    }
    
    public func getModule<T>(withId: String, completion: ((Result<T, ZCacheError>) -> Void)) where T : ZCacheModule {
        
    }
    
    public func getModuleFromServer<T>(withId: String, completion: ((Result<T, ZCacheError>) -> Void)) where T : ZCacheModule {
        
    }
    
    public func getModule<T>(withName: String, completion: ((Result<T, ZCacheError>) -> Void)) where T : ZCacheModule {
        
    }
    
    public func getModuleFromServer<T>(withName: String, modifiedSince: String, completion: ((Result<T, ZCacheError>) -> Void)) where T : ZCacheModule {
        
    }
    
    public func getUsers<T>(completion: ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheUser {
        
    }
    
    public func getUsersFromServer<T>(completion: ((Result<[T], ZCacheError>) -> Void)) where T : ZCacheUser {
        
    }
    
    public func getUser<T>(withId: String, completion: ((Result<T, ZCacheError>) -> Void)) where T : ZCacheUser {
        
    }
    
    public func getUserFromServer<T>(withId: String, completion: ((Result<T, ZCacheError>) -> Void)) where T : ZCacheUser {
        
    }
    
    public func getCurrentUser<T>(completion: ((Result<T, ZCacheError>) -> Void)) where T : ZCacheUser {
        
    }
    
    public func getCurrentUserFromServer<T>(completion: ((Result<T, ZCacheError>) -> Void)) where T : ZCacheUser {
        
    }
    
//    func getModules<T: ZCacheModule>(completion: ((Result<[T], ZCacheError>) -> Void)) {
//
//    }
    
    public static func getModuleDelegate( apiName : String ) -> ZCRMModuleDelegate
    {
        return ZCRMModuleDelegate(apiName: apiName)
    }
    
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
    
    public static func getOrgDetails( completion : @escaping( ResultType.DataResponse< ZCRMOrg, APIResponse > ) -> () )
    {
        OrgAPIHandler(cacheFlavour: CacheFlavour.forceCache).getOrgDetails { ( result ) in
            completion( result )
        }
    }
    
    public static func getOrgDetailsFromServer( completion : @escaping( ResultType.DataResponse< ZCRMOrg, APIResponse > ) -> () )
    {
        OrgAPIHandler(cacheFlavour: CacheFlavour.noCache).getOrgDetails { ( result ) in
            completion( result )
        }
    }
    
    public static func getOrgDetails( forId id : Int64, completion : @escaping( ResultType.DataResponse< ZCRMOrg, APIResponse > ) -> () )
    {
        OrgAPIHandler(cacheFlavour: CacheFlavour.forceCache).getOrgDetails( id ) { ( result ) in
            completion( result )
        }
    }
    
    public static func getOrgDetailsFromServer( forId id : Int64, completion : @escaping( ResultType.DataResponse< ZCRMOrg, APIResponse > ) -> () )
    {
        OrgAPIHandler(cacheFlavour: CacheFlavour.noCache).getOrgDetails( id ) { ( result ) in
            completion( result )
        }
    }
    
    public static func getModule( moduleAPIName : String, completion : @escaping( ResultType.DataResponse< ZCRMModule, APIResponse > ) -> () )
    {
        MetaDataAPIHandler().getModule( apiName : moduleAPIName ) { ( result ) in
            completion( result )
        }
    }
    
    public func getModules( completion : @escaping( ResultType.DataResponse< [ ZCRMModule ], BulkAPIResponse > ) -> () )
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public static func getModules( modifiedSince : String, completion : @escaping( ResultType.DataResponse< [ ZCRMModule ], BulkAPIResponse > ) -> () )
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : modifiedSince ) { ( result ) in
            completion( result )
        }
    }
    
    public static func getCurrentUser( completion : @escaping( ResultType.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler(cacheFlavour: CacheFlavour.forceCache).getCurrentUser() { ( result ) in
            completion( result )
        }
    }
    
    public static func getCurrentUserFromServer( completion : @escaping( ResultType.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler(cacheFlavour: .noCache).getCurrentUser { ( result ) in
            completion( result )
        }
    }
    
    public static func createVariables( variables : [ZCRMVariable], completion : @escaping( ResultType.DataResponse< [ZCRMVariable], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().createVariables(variables: variables) { ( result ) in
            completion( result )
        }
    }
    
    public static func updateVariables( variables : [ZCRMVariable], completion : @escaping( ResultType.DataResponse< [ZCRMVariable], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().updateVariables(variables: variables) { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariableGroups( completion : @escaping( ResultType.DataResponse< [ZCRMVariableGroup], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().getVariableGroups { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariableGroup( id : Int64, completion : @escaping( ResultType.DataResponse< ZCRMVariableGroup, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariableGroup(id: id, apiName: nil) { ( result ) in
            completion(result)
        }
    }
    
    public static func getVariableGroup( apiName : String, completion : @escaping( ResultType.DataResponse< ZCRMVariableGroup, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariableGroup(id: nil, apiName: apiName) { ( result ) in
            completion(result)
        }
    }
    
    public static func getVariables( completion : @escaping( ResultType.DataResponse< [ZCRMVariable], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().getVariables { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariable( variableId : Int64, variableGroupId : Int64, completion : @escaping( ResultType.DataResponse< ZCRMVariable, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariable(variableId: variableId, variableAPIName: nil, variableGroupId: variableGroupId, variableGroupAPIName: nil) { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariable( variableId : Int64, variableGroupAPIName : String, completion : @escaping( ResultType.DataResponse< ZCRMVariable, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariable(variableId: variableId, variableAPIName: nil, variableGroupId: nil, variableGroupAPIName:  variableGroupAPIName) { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariable( variableAPIName : String, variableGroupId : Int64, completion : @escaping( ResultType.DataResponse< ZCRMVariable, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariable(variableId: nil, variableAPIName: variableAPIName, variableGroupId: variableGroupId, variableGroupAPIName: nil) { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariable( variableAPIName : String, variableGroupAPIName : String, completion : @escaping( ResultType.DataResponse< ZCRMVariable, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariable(variableId: nil, variableAPIName: variableAPIName, variableGroupId: nil, variableGroupAPIName: variableGroupAPIName) { ( result ) in
            completion( result )
        }
    }
    
    public static func deleteVariables( ids : [Int64], completion : @escaping( ResultType.Response< BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().deleteVariables(ids: ids) { ( result ) in
            completion( result )
        }
    }
    
    public static func getOrgDetails( _ id : Int64, completion : @escaping ( ResultType.DataResponse< ZCRMOrg, APIResponse > ) -> Void )
    {
        OrgAPIHandler().getOrgDetails( id ) { result in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method makeRequest with param requestBody instead" )
    public static func makeRequest(withURL url : URL, _ requestMethod : RequestMethod , headers : [ String : String ]?, completion : @escaping ( ResultType.DataURLResponse<Data, HTTPURLResponse> ) -> Void )
    {
        APIRequest(absoluteURL: url, requestMethod: requestMethod).initialiseRequest( headers, nil ) { result in
            completion( result )
        }
    }
    
    public static func makeRequest(withURL url : URL, _ requestMethod : RequestMethod , headers : [ String : String ]?, requestBody : [ String : Any ]?, completion : @escaping ( ResultType.DataURLResponse<Data, HTTPURLResponse> ) -> Void )
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
    public static func getZCRMTerritories( completion : @escaping ( ResultType.DataResponse< [ ZCRMTerritory ], BulkAPIResponse > ) -> ())
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
    public static func getZCRMTerritory( byId id : Int64, completion : @escaping ( ResultType.DataResponse< ZCRMTerritory, APIResponse > ) -> ())
    {
        OrgAPIHandler().getZCRMTerritory( byId : id ) { result in
            completion( result )
        }
    }
}

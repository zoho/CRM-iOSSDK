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
    public func new() -> ZCacheClient
    {
        return ZCRMSDKUtil()
    }
    
    public func getModule() -> ZCacheModule
    {
        return ZCRMModule(apiName: APIConstants.STRING_MOCK, singularLabel: APIConstants.STRING_MOCK, pluralLabel: APIConstants.STRING_MOCK)
    }
    
    public func getLayout() -> ZCacheLayout?
    {
        return nil
    }
    
    public func getSection() -> ZCacheSection?
    {
        return nil
    }
    
    public func getField() -> ZCacheField
    {
        return ZCRMField(apiName: APIConstants.STRING_MOCK)
    }
    
    public func getUser() -> ZCacheUser
    {
        return ZCRMUser(emailId: APIConstants.STRING_MOCK)
    }
    
    public func getRecord(moduleName: String) -> ZCacheRecord
    {
        return ZCRMRecord(moduleAPIName: moduleName)
    }
    
    public func getEntity(ofType type: DataType) -> ZCacheEntity
    {
        if type == .subform
        {
            return ZCRMSubformRecord(name: APIConstants.STRING_MOCK)
        }
        else if type == .user_lookup
        {
            return ZCRMUser(emailId: APIConstants.STRING_MOCK)
        }
        else if type == .lookup
        {
            return ZCRMRecord(moduleAPIName: APIConstants.STRING_MOCK)
        }
        else
        {
            return ZCRMRecord(moduleAPIName: APIConstants.STRING_MOCK)
        }
    }
    
    public func getModulesFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : nil )
        {
            ( result ) in
            switch result
            {
            case .success(let modules, _):
                do
                {
                    completion(.success(modules as! [T]))
                }
            case .failure(let error):
                do
                {
                    let code = error.ZCRMErrordetails?.code
                    let message = error.ZCRMErrordetails?.code
                
                    completion(.failure(ZCacheError.processingError(code: code ?? ErrorCode.internalError, message: message ?? ErrorMessage.responseNilMsg, details: nil)))
                }
            }
        }
    }
    
    public func getModulesFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : modifiedSince )
        {
            ( result ) in
            switch result
            {
            case .success(let modules, _):
                do
                {
                    completion(.success(modules as! [T]))
                }
            case .failure(let error):
                do
                {
                    let code = error.ZCRMErrordetails?.code
                    let message = error.ZCRMErrordetails?.code
                
                    completion(.failure(ZCacheError.processingError(code: code ?? ErrorCode.internalError, message: message ?? ErrorMessage.responseNilMsg, details: nil)))
                }
            }
        }
    }
    
    public func getModuleFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        
    }
    
    public func getModuleFromServer<T>(withName: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        MetaDataAPIHandler().getModule(apiName: withName)
        {
            ( result ) in
            switch result
            {
            case .success(let module, _):
                do
                {
                    completion(.success(module as! T))
                }
            case .failure(let error):
                do
                {
                    let code = error.ZCRMErrordetails?.code
                    let message = error.ZCRMErrordetails?.code
                
                    completion(.failure(ZCacheError.processingError(code: code ?? ErrorCode.internalError, message: message ?? ErrorMessage.responseNilMsg, details: nil)))
                }
            }
        }
    }
   
    public func getUsersFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        UserAPIHandler(cacheFlavour: .noCache).getUsers(ofType: nil, modifiedSince: nil, page: nil, perPage: nil)
        {
            ( result ) in
            switch result
            {
            case .success(let users, _):
                do
                {
                    completion(.success(users as! [T]))
                }
            case .failure(let error):
                do
                {
                    let code = error.ZCRMErrordetails?.code
                    let message = error.ZCRMErrordetails?.code
                
                    completion(.failure(ZCacheError.processingError(code: code ?? ErrorCode.internalError, message: message ?? ErrorMessage.responseNilMsg, details: nil)))
                }
            }
        }
    }
    
    public func getUserFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        UserAPIHandler(cacheFlavour: .noCache).getUser(userId: id)
        {
            ( result ) in
            switch result
            {
            case .success(let user, _):
                do
                {
                    completion(.success(user as! T))
                }
            case .failure(let error):
                do
                {
                    let code = error.ZCRMErrordetails?.code
                    let message = error.ZCRMErrordetails?.code
                
                    completion(.failure(ZCacheError.processingError(code: code ?? ErrorCode.internalError, message: message ?? ErrorMessage.responseNilMsg, details: nil)))
                }
            }
        }
    }
    
    public func getCurrentUserFromServer<T>(completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        UserAPIHandler(cacheFlavour: .noCache).getCurrentUser
        {
            ( result ) in
            switch result
            {
            case .success(let user, _):
                do
                {
                    completion(.success(user as! T))
                }
            case .failure(let error):
                do
                {
                    let code = error.ZCRMErrordetails?.code
                    let message = error.ZCRMErrordetails?.code
                
                    completion(.failure(ZCacheError.processingError(code: code ?? ErrorCode.internalError, message: message ?? ErrorMessage.responseNilMsg, details: nil)))
                }
            }
        }
    }
    
    public func searchFromServer<T>(key: String, fromModules: [String], completion: @escaping (DataResponseCallback<ZCacheResponse, [T]>) -> Void)
    {
        searchFromServer(key: key, fromModules: fromModules, page: 1, perPage: 200, completion: completion)
    }
    
    public func searchFromServer<T>(key: String, fromModules: [String], page: Int, perPage: Int, completion: @escaping (DataResponseCallback<ZCacheResponse, [T]>) -> Void)
    {
        if !fromModules.isEmpty
        {
            let moduleDelegate = ZCRMSDKUtil.getModuleDelegate(apiName: fromModules[0])
            moduleDelegate.searchBy(text: key, page: page, per_page: perPage)
            {
                result in
                switch result
                {
                case .success(let records, let response):
                    completion(.fromServer(info: response, data: records as? [T]))
                case .failure(let error):
                    completion(.failure(error: ZCacheError.processingError(code: ErrorCode.invalidData, message: error.description, details: nil)))
                }
            }
        }
        else
        {
            completion(.failure(error: ZCacheError.processingError(code: ErrorCode.invalidData, message: ErrorMessage.responseNilMsg, details: nil)))
        }
    }
    
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
    
    public static func getModules( completion : @escaping( ResultType.DataResponse< [ ZCRMModule ], BulkAPIResponse > ) -> () )
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

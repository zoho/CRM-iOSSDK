
//
//  TagAPIHandler.swift
//  ZCRMiOS
//
//  Created by Umashri R on 30/07/18.
//

import Foundation

internal class TagAPIHandler : CommonAPIHandler
{
    private var tag : ZCRMTag?
    private var module : ZCRMModuleDelegate?
    
    public override init (){}
    
    public init(module : ZCRMModuleDelegate)
    {
        self.module = module
    }
    
    public init(tag : ZCRMTag, module : ZCRMModuleDelegate)
    {
        self.tag = tag
        self.module = module
    }
    
    // MARK: - Handler Functions
    internal func getTags( completion : @escaping( Result.DataResponse< [ ZCRMTag ], BulkAPIResponse > ) -> () )
    {
        if let module = self.module
        {
            var tags : [ZCRMTag] = [ZCRMTag]()
            setJSONRootKey(key: JSONRootKey.TAGS)
            setUrlPath(urlPath: "settings/tags")
            setRequestMethod(requestMethod: .GET)
            addRequestParam( param : RequestParamKeys.module, value : module.apiName )
            
            let request : APIRequest = APIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.getBulkAPIResponse { ( resultType ) in
                do{
                    let bulkResponse = try resultType.resolve()
                    let responseJSON = bulkResponse.getResponseJSON()
                    if responseJSON.isEmpty == false
                    {
                        let tagsList :[ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                        if( tagsList.isEmpty == true )
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_JSON_NIL_MSG)")
                            completion( .failure( ZCRMError.SDKError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_JSON_NIL_MSG, details : nil ) ) )
                            return
                        }
                        for tagDetails in tagsList
                        {
                            let tag : ZCRMTag = ZCRMTag()
                            tags.append(try self.getZCRMTag(tag: tag, tagDetails: tagDetails))
                        }
                    }
                    bulkResponse.setData(data: tags)
                    completion( .success( tags, bulkResponse ) )
                }
                catch{
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : MODULE NAME must not be nil")
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "MODULE NAME must not be nil", details : nil ) ) )
        }
    }

    internal func getRecordCount( completion : @escaping( Result.DataResponse< Int64, APIResponse > ) -> () )
    {
        if let tag = self.tag, let module = self.module
        {
            let tagIdString : String = String( tag.id )
            setJSONRootKey(key: JSONRootKey.TAGS)
            setUrlPath(urlPath: "settings/tags/\(tagIdString)/actions/records_count")
            setRequestMethod(requestMethod: .GET)
            addRequestParam( param : RequestParamKeys.module, value : module.apiName )
            
            let request : APIRequest = APIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.getAPIResponse { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let responseJSON = response.getResponseJSON()
                    if let count = try Int64( responseJSON.getString( key : ResponseJSONKeys.count ) )
                    {
                        completion( .success( count, response ) )
                    }
                    else
                    {
                        completion( .success( 0, response ) )
                    }
                }
                catch{
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : MODULE NAME and TAG ID must not be nil")
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "MODULE NAME and TAG ID must not be nil", details : nil ) ) )
        }
    }

    internal func createTags( tags : [ZCRMTag], completion : @escaping( Result.DataResponse< [ ZCRMTag ], BulkAPIResponse > ) -> () )
    {
        if let module = module
        {
            setJSONRootKey(key: JSONRootKey.TAGS)
            var reqBodyObj : [String:[[String:Any?]]] = [String:[[String:Any?]]]()
            var dataArray : [[String:Any?]] = [[String:Any?]]()
            for tag in tags
            {
                if tag.isCreate
                {
                    dataArray.append( self.getZCRMTagAsJSON(tag: tag) )
                }
            }
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath(urlPath: "settings/tags")
            setRequestMethod(requestMethod: .POST)
            addRequestParam( param : RequestParamKeys.module, value : module.apiName )
            setRequestBody(requestBody: reqBodyObj)
            
            let request : APIRequest = APIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.getBulkAPIResponse { ( resultType ) in
                do{
                    let bulkResponse = try resultType.resolve()
                    let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                    var createdTags : [ZCRMTag] = [ZCRMTag]()
                    for index in 0..<responses.count
                    {
                        let entityResponse = responses[ index ]
                        if( APIConstants.CODE_SUCCESS == entityResponse.getStatus())
                        {
                            let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                            let tagJSON : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                            if tagJSON.isEmpty == true
                            {
                                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_JSON_NIL_MSG)")
                                completion( .failure( ZCRMError.SDKError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_JSON_NIL_MSG, details : nil ) ) )
                                return
                            }
                            let tag : ZCRMTag = try self.getZCRMTag(tag: tags[index], tagDetails: tagJSON)
                            tag.isCreate = false
                            createdTags.append(tag)
                            entityResponse.setData(data: tag)
                        }
                        else
                        {
                            entityResponse.setData(data: nil)
                        }
                    }
                    bulkResponse.setData(data: createdTags)
                    completion( .success( createdTags, bulkResponse ) )
                }
                catch{
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : MODULE NAME must not be nil")
            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "MODULE NAME must not be nil", details : nil ) ) )
        }
    }

    internal func merge( withTag : ZCRMTag, completion : @escaping( Result.DataResponse< ZCRMTag, APIResponse > ) -> () )
    {
        if let tag = self.tag
        {
            var conflictIdJSON : [String:Any] = [String:Any]()
            conflictIdJSON[RequestParamKeys.conflictId] = withTag.id
            setJSONRootKey(key: JSONRootKey.TAGS)
            var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
            var dataArray : [[String:Any]] = [[String:Any]]()
            dataArray.append(conflictIdJSON)
            reqBodyObj[getJSONRootKey()] = dataArray
            let idString = String( tag.id )
            setUrlPath(urlPath: "settings/tags/\(idString)/actions/merge")
            setRequestMethod(requestMethod: .POST)
            setRequestBody(requestBody: reqBodyObj)
            let request : APIRequest = APIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.getAPIResponse { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let responseJSON :[String:Any] = response.getResponseJSON()
                    let respDataArray : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    let respData : [String:Any?] = respDataArray[0]
                    let tagDetails : [ String : Any ] = try respData.getDictionary( key : APIConstants.DETAILS )
                    var tag = ZCRMTag()
                    tag = try self.getZCRMTag(tag: tag, tagDetails: tagDetails)
                    response.setData(data: tag)
                    completion( .success( tag, response ) )
                }
                catch{
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : TAG ID must not be nil")
            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "TAG ID must not be nil", details : nil ) ) )
        }
    }

    internal func update( completion : @escaping( Result.DataResponse< ZCRMTag, APIResponse > ) -> () )
    {
        if let module = self.module, let tag = self.tag
        {
            if tag.isCreate
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : TAG ID must not be nil")
                completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "TAG ID must not be nil", details : nil ) ) )
                return
            }
            setJSONRootKey(key: JSONRootKey.TAGS)
            let tagId : String = String( tag.id )
            var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
            var dataArray : [[String:Any]] = [[String:Any]]()
            var updateTagJSON = self.getZCRMTagAsJSON(tag: tag)
            var nameJSON : [String:Any] = [String:Any]()
            if let updateTagName = updateTagJSON[ ResponseJSONKeys.name ]
            {
                nameJSON[ResponseJSONKeys.name] = updateTagName
            }
            dataArray.append(nameJSON)
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath(urlPath: "settings/tags/\(tagId)")
            addRequestParam( param : RequestParamKeys.module, value : module.apiName )
            setRequestMethod(requestMethod: .PATCH )
            setRequestBody(requestBody: reqBodyObj)
            let request : APIRequest = APIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.getAPIResponse { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let responseJSON = response.getResponseJSON()
                    let respDataArr : [ [ String : Any? ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    let respData : [String:Any?] = respDataArr[0]
                    let recordDetails : [ String : Any ] = try respData.getDictionary( key : APIConstants.DETAILS )
                    let updatedTag = try self.getZCRMTag(tag: tag, tagDetails : recordDetails)
                    response.setData(data: updatedTag )
                    completion( .success( updatedTag, response ) )
                }
                catch{
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : TAG ID and MODULE NAME must not be nil")
            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "MODULE NAME and TAG ID must not be nil", details : nil ) ) )
        }
    }

    internal func updateTags( tags : [ZCRMTag], completion : @escaping( Result.DataResponse< [ZCRMTag], BulkAPIResponse > ) -> () )
    {
        if let module = self.module
        {
            setJSONRootKey(key: JSONRootKey.TAGS)
            var reqBodyObj : [String:[[String:Any?]]] = [String:[[String:Any?]]]()
            var dataArray : [[String:Any?]] = [[String:Any?]]()
            for tag in tags
            {
                if !tag.isCreate
                {
                    dataArray.append( self.getZCRMTagAsJSON(tag: tag) )
                }
            }
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath(urlPath: "settings/tags")
            addRequestParam( param : RequestParamKeys.module, value : module.apiName )
            setRequestMethod(requestMethod: .PATCH)
            setRequestBody(requestBody: reqBodyObj)
            
            let request : APIRequest = APIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.getBulkAPIResponse { ( resultType ) in
                do{
                    let bulkResponse = try resultType.resolve()
                    let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                    var updatedTags : [ZCRMTag] = [ZCRMTag]()
                    for index in 0..<responses.count
                    {
                        let entityResponse = responses[ index ]
                        if(APIConstants.CODE_SUCCESS == entityResponse.getStatus())
                        {
                            let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                            let tagJSON : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                            if tagJSON.isEmpty == true
                            {
                                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_JSON_NIL_MSG)")
                                completion( .failure( ZCRMError.SDKError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_JSON_NIL_MSG, details : nil ) ) )
                                return
                            }
                            let tag : ZCRMTag = try self.getZCRMTag(tag: tags[index], tagDetails: tagJSON)
                            updatedTags.append(tag)
                            entityResponse.setData(data: tag)
                        }
                        else
                        {
                            entityResponse.setData(data: nil)
                        }
                    }
                    bulkResponse.setData(data: updatedTags)
                    completion( .success( updatedTags, bulkResponse ) )
                }
                catch{
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : MODULE NAME must not be nil")
            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "MODULE NAME must not be nil", details : nil ) ) )
        }
    }

    internal func delete( tagId : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.TAGS)
        let idString = String(tagId)
        setUrlPath(urlPath: "settings/tags/\(idString)" )
        setRequestMethod(requestMethod: .DELETE )
        setJSONRootKey( key : JSONRootKey.TAGS )
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                completion( .success( response ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getZCRMTag( tag : ZCRMTag, tagDetails : [String : Any?] ) throws -> ZCRMTag
    {
        if tagDetails.hasKey(forKey: ResponseJSONKeys.id)
        {
            tag.id = try tagDetails.getInt64( key : ResponseJSONKeys.id )
        }
        if tagDetails.hasKey(forKey: ResponseJSONKeys.name)
        {
            tag.name = try tagDetails.getString( key : ResponseJSONKeys.name )
        }
        if ( tagDetails.hasValue( forKey : ResponseJSONKeys.createdBy ) )
        {
            let createdByDetails : [ String : Any ] = try tagDetails.getDictionary( key : ResponseJSONKeys.createdBy )
            tag.createdBy = try getUserDelegate(userJSON : createdByDetails)
            tag.createdTime = try tagDetails.getString( key : ResponseJSONKeys.createdTime )
        }
        if ( tagDetails.hasValue( forKey : ResponseJSONKeys.modifiedBy ) )
        {
            let modifiedByDetails : [ String : Any ] = try tagDetails.getDictionary( key : ResponseJSONKeys.modifiedBy )
            tag.modifiedBy = try getUserDelegate(userJSON : modifiedByDetails)
            tag.modifiedTime = try tagDetails.getString( key : ResponseJSONKeys.modifiedTime )
        }
        if let moduleAPIName = module?.apiName
        {
            tag.moduleAPIName = moduleAPIName
        }
        tag.isCreate = false
        return tag
    }
    
    internal func getZCRMTagAsJSON( tag : ZCRMTag ) -> [String : Any?]
    {
        var tagJSON : [String:Any?] = [String:Any?]()
        if !tag.isCreate
        {
            tagJSON.updateValue( tag.id, forKey : ResponseJSONKeys.id )
        }
        tagJSON.updateValue( tag.name, forKey : ResponseJSONKeys.name )
        return tagJSON
    }
}

fileprivate extension TagAPIHandler
{
    struct ResponseJSONKeys
    {
        static let id = "id"
        static let name = "name"
        static let createdBy = "created_by"
        static let createdTime = "created_time"
        static let modifiedBy = "modified_by"
        static let modifiedTime = "modified_time"
        static let count = "count"
    }
}

extension RequestParamKeys
{
    static let conflictId = "conflict_id"
}


//
//  TagAPIHandler.swift
//  ZCRMiOS
//
//  Created by Umashri R on 30/07/18.
//

import Foundation

internal class TagAPIHandler : CommonAPIHandler
{
    private var tag : ZCRMTagDelegate?
    private var module : ZCRMModuleDelegate?
    
    public override init (){}
    
    public init(tag : ZCRMTagDelegate)
    {
        self.tag = tag
    }
    
    public init(module : ZCRMModuleDelegate)
    {
        self.module = module
    }
    
    public init(tag : ZCRMTagDelegate, module : ZCRMModuleDelegate)
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
            setUrlPath(urlPath: "/settings/tags")
            setRequestMethod(requestMethod: .GET)
            addRequestParam(param: "module", value: module.apiName)
            
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \(request.toString())" )
            
            request.getBulkAPIResponse { ( resultType ) in
                do{
                    let bulkResponse = try resultType.resolve()
                    let responseJSON = bulkResponse.getResponseJSON()
                    if( responseJSON.isEmpty == false )
                    {
                        let tagsList :[[String:Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                        for tagDetails in tagsList
                        {
                            tags.append(self.getZCRMTag(tagDetails: tagDetails))
                        }
                        bulkResponse.setData(data: tags)
                        completion( .success( tags, bulkResponse ) )
                    }
                    else
                    {
                        completion( .failure( ZCRMError.SDKError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG ) ) )
                    }
                }
                catch{
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Module MUST NOT be nil" ) ) )
        }
    }

    internal func getRecordCount( completion : @escaping( Result.DataResponse< Int64, APIResponse > ) -> () )
    {
        if let tag = self.tag, let module = self.module
        {
            if tag.tagId == APIConstants.INT64_MOCK
            {
                completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Tag ID MUST NOT be nil" ) ) )
                return
            }
            let tagIdString : String = String(tag.tagId)
            setJSONRootKey(key: JSONRootKey.TAGS)
            setUrlPath(urlPath: "/settings/tags/\(tagIdString)/actions/records_count")
            setRequestMethod(requestMethod: .GET)
            addRequestParam(param: "module", value: module.apiName)
            
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \(request.toString())" )
            
            request.getAPIResponse { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let responseJSON = response.getResponseJSON()
                    if let count = Int64( responseJSON.getString( key : ResponseJSONKeys.count ) )
                    {
                        completion( .success( count, response ) )
                    }
                    else
                    {
                        completion( .success( 0, response ) )
                    }
                }
                catch{
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Module and Tag ID MUST NOT be nil" ) ) )
        }
    }

    internal func createTags( tags : [ZCRMTag], completion : @escaping( Result.DataResponse< [ ZCRMTag ], BulkAPIResponse > ) -> () )
    {
        if let module = module
        {
            setJSONRootKey(key: JSONRootKey.TAGS)
            var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
            var dataArray : [[String:Any]] = [[String:Any]]()
            for tag in tags
            {
                if ( tag.tagName != APIConstants.STRING_MOCK )
                {
                    dataArray.append( self.getZCRMTagAsJSON(tag: tag) as Any as! [String:Any] )
                }
            }
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath(urlPath: "/settings/tags")
            setRequestMethod(requestMethod: .POST)
            addRequestParam(param: "module", value: module.apiName)
            setRequestBody(requestBody: reqBodyObj)
            
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \(request.toString())" )
            
            request.getBulkAPIResponse { ( resultType ) in
                do{
                    let bulkResponse = try resultType.resolve()
                    let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                    var createdTags : [ZCRMTag] = [ZCRMTag]()
                    for entityResponse in responses
                    {
                        if( APIConstants.CODE_SUCCESS == entityResponse.getStatus())
                        {
                            let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                            let tagJSON :[String:Any] = entResponseJSON.getDictionary(key: APIConstants.DETAILS)
                            let tag : ZCRMTag = self.getZCRMTag(tagDetails: tagJSON)
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
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "Module MUST NOT be nil" ) ) )
        }
    }

    internal func merge( withTag : ZCRMTag, completion : @escaping( Result.DataResponse< ZCRMTag, APIResponse > ) -> () )
    {
        if let tag = self.tag
        {
            if tag.tagId == APIConstants.INT64_MOCK
            {
                completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "Tag ID MUST NOT be nil" ) ) )
                return
            }
            var conflictTagJSON : [String:Any] = self.getZCRMTagAsJSON(tag: withTag) as Any as! [String:Any]
            var conflictIdJSON : [String:Any] = [String:Any]()
            conflictIdJSON[RequestParamKeys.conflictId] = conflictTagJSON[ResponseJSONKeys.id]
            setJSONRootKey(key: JSONRootKey.TAGS)
            var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
            var dataArray : [[String:Any]] = [[String:Any]]()
            dataArray.append(conflictIdJSON)
            reqBodyObj[getJSONRootKey()] = dataArray
            let idString = String(tag.tagId)
            setUrlPath(urlPath: "/settings/tags/\(idString)/actions/merge")
            setRequestMethod(requestMethod: .POST)
            setRequestBody(requestBody: reqBodyObj)
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \(request.toString())" )
            
            request.getAPIResponse { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let responseJSON :[String:Any] = response.getResponseJSON()
                    let respDataArray : [[String:Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                    let respData : [String:Any?] = respDataArray[0]
                    let tagDetails : [String:Any] = respData.getDictionary(key: APIConstants.DETAILS)
                    let tag = self.getZCRMTag(tagDetails: tagDetails)
                    response.setData(data: tag)
                    completion( .success( tag, response ) )
                }
                catch{
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "Tag MUST NOT be nil" ) ) )
        }
    }

    internal func update(updateTag : ZCRMTag, completion : @escaping( Result.DataResponse< ZCRMTag, APIResponse > ) -> () )
    {
        if let module = self.module, let tag = self.tag
        {
            if tag.tagId == APIConstants.INT64_MOCK
            {
                completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "Tag ID MUST NOT be nil" ) ) )
                return
            }
            setJSONRootKey(key: JSONRootKey.TAGS)
            let tagId : String = String( tag.tagId )
            var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
            var dataArray : [[String:Any]] = [[String:Any]]()
            var updateTagJSON = self.getZCRMTagAsJSON(tag: updateTag) as Any as! [String:Any]
            var nameJSON : [String:Any] = [String:Any]()
            nameJSON[ResponseJSONKeys.name] = updateTagJSON[ResponseJSONKeys.name]
            dataArray.append(nameJSON)
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath(urlPath: "/settings/tags/\(tagId)")
            addRequestParam(param: "module", value: module.apiName)
            setRequestMethod(requestMethod: .PUT )
            setRequestBody(requestBody: reqBodyObj)
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \( request.toString() )" )
            
            request.getAPIResponse { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let responseJSON = response.getResponseJSON()
                    let respDataArr : [[String:Any?]] = responseJSON.optArrayOfDictionaries(key: self.getJSONRootKey())!
                    let respData : [String:Any?] = respDataArr[0]
                    let recordDetails : [String:Any] = respData.getDictionary(key: APIConstants.DETAILS)
                    let updatedTag = self.getZCRMTag(tagDetails : recordDetails)
                    response.setData(data: updatedTag )
                    completion( .success( updatedTag, response ) )
                }
                catch{
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "Module and Tag MUST NOT be nil" ) ) )
        }
    }

    internal func updateTags( tags : [ZCRMTag], completion : @escaping( Result.DataResponse< [ZCRMTag], BulkAPIResponse > ) -> () )
    {
        if let module = self.module
        {
            setJSONRootKey(key: JSONRootKey.TAGS)
            var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
            var dataArray : [[String:Any]] = [[String:Any]]()
            for tag in tags
            {
                if tag.tagId != APIConstants.INT64_MOCK
                {
                    dataArray.append( self.getZCRMTagAsJSON(tag: tag) as Any as! [String:Any] )
                }
            }
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath(urlPath: "/settings/tags")
            addRequestParam(param: "module", value: module.apiName)
            setRequestMethod(requestMethod: .PUT)
            setRequestBody(requestBody: reqBodyObj)
            
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \(request.toString())" )
            
            request.getBulkAPIResponse { ( resultType ) in
                do{
                    let bulkResponse = try resultType.resolve()
                    let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                    var updatedTags : [ZCRMTag] = [ZCRMTag]()
                    for entityResponse in responses
                    {
                        if(APIConstants.CODE_SUCCESS == entityResponse.getStatus())
                        {
                            let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                            let tagJSON :[String:Any] = entResponseJSON.getDictionary(key: APIConstants.DETAILS)
                            let tag : ZCRMTag = self.getZCRMTag(tagDetails: tagJSON)
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
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "Module MUST NOT be nil" ) ) )
        }
    }

    internal func delete( tagId : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.TAGS)
        let idString = String(tagId)
        setUrlPath(urlPath: "/settings/tags/\(idString)" )
        setRequestMethod(requestMethod: .DELETE )
        setJSONRootKey( key : JSONRootKey.TAGS )
        let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                completion( .success( response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getZCRMTag( tagDetails : [String : Any?] ) -> ZCRMTag
    {
        let tag : ZCRMTag = ZCRMTag()
        if tagDetails.hasKey(forKey: ResponseJSONKeys.id)
        {
            tag.tagId = tagDetails.getInt64(key: ResponseJSONKeys.id)
        }
        if tagDetails.hasKey(forKey: ResponseJSONKeys.name)
        {
            tag.tagName = tagDetails.getString(key: ResponseJSONKeys.name)
        }
        if ( tagDetails.hasValue( forKey : ResponseJSONKeys.createdBy ) )
        {
            let createdByDetails : [String:Any] = tagDetails.getDictionary(key: ResponseJSONKeys.createdBy)
            tag.createdBy = getUserDelegate(userJSON : createdByDetails)
            tag.createdTime = tagDetails.getString(key: ResponseJSONKeys.createdTime)
        }
        if ( tagDetails.hasValue( forKey : ResponseJSONKeys.modifiedBy ) )
        {
            let modifiedByDetails : [String:Any] = tagDetails.getDictionary(key: ResponseJSONKeys.modifiedBy)
            tag.modifiedBy = getUserDelegate(userJSON : modifiedByDetails)
            tag.modifiedTime = tagDetails.getString(key: ResponseJSONKeys.modifiedTime)
        }
        if let moduleAPIName = module?.apiName
        {
            tag.moduleAPIName = moduleAPIName
        }
        return tag
    }
    
    internal func getZCRMTagAsJSON( tag : ZCRMTag ) -> [String : Any?]
    {
        var tagJSON : [String:Any?] = [String:Any?]()
        if tag.tagId != APIConstants.INT64_MOCK
        {
            tagJSON[ResponseJSONKeys.id] = tag.tagId
        }
        if tag.tagName != APIConstants.STRING_MOCK
        {
            tagJSON[ResponseJSONKeys.name] = tag.tagName
        }
        if tag.createdBy.id != APIConstants.INT64_MOCK
        {
            tagJSON[ResponseJSONKeys.createdBy] = setUserDelegate( userObj : tag.createdBy )
            tagJSON[ResponseJSONKeys.createdTime] = tag.createdTime
        }
        if tag.modifiedBy.id != APIConstants.INT64_MOCK
        {
            tagJSON[ResponseJSONKeys.modifiedBy] = setUserDelegate( userObj : tag.modifiedBy )
            tagJSON[ResponseJSONKeys.modifiedTime] = tag.modifiedTime
        }
        return tagJSON
    }
}

fileprivate extension TagAPIHandler
{
    struct RequestParamKeys
    {
        static let conflictId = "conflict_id"
    }
    
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


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
    private var module : ZCRMModule?
    
    public override init ()
    {
    }
    
    public init(tag : ZCRMTag)
    {
        self.tag = tag
    }
    
    public init(module : ZCRMModule)
    {
        self.module = module
    }
    
    public init(tag : ZCRMTag, module : ZCRMModule)
    {
        self.tag = tag
        self.module = module
    }
    
    // MARK: - Handler Functions
    
    internal func getTags( completion : @escaping( [ZCRMTag]?, BulkAPIResponse?, Error? ) -> () )
    {
        if let module = self.module
        {
            var tags : [ZCRMTag] = [ZCRMTag]()
            setJSONRootKey(key: JSONRootKey.TAGS)
            setUrlPath(urlPath: "/settings/tags")
            setRequestMethod(requestMethod: .GET)
            addRequestParam(param: "module", value: module.getAPIName())
            
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \(request.toString())" )
            
            request.getBulkAPIResponse { ( response, err ) in
                if let error = err
                {
                    completion( nil, nil, error )
                    return
                }
                if let bulkResponse = response
                {
                    let responseJSON = bulkResponse.getResponseJSON()
                    if( responseJSON.isEmpty == false )
                    {
                        let tagsList :[[String:Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                        for tagDetails in tagsList
                        {
                            tags.append(self.getZCRMTag(tagDetails: tagDetails))
                        }
                        bulkResponse.setData(data: tags)
                    }
                    completion( tags, bulkResponse, nil)
                }
            }
        }
        else
        {
            completion( nil, nil, ZCRMError.ProcessingError( "Module MUST NOT be nil" ) )
        }
    }
    
    internal func getRecordCount( completion : @escaping( Int64?, Error? ) -> () )
    {
        if let tag = self.tag, let module = self.module
        {
            if tag.getId() == nil
            {
                completion( nil, ZCRMError.ProcessingError( "Tag ID MUST NOT be nil" ) )
                return
            }
            let tagIdString : String = String(tag.getId()!)
            setJSONRootKey(key: JSONRootKey.TAGS)
            setUrlPath(urlPath: "/settings/tags/\(tagIdString)/actions/records_count")
            setRequestMethod(requestMethod: .GET)
            addRequestParam(param: "module", value: module.getAPIName())
            
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \(request.toString())" )
        
            request.getAPIResponse { ( resp, error ) in
                guard let response = resp else
                {
                    completion( nil, error )
                    return
                }
                let responseJSON = response.getResponseJSON()
                let count = Int64( responseJSON.getString( key : ResponseJSONKeys.count ) )
                completion( count, nil )
            }
        }
        else
        {
            completion( nil, ZCRMError.ProcessingError( "Module and Tag MUST NOT be nil" ) )
        }
    }
    
    internal func createTags( tags : [ZCRMTag], completion : @escaping( [ZCRMTag]?, BulkAPIResponse?, Error? ) -> () )
    {
        if let module = module
        {
            setJSONRootKey(key: JSONRootKey.TAGS)
            var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
            var dataArray : [[String:Any]] = [[String:Any]]()
            for tag in tags
            {
                if ( tag.getName() != nil)
                {
                    dataArray.append( self.getZCRMTagAsJSON(tag: tag) as Any as! [String:Any] )
                }
            }
            reqBodyObj[getJSONRootKey()] = dataArray
            
            
            setUrlPath(urlPath: "/settings/tags")
            setRequestMethod(requestMethod: .POST)
            addRequestParam(param: "module", value: module.getAPIName())
            setRequestBody(requestBody: reqBodyObj)
            
            
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \(request.toString())" )
            
            request.getBulkAPIResponse { ( response, err ) in
                if let error = err
                {
                    completion( nil, nil, error )
                    return
                }
                if let bulkResponse = response
                {
                    let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                    var createdTags : [ZCRMTag] = [ZCRMTag]()
                    for entityResponse in responses
                    {
                        if(CODE_SUCCESS == entityResponse.getStatus())
                        {
                            let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                            let tagJSON :[String:Any] = entResponseJSON.getDictionary(key: DETAILS)
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
                    completion( createdTags, bulkResponse, nil )
                }
            }
        }
        else
        {
            completion( nil, nil, ZCRMError.ProcessingError( "Module MUST NOT be nil" ) )
        }
    }
    
    internal func merge( withTag : ZCRMTag, completion : @escaping( ZCRMTag?, APIResponse?, Error? ) -> () )
    {
        if let tag = self.tag
        {
            if tag.getId() == nil
            {
                completion( nil, nil, ZCRMError.ProcessingError( "Tag ID MUST NOT be nil" ) )
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
            let idString = String(tag.getId()!)
            setUrlPath(urlPath: "/settings/tags/\(idString)/actions/merge")
            setRequestMethod(requestMethod: .POST)
            setRequestBody(requestBody: reqBodyObj)
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \(request.toString())" )
            
            request.getAPIResponse{ ( resp, err ) in
                if let error = err
                {
                    completion( nil, nil, error)
                }
                if let response = resp
                {
                    let responseJSON :[String:Any] = response.getResponseJSON()
                    let respDataArray : [[String:Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                    let respData : [String:Any?] = respDataArray[0]
                    let tagDetails : [String:Any] = respData.getDictionary(key: DETAILS)
                    let tag = self.getZCRMTag(tagDetails: tagDetails)
                    response.setData(data: tag)
                    completion( tag, response, nil )
                }
            }
        }
        else
        {
            completion( nil, nil, ZCRMError.ProcessingError( "Tag MUST NOT be nil" ) )
        }
    }
    
    internal func update(updateTag : ZCRMTag, completion : @escaping( ZCRMTag?, APIResponse?, Error? ) -> () )
    {
        if let module = self.module, let tag = self.tag
        {
            if tag.getId() == nil
            {
                completion( nil, nil, ZCRMError.ProcessingError( "Tag ID MUST NOT be nil" ) )
                return
            }
            setJSONRootKey(key: JSONRootKey.TAGS)
            let tagId : String = String( tag.getId()! )
            var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
            var dataArray : [[String:Any]] = [[String:Any]]()
            var updateTagJSON = self.getZCRMTagAsJSON(tag: updateTag) as Any as! [String:Any]
            var nameJSON : [String:Any] = [String:Any]()
            nameJSON[ResponseJSONKeys.name] = updateTagJSON[ResponseJSONKeys.name]
            dataArray.append(nameJSON)
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath(urlPath: "/settings/tags/\(tagId)")
            addRequestParam(param: "module", value: module.getAPIName())
            setRequestMethod(requestMethod: .PUT )
            setRequestBody(requestBody: reqBodyObj)
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
                    let respDataArr : [[String:Any?]] = responseJSON.optArrayOfDictionaries(key: self.getJSONRootKey())!
                    let respData : [String:Any?] = respDataArr[0]
                    let recordDetails : [String:Any] = respData.getDictionary(key: DETAILS)
                    let updatedTag = self.getZCRMTag(tagDetails : recordDetails)
                    response.setData(data: updatedTag )
                    completion( updatedTag, response, nil )
                }
            }
        }
        else
        {
            completion( nil, nil, ZCRMError.ProcessingError( "Module and Tag MUST NOT be nil" ) )
        }
    }
    
    internal func updateTags( tags : [ZCRMTag], completion : @escaping( [ZCRMTag]?, BulkAPIResponse?, Error? ) -> () )
    {
        if let module = self.module
        {
            setJSONRootKey(key: JSONRootKey.TAGS)
            var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
            var dataArray : [[String:Any]] = [[String:Any]]()
            for tag in tags
            {
                if ( tag.getId() != nil )
                {
                    dataArray.append( self.getZCRMTagAsJSON(tag: tag) as Any as! [String:Any] )
                }
            }
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath(urlPath: "/settings/tags")
            addRequestParam(param: "module", value: module.getAPIName())
            setRequestMethod(requestMethod: .PUT)
            setRequestBody(requestBody: reqBodyObj)
            
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \(request.toString())" )
            request.getBulkAPIResponse { ( response, err ) in
                if let error = err
                {
                    completion( nil, nil, error )
                    return
                }
                if let bulkResponse = response
                {
                    let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                    var updatedTags : [ZCRMTag] = [ZCRMTag]()
                    for entityResponse in responses
                    {
                        if(CODE_SUCCESS == entityResponse.getStatus())
                        {
                            let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                            let tagJSON :[String:Any] = entResponseJSON.getDictionary(key: DETAILS)
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
                    completion( updatedTags, bulkResponse, nil )
                }
            }
        }
        else
        {
            completion( nil, nil, ZCRMError.ProcessingError( "Module MUST NOT be nil" ) )
        }
    }
    
    internal func delete( tagId : Int64, completion : @escaping( APIResponse?, Error? ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.TAGS)
        let idString = String(tagId)
        setUrlPath(urlPath: "/settings/tags/\(idString)" )
        setRequestMethod(requestMethod: .DELETE )
        let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( response, error ) in
            completion( response, error )
        }
    }
    
    internal func getZCRMTag( tagDetails : [String : Any?] ) -> ZCRMTag
    {
        let tag : ZCRMTag = ZCRMTag()
        if tagDetails.hasKey(forKey: ResponseJSONKeys.id)
        {
            tag.setId(tagId: tagDetails.getInt64(key: ResponseJSONKeys.id))
        }
        if tagDetails.hasKey(forKey: ResponseJSONKeys.name)
        {
            tag.setName(tagName: tagDetails.getString(key: ResponseJSONKeys.name))
        }
        if ( tagDetails.hasValue( forKey : ResponseJSONKeys.createdBy ) )
        {
            let createdByDetails : [String:Any] = tagDetails.getDictionary(key: ResponseJSONKeys.createdBy)
            let createdBy : ZCRMUser = ZCRMUser(userId: createdByDetails.getInt64(key: ResponseJSONKeys.id), userFullName: createdByDetails.getString(key: ResponseJSONKeys.name))
            tag.setCreatedBy(createdBy: createdBy)
            tag.setCreatedTime(createdTime: tagDetails.getString(key: ResponseJSONKeys.createdTime))
        }
        if ( tagDetails.hasValue( forKey : ResponseJSONKeys.modifiedBy ) )
        {
            let modifiedByDetails : [String:Any] = tagDetails.getDictionary(key: ResponseJSONKeys.modifiedBy)
            let modifiedBy : ZCRMUser = ZCRMUser(userId: modifiedByDetails.getInt64(key: ResponseJSONKeys.id), userFullName: modifiedByDetails.getString(key: ResponseJSONKeys.name))
            tag.setModifiedBy(modifiedBy : modifiedBy)
            tag.setModifiedTime(modifiedTime : tagDetails.getString(key: ResponseJSONKeys.modifiedTime))
        }
        if let moduleAPIName = module?.getAPIName()
        {
           tag.setModuleAPIName(moduleAPIName: moduleAPIName)
        }
        return tag
    }
    
    internal func getZCRMTagAsJSON( tag : ZCRMTag ) -> [String : Any?]
    {
        var tagJSON : [String:Any?] = [String:Any?]()
        if let id = tag.getId()
        {
            tagJSON[ResponseJSONKeys.id] = id
        }
        if let name = tag.getName()
        {
            tagJSON[ResponseJSONKeys.name] = name
        }
        if let createdBy = tag.getCreatedBy()
        {
            var createdByJSON : [String:Any] = [String:Any]()
            createdByJSON[ResponseJSONKeys.id] = createdBy.getId()
            createdByJSON[ResponseJSONKeys.name] = createdBy.getFullName()
            tagJSON[ResponseJSONKeys.createdBy] = createdByJSON
            tagJSON[ResponseJSONKeys.createdTime] = tag.getCreatedTime()
        }
        if let modifiedBy = tag.getModifiedBy()
        {
            var modifiedByJSON : [String:Any] = [String:Any]()
            modifiedByJSON[ResponseJSONKeys.id] = modifiedBy.getId()
            modifiedByJSON[ResponseJSONKeys.name] = modifiedBy.getFullName()
            tagJSON[ResponseJSONKeys.modifiedBy] = modifiedByJSON
            tagJSON[ResponseJSONKeys.modifiedTime] = modifiedByJSON
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

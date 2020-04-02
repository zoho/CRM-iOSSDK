
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
    
    override func setModuleName() {
        self.requestedModule = "tag"
    }
    
    // MARK: - Handler Functions
    internal func getTags( completion : @escaping( Result.DataResponse< [ ZCRMTag ], BulkAPIResponse > ) -> () )
    {
        if let module = self.module
        {
            var tags : [ZCRMTag] = [ZCRMTag]()
            setJSONRootKey(key: JSONRootKey.TAGS)
            setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.tags )")
            setRequestMethod(requestMethod: .get)
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
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                            completion( .failure( ZCRMError.sdkError( code: ErrorCode.responseNil, message: ErrorMessage.responseJSONNilMsg, details : nil ) ) )
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
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : MODULE NAME must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "MODULE NAME must not be nil", details : nil ) ) )
        }
    }

    internal func getRecordCount( completion : @escaping( Result.DataResponse< Int64, APIResponse > ) -> () )
    {
        if let tag = self.tag, let module = self.module
        {
            let tagIdString : String = String( tag.id )
            setJSONRootKey(key: JSONRootKey.TAGS)
            setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.tags )/\(tagIdString)/\( URLPathConstants.actions )/\( URLPathConstants.recordsCount )")
            setRequestMethod(requestMethod: .get)
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
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : MODULE NAME and TAG ID must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "MODULE NAME and TAG ID must not be nil", details : nil ) ) )
        }
    }
    
    internal func createTag( tag : ZCRMTag, completion : @escaping( Result.DataResponse< ZCRMTag, APIResponse > ) -> () )
    {
        if let module = module
        {
            setJSONRootKey(key: JSONRootKey.TAGS)
            var reqBodyObj : [String:[[String:Any?]]] = [String:[[String:Any?]]]()
            var dataArray : [[String:Any?]] = [[String:Any?]]()
            dataArray.append( self.getZCRMTagAsJSON(tag: tag) )
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.tags )")
            setRequestMethod(requestMethod: .post)
            addRequestParam( param : RequestParamKeys.module, value : module.apiName )
            setRequestBody(requestBody: reqBodyObj)
            
            let request : APIRequest = APIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.getAPIResponse { ( resultType ) in
                do
                {
                    switch resultType
                    {
                    case .success(let response) :
                        let entResponseJSON : [String:Any] = response.getResponseJSON()
                        let respDataArr : [ [ String : Any? ] ] = try entResponseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                        let respData : [String:Any?] = respDataArr[0]
                        let tagJSON : [ String : Any ] = try respData.getDictionary( key : APIConstants.DETAILS )
                        let tag : ZCRMTag = try self.getZCRMTag(tag: tag, tagDetails: tagJSON)
                        response.setData(data: tag)
                        completion( .success( tag, response ) )
                    case .failure(let error) :
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }
                catch
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : MODULE NAME must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code: ErrorCode.mandatoryNotFound, message: "MODULE NAME must not be nil", details : nil ) ) )
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
            
            setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.tags )")
            setRequestMethod(requestMethod: .post)
            addRequestParam( param : RequestParamKeys.module, value : module.apiName )
            setRequestBody(requestBody: reqBodyObj)
            
            let request : APIRequest = APIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.getBulkAPIResponse { ( resultType ) in
                do{
                    switch resultType
                    {
                    case .success(let bulkResponse) :
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
                                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                                    completion( .failure( ZCRMError.sdkError( code: ErrorCode.responseNil, message: ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                                    return
                                }
                                let tag : ZCRMTag = try self.getZCRMTag(tag: tags[index], tagDetails: tagJSON)
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
                    case .failure(let error) :
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        completion( .failure( typeCastToZCRMError( error ) ) )
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
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : MODULE NAME must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code: ErrorCode.mandatoryNotFound, message: "MODULE NAME must not be nil", details : nil ) ) )
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
            setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.tags )/\(idString)/\( URLPathConstants.actions )/\( URLPathConstants.merge )")
            setRequestMethod(requestMethod: .post)
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
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : TAG ID must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code: ErrorCode.mandatoryNotFound, message: "TAG ID must not be nil", details : nil ) ) )
        }
    }

    internal func update( completion : @escaping( Result.DataResponse< ZCRMTag, APIResponse > ) -> () )
    {
        if let module = self.module, let tag = self.tag
        {
            if tag.isCreate
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : TAG ID must not be nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code: ErrorCode.mandatoryNotFound, message: "TAG ID must not be nil", details : nil ) ) )
                return
            }
            setJSONRootKey(key: JSONRootKey.TAGS)
            let tagId : String = String( tag.id )
            var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
            var dataArray : [[String:Any]] = [[String:Any]]()
            let updateTagJSON = self.getZCRMTagAsJSON(tag: tag)
            var nameJSON : [String:Any] = [String:Any]()
            if let updateTagName = updateTagJSON[ ResponseJSONKeys.name ]
            {
                nameJSON[ResponseJSONKeys.name] = updateTagName
            }
            dataArray.append(nameJSON)
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.tags )/\(tagId)")
            addRequestParam( param : RequestParamKeys.module, value : module.apiName )
            setRequestMethod(requestMethod: .patch )
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
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : TAG ID and MODULE NAME must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code: ErrorCode.mandatoryNotFound, message: "MODULE NAME and TAG ID must not be nil", details : nil ) ) )
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
            
            setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.tags )")
            addRequestParam( param : RequestParamKeys.module, value : module.apiName )
            setRequestMethod(requestMethod: .patch)
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
                                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                                completion( .failure( ZCRMError.sdkError( code: ErrorCode.responseNil, message: ErrorMessage.responseJSONNilMsg, details : nil ) ) )
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
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : MODULE NAME must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code: ErrorCode.mandatoryNotFound, message: "MODULE NAME must not be nil", details : nil ) ) )
        }
    }

    internal func delete( tagId : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.TAGS)
        let idString = String(tagId)
        setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.tags )/\(idString)" )
        setRequestMethod(requestMethod: .delete )
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
    
    struct URLPathConstants {
        static let settings = "settings"
        static let tags = "tags"
        static let actions = "actions"
        static let recordsCount = "records_count"
        static let merge = "merge"
    }
}

extension RequestParamKeys
{
    static let conflictId = "conflict_id"
}

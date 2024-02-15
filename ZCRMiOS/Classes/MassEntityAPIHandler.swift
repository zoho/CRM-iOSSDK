//
//  MassEntityAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 16/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class MassEntityAPIHandler : CommonAPIHandler
{
    internal var module : ZCRMModuleDelegate
    
    init(module : ZCRMModuleDelegate)
    {
        self.module = module
    }
    
    override func setModuleName() {
        self.requestedModule = module.apiName
    }
    
    // MARK: - Handler Functions
    private func makeRecordRequest( records : [ ZCRMRecord ], dispatchQueue : DispatchQueue , completion : @escaping ( ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ()  )
    {
        var zcrmFields : [ ZCRMField ]?
        var bulkAPIResponse : BulkAPIResponse?
        var recordAPIError : Error?
        var fieldsAPIError : Error?
        let dispatchGroup : DispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        let moduleDelegate : ZCRMModuleDelegate = ZCRMModuleDelegate(apiName: self.module.apiName)
        ModuleAPIHandler(module: moduleDelegate, cacheFlavour: .noCache).getAllFields(modifiedSince: nil) { result in
            switch result
            {
            case .success(let fields, _) :
                zcrmFields = fields
            case .failure(let error) :
                fieldsAPIError = error
            }
            dispatchGroup.leave()
        }
        
        let request : APIRequest = APIRequest(handler: self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        dispatchGroup.enter()
        request.getBulkAPIResponse { ( resultType ) in
            switch resultType
            {
            case .success(let response) :
                bulkAPIResponse = response
            case .failure(let error) :
                recordAPIError = error
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
            if let recordAPIError = recordAPIError
            {
                ZCRMLogger.logError( message : "\( recordAPIError )" )
                completion( .failure( typeCastToZCRMError( recordAPIError ) ) )
                return
            }
            else if let fieldsAPIError = fieldsAPIError
            {
                ZCRMLogger.logError( message : "\( fieldsAPIError )" )
                completion( .failure( typeCastToZCRMError( fieldsAPIError ) ) )
                return
            }
            if let bulkAPIResponse = bulkAPIResponse, let fields = zcrmFields
            {
                do
                {
                    var obtainedRecords : [ ZCRMRecord ] = [ ZCRMRecord ]()
                    let dispatchGroup : DispatchGroup = DispatchGroup()
                    let responses : [EntityResponse] = bulkAPIResponse.getEntityResponses()
                    for ( index, entityResponse ) in responses.enumerated()
                    {
                        if(APIConstants.CODE_SUCCESS == entityResponse.getStatus())
                        {
                            let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                            let recordJSON : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                            if recordJSON.isEmpty == true
                            {
                                ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                                completion( .failure( ZCRMError.processingError( code: ZCRMErrorCode.responseNil, message: ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                                return
                            }
                            let moduleFields = getFieldVsApinameJSON(fields: fields)
                            for ( key, value ) in records[ index ].upsertJSON
                            {
                                if moduleFields[ key ]?.dataType != FieldDataTypeConstants.multiSelectLookup
                                {
                                    records[ index ].data.updateValue( value, forKey : key )
                                }
                            }
                            dispatchGroup.enter()
                            EntityAPIHandler( record : records[ index ], moduleFields: moduleFields ).setRecordProperties( recordDetails : recordJSON, completion : { ( recordResult ) in
                                switch recordResult
                                {
                                case .success(let obtainedRecord) :
                                    obtainedRecord.upsertJSON = [ String : Any? ]()
                                    dispatchQueue.sync {
                                        obtainedRecords.append( obtainedRecord )
                                    }
                                    entityResponse.setData(data: obtainedRecord)
                                    dispatchGroup.leave()
                                case .failure(let error) :
                                    ZCRMLogger.logError( message : "\( error )" )
                                    completion( .failure( typeCastToZCRMError( error ) ) )
                                    dispatchGroup.leave()
                                    return
                                }
                            })
                        }
                        else
                        {
                            entityResponse.setData(data: nil)
                        }
                    }
                    dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
                        bulkAPIResponse.setData( data : obtainedRecords )
                        completion( .success( obtainedRecords, bulkAPIResponse ) )
                    }
                }
                catch
                {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
    }
    
    internal func createRecords( triggers : [ZCRMTrigger]?, records : [ ZCRMRecord ], completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if(records.count > 100)
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.maxCountExceeded) : \(ZCRMErrorMessage.apiMaxRecordsMsg), \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ZCRMErrorCode.maxCountExceeded, message : ZCRMErrorMessage.apiMaxRecordsMsg, details : nil ) ) )
            return
        }
        var reqBodyObj : [String:Any?] = [String:Any?]()
        var dataArray : [[String:Any?]] = [[String:Any?]]()
        for record in records
        {
            dataArray.append(EntityAPIHandler(record: record).getZCRMRecordAsJSON())
        }
        reqBodyObj[getJSONRootKey()] = dataArray
        if let triggers = triggers
        {
            reqBodyObj[ APIConstants.TRIGGER ] = getTriggerArray(triggers: triggers)
        }
        
        setUrlPath(urlPath :  "\(self.module.apiName)" )
        setRequestMethod(requestMethod : .post )
        setRequestBody(requestBody : reqBodyObj )
        
        let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.massEntityAPIHandler.createRecords")
        makeRecordRequest( records: records, dispatchQueue: dispatchQueue, completion: completion)
    }
    
    internal func getDeals( cvId : Int64?, kanbanViewColumns : [ String ], requestParams : GETEntityRequestParams, requestHeaders : [ String : String ]?, completion : @escaping ( ZCRMResult.Data<  [ String : ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ] > ) -> () )
    {
        var zcrmFields : [ZCRMField]?
        var fieldsAPIError : Error?
        var zcrmTags : [ZCRMTag]?
        var tagsAPIError : Error?
        let dispatchGroup : DispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        ModuleAPIHandler( module : self.module, cacheFlavour : .urlVsResponse, requestHeaders: requestHeaders ).getAllFields( modifiedSince : nil ) { ( result ) in
            switch result
            {
            case .success(let fields, _) :
                zcrmFields = fields
            case .failure(let error) :
                fieldsAPIError = error
            }
            dispatchGroup.leave()
        }
        
        if ZCRMSDKClient.shared.orgLicensePlan != FREE_PLAN
        {
            dispatchGroup.enter()
            TagAPIHandler(module: self.module).getTags() { result in
                switch result
                {
                case .success(let tags, _) :
                    zcrmTags = tags
                case .failure(let error) :
                    tagsAPIError = error
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
            if let fieldsAPIError = fieldsAPIError
            {
                ZCRMLogger.logError( message : "\( fieldsAPIError )" )
                completion( .failure( typeCastToZCRMError( fieldsAPIError ) ) )
                return
            }
            else if let tagsAPIError = tagsAPIError {
                ZCRMLogger.logError(message: "\( tagsAPIError )")
            }
            
            if let fields = zcrmFields
            {
                self.getAllStageRecordsResponse(cvId: cvId, kanbanViewColumns: kanbanViewColumns, requestParams: requestParams, fields: fields, requestHeaders: requestHeaders) { bulkAPIResponses in
                    self.getLatestFields(bulkResponses: bulkAPIResponses, kanbanViewColumns: kanbanViewColumns, fields: fields, requestHeaders: requestHeaders) { updatedFields, error in
                        if let error = error
                        {
                            completion( .failure( error ) )
                            return
                        }
                        self.getAllStageRecords(bulkResponses: bulkAPIResponses, kanbanViewColumns: kanbanViewColumns, fields: updatedFields, tags: zcrmTags, requestHeaders: requestHeaders) { result in
                            completion( .success( result ) )
                        }
                    }
                }
            }
            else
            {
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.mandatoryNotFound) : FIELDS must not be nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.mandatoryNotFound, message : "FIELDS must not be nil", details : nil ) ) )
            }
        }
    }
    
    internal func getLatestFields( bulkResponses : [ ZCRMResult.Response< BulkAPIResponse > ], kanbanViewColumns: [ String ], fields : [ ZCRMField ], tags : [ ZCRMTag ]? = nil, requestHeaders : [ String : String ]? = nil, completion : @escaping ( [ ZCRMField ], ZCRMError? ) -> ()  )
    {
        do
        {
            var isRecordFound = false
            for ( _, bulkResponse ) in bulkResponses.enumerated() {
                if case .success( let response ) = bulkResponse
                {
                    let recordsDetailsJSON = response.getResponseJSON()
                    if recordsDetailsJSON.isEmpty
                    {
                        continue
                    }
                    let recordsDetailsList = try recordsDetailsJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                    guard let firstRecordJSON = recordsDetailsList.first else
                    {
                        continue
                    }
                    let firstRecord : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.apiName)
                    firstRecord.id = try firstRecordJSON.getInt64( key : ResponseJSONKeys.id )
                    let entityAPIHandler = EntityAPIHandler(record: firstRecord, moduleFields: getFieldVsApinameJSON(fields: fields))
                    entityAPIHandler.getLatestFields(forRecord: firstRecordJSON, fields: fields) { updatedFields, error in
                        completion( updatedFields, error )
                        return
                    }
                    isRecordFound = true
                    break
                }
            }
            if !isRecordFound
            {
                completion( fields, nil )
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "\( error )" )
            completion( fields, typeCastToZCRMError( error ) )
        }
    }
    
    internal func getAllStageRecords( bulkResponses : [ ZCRMResult.Response< BulkAPIResponse > ], kanbanViewColumns: [ String ], fields : [ ZCRMField ], tags : [ ZCRMTag ]? = nil, requestHeaders : [ String : String ]? = nil, completion : @escaping ( [ String : ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ] ) -> () )
    {
        let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.massEnityAPIHandler.getAllStageRecords")
        let dispatchGroup : DispatchGroup = DispatchGroup()
        
        var recordResponses : [ String : ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ] = [:]
        
        for ( index, bulkResponse ) in bulkResponses.enumerated() {
            switch bulkResponse
            {
            case .success(let response) :
                dispatchGroup.enter()
                getStageRecords(responseJSON: response.getResponseJSON(), fields: fields, tags: tags, requestHeaders: requestHeaders) { result in
                    switch result
                    {
                    case .success(let records) :
                        dispatchQueue.sync {
                            recordResponses[ kanbanViewColumns[ index ] ] = .success( records, response)
                            dispatchGroup.leave()
                        }
                    case .failure(let error) :
                        dispatchQueue.sync {
                            recordResponses[ kanbanViewColumns[ index ] ] = .failure( error )
                            dispatchGroup.leave()
                        }
                    }
                }
            case .failure(let error) :
                dispatchQueue.sync {
                    recordResponses[ kanbanViewColumns[ index ] ] = .failure( error )
                }
            }
        }
        dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
            completion( recordResponses )
        }
    }
    
    internal func getStageRecords( responseJSON : [ String : Any ], fields : [ ZCRMField ],tags : [ ZCRMTag ]? = nil, requestHeaders : [ String : String ]? = nil, completion : @escaping ( ZCRMResult.Data< [ ZCRMRecord ] > ) -> () )
    {
        do
        {
            var records : [ ZCRMRecord ] = [ ZCRMRecord ]()
            guard responseJSON.isEmpty == false else
            {
                completion( .success( records ) )
                return
            }
            let recordsDetailsList:[ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
            let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.massEnityAPIHandler.getStageRecords")
            let dispatchGroup : DispatchGroup = DispatchGroup()
            for recordDetails in recordsDetailsList
            {
                let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.apiName)
                record.id = try recordDetails.getInt64( key : ResponseJSONKeys.id )
                dispatchGroup.enter()
                EntityAPIHandler(record: record, moduleFields: getFieldVsApinameJSON(fields: fields), requestHeaders: requestHeaders).setRecordProperties(recordDetails: recordDetails,tags: tags, completion: { ( recordResult ) in
                    switch recordResult
                    {
                    case .success(let record) :
                        record.upsertJSON = [ String : Any ]()
                        dispatchQueue.sync {
                            records.append(record)
                        }
                    case .failure(let error) :
                        ZCRMLogger.logError( message : "\( error )" )
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                    dispatchGroup.leave()
                })
            }
            dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
                completion( .success( records ) )
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "\( error )" )
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    internal func getAllStageRecordsResponse( cvId : Int64?, kanbanViewColumns : [ String ], requestParams : GETEntityRequestParams, fields : [ ZCRMField ], tags : [ ZCRMTag ]? = nil, requestHeaders : [ String : String ]? = nil, completion : @escaping( [ ZCRMResult.Response< BulkAPIResponse > ] ) -> () )
    {
        var allStageRecordsResponse : [ ZCRMResult.Response< BulkAPIResponse > ] = []
        var unOrderedAllStageRecords : [ Int : ZCRMResult.Response< BulkAPIResponse > ] = [:]
        let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.MassEntityAPIHandler.getAllStageRecordsResponse")
        let dispatchGroup : DispatchGroup = DispatchGroup()
        
        for index in 0..<kanbanViewColumns.count {
            dispatchGroup.enter()
            MassEntityAPIHandler(module: module).getStageRecordsResponse(cvId: cvId, kanbanViewColumn: kanbanViewColumns[ index ], requestParams: requestParams, requestHeaders: requestHeaders) { result in
                switch result
                {
                case .success(let response) :
                    dispatchQueue.sync {
                        unOrderedAllStageRecords[ index ] = .success( response )
                        dispatchGroup.leave()
                    }
                case .failure(let error) :
                    dispatchQueue.sync {
                        unOrderedAllStageRecords[ index ] = .failure( error )
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
            for stageRecords in unOrderedAllStageRecords.sorted(by: { $0.key < $1.key }) {
                allStageRecordsResponse.append( stageRecords.value )
            }
            completion( allStageRecordsResponse )
        }
    }
    
    internal func getStageRecordsResponse( cvId : Int64?, kanbanViewColumn : String, requestParams : GETEntityRequestParams, requestHeaders : [ String : String ]? = nil, completion : @escaping( ZCRMResult.Response< BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        setUrlPath(urlPath: "\(self.module.apiName)" )
        setRequestMethod( requestMethod : .get )
        if ZCRMSDKClient.shared.isInternal
        {
            setAPIVersion("v2.2")
        }
        
        if let cvId = cvId
        {
            addRequestParam(param:  RequestParamKeys.cvId , value: String( cvId ) )
        }
        if let fields = requestParams.fields, fields.isEmpty == false
        {
            addRequestParam(param: RequestParamKeys.fields , value: fields.joined(separator: ",") )
        }
        if let sortBy = requestParams.sortBy
        {
            addRequestParam(param: RequestParamKeys.sortBy , value:  sortBy )
        }
        if let sortOrder = requestParams.sortOrder
        {
            addRequestParam(param: RequestParamKeys.sortOrder , value: sortOrder.rawValue )
        }
        if requestParams.modifiedSince.notNilandEmpty, let modifiedSince = requestParams.modifiedSince
        {
            addRequestHeader(header: RequestParamKeys.ifModifiedSince , value: modifiedSince )
        }
        if let page = requestParams.page
        {
            addRequestParam(param: RequestParamKeys.page , value: String( page ) )
        }
        if let perPage = requestParams.perPage
        {
            addRequestParam(param: RequestParamKeys.perPage , value: String( perPage ) )
        }
        if let filter = requestParams.filter, let filterQuery = filter.filterQuery
        {
            addRequestParam( param : RequestParamKeys.filters, value : filterQuery )
        }
        
        addRequestParam( param : RequestParamKeys.kanbanView, value : kanbanViewColumn )
        
        if let requestHeaders = requestHeaders, !requestHeaders.isEmpty
        {
            for ( key, value ) in requestHeaders
            {
                addRequestHeader(header: key, value: value)
            }
        }
        let request : APIRequest = APIRequest(handler: self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            switch resultType
            {
            case .success(let response) :
                completion( .success( response ) )
            case .failure(let error) :
                completion( .failure( error ) )
            }
        }
    }
    
    internal func getRecords( cvId : Int64?, filterId : Int64?, recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        setUrlPath(urlPath: "\(self.module.apiName)" )
        setRequestMethod( requestMethod : .get )
        if let fields = recordParams.fields, fields.isEmpty == false
        {
            addRequestParam(param: RequestParamKeys.fields , value: fields.joined(separator: ",") )
        }
        if let cvId = cvId
        {
            addRequestParam(param:  RequestParamKeys.cvId , value: String( cvId ) )
        }
        if let filterId = filterId
        {
            addRequestParam(param:  RequestParamKeys.filterId , value: String( filterId ) )
        }
        if let sortBy = recordParams.sortBy
        {
            addRequestParam(param: RequestParamKeys.sortBy , value:  sortBy )
        }
        if let sortOrder = recordParams.sortOrder
        {
            addRequestParam(param: RequestParamKeys.sortOrder , value: sortOrder.rawValue )
        }
        if let isConverted = recordParams.isConverted
        {
            addRequestParam(param: RequestParamKeys.converted , value: isConverted.description )
        }
        if let isApproved = recordParams.isApproved
        {
            addRequestParam(param: RequestParamKeys.approved , value: isApproved.description )
        }
        if recordParams.modifiedSince.notNilandEmpty, let modifiedSince = recordParams.modifiedSince
        {
            addRequestHeader(header: RequestParamKeys.ifModifiedSince , value: modifiedSince )
        }
        if( recordParams.includePrivateFields != nil && recordParams.includePrivateFields == true )
        {
            addRequestParam( param : RequestParamKeys.include, value : APIConstants.PRIVATE_FIELDS )
        }
        if let kanbanViewColumn = recordParams.kanbanViewColumn
        {
            addRequestParam( param : RequestParamKeys.kanbanView, value : kanbanViewColumn )
        }
        if let page = recordParams.page
        {
            addRequestParam(param: RequestParamKeys.page , value: String( page ) )
        }
        if let perPage = recordParams.perPage
        {
            addRequestParam(param: RequestParamKeys.perPage , value: String( perPage ) )
        }
        if let startDateTime = recordParams.startDateTime
        {
            addRequestParam( param : RequestParamKeys.startDateTime, value : startDateTime )
        }
        if let endDateTime = recordParams.endDateTime
        {
            addRequestParam(param: RequestParamKeys.endDateTime, value: endDateTime)
        }
        if let filter = recordParams.filter, let filterQuery = filter.filterQuery
        {
            addRequestParam( param : RequestParamKeys.filters, value : filterQuery )
        }
        if let isFormattedCurrencyNeeded = recordParams.isFormattedCurrencyNeeded
        {
            addRequestParam( param: RequestParamKeys.formattedCurrency , value: "\(isFormattedCurrencyNeeded)" )
        }
        if let isConvertedHomeCurrencyNeeded = recordParams.isConvertedHomeCurrencyNeeded
        {
            addRequestParam( param: RequestParamKeys.homeConvertedCurrency , value: "\(isConvertedHomeCurrencyNeeded)" )
        }
        let requestHeaders = recordParams.headers ?? [:]
        if !requestHeaders.isEmpty
        {
            for ( key, value ) in requestHeaders
            {
                addRequestHeader(header: key, value: value)
            }
        }
        let request : APIRequest = APIRequest(handler: self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        var zcrmFields : [ZCRMField]?
        var bulkResponse : BulkAPIResponse?
        var recordAPIError : Error?
        var fieldsAPIError : Error?
        var zcrmTags : [ ZCRMTag ]?
        var tagsAPIError : Error?
        let dispatchGroup : DispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        ModuleAPIHandler( module : self.module, cacheFlavour : .urlVsResponse, requestHeaders: requestHeaders ).getAllFields( modifiedSince : nil ) { ( result ) in
            switch result
            {
            case .success(let fields, _) :
                zcrmFields = fields
            case .failure(let error) :
                fieldsAPIError = error
            }
            dispatchGroup.leave()
        }
        if ZCRMSDKClient.shared.orgLicensePlan != FREE_PLAN
        {
            dispatchGroup.enter()
            TagAPIHandler(module: self.module).getTags() { result in
                switch result
                {
                case .success(let tags, _):
                    zcrmTags = tags
                case .failure(let error):
                    tagsAPIError = error
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        request.getBulkAPIResponse { ( resultType ) in
            switch resultType
            {
            case .success(let response) :
                bulkResponse = response
            case .failure(let error) :
                recordAPIError = error
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
            if let recordAPIError = recordAPIError
            {
                ZCRMLogger.logError( message : "\( recordAPIError )" )
                completion( .failure( typeCastToZCRMError( recordAPIError ) ) )
                return
            }
            else if let fieldsAPIError = fieldsAPIError
            {
                ZCRMLogger.logError( message : "\( fieldsAPIError )" )
                completion( .failure( typeCastToZCRMError( fieldsAPIError ) ) )
                return
            }
            else if let tagsAPIError = tagsAPIError
            {
                ZCRMLogger.logError(message: "\(tagsAPIError)")
            }
            
            if let fields = zcrmFields, let response = bulkResponse
            {
                
                self.getZCRMRecords(fields: fields, bulkResponse: response, tags: zcrmTags, requestHeaders: recordParams.headers, completion: { ( records, error ) in
                    if let err = error
                    {
                        ZCRMLogger.logError( message : "\( err )" )
                        completion( .failure( typeCastToZCRMError( err ) ) )
                        return
                    }
                    if let records = records
                    {
                        response.setData(data: records)
                        completion( .success( records, response ) )
                        return
                    }
                })
            }
            else
            {
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.mandatoryNotFound) : FIELDS must not be nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.mandatoryNotFound, message : "FIELDS must not be nil", details : nil ) ) )
            }
        }
    }
    
    internal func getZCRMRecords( fields : [ ZCRMField ], bulkResponse : BulkAPIResponse, tags : [ ZCRMTag ]?, requestHeaders : [ String : String ]? = nil, completion : @escaping( [ ZCRMRecord ]?, ZCRMError? ) -> () )
    {
        var records : [ ZCRMRecord ] = [ ZCRMRecord ]()
        let responseJSON = bulkResponse.getResponseJSON()
        let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.massEnityAPIHandler.getZCRMRecords")
        guard responseJSON.isEmpty == false else
        {
            completion( records, nil )
            return
        }
        do
        {
            let recordsDetailsList:[ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
            guard let firstRecordJSON = recordsDetailsList.first else
            {
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                completion( nil, ZCRMError.processingError( code: ZCRMErrorCode.responseNil, message: ZCRMErrorMessage.responseJSONNilMsg, details : nil ) )
                return
            }
            let firstRecord : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.apiName)
            firstRecord.id = try firstRecordJSON.getInt64( key : ResponseJSONKeys.id )
            let entityAPIHandler = EntityAPIHandler(record: firstRecord, moduleFields: getFieldVsApinameJSON(fields: fields))
            entityAPIHandler.getLatestFields(forRecord: firstRecordJSON, fields: fields) { updatedFields, error in
                do
                {
                    if let error = error
                    {
                        throw error
                    }
                    let dispatchGroup : DispatchGroup = DispatchGroup()
                    for recordDetails in recordsDetailsList
                    {
                        let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.apiName)
                        record.id = try recordDetails.getInt64( key : ResponseJSONKeys.id )
                        dispatchGroup.enter()
                        EntityAPIHandler(record: record, moduleFields: getFieldVsApinameJSON(fields: fields), requestHeaders: requestHeaders).setRecordProperties(recordDetails: recordDetails,tags: tags, completion: { ( recordResult ) in
                            switch recordResult
                            {
                            case .success(let record) :
                                record.upsertJSON = [ String : Any ]()
                                dispatchQueue.sync {
                                    records.append(record)
                                }
                            case .failure(let error) :
                                ZCRMLogger.logError( message : "\( error )" )
                                completion( nil, typeCastToZCRMError( error ) )
                            }
                            dispatchGroup.leave()
                        })
                    }
                    dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
                        completion( records, nil )
                    }
                }
                catch
                {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( nil, typeCastToZCRMError( error ) )
                }
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "\( error )" )
            completion( nil, typeCastToZCRMError( error ) )
        }
    }
    
    internal func searchByText( searchText : String, page : Int?, perPage : Int?, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        self.searchRecords( searchKey : RequestParamValues.word, searchValue : searchText, page : page, perPage : perPage) { ( resultType ) in
            completion( resultType )
        }
    }
    
    internal func searchByCriteria( searchCriteria : ZCRMQuery.ZCRMCriteria, page : Int?, perPage : Int?, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        guard let recordQuery = searchCriteria.recordQuery else
        {
            ZCRMLogger.logError( message : "\( ZCRMErrorCode.internalError) : Criteria cannot be constructed, \( APIConstants.DETAILS ) : -" )
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.internalError, message : "Criteria cannot be constructed", details : nil ) ) )
            return
        }
        self.searchRecords(searchKey: RequestParamValues.criteria, searchValue: recordQuery, page: page, perPage: perPage) { ( resultType ) in
            completion( resultType )
        }
    }
    
    internal func searchByEmail( searchValue : String, page : Int?, perPage : Int?, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        self.searchRecords( searchKey : RequestParamValues.email, searchValue : searchValue, page : page, perPage : perPage) { ( resultType ) in
            completion( resultType )
        }
    }
    
    internal func searchByPhone( searchValue : String, page : Int?, perPage : Int?, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        self.searchRecords( searchKey : RequestParamValues.phone, searchValue : searchValue, page : page, perPage : perPage) { ( resultType ) in
            completion( resultType )
        }
    }
    
    private func searchRecords( searchKey : String, searchValue : String, page : Int?, perPage : Int?, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        if searchValue.count < 2 {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidData) : Please enter two or more characters to make a search request, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.invalidData, message : "Please enter two or more characters to make a search request", details : nil ) ) )
            return
        }
        setJSONRootKey( key : JSONRootKey.DATA )
        setUrlPath(urlPath : "\(self.module.apiName)/\( URLPathConstants.search )" )
        setRequestMethod(requestMethod : .get )
        addRequestParam(param: searchKey, value: searchValue)
        if let page = page
        {
            addRequestParam( param : RequestParamKeys.page, value : String( page ) )
        }
        if let perPage = perPage
        {
            addRequestParam( param : RequestParamKeys.perPage, value : String( perPage ) )
        }
        let request : APIRequest = APIRequest(handler: self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        var zcrmFields : [ZCRMField]?
        var bulkResponse : BulkAPIResponse?
        var recordAPIError : Error?
        var fieldsAPIError : Error?
        var zcrmTags : [ ZCRMTag ]?
        var tagsAPIError : Error?
        let dispatchGroup : DispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        ModuleAPIHandler( module : self.module, cacheFlavour : .noCache ).getAllFields( modifiedSince : nil ) { ( result ) in
            do
            {
                let resp = try result.resolve()
                zcrmFields = resp.data
                dispatchGroup.leave()
            }
            catch
            {
                fieldsAPIError = error
                dispatchGroup.leave()
            }
        }
        if ZCRMSDKClient.shared.orgLicensePlan != FREE_PLAN
        {
            dispatchGroup.enter()
            TagAPIHandler(module: ZCRMModuleDelegate(apiName: self.module.apiName)).getTags() { result in
                switch result
                {
                case .success(let tags, _):
                    zcrmTags = tags
                case .failure(let error):
                    tagsAPIError = error
                }
                dispatchGroup.leave()
            }
        }
        
        
        dispatchGroup.enter()
        request.getBulkAPIResponse { ( resultType ) in
            do
            {
                let response = try resultType.resolve()
                bulkResponse = response
                dispatchGroup.leave()
            }
            catch
            {
                recordAPIError = error
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
            if let recordAPIError = recordAPIError
            {
                ZCRMLogger.logError( message : "\( recordAPIError )" )
                completion( .failure( typeCastToZCRMError( recordAPIError ) ) )
                return
            }
            else if let fieldsAPIError = fieldsAPIError
            {
                ZCRMLogger.logError( message : "\( fieldsAPIError )" )
                completion( .failure( typeCastToZCRMError( fieldsAPIError ) ) )
                return
            }
            else if let tagsAPIError = tagsAPIError
            {
                ZCRMLogger.logError(message: "\(tagsAPIError)")
            }
            
            if let fields = zcrmFields, let response = bulkResponse
            {
                self.getZCRMRecords(fields: fields, bulkResponse: response, tags: zcrmTags, completion: { ( records, error ) in
                    if let err = error
                    {
                        ZCRMLogger.logError( message : "\( err )" )
                        completion( .failure( typeCastToZCRMError( err ) ) )
                        return
                    }
                    if let records = records
                    {
                        response.setData(data: records)
                        completion( .success( records, response ) )
                        return
                    }
                })
            }
            else
            {
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.mandatoryNotFound) : FIELDS must not be nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.mandatoryNotFound, message : "FIELDS must not be nil", details : nil ) ) )
            }
        }
    }
    
    internal func updateRecords( triggers : [ZCRMTrigger]?, records : [ ZCRMRecord ], completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if( records.count > 100 )
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.maxCountExceeded) : \(ZCRMErrorMessage.apiMaxRecordsMsg), \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ZCRMErrorCode.maxCountExceeded, message : ZCRMErrorMessage.apiMaxRecordsMsg, details : nil ) ) )
            return
        }
        guard records.count != 0 else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidData) : No records found to be updated, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ZCRMErrorCode.invalidData, message : "No records found to be updated", details : nil ) ) )
            return
        }
        var reqBodyObj : [ String : Any ] = [ String : Any ]()
        var dataArray : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        for record in records
        {
            let recordJSON = EntityAPIHandler(record : record ).getZCRMRecordAsJSON()
            dataArray.append( recordJSON )
        }
        reqBodyObj[getJSONRootKey()] = dataArray
        if let triggers = triggers
        {
            reqBodyObj[ APIConstants.TRIGGER ] = getTriggerArray(triggers: triggers)
        }
        setUrlPath(urlPath : "\(self.module.apiName)")
        setRequestMethod(requestMethod : .patch )
        setRequestBody(requestBody : reqBodyObj )
        
        let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.massEnityAPIHandler.updateRecords")
        makeRecordRequest(records: records, dispatchQueue: dispatchQueue, completion: completion)
    }
    
    internal func massUpdateRecords( triggers : [ ZCRMTrigger ]?, ids : [ Int64 ], fieldValuePair : [ String : Any? ], completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        if(ids.count > 500)
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.maxCountExceeded) : \(ZCRMErrorMessage.apiMaxRecordsMsg), \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ZCRMErrorCode.maxCountExceeded, message : ZCRMErrorMessage.apiMaxRecordsMsg, details : nil ) ) )
            return
        }
        if ( self.module.apiName == ZCRMDefaultModuleAPINames.DEALS && fieldValuePair.count > 3 ) || ( self.module.apiName != ZCRMDefaultModuleAPINames.DEALS && fieldValuePair.count > 1 )
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidData) : Max field limit exceeded, \( APIConstants.DETAILS ) : limit = \( ( self.module.apiName == ZCRMDefaultModuleAPINames.DEALS ) ? 3 : 1 )")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ZCRMErrorCode.invalidData, message : "Max field limit exceeded", details : [ "limit" : ( self.module.apiName == ZCRMDefaultModuleAPINames.DEALS ) ? 3 : 1 ] ) ) )
            return
        }
        else if fieldValuePair.count == 0
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidData) : No field found, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.inValidError( code : ZCRMErrorCode.invalidData, message : "No field found", details : nil ) ) )
            return
        }
        
        setJSONRootKey( key : JSONRootKey.DATA )
        var reqBodyObj : [String:Any] = [String:Any]()
        reqBodyObj[getJSONRootKey()] = [ fieldValuePair ]
        reqBodyObj[ ResponseJSONKeys.ids ] = ids
        if let triggers = triggers
        {
            reqBodyObj[ APIConstants.TRIGGER ] = getTriggerArray(triggers: triggers)
        }
        setUrlPath(urlPath : "\(self.module.apiName)/\( URLPathConstants.actions )/\( URLPathConstants.massUpdate )")
        setRequestMethod(requestMethod : .post )
        setRequestBody(requestBody : reqBodyObj )
        let request : APIRequest = APIRequest(handler: self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        var zcrmFields : [ ZCRMField ]?
        var bulkAPIResponse : BulkAPIResponse?
        var recordAPIError : Error?
        var fieldsAPIError : Error?
        let dispatchGroup : DispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        let moduleDelegate : ZCRMModuleDelegate = ZCRMModuleDelegate(apiName: self.module.apiName)
        ModuleAPIHandler(module: moduleDelegate, cacheFlavour: .urlVsResponse).getAllFields(modifiedSince: nil) { result in
            switch result
            {
            case .success(let fields, _) :
                zcrmFields = fields
            case .failure(let error) :
                fieldsAPIError = error
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        request.getBulkAPIResponse { ( resultType ) in
            switch resultType
            {
            case .success(let response) :
                bulkAPIResponse = response
            case .failure(let error) :
                recordAPIError = error
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
            if let error = recordAPIError ?? fieldsAPIError
            {
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
                return
            }
            guard let modulefields = zcrmFields, let bulkResponse = bulkAPIResponse else
            {
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.mandatoryNotFound) : FIELDS must not be nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.mandatoryNotFound, message : "FIELDS must not be nil", details : nil ) ) )
                return
            }
            self.getFieldIfMissing(fieldAPINames: Array( fieldValuePair.keys ), fields: modulefields) { updatedFields, error in
                do
                {
                    let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                    var updatedRecords : [ZCRMRecord] = [ZCRMRecord]()
                    let dispatchGroup : DispatchGroup = DispatchGroup()
                    let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.massEnityAPIHandler.updateRecords")
                    for index in 0..<responses.count
                    {
                        let entityResponse = responses[ index ]
                        if(APIConstants.CODE_SUCCESS == entityResponse.getStatus())
                        {
                            let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                            let recordJSON : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                            let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.apiName)
                            record.id = ids[ index ]
                            dispatchGroup.enter()
                            EntityAPIHandler(record: record, moduleFields: getFieldVsApinameJSON(fields: updatedFields)).setRecordProperties(recordDetails: recordJSON, completion: { ( recordResult ) in
                                switch recordResult
                                {
                                case .success(let updatedRecord) :
                                    dispatchQueue.sync {
                                        updatedRecords.append( updatedRecord )
                                    }
                                    responses[ index ].setData(data: updatedRecord )
                                    dispatchGroup.leave()
                                case .failure(let error) :
                                    ZCRMLogger.logError( message : "\( error )" )
                                    completion( .failure( typeCastToZCRMError( error ) ) )
                                    dispatchGroup.leave()
                                    return
                                }
                            })
                        }
                        else
                        {
                            entityResponse.setData(data: nil)
                        }
                    }
                    dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
                        bulkResponse.setData( data : updatedRecords )
                        completion( .success( updatedRecords, bulkResponse ) )
                    }
                }
                catch
                {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
    }
    
    internal func getFieldIfMissing( fieldAPINames : [ String ], fields : [ ZCRMField ], completion : @escaping ( [ ZCRMField ], ZCRMError? ) -> () )
    {
        let fieldVsApinameMap = getFieldVsApinameJSON(fields: fields)
        for fieldAPIName in fieldAPINames
        {
            if !fieldVsApinameMap.hasKey(forKey: fieldAPIName)
            {
                ZCRMModuleDelegate(apiName: self.module.apiName).getFieldsFromServer() { fieldsResponse in
                    switch fieldsResponse
                    {
                    case .success(let updatedFields, _) :
                        completion( updatedFields, nil )
                    case .failure(let error) :
                        ZCRMLogger.logError( message : "\( error )" )
                        completion( fields, error )
                    }
                }
                break
            }
            else
            {
                completion( fields, nil )
            }
        }
    }
    
    internal func upsertRecords( triggers : [ZCRMTrigger]?, records : [ ZCRMRecord ], duplicateCheckFields : [ String ]?, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if ( records.count > 100 )
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.maxCountExceeded) : \(ZCRMErrorMessage.apiMaxRecordsMsg), \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ZCRMErrorCode.maxCountExceeded, message : ZCRMErrorMessage.apiMaxRecordsMsg, details : nil ) ) )
            return
        }
        var reqBodyObj : [ String : Any? ] = [ String : Any? ]()
        var dataArray : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        for record in records
        {
            let recordJSON = EntityAPIHandler(record : record ).getZCRMRecordAsJSON()
            dataArray.append( recordJSON )
        }
        reqBodyObj[getJSONRootKey()] = dataArray
        if let triggers = triggers
        {
            reqBodyObj[ APIConstants.TRIGGER ] = getTriggerArray(triggers: triggers)
        }
        if let duplicateCheckFields = duplicateCheckFields
        {
            reqBodyObj[ APIConstants.DUPLICATE_CHECK_FIELDS ] = duplicateCheckFields
        }
        
        setUrlPath(urlPath:  "\( self.module.apiName )/\( URLPathConstants.upsert )")
        setRequestMethod(requestMethod: .post )
        setRequestBody(requestBody: reqBodyObj )
        let request : APIRequest = APIRequest(handler: self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responses : [ EntityResponse ] = bulkResponse.getEntityResponses()
                var upsertRecords : [ ZCRMRecord ] = [ ZCRMRecord ]()
                let dispatchGroup : DispatchGroup = DispatchGroup()
                let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.massEnityAPIHandler.upsertRecords")
                for index in 0..<responses.count
                {
                    let entityResponse = responses[ index ]
                    if(APIConstants.CODE_SUCCESS == entityResponse.getStatus())
                    {
                        let entResponseJSON : [ String : Any ] = entityResponse.getResponseJSON()
                        let recordJSON : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS)
                        if recordJSON.isEmpty == true
                        {
                            ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                            completion( .failure( ZCRMError.processingError( code: ZCRMErrorCode.responseNil, message: ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                            return
                        }
                        records[ index ].id = try recordJSON.getInt64( key : ResponseJSONKeys.id )
                        for ( key, value ) in records[ index ].upsertJSON
                        {
                            records[ index ].data.updateValue( value, forKey : key )
                        }
                        dispatchGroup.enter()
                        EntityAPIHandler( record : records[ index ] ).setRecordProperties( recordDetails : recordJSON, completion : { ( recordResult ) in
                            do
                            {
                                let upsertRecord = try recordResult.resolve()
                                upsertRecord.upsertJSON = [ String : Any? ]()
                                dispatchQueue.sync {
                                    upsertRecords.append( upsertRecord )
                                }
                                entityResponse.setData( data : upsertRecord )
                                dispatchGroup.leave()
                            }
                            catch
                            {
                                ZCRMLogger.logError( message : "\( error )" )
                                completion( .failure( typeCastToZCRMError( error ) ) )
                                dispatchGroup.leave()
                                return
                            }
                        })
                    }
                    else
                    {
                        entityResponse.setData( data : nil )
                    }
                }
                dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
                    bulkResponse.setData( data : upsertRecords )
                    completion( .success( upsertRecords, bulkResponse ) )
                }
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func deleteRecords( ids : [ Int64 ], completion : @escaping( ZCRMResult.DataResponse< [ Int64 ] , BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if(ids.count > 100)
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.maxCountExceeded) : \(ZCRMErrorMessage.apiMaxRecordsMsg), \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ZCRMErrorCode.maxCountExceeded, message : ZCRMErrorMessage.apiMaxRecordsMsg, details : nil ) ) )
            return
        }
        setUrlPath(urlPath : "\(self.module.apiName)")
        setRequestMethod(requestMethod: .delete )
        addRequestParam( param : RequestParamKeys.ids, value : ids.map{ String( $0 ) }.joined(separator: ",") )
        let request : APIRequest = APIRequest(handler: self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                switch resultType
                {
                case .success(let bulkResponse) :
                    var deletedIds : [ Int64 ] = []
                    let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                    for entityResponse in responses
                    {
                        if APIConstants.CODE_SUCCESS == entityResponse.getStatus()
                        {
                            let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                            let recordJSON : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                            if recordJSON.isEmpty == true
                            {
                                ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                                completion( .failure( ZCRMError.processingError( code: ZCRMErrorCode.responseNil, message: ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                                return
                            }
                            deletedIds.append( try recordJSON.getInt64( key: ResponseJSONKeys.id ) )
                        }
                    }
                    completion( .success( deletedIds, bulkResponse ) )
                case .failure(let error) :
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func deleteRecords( ids : [ Int64 ], completion : @escaping( ZCRMResult.Response< BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if(ids.count > 100)
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.maxCountExceeded) : \(ZCRMErrorMessage.apiMaxRecordsMsg), \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ZCRMErrorCode.maxCountExceeded, message : ZCRMErrorMessage.apiMaxRecordsMsg, details : nil ) ) )
            return
        }
        setUrlPath(urlPath : "\(self.module.apiName)")
        setRequestMethod(requestMethod: .delete )
        addRequestParam( param : RequestParamKeys.ids, value : ids.map{ String( $0 ) }.joined(separator: ",") )
        let request : APIRequest = APIRequest(handler: self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                for entityResponse in responses
                {
                    let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                    let recordJSON : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                    if recordJSON.isEmpty == true
                    {
                        ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.processingError( code: ZCRMErrorCode.responseNil, message: ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.apiName)
                    record.id = try recordJSON.getInt64( key : ResponseJSONKeys.id )
                    entityResponse.setData(data: record)
                }
                completion( .success( bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getDeletedRecords( type : ZCRMTrashRecordTypes, params : GETRequestParams, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        setUrlPath(urlPath : "\( self.module.apiName )/\( URLPathConstants.deleted )")
        setRequestMethod(requestMethod : .get )
        addRequestParam(param: RequestParamKeys.type , value: type.rawValue )
        if params.modifiedSince.notNilandEmpty, let modifiedSince = params.modifiedSince
        {
            addRequestHeader( header : RequestParamKeys.ifModifiedSince, value : modifiedSince )
        }
        if let page = params.page
        {
            addRequestParam( param : RequestParamKeys.page, value : String( page ) )
        }
        if let perPage = params.perPage
        {
            addRequestParam( param : RequestParamKeys.perPage, value : String( perPage ) )
        }
        let request : APIRequest = APIRequest(handler: self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                var trashRecords : [ ZCRMTrashRecord ] = [ ZCRMTrashRecord ]()
                if responseJSON.isEmpty == false
                {
                    trashRecords = try self.setTrashRecordsProperties( recordsDetails : responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() ) )
                    if trashRecords.isEmpty
                    {
                        ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ZCRMErrorCode.responseNil, message : ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                }
                bulkResponse.setData( data : trashRecords )
                completion( .success( trashRecords, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    // TODO : Add response object as List of Records when overwrite false case is fixed
    internal func addTags( records : [ ZCRMRecord ], tags : [ ZCRMTagDelegate ], overWrite : Bool?, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.DATA)
        setUrlPath(urlPath: "\(self.module.apiName)/\( URLPathConstants.actions )/\( URLPathConstants.addTags )")
        setRequestMethod(requestMethod: .post)
        if ZCRMSDKClient.shared.apiVersion <= "v2.1"
        {
            addRequestParam(param: RequestParamKeys.ids, value: records.map{ String( $0.id ) }.joined(separator: ",") )
            addRequestParam(param: RequestParamKeys.tagNames, value: tags.map{ $0.name }.joined(separator: ",") )
        }
        else
        {
            var requestBody : [ String : Any ] = [:]
            requestBody[ RequestParamKeys.ids ] = records.map{ $0.id }
            requestBody[ JSONRootKey.TAGS ] = tags.map{ [ ResponseJSONKeys.name : $0.name, ResponseJSONKeys.colorCode : $0.colorCode ] }
            setRequestBody(requestBody: requestBody)
        }
        if let overWrite = overWrite
        {
            addRequestParam( param : RequestParamKeys.overWrite, value : String( overWrite ) )
        }
        
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse() { result in
            switch result
            {
            case .success(let bulkResponse) :
                do
                {
                    let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                    for index in 0..<responses.count
                    {
                        if(APIConstants.CODE_SUCCESS == responses[ index ].getStatus())
                        {
                            let entResponseJSON : [ String : Any ] = responses[ index ].getResponseJSON()
                            let recordDetails : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                            if recordDetails.isEmpty == true
                            {
                                ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                                completion( .failure( ZCRMError.processingError( code: ZCRMErrorCode.responseNil, message: ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                                return
                            }
                            
                            var tagNames : [ String ] = []
                            if let tags = recordDetails.optArray( key : ResponseJSONKeys.tags ) as? [ String ]
                            {
                                tagNames = tags
                            }
                            else
                            {
                                tagNames = try recordDetails.getArrayOfDictionaries(key: ResponseJSONKeys.tags).map{ try $0.getString(key: ResponseJSONKeys.name) }
                            }
                            
                            var existingTags : [ ZCRMTagDelegate ] = records[ index ].tags ?? []
                            let existingTagNames : [ String ] = existingTags.map{ $0.name }
                            
                            for tag in tags
                            {
                                if !existingTagNames.contains( tag.name ) && tagNames.contains( tag.name )
                                {
                                    existingTags.append( tag )
                                }
                            }
                            records[ index ].tags = existingTags
                            responses[ index ].setData(data: records[ index ])
                        }
                        else
                        {
                            responses[ index ].setData(data: records[ index ])
                        }
                    }
                    bulkResponse.setData( data : records )
                    completion( .success( records, bulkResponse ) )
                }
                catch
                {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func addTags( records : [ ZCRMRecord ], tags : [ String ], overWrite : Bool?, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.DATA)
        setUrlPath(urlPath: "\(self.module.apiName)/\( URLPathConstants.actions )/\( URLPathConstants.addTags )")
        setRequestMethod(requestMethod: .post)
        if ZCRMSDKClient.shared.apiVersion <= "v2.1"
        {
            addRequestParam(param: RequestParamKeys.ids, value: records.map{ String( $0.id ) }.joined(separator: ",") )
            addRequestParam(param: RequestParamKeys.tagNames, value: tags.joined(separator: ",") )
        }
        else
        {
            var requestBody : [ String : Any ] = [:]
            requestBody[ RequestParamKeys.ids ] = records.map{ $0.id }
            requestBody[ JSONRootKey.TAGS ] = tags.map{ [ ResponseJSONKeys.name : $0 ] }
            setRequestBody(requestBody: requestBody)
        }
        if let overWrite = overWrite
        {
            addRequestParam( param : RequestParamKeys.overWrite, value : String( overWrite ) )
        }
        
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                for index in 0..<responses.count
                {
                    if(APIConstants.CODE_SUCCESS == responses[ index ].getStatus())
                    {
                        let entResponseJSON : [ String : Any ] = responses[ index ].getResponseJSON()
                        let recordDetails : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                        if recordDetails.isEmpty == true
                        {
                            ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                            completion( .failure( ZCRMError.processingError( code: ZCRMErrorCode.responseNil, message: ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                            return
                        }
                        var tagNames : [ String ] = []
                        if let tags = recordDetails.optArray( key : ResponseJSONKeys.tags ) as? [ String ]
                        {
                            tagNames = tags
                        }
                        else
                        {
                            tagNames = try recordDetails.getArrayOfDictionaries(key: ResponseJSONKeys.tags).map{ try $0.getString(key: ResponseJSONKeys.name) }
                        }
                        records[ index ].tags = [ ZCRMTagDelegate ]()
                        for name in tagNames
                        {
                            let tagDelegate = ZCRMTagDelegate(name: name)
                            records[ index ].tags?.append( tagDelegate )
                        }
                        responses[ index ].setData(data: records[ index ])
                    }
                    else
                    {
                        responses[ index ].setData(data: records[ index ])
                    }
                }
                bulkResponse.setData( data : records )
                completion( .success( records, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func removeTags( records : [ ZCRMRecord ], tags removableTags : [ String ], completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.DATA)
        setUrlPath(urlPath: "\(self.module.apiName)/\( URLPathConstants.actions )/\( URLPathConstants.removeTags )")
        setRequestMethod(requestMethod: .post)
        if ZCRMSDKClient.shared.apiVersion <= "v2.1"
        {
            addRequestParam(param: RequestParamKeys.ids, value: records.map{ String( $0.id ) }.joined(separator: ","))
            addRequestParam(param: RequestParamKeys.tagNames, value: removableTags.joined(separator: ",") )
        }
        else
        {
            var requestBody : [ String : Any ] = [:]
            requestBody[ RequestParamKeys.ids ] = records.map{ $0.id }
            requestBody[ JSONRootKey.TAGS ] = removableTags.map{ [ ResponseJSONKeys.name : $0 ] }
            setRequestBody(requestBody: requestBody)
        }
        
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse() { result in
            switch result
            {
            case .success(let bulkResponse) :
                do
                {
                    let responses = bulkResponse.getEntityResponses()
                    for index in 0..<responses.count
                    {
                        if( APIConstants.CODE_SUCCESS == responses[ index ].getStatus() )
                        {
                            let entResponseJSON : [ String : Any ] = responses[ index ].getResponseJSON()
                            let recordDetails : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                            if recordDetails.isEmpty == true
                            {
                                ZCRMLogger.logError( message : "\( ZCRMErrorCode.responseNil ) : \( ZCRMErrorMessage.responseJSONNilMsg ), \( APIConstants.DETAILS ) : -" )
                                completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.responseNil, message : ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                                return
                            }
                            var updatedTags : [ ZCRMTagDelegate ] = []
                            if let tagNames = try recordDetails.getArray( key : JSONRootKey.TAGS ) as? [ String ]
                            {
                                for tag in records[ index ].tags ?? []
                                {
                                    if !removableTags.contains( tag.name ) && tagNames.contains( tag.name )
                                    {
                                        updatedTags.append( tag )
                                    }
                                }
                                
                            }
                            else if let tags = try recordDetails.getArrayOfDictionaries(key: JSONRootKey.TAGS) as? [ [ String : String ] ]
                            {
                                let tagNames = try tags.map{ try $0.getString(key: ResponseJSONKeys.name) }
                                for tag in records[ index ].tags ?? []
                                {
                                    if !removableTags.contains( tag.name ) && tagNames.contains( tag.name )
                                    {
                                        updatedTags.append( tag )
                                    }
                                }
                            }
                            records[ index ].tags = updatedTags
                            responses[ index ].setData( data : records[ index ] )
                        }
                        else
                        {
                            responses[ index ].setData( data : records[ index ] )
                        }
                    }
                    bulkResponse.setData( data : records )
                    completion( .success( records, bulkResponse ) )
                }
                catch
                {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    // MARK: - Utility Functions
    private func setTrashRecordsProperties( recordsDetails : [ [ String : Any ] ] ) throws -> [ ZCRMTrashRecord ]
    {
        var trashRecords : [ ZCRMTrashRecord ] = [ ZCRMTrashRecord ]()
        for recordDetails in recordsDetails
        {
            trashRecords.append( try self.setTrashRecordProperties( recordDetails : recordDetails ) )
        }
        return trashRecords
    }
    
    private func setTrashRecordProperties( recordDetails : [ String : Any ] ) throws -> ZCRMTrashRecord
    {
        let trashRecord : ZCRMTrashRecord = try ZCRMTrashRecord( type : recordDetails.getString( key : ResponseJSONKeys.type ), id : recordDetails.getInt64( key : ResponseJSONKeys.id ) )
        if recordDetails.hasValue( forKey : ResponseJSONKeys.createdBy )
        {
            let createdBy : [ String : Any ] = try recordDetails.getDictionary( key : ResponseJSONKeys.createdBy )
            trashRecord.createdBy = try getUserDelegate( userJSON : createdBy )
        }
        if recordDetails.hasValue( forKey : ResponseJSONKeys.deletedBy )
        {
            let deletedBy : [ String : Any ] = try recordDetails.getDictionary( key : ResponseJSONKeys.deletedBy )
            trashRecord.deletedBy = try getUserDelegate( userJSON : deletedBy )
        }
        trashRecord.displayName = recordDetails.optString( key : ResponseJSONKeys.displayName )
        trashRecord.deletedTime = try recordDetails.getString( key : ResponseJSONKeys.deletedTime )
        return trashRecord
    }
}

internal extension MassEntityAPIHandler
{
    struct RequestParamValues
    {
        static let word = "word"
        static let criteria = "criteria"
        static let email = "email"
        static let phone = "phone"
        static let all = "all"
        static let recycle = "recycle"
        static let permanent = "permanent"
    }
    
    struct ResponseJSONKeys
    {
        static let id = "id"
        static let ids = "ids"
        static let name = "name"
        static let createdBy = "created_by"
        static let deletedBy = "deleted_by"
        static let displayName = "display_name"
        static let deletedTime = "deleted_time"
        static let tags = "tags"
        static let type = "type"
        
        static let colorCode = "color_code"
    }
    
    struct URLPathConstants
    {
        static let actions = "actions"
        static let cancel = "cancel"
        static let deleted = "deleted"
        static let addTags = "add_tags"
        static let removeTags = "remove_tags"
        static let search = "search"
        static let upsert = "upsert"
        static let reschedule = "reschedule"
        static let massUpdate = "mass_update"
    }
}

extension RequestParamKeys
{
    static let fields = "fields"
    static let kanbanView = "kanban_view"
    static let cvId = "cvid"
    static let filterId = "filter_id"
    static let converted = "converted"
    static let approved = "approved"
    static let filters = "filters"
    static let endDateTime = "endDateTime"
    static let startDateTime = "startDateTime"
    static let formattedCurrency = "formatted_currency"
    static let homeConvertedCurrency = "home_converted_currency"
}


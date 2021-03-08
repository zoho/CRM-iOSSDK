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
    internal func createRecords( triggers : [Trigger]?, records : [ ZCRMRecord ], completion : @escaping( CRMResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if(records.count > 100)
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.maxCountExceeded) : \(ErrorMessage.apiMaxRecordsMsg), \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ErrorCode.maxCountExceeded, message : ErrorMessage.apiMaxRecordsMsg, details : nil ) ) )
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
		let request : APIRequest = APIRequest(handler: self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                var createdRecords : [ ZCRMRecord ] = [ ZCRMRecord ]()
                let dispatchGroup : DispatchGroup = DispatchGroup()
                let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.massEntityAPIHandler.createRecords")
                for index in 0..<responses.count
                {
                    let entityResponse = responses[ index ]
                    if(APIConstants.CODE_SUCCESS == responses[ index ].getStatus())
                    {
                        let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                        let recordJSON : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                        if recordJSON.isEmpty == true
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                            completion( .failure( ZCRMError.processingError( code: ErrorCode.responseNil, message: ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                            return
                        }
                        records[ index ].id = try recordJSON.getString( key : ResponseJSONKeys.id )
                        for ( key, value ) in records[ index ].upsertJSON
                        {
                            records[ index ].data.updateValue( value, forKey : key )
                        }
                        dispatchGroup.enter()
                        EntityAPIHandler( record : records[ index ] ).setRecordProperties( recordDetails : recordJSON, completion : { ( recordResult ) in
                            do
                            {
                                let createdRecord = try recordResult.resolve()
                                createdRecord.upsertJSON = [ String : JSONValue? ]()
                                dispatchQueue.sync {
                                    createdRecords.append( createdRecord )
                                }
                                entityResponse.setData(data: createdRecord)
                                dispatchGroup.leave()
                            }
                            catch
                            {
                                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
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
                    bulkResponse.setData( data : createdRecords )
                    completion( .success( createdRecords, bulkResponse ) )
                }
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getRecords( cvId : Int64?, filterId : Int64?, recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( CRMResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
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
        let request : APIRequest = APIRequest(handler: self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        var zcrmFields : [ZCRMField]?
        var bulkResponse : BulkAPIResponse?
        var err : Error?
        let dispatchGroup : DispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        ModuleAPIHandler( module : self.module, cacheFlavour : .urlVsResponse ).getAllFields( modifiedSince : nil ) { ( result ) in
            do
            {
                let resp = try result.resolve()
                zcrmFields = resp.data
                dispatchGroup.leave()
            }
            catch
            {
                err = error
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
                err = error
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
            if let fields = zcrmFields, let response = bulkResponse
            {
                self.getZCRMRecords(fields: fields, bulkResponse: response, completion: { ( records, error ) in
                    if let err = error
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
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
            else if let error = err
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
            else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : FIELDS must not be nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "FIELDS must not be nil", details : nil ) ) )
            }
        }
    }
    
    internal func getZCRMRecords( fields : [ ZCRMField ], bulkResponse : BulkAPIResponse, completion : @escaping( [ ZCRMRecord ]?, ZCRMError? ) -> () )
    {
        var records : [ ZCRMRecord ] = [ ZCRMRecord ]()
        let responseJSON = bulkResponse.getResponseJSON()
        let dispatchGroup : DispatchGroup = DispatchGroup()
        let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.massEnityAPIHandler.getZCRMRecords")
        if responseJSON.isEmpty == false
        {
            do
            {
                let recordsDetailsList:[ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                if recordsDetailsList.isEmpty == true
                {
                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                    completion( nil, ZCRMError.processingError( code: ErrorCode.responseNil, message: ErrorMessage.responseJSONNilMsg, details : nil ) )
                    return
                }
                for recordDetails in recordsDetailsList
                {
                    let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.apiName)
                    record.id = try recordDetails.getString( key : ResponseJSONKeys.id )
                    dispatchGroup.enter()
                    EntityAPIHandler(record: record, moduleFields: getFieldVsApinameMap(fields: fields)).setRecordProperties(recordDetails: recordDetails, completion: { ( recordResult ) in
                        do
                        {
                            let getRecord = try recordResult.resolve()
                            getRecord.upsertJSON = [ String : JSONValue ]()
                            dispatchQueue.sync {
                                records.append(getRecord)
                            }
                            dispatchGroup.leave()
                        }
                        catch
                        {
                            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                            completion( nil, typeCastToZCRMError( error ) )
                            dispatchGroup.leave()
                            return
                        }
                    })
                }
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( nil, typeCastToZCRMError( error ) )
            }
        }
        dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
            completion( records, nil )
        }
    }

    internal func searchByText( searchText : String, page : Int?, perPage : Int?, completion : @escaping( CRMResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        self.searchRecords( searchKey : RequestParamValues.word, searchValue : searchText, page : page, perPage : perPage) { ( resultType ) in
            completion( resultType )
        }
    }
    
    internal func searchByCriteria( searchCriteria : ZCRMQuery.ZCRMCriteria, page : Int?, perPage : Int?, completion : @escaping( CRMResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        guard let recordQuery = searchCriteria.recordQuery else
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.internalError) : Criteria cannot be constructed, \( APIConstants.DETAILS ) : -" )
            completion( .failure( ZCRMError.processingError( code : ErrorCode.internalError, message : "Criteria cannot be constructed", details : nil ) ) )
            return
        }
        self.searchRecords(searchKey: RequestParamValues.criteria, searchValue: recordQuery, page: page, perPage: perPage) { ( resultType ) in
            completion( resultType )
        }
    }

    internal func searchByEmail( searchValue : String, page : Int?, perPage : Int?, completion : @escaping( CRMResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        self.searchRecords( searchKey : RequestParamValues.email, searchValue : searchValue, page : page, perPage : perPage) { ( resultType ) in
            completion( resultType )
        }
    }
    
    internal func searchByPhone( searchValue : String, page : Int?, perPage : Int?, completion : @escaping( CRMResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        self.searchRecords( searchKey : RequestParamValues.phone, searchValue : searchValue, page : page, perPage : perPage) { ( resultType ) in
            completion( resultType )
        }
    }
	
    private func searchRecords( searchKey : String, searchValue : String, page : Int?, perPage : Int?, completion : @escaping( CRMResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
	{
        if searchValue.count < 2 {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : Please enter two or more characters to make a search request, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidData, message : "Please enter two or more characters to make a search request", details : nil ) ) )
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
        var err : Error?
        let dispatchGroup : DispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        ModuleAPIHandler( module : self.module, cacheFlavour : .urlVsResponse ).getAllFields( modifiedSince : nil ) { ( result ) in
            do
            {
                let resp = try result.resolve()
                zcrmFields = resp.data
                dispatchGroup.leave()
            }
            catch
            {
                err = error
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
                err = error
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
            if let fields = zcrmFields, let response = bulkResponse
            {
                self.getZCRMRecords(fields: fields, bulkResponse: response, completion: { ( records, error ) in
                    if let err = error
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
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
            else if let error = err
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
            else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : FIELDS must not be nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "FIELDS must not be nil", details : nil ) ) )
            }
        }
	}

    internal func updateRecords( triggers : [Trigger]?, records : [ ZCRMRecord ], completion : @escaping( CRMResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if( records.count > 100 )
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.maxCountExceeded) : \(ErrorMessage.apiMaxRecordsMsg), \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ErrorCode.maxCountExceeded, message : ErrorMessage.apiMaxRecordsMsg, details : nil ) ) )
            return
        }
        guard records.count != 0 else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : No records found to be updated, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ErrorCode.invalidData, message : "No records found to be updated", details : nil ) ) )
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
        let request : APIRequest = APIRequest(handler: self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")

        request.getBulkAPIResponse { ( resultType ) in
            do{
                switch resultType
                {
                case .success(let bulkResponse) :
                    let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                    var updatedRecords : [ZCRMRecord] = [ZCRMRecord]()
                    let dispatchGroup : DispatchGroup = DispatchGroup()
                    let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.massEnityAPIHandler.updateRecords")
                    for ( index ) in 0..<responses.count
                    {
                        let entityResponse = responses[index]
                        if(APIConstants.CODE_SUCCESS == entityResponse.getStatus())
                        {
                            let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                            let recordJSON : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                            dispatchGroup.enter()
                            for ( key, value ) in records[ index ].upsertJSON
                            {
                                records[ index ].data.updateValue( value, forKey : key )
                            }
                            EntityAPIHandler(record: records[ index ] ).setRecordProperties(recordDetails: recordJSON, completion: { ( recordResult ) in
                                switch recordResult
                                {
                                case .success(let updatedRecord) :
                                    dispatchQueue.sync {
                                        print("<<< CRM UPDATED: \(updatedRecord.getData())")

                                        updatedRecords.append(updatedRecord)
                                    }
                                    entityResponse.setData(data: updatedRecord)
                                    dispatchGroup.leave()
                                case .failure(let error) :
                                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
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

    internal func massUpdateRecords( triggers : [ Trigger ]?, ids : [ String ], fieldValuePair : [ String : Any? ], completion : @escaping( CRMResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
	{
        if(ids.count > 500)
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.maxCountExceeded) : \(ErrorMessage.apiMaxRecordsMsg), \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ErrorCode.maxCountExceeded, message : ErrorMessage.apiMaxRecordsMsg, details : nil ) ) )
            return
        }
        if ( self.module.apiName == DefaultModuleAPINames.DEALS && fieldValuePair.count > 3 ) || ( self.module.apiName != DefaultModuleAPINames.DEALS && fieldValuePair.count > 1 )
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : Max field limit exceeded, \( APIConstants.DETAILS ) : limit = \( ( self.module.apiName == DefaultModuleAPINames.DEALS ) ? 3 : 1 )")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ErrorCode.invalidData, message : "Max field limit exceeded", details : [ "limit" : ( self.module.apiName == DefaultModuleAPINames.DEALS ) ? 3 : 1 ] ) ) )
            return
        }
        else if fieldValuePair.count == 0
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : No field found, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.inValidError( code : ErrorCode.invalidData, message : "No field found", details : nil ) ) )
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
		
        request.getBulkAPIResponse { ( resultType ) in
            do{
                switch resultType
                {
                case .success(let bulkResponse) :
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
                            EntityAPIHandler(record: record).setRecordProperties(recordDetails: recordJSON, completion: { ( recordResult ) in
                                switch recordResult
                                {
                                case .success(let updatedRecord) :
                                    dispatchQueue.sync {
                                        updatedRecords.append( updatedRecord )
                                    }
                                    responses[ index ].setData(data: updatedRecord )
                                    dispatchGroup.leave()
                                case .failure(let error) :
                                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
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

    internal func upsertRecords( triggers : [Trigger]?, records : [ ZCRMRecord ], duplicateCheckFields : [ String ]?, completion : @escaping( CRMResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if ( records.count > 100 )
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.maxCountExceeded) : \(ErrorMessage.apiMaxRecordsMsg), \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ErrorCode.maxCountExceeded, message : ErrorMessage.apiMaxRecordsMsg, details : nil ) ) )
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
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                            completion( .failure( ZCRMError.processingError( code: ErrorCode.responseNil, message: ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                            return
                        }
                        records[ index ].id = try recordJSON.getString( key : ResponseJSONKeys.id )
                        for ( key, value ) in records[ index ].upsertJSON
                        {
                            records[ index ].data.updateValue( JSONValue(value: value), forKey : key )
                        }
                        dispatchGroup.enter()
                        EntityAPIHandler( record : records[ index ] ).setRecordProperties( recordDetails : recordJSON, completion : { ( recordResult ) in
                            do
                            {
                                let upsertRecord = try recordResult.resolve()
                                upsertRecord.upsertJSON = [ String : JSONValue? ]()
                                dispatchQueue.sync {
                                    upsertRecords.append( upsertRecord )
                                }
                                entityResponse.setData( data : upsertRecord )
                                dispatchGroup.leave()
                            }
                            catch
                            {
                                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
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
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func deleteRecords( ids : [ String ], completion : @escaping( CRMResultType.DataResponse< [ String ] , BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if(ids.count > 100)
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.maxCountExceeded) : \(ErrorMessage.apiMaxRecordsMsg), \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ErrorCode.maxCountExceeded, message : ErrorMessage.apiMaxRecordsMsg, details : nil ) ) )
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
                    var deletedIds : [ String ] = []
                    let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                    for entityResponse in responses
                    {
                        if APIConstants.CODE_SUCCESS == entityResponse.getStatus()
                        {
                            let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                            let recordJSON : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                            if recordJSON.isEmpty == true
                            {
                                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                                completion( .failure( ZCRMError.processingError( code: ErrorCode.responseNil, message: ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                                return
                            }
                            deletedIds.append( try recordJSON.getString( key: ResponseJSONKeys.id ) )
                        }
                    }
                    completion( .success( deletedIds, bulkResponse ) )
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

    internal func deleteRecords( ids : [ Int64 ], completion : @escaping( CRMResultType.Response< BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if(ids.count > 100)
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.maxCountExceeded) : \(ErrorMessage.apiMaxRecordsMsg), \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.maxRecordCountExceeded( code : ErrorCode.maxCountExceeded, message : ErrorMessage.apiMaxRecordsMsg, details : nil ) ) )
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
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.processingError( code: ErrorCode.responseNil, message: ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.apiName)
                    record.id = try recordJSON.getString( key : ResponseJSONKeys.id )
                    entityResponse.setData(data: record)
                }
                completion( .success( bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getDeletedRecords( type : TrashRecordTypes, params : GETRequestParams, completion : @escaping( CRMResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
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
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                }
                bulkResponse.setData( data : trashRecords )
                completion( .success( trashRecords, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    // TODO : Add response object as List of Records when overwrite false case is fixed
    internal func addTags( records : [ ZCRMRecord ], tags : [ String ], overWrite : Bool?, completion : @escaping( CRMResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.DATA)
        setUrlPath(urlPath: "\(self.module.apiName)/\( URLPathConstants.actions )/\( URLPathConstants.addTags )")
        setRequestMethod(requestMethod: .post)
        addRequestParam(param: RequestParamKeys.ids, value: records.map{ String( $0.id ) }.joined(separator: ",") )
        addRequestParam(param: RequestParamKeys.tagNames, value: tags.joined(separator: ",") )
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
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                            completion( .failure( ZCRMError.processingError( code: ErrorCode.responseNil, message: ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                            return
                        }
                        let tagNames : [ String ] = try recordDetails.getArray( key : ResponseJSONKeys.tags ) as! [ String ]
                        records[ index ].tags = [ String ]()
                        for name in tagNames
                        {
                            records[ index ].tags?.append( name )
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
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func removeTags( records : [ ZCRMRecord ], tags : [ String ], completion : @escaping( CRMResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.DATA)
        setUrlPath(urlPath: "\(self.module.apiName)/\( URLPathConstants.actions )/\( URLPathConstants.removeTags )")
        setRequestMethod(requestMethod: .post)
        addRequestParam(param: RequestParamKeys.ids, value: records.map{ String( $0.id ) }.joined(separator: ","))
        addRequestParam(param: RequestParamKeys.tagNames, value: tags.joined(separator: ",") )
        
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responses : [ EntityResponse ] = bulkResponse.getEntityResponses()
                for index in 0..<responses.count
                {
                    if( APIConstants.CODE_SUCCESS == responses[ index ].getStatus() )
                    {
                        let entResponseJSON : [ String : Any ] = responses[ index ].getResponseJSON()
                        let recordDetails : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                        if recordDetails.isEmpty == true
                        {
                            ZCRMLogger.logError( message : "\( ErrorCode.responseNil ) : \( ErrorMessage.responseJSONNilMsg ), \( APIConstants.DETAILS ) : -" )
                            completion( .failure( ZCRMError.processingError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                            return
                        }
                        let tagNames : [ String ] = try recordDetails.getArray( key : ResponseJSONKeys.tags ) as! [ String ]
                        records[ index ].tags = [ String ]()
                        for name in tagNames
                        {
                            records[ index ].tags?.append( name )
                        }
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
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
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
        let trashRecord : ZCRMTrashRecord = try ZCRMTrashRecord( type : recordDetails.getString( key : ResponseJSONKeys.type ), id : recordDetails.getString( key : ResponseJSONKeys.id ) )
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
        trashRecord.moduleName = module.apiName
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
}


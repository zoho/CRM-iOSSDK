//
//  MassEntityAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 16/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class MassEntityAPIHandler : CommonAPIHandler
{
	private var module : ZCRMModuleDelegate
	
	init(module : ZCRMModuleDelegate)
	{
		self.module = module
	}
	
	// MARK: - Handler Functions
    internal func createRecords( triggers : [Trigger]?, records : [ ZCRMRecord ], completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if(records.count > 100)
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MAX_COUNT_EXCEEDED) : \(ErrorMessage.API_MAX_RECORDS_MSG)")
            completion( .failure( ZCRMError.MaxRecordCountExceeded( code : ErrorCode.MAX_COUNT_EXCEEDED, message : ErrorMessage.API_MAX_RECORDS_MSG, details : nil ) ) )
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
		setRequestMethod(requestMethod : .POST )
		setRequestBody(requestBody : reqBodyObj )
		let request : APIRequest = APIRequest(handler: self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                var createdRecords : [ ZCRMRecord ] = [ ZCRMRecord ]()
                let dispatchGroup : DispatchGroup = DispatchGroup()
                let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.massEnityAPIHandler.createRecords")
                for index in 0..<responses.count
                {
                    let entityResponse = responses[ index ]
                    if(APIConstants.CODE_SUCCESS == responses[ index ].getStatus())
                    {
                        let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                        let recordJSON : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                        if recordJSON.isEmpty == true
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_JSON_NIL_MSG)")
                            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_JSON_NIL_MSG, details : nil ) ) )
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
                                let createdRecord = try recordResult.resolve()
                                createdRecord.upsertJSON = [ String : Any? ]()
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

    @available(*, deprecated, message: "Use the struct 'GetRecordParams'" )
    internal func getRecords( cvId : Int64?, filterId : Int64?, recordParams : ZCRMQuery.GetRecords, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
	{
        setJSONRootKey( key : JSONRootKey.DATA )
        setUrlPath(urlPath: "\(self.module.apiName)" )
		setRequestMethod( requestMethod : .GET )
        if let fields = recordParams.fields, fields.isEmpty == false
		{
			var fieldsStr : String = ""
			for index in 0..<fields.count
			{
                fieldsStr.append( contentsOf : fields[ index ] )
                if index != ( fields.count - 1 )
                {
                    fieldsStr.append( "," )
                }
			}
			if(!fieldsStr.isEmpty)
			{
				addRequestParam(param: RequestParamKeys.fields , value: String(fieldsStr.dropLast()) )
			}
		}
		if let cvId = cvId
		{
			addRequestParam(param:  RequestParamKeys.cvId , value: String(cvId) )
		}
        if let filterId = filterId
        {
            addRequestParam(param:  RequestParamKeys.filterId , value: String(filterId) )
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
        if recordParams.modifiedSince.notNilandEmpty
        {
         	addRequestHeader(header: RequestParamKeys.ifModifiedSince , value: recordParams.modifiedSince! )
        }
        if( recordParams.includePrivateFields != nil && recordParams.includePrivateFields == true )
        {
            addRequestParam( param : RequestParamKeys.include, value : APIConstants.PRIVATE_FIELDS )
        }
        if let page = recordParams.page
        {
            addRequestParam(param: RequestParamKeys.page , value: String(page) )
        }
        if let perPage = recordParams.perPage
        {
            addRequestParam(param: RequestParamKeys.perPage , value: String(perPage) )
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
        ModuleAPIHandler( module : self.module, cacheFlavour : .URL_VS_RESPONSE ).getAllFields( modifiedSince : nil ) { ( result ) in
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
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : FIELDS must not be nil")
                completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "FIELDS must not be nil", details : nil ) ) )
            }
        }
	}
    
    internal func getRecords( cvId : Int64?, filterId : Int64?, recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        setUrlPath(urlPath: "\(self.module.apiName)" )
        setRequestMethod( requestMethod : .GET )
        if let fields = recordParams.fields, fields.isEmpty == false
        {
            var fieldsStr : String = ""
            for field in fields
            {
                if(!field.isEmpty)
                {
                    fieldsStr += field + ","
                }
            }
            if(!fieldsStr.isEmpty)
            {
                addRequestParam(param: RequestParamKeys.fields , value: String(fieldsStr.dropLast()) )
            }
        }
        if let cvId = cvId
        {
            addRequestParam(param:  RequestParamKeys.cvId , value: String(cvId) )
        }
        if let filterId = filterId
        {
            addRequestParam(param:  RequestParamKeys.filterId , value: String(filterId) )
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
        if recordParams.modifiedSince.notNilandEmpty
        {
            addRequestHeader(header: RequestParamKeys.ifModifiedSince , value: recordParams.modifiedSince! )
        }
        if( recordParams.includePrivateFields != nil && recordParams.includePrivateFields == true )
        {
            addRequestParam( param : RequestParamKeys.include, value : APIConstants.PRIVATE_FIELDS )
        }
        if let page = recordParams.page
        {
            addRequestParam(param: RequestParamKeys.page , value: String(page) )
        }
        if let perPage = recordParams.perPage
        {
            addRequestParam(param: RequestParamKeys.perPage , value: String(perPage) )
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
        ModuleAPIHandler( module : self.module, cacheFlavour : .URL_VS_RESPONSE ).getAllFields( modifiedSince : nil ) { ( result ) in
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
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : FIELDS must not be nil")
                completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "FIELDS must not be nil", details : nil ) ) )
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
                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_JSON_NIL_MSG)")
                    completion( nil, ZCRMError.ProcessingError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_JSON_NIL_MSG, details : nil ) )
                    return
                }
                for recordDetails in recordsDetailsList
                {
                    let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.apiName)
                    record.id = try recordDetails.getInt64( key : ResponseJSONKeys.id )
                    dispatchGroup.enter()
                    EntityAPIHandler(record: record, moduleFields: getFieldVsApinameMap(fields: fields)).setRecordProperties(recordDetails: recordDetails, completion: { ( recordResult ) in
                        do
                        {
                            let getRecord = try recordResult.resolve()
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

    internal func searchByText( searchText : String, page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        self.searchRecords( searchKey : RequestParamValues.word, searchValue : searchText, page : page, perPage : perPage) { ( resultType ) in
            completion( resultType )
        }
    }
    
    @available(*, deprecated, message: "Use the method with searchCriteria type 'ZCRMCriteria'" )
    internal func searchByCriteria( searchCriteria : String, page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        self.searchRecords( searchKey : RequestParamValues.criteria, searchValue : searchCriteria, page : page, perPage : perPage ) { ( resultType ) in
            completion( resultType )
        }
    }
    
    internal func searchByCriteria( searchCriteria : ZCRMQuery.ZCRMCriteria, page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        guard let recordQuery = searchCriteria.recordQuery else
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.INTERNAL_ERROR) : Criteria cannot be constructed" )
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.INTERNAL_ERROR, message : "Criteria cannot be constructed", details : nil ) ) )
            return
        }
        self.searchRecords(searchKey: RequestParamValues.criteria, searchValue: recordQuery, page: page, perPage: perPage) { ( resultType ) in
            completion( resultType )
        }
    }

    internal func searchByEmail( searchValue : String, page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        self.searchRecords( searchKey : RequestParamValues.email, searchValue : searchValue, page : page, perPage : perPage) { ( resultType ) in
            completion( resultType )
        }
    }
    
    internal func searchByPhone( searchValue : String, page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        self.searchRecords( searchKey : RequestParamValues.phone, searchValue : searchValue, page : page, perPage : perPage) { ( resultType ) in
            completion( resultType )
        }
    }
	
    private func searchRecords( searchKey : String, searchValue : String, page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
	{
        setJSONRootKey( key : JSONRootKey.DATA )
		setUrlPath(urlPath : "\(self.module.apiName)/search" )
		setRequestMethod(requestMethod : .GET )
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
        ModuleAPIHandler( module : self.module, cacheFlavour : .URL_VS_RESPONSE ).getAllFields( modifiedSince : nil ) { ( result ) in
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
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : FIELDS must not be nil")
                completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "FIELDS must not be nil", details : nil ) ) )
            }
        }
	}

    internal func updateRecords( triggers : [Trigger]?, ids : [ Int64 ], fieldAPIName : String, value : Any?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
	{
        setJSONRootKey( key : JSONRootKey.DATA )
        if(ids.count > 100)
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MAX_COUNT_EXCEEDED) : \(ErrorMessage.API_MAX_RECORDS_MSG)")
            completion( .failure( ZCRMError.MaxRecordCountExceeded( code : ErrorCode.MAX_COUNT_EXCEEDED, message : ErrorMessage.API_MAX_RECORDS_MSG, details : nil ) ) )
            return
        }
		var reqBodyObj : [String:Any] = [String:Any]()
		var dataArray : [[String:Any]] = [[String:Any]]()
		for id in ids
		{
			var dataJSON : [String:Any] = [String:Any]()
			dataJSON[ResponseJSONKeys.id] = String(id)
			dataJSON[fieldAPIName] = value
			dataArray.append(dataJSON)
		}
		reqBodyObj[getJSONRootKey()] = dataArray
        if let triggers = triggers
        {
            reqBodyObj[ APIConstants.TRIGGER ] = getTriggerArray(triggers: triggers)
        }
        setUrlPath(urlPath : "\(self.module.apiName)")
		setRequestMethod(requestMethod : .PATCH )
		setRequestBody(requestBody : reqBodyObj )
		let request : APIRequest = APIRequest(handler: self )
		ZCRMLogger.logDebug(message: "Request : \(request.toString())")
		
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
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
                        if recordJSON.isEmpty == true
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_JSON_NIL_MSG)")
                            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_JSON_NIL_MSG, details : nil ) ) )
                            return
                        }
                        let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.apiName)
                        record.id = ids[ index ]
                        dispatchGroup.enter()
                        EntityAPIHandler(record: record).setRecordProperties(recordDetails: recordJSON, completion: { ( recordResult ) in
                            do
                            {
                                let updatedRecord = try recordResult.resolve()
                                dispatchQueue.sync {
                                    updatedRecords.append(updatedRecord)
                                }
                                responses[ index ].setData(data: updatedRecord)
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
                    bulkResponse.setData( data : updatedRecords )
                    completion( .success( updatedRecords, bulkResponse ) )
                }
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
	}

    internal func upsertRecords( triggers : [Trigger]?, records : [ ZCRMRecord ], completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if ( records.count > 100 )
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MAX_COUNT_EXCEEDED) : \(ErrorMessage.API_MAX_RECORDS_MSG)")
            completion( .failure( ZCRMError.MaxRecordCountExceeded( code : ErrorCode.MAX_COUNT_EXCEEDED, message : ErrorMessage.API_MAX_RECORDS_MSG, details : nil ) ) )
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
		
		setUrlPath(urlPath:  "\( self.module.apiName )/upsert")
		setRequestMethod(requestMethod: .POST )
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
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_JSON_NIL_MSG)")
                            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_JSON_NIL_MSG, details : nil ) ) )
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

    internal func deleteRecords( ids : [ Int64 ], completion : @escaping( Result.Response< BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if(ids.count > 100)
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MAX_COUNT_EXCEEDED) : \(ErrorMessage.API_MAX_RECORDS_MSG)")
            completion( .failure( ZCRMError.MaxRecordCountExceeded( code : ErrorCode.MAX_COUNT_EXCEEDED, message : ErrorMessage.API_MAX_RECORDS_MSG, details : nil ) ) )
            return
        }
        let idsStrArr : [ String ] = ids.map { String( $0 ) }
        let idsStr : String = idsStrArr.joined(separator: ",")
		setUrlPath(urlPath : "\(self.module.apiName)")
		setRequestMethod(requestMethod: .DELETE )
		addRequestParam( param : RequestParamKeys.ids, value : idsStr )
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
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_JSON_NIL_MSG)")
                        completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_JSON_NIL_MSG, details : nil ) ) )
                        return
                    }
                    let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.apiName)
                    record.id = try recordJSON.getInt64( key : ResponseJSONKeys.id )
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
    
    internal func rescheduleCalls( records : [ ZCRMRecord ], triggers : [Trigger]?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if(records.count > 100)
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MAX_COUNT_EXCEEDED) : \(ErrorMessage.API_MAX_RECORDS_MSG)")
            completion( .failure( ZCRMError.MaxRecordCountExceeded( code : ErrorCode.MAX_COUNT_EXCEEDED, message : ErrorMessage.API_MAX_RECORDS_MSG, details : nil ) ) )
            return
        }
        var reqBodyObj : [String:Any?] = [String:Any?]()
        var dataArray : [[String:Any?]] = [[String:Any?]]()
        for record in records
        {
            var dataJSON : [ String : Any? ] = [ String : Any? ]()
            dataJSON = EntityAPIHandler(record: record).getZCRMRecordAsJSON()
            dataArray.append( dataJSON )
        }
        reqBodyObj[getJSONRootKey()] = dataArray
        if let triggers = triggers
        {
            reqBodyObj[ APIConstants.TRIGGER ] = getTriggerArray(triggers: triggers)
        }
        setUrlPath(urlPath : "\(self.module.apiName)/actions/reschedule" )
        setRequestMethod(requestMethod : .POST )
        setRequestBody(requestBody : reqBodyObj )
        let request : APIRequest = APIRequest(handler: self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                var updatedRecords : [ZCRMRecord] = [ZCRMRecord]()
                let dispatchGroup : DispatchGroup = DispatchGroup()
                let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.massEnityAPIHandler.rescheduledCalls")
                for index in 0..<responses.count
                {
                    let entityResponse = responses[ index ]
                    if(APIConstants.CODE_SUCCESS == entityResponse.getStatus())
                    {
                        let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                        let recordJSON : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                        if recordJSON.isEmpty == true
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_JSON_NIL_MSG)")
                            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_JSON_NIL_MSG, details : nil ) ) )
                            return
                        }
                        records[ index ].id = try recordJSON.getInt64( key : ResponseJSONKeys.id )
                        dispatchGroup.enter()
                        EntityAPIHandler( record : records[ index ] ).setRecordProperties( recordDetails : recordJSON, completion : { ( recordResult ) in
                            do
                            {
                                let updatedRecord = try recordResult.resolve()
                                updatedRecord.upsertJSON = [ String : Any? ]()
                                dispatchQueue.sync {
                                    updatedRecords.append(updatedRecord)
                                }
                                entityResponse.setData(data: updatedRecord)
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
                    bulkResponse.setData( data : updatedRecords )
                    completion( .success( updatedRecords, bulkResponse ) )
                }
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func cancelCalls( records : [ ZCRMRecord ], triggers : [Trigger]?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if(records.count > 100)
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MAX_COUNT_EXCEEDED) : \(ErrorMessage.API_MAX_RECORDS_MSG)")
            completion( .failure( ZCRMError.MaxRecordCountExceeded( code : ErrorCode.MAX_COUNT_EXCEEDED, message : ErrorMessage.API_MAX_RECORDS_MSG, details : nil ) ) )
            return
        }
        var reqBodyObj : [String:Any] = [String:Any]()
        if let triggers = triggers
        {
            reqBodyObj[ APIConstants.TRIGGER ] = getTriggerArray(triggers: triggers)
        }
        setUrlPath(urlPath : "\(self.module.apiName)/actions/cancel" )
        setRequestMethod(requestMethod : .POST )
        var idString : String = String()
        for index in 0..<records.count
        {
            idString.append( String( records[ index ].id ) )
            if ( index != ( records.count - 1 ) )
            {
                idString.append(",")
            }
        }
        addRequestParam( param : RequestParamKeys.ids, value : idString )
        setRequestBody(requestBody : reqBodyObj )
        let request : APIRequest = APIRequest(handler: self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                var updatedRecords : [ZCRMRecord] = [ZCRMRecord]()
                let dispatchGroup : DispatchGroup = DispatchGroup()
                let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.massEnityAPIHandler.cancelCalls")
                for index in 0..<responses.count
                {
                    let entityResponse = responses[ index ]
                    if(APIConstants.CODE_SUCCESS == entityResponse.getStatus())
                    {
                        let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                        let recordJSON : [ String : Any ] = try entResponseJSON.getDictionary( key : APIConstants.DETAILS )
                        if recordJSON.isEmpty == true
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_JSON_NIL_MSG)")
                            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_JSON_NIL_MSG, details : nil ) ) )
                            return
                        }
                        records[ index ].id = try recordJSON.getInt64( key : ResponseJSONKeys.id )
                        dispatchGroup.enter()
                        EntityAPIHandler( record : records[ index ] ).setRecordProperties( recordDetails : recordJSON, completion : { ( recordResult ) in
                            do
                            {
                                let updatedRecord = try recordResult.resolve()
                                updatedRecord.upsertJSON = [ String : Any? ]()
                                dispatchQueue.sync {
                                    updatedRecords.append( updatedRecord )
                                }
                                entityResponse.setData(data: updatedRecord)
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
                    bulkResponse.setData( data : updatedRecords )
                    completion( .success( updatedRecords, bulkResponse ) )
                }
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getDeletedRecords( modifiedSince : String?, page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        self.getDeletedRecords( type : RequestParamValues.all, modifiedSince : modifiedSince, page : page, perPage : perPage ) { ( resultType ) in
            completion( resultType )
        }
    }
    
    internal func getRecycleBinRecords( modifiedSince : String?, page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        self.getDeletedRecords( type : RequestParamValues.recycle, modifiedSince : modifiedSince, page : page, perPage : perPage ) { ( resultType ) in
            completion( resultType )
        }
    }
    
    internal func getPermanentlyDeletedRecords( modifiedSince : String?, page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        self.getDeletedRecords( type : RequestParamValues.permanent, modifiedSince : modifiedSince, page : page, perPage : perPage ) { ( resultType ) in
            completion( resultType )
        }
    }

    private func getDeletedRecords( type : String, modifiedSince : String?, page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
		setUrlPath(urlPath : "\( self.module.apiName )/deleted")
		setRequestMethod(requestMethod : .GET )
		addRequestParam(param: RequestParamKeys.type , value: type )
        if ( modifiedSince.notNilandEmpty)
        {
            addRequestHeader( header : RequestParamKeys.ifModifiedSince, value : modifiedSince! )
        }
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
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_JSON_NIL_MSG)")
                        completion( .failure( ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message : ErrorMessage.RESPONSE_JSON_NIL_MSG, details : nil ) ) )
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
    internal func addTags( records : [ ZCRMRecord ], tags : [ String ], overWrite : Bool?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.DATA)
        var idString : String = String()
        for index in 0..<records.count
        {
            idString.append( String( records[ index ].id ) )
            if ( index != ( records.count - 1 ) )
            {
                idString.append(",")
            }
        }
        var tagNamesString : String = String()
        for index in 0..<tags.count
        {
            tagNamesString.append( tags[ index ] )
            if ( index != ( tags.count - 1 ) )
            {
                tagNamesString.append(",")
            }
        }
        
        setUrlPath(urlPath: "\(self.module.apiName)/actions/add_tags")
        setRequestMethod(requestMethod: .POST)
        addRequestParam(param: RequestParamKeys.ids, value: idString)
        addRequestParam(param: RequestParamKeys.tagNames, value: tagNamesString)
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
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_JSON_NIL_MSG)")
                            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_JSON_NIL_MSG, details : nil ) ) )
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

    internal func removeTags( records : [ ZCRMRecord ], tags : [ String ], completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.DATA)
        var idString : String = String()
        for index in 0..<records.count
        {
            idString.append( String( records[ index ].id ) )
            if ( index != ( records.count - 1 ) )
            {
                idString.append(",")
            }
        }
        var tagNamesString : String = String()
        for index in 0..<tags.count
        {
            tagNamesString.append( tags[ index ] )
            if ( index != ( tags.count - 1 ) )
            {
                tagNamesString.append(",")
            }
        }
        setUrlPath(urlPath: "\(self.module.apiName)/actions/remove_tags")
        setRequestMethod(requestMethod: .POST)
        addRequestParam(param: RequestParamKeys.ids, value: idString)
        addRequestParam(param: RequestParamKeys.tagNames, value: tagNamesString)
        
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
                            ZCRMLogger.logError( message : "\( ErrorCode.RESPONSE_NIL ) : \( ErrorMessage.RESPONSE_JSON_NIL_MSG )" )
                            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.RESPONSE_NIL, message : ErrorMessage.RESPONSE_JSON_NIL_MSG, details : nil ) ) )
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

fileprivate extension MassEntityAPIHandler
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
        static let name = "name"
        static let createdBy = "created_by"
        static let deletedBy = "deleted_by"
        static let displayName = "display_name"
        static let deletedTime = "deleted_time"
        static let tags = "tags"
        static let type = "type"
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


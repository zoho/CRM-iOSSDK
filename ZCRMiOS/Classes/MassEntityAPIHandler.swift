//
//  MassEntityAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 16/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class MassEntityAPIHandler : CommonAPIHandler
{
	private var module : ZCRMModule
    private var trashRecord : ZCRMTrashRecord = ZCRMTrashRecord( type : "" )
	
	init(module : ZCRMModule)
	{
		self.module = module
	}
	
	// MARK: - Handler Functions
    
    internal func createRecords( records : [ ZCRMRecord ], completion : @escaping( BulkAPIResponse?, [ ZCRMRecord ]?, Error? ) -> () )
    {
        setJSONRootKey( key : DATA )
        if(records.count > 100)
        {
            completion( nil, nil, ZCRMSDKError.MaxRecordCountExceeded( "Cannot process more than 100 records at a time." ) )
        }
        var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
        var dataArray : [[String:Any]] = [[String:Any]]()
        for record in records
        {
            dataArray.append(EntityAPIHandler(record: record).getZCRMRecordAsJSON() as Any as! [String : Any])
        }
        reqBodyObj[getJSONRootKey()] = dataArray
		
		setUrlPath(urlPath :  "/\(self.module.getAPIName())" )
		setRequestMethod(requestMethod : .POST )
		setRequestBody(requestBody : reqBodyObj )
		let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
        
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let bulkResponse = response
            {
                let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                var updatedRecords : [ZCRMRecord] = [ZCRMRecord]()
                for entityResponse in responses
                {
                    if(CODE_SUCCESS == entityResponse.getStatus())
                    {
                        let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                        let recordJSON : [String:Any] = entResponseJSON.getDictionary(key: "details")
                        let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.getAPIName(), recordId: recordJSON.getInt64(key: "id"))
                        EntityAPIHandler(record: record).setRecordProperties(recordDetails: recordJSON)
                        updatedRecords.append(record)
                        entityResponse.setData(data: record)
                    }
                    else
                    {
                        entityResponse.setData(data: nil)
                    }
                }
                bulkResponse.setData( data : updatedRecords )
                completion( bulkResponse, updatedRecords, nil )
            }
        }
    }
	
    internal func getRecords(cvId : Int64? ,fields : [String]? ,  sortByField : String? , sortOrder : SortOrder? , converted : Bool? , approved : Bool? , page : Int , per_page : Int , modifiedSince : String?, includePrivateFields : Bool, completion : @escaping( BulkAPIResponse?, [ ZCRMRecord ]?, Error? ) -> () )
	{
        setJSONRootKey( key : DATA )
		var records : [ZCRMRecord] = [ZCRMRecord]()
		setUrlPath(urlPath: "/\(self.module.getAPIName())" )
		setRequestMethod( requestMethod : .GET )
		if ( fields != nil && !fields!.isEmpty)
		{
			
			var fieldsStr : String = ""
			for field in fields!
			{
				if(!field.isEmpty)
				{
					fieldsStr += field + ","
				}
			}
			if(!fieldsStr.isEmpty)
			{
				addRequestParam(param: "fields" , value: String(fieldsStr.dropLast()) )
			}
			
		}
		if(cvId != nil)
		{
			addRequestParam(param:  "cvid" , value: String(cvId!) )
		}
		if(sortByField.notNilandEmpty)
		{
			addRequestParam(param: "sort_by" , value:  sortByField! )
		}
		if(sortOrder != nil)
		{
			addRequestParam(param: "sort_order" , value: sortOrder!.rawValue )
		}
		if(converted != nil)
		{
			addRequestParam(param: "converted" , value: converted!.description )
		}
		if(approved != nil)
		{
			addRequestParam(param: "approved" , value: approved!.description )
		}
        if ( modifiedSince.notNilandEmpty )
        {
         	addRequestHeader(header: "If-Modified-Since" , value: modifiedSince! )
        }
        if( includePrivateFields == true )
        {
            addRequestParam( param : "include", value : PRIVATE_FIELDS )
        }
		addRequestParam(param: "page" , value: String(page) )
		addRequestParam(param: "per_page" , value: String(per_page) )
		let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
		
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let bulkResponse = response
            {
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let recordsDetailsList:[[String:Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                    for recordDetails in recordsDetailsList
                    {
                        let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.getAPIName(), recordId: recordDetails.getInt64(key: "id"))
                        EntityAPIHandler(record: record).setRecordProperties(recordDetails: recordDetails)
                        records.append(record)
                    }
                    bulkResponse.setData(data: records)
                }
                completion( bulkResponse, records, nil )
            }
        }
		
	}
    
    internal func searchByText( searchText : String, page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMRecord ]?, Error? ) -> () )
    {
        self.searchRecords( searchKey : "word", searchValue : searchText, page : page, per_page : perPage ) { ( response, records, error ) in
            completion( response, records, error )
        }
    }
    
    internal func searchByCriteria( searchCriteria : String, page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMRecord ]?, Error? ) -> () )
    {
        self.searchRecords( searchKey : "criteria", searchValue : searchCriteria, page : page, per_page : perPage ) { ( response, records, error ) in
            completion( response, records, error )
        }
    }
    
    internal func searchByEmail( searchValue : String, page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMRecord ]?, Error? ) -> () )
    {
        self.searchRecords( searchKey : "email", searchValue : searchValue, page : page, per_page : perPage) { ( response, records, error ) in
            completion( response, records, error )
        }
    }
    
    internal func searchByPhone( searchValue : String, page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMRecord ]?, Error? ) -> () )
    {
        self.searchRecords( searchKey : "phone", searchValue : searchValue, page : page, per_page : perPage) { ( response, records, error ) in
            completion( response, records, error )
        }
    }
	
    internal func searchRecords( searchKey : String, searchValue : String, page : Int, per_page : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMRecord ]?, Error? ) -> () )
	{
        setJSONRootKey( key : DATA )
		var records : [ZCRMRecord] = [ZCRMRecord]()
		setUrlPath(urlPath : "/\(self.module.getAPIName())/search" )
		setRequestMethod(requestMethod : .GET )
		addRequestParam(param:  searchKey , value: searchValue.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
		addRequestParam(param: "page" , value: String(page) )
		addRequestParam(param: "per_page" , value: String(per_page) )
		let request : APIRequest = APIRequest(handler: self )
		
        print( "Request : \( request.toString() )" )
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let bulkResponse = response
            {
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let recordsList:[[String:Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                    for recordDetails in recordsList
                    {
                        let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.getAPIName(), recordId: recordDetails.getInt64(key: "id"))
                        EntityAPIHandler(record: record).setRecordProperties(recordDetails: recordDetails)
                        records.append(record)
                    }
                }
                bulkResponse.setData( data : records )
                completion( bulkResponse, records, nil )
            }
        }
	}
	
    internal func updateRecords( ids : [ Int64 ], fieldAPIName : String, value : Any?, completion : @escaping( BulkAPIResponse?, [ ZCRMRecord ]?, Error? ) -> () )
	{
        setJSONRootKey( key : DATA )
        if(ids.count > 100)
        {
            completion( nil, nil, ZCRMSDKError.MaxRecordCountExceeded("Cannot process more than 100 records at a time.") )
        }
		var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
		var dataArray : [[String:Any]] = [[String:Any]]()
		for id in ids
		{
			var dataJSON : [String:Any] = [String:Any]()
			dataJSON["id"] = String(id)
			dataJSON[fieldAPIName] = value
			dataArray.append(dataJSON)
		}
		reqBodyObj[getJSONRootKey()] = dataArray

		setUrlPath(urlPath : "/\(self.module.getAPIName())")
		setRequestMethod(requestMethod : .PUT )
		setRequestBody(requestBody : reqBodyObj )
		let request : APIRequest = APIRequest(handler: self )
		
        print( "Request : \( request.toString() )" )
		
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let bulkResponse = response
            {
                let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                var updatedRecords : [ZCRMRecord] = [ZCRMRecord]()
                for entityResponse in responses
                {
                    if(CODE_SUCCESS == entityResponse.getStatus())
                    {
                        let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                        let recordJSON : [String:Any] = entResponseJSON.getDictionary(key: "details")
                        let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.getAPIName(), recordId: recordJSON.getInt64( key : "id" ) )
                        EntityAPIHandler(record: record).setRecordProperties(recordDetails: recordJSON)
                        updatedRecords.append(record)
                        entityResponse.setData(data: record)
                    }
                    else
                    {
                        entityResponse.setData(data: nil)
                    }
                }
                bulkResponse.setData( data : updatedRecords )
                completion( bulkResponse, updatedRecords, nil )
            }
        }
	}
    
    internal func upsertRecords( records : [ ZCRMRecord ], completion : @escaping( BulkAPIResponse?, [ ZCRMRecord ]?, Error? ) -> () )
    {
        setJSONRootKey( key : DATA )
        if ( records.count > 100 )
        {
            completion( nil, nil, ZCRMSDKError.MaxRecordCountExceeded( "Cannot process more than 100 records at a time." ) )
        }
        var reqBodyObj : [ String : [ [ String : Any ] ] ] = [ String : [ [ String : Any ] ] ]()
        var dataArray : [ [ String : Any ] ] = [ [ String : Any ] ]()
        for record in records
        {
            let recordJSON = EntityAPIHandler(record : record ).getZCRMRecordAsJSON() as Any as! [String : Any]
            dataArray.append( recordJSON as Any as! [String : Any] )
        }
        reqBodyObj[getJSONRootKey()] = dataArray
		
		setUrlPath(urlPath:  "/\( self.module.getAPIName() )/upsert")
		setRequestMethod(requestMethod: .POST )
		setRequestBody(requestBody: reqBodyObj )
		let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
		
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let bulkResponse = response
            {
                let responses : [ EntityResponse ] = bulkResponse.getEntityResponses()
                var upsertRecords : [ ZCRMRecord ] = [ ZCRMRecord ]()
                for entityResponse in responses
                {
                    if(CODE_SUCCESS == entityResponse.getStatus())
                    {
                        let entResponseJSON : [ String : Any ] = entityResponse.getResponseJSON()
                        let recordJSON : [ String : Any ] = entResponseJSON.getDictionary( key : "details")
                        let record : ZCRMRecord = ZCRMRecord( moduleAPIName : self.module.getAPIName(), recordId : recordJSON.getInt64( key : "id" ) )
                        EntityAPIHandler( record : record ).setRecordProperties( recordDetails : recordJSON )
                        upsertRecords.append( record )
                        entityResponse.setData( data : record )
                    }
                    else
                    {
                        entityResponse.setData( data : nil )
                    }
                }
                bulkResponse.setData( data : upsertRecords )
                completion( bulkResponse, upsertRecords, nil )
            }
        }
    }
    
    internal func deleteRecords( ids : [ Int64 ], completion : @escaping( BulkAPIResponse?, Error? ) -> () )
    {
        if(ids.count > 100)
        {
            completion( nil, ZCRMSDKError.MaxRecordCountExceeded("Cannot process more than 100 records at a time.") )
        }
        var idsStr : String = "\(ids)"
        idsStr = idsStr.replacingOccurrences(of: " ", with: "")
        idsStr = idsStr.replacingOccurrences(of: "[", with: "")
        idsStr = idsStr.replacingOccurrences(of: "]", with: "")
		setUrlPath(urlPath : "/\(self.module.getAPIName())")
		setRequestMethod(requestMethod: .DELETE )
		addRequestParam(param:  "ids" , value: idsStr )
		let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
        
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, error )
            }
            if let bulkResponse = response
            {
                let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                for entityResponse in responses
                {
                    let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                    let recordJSON : [String:Any] = entResponseJSON.getDictionary(key: "details")
                    let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.getAPIName(), recordId: recordJSON.getInt64( key : "id" ) )
                    entityResponse.setData(data: record)
                }
                completion( bulkResponse, nil )
            }
        }
    }
    
    internal func getAllDeletedRecords( completion : @escaping( BulkAPIResponse?, [ ZCRMTrashRecord ]?, Error? ) -> () )
    {
        self.getDeletedRecords( type : "all") { ( response, deletedRecords, error ) in
            completion( response,deletedRecords, error )
        }
    }
    
    internal func getRecycleBinRecords( completion : @escaping( BulkAPIResponse?, [ ZCRMTrashRecord ]?, Error? ) -> () )
    {
        self.getDeletedRecords( type : "recycle") { ( response, deletedRecords, error ) in
            completion( response, deletedRecords, error )
        }
    }
    
    internal func getPermanentlyDeletedRecords( completion : @escaping( BulkAPIResponse?, [ ZCRMTrashRecord ]?, Error? ) -> () )
    {
        self.getDeletedRecords( type : "permanent") { ( response, deletedRecords, error ) in
            completion( response, deletedRecords, error )
        }
    }
    
    internal func getDeletedRecords( type : String, completion : @escaping( BulkAPIResponse?, [ ZCRMTrashRecord ]?, Error? ) -> () )
    {
		setUrlPath(urlPath : "/\( self.module.getAPIName() )/deleted")
		setRequestMethod(requestMethod : .GET )
		addRequestParam(param: "type" , value: type )
		let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let bulkResponse = response
            {
                let responses : [ EntityResponse ] = bulkResponse.getEntityResponses()
                var trashRecords : [ ZCRMTrashRecord ] = [ ZCRMTrashRecord ]()
                for entityResponse in responses
                {
                    let trashRecordDetails : [ String : Any ] = entityResponse.getResponseJSON()
                    self.trashRecord = ZCRMTrashRecord(type : trashRecordDetails.getString( key : "type" ), entityId : trashRecordDetails.getInt64( key : "id" ) )
                    self.setTrashRecordProperties( record : trashRecordDetails )
                    trashRecords.append( self.trashRecord )
                }
                bulkResponse.setData( data : trashRecords )
                completion( bulkResponse, trashRecords, nil )
            }
        }
    }
	
	// MARK: - Utility Functions
	
    internal func setTrashRecordProperties( record : [ String : Any ] )
    {
        for ( fieldAPIName, value ) in record
        {
            if( "Created_By" == fieldAPIName )
            {
                let createdBy : [ String : Any ] = value as! [ String : Any ]
                let createdByUser : ZCRMUser = ZCRMUser( userId : createdBy.getInt64( key : "id" ), userFullName : createdBy.getString( key : "name") )
                self.trashRecord.setCreatedBy( createdBy : createdByUser )
            }
            else if( "deleted_by" == fieldAPIName )
            {
                let deletedBy : [ String : Any ] = value as! [ String : Any ]
                let deletedByUser : ZCRMUser = ZCRMUser( userId : deletedBy.getInt64( key : "id" ), userFullName : deletedBy.getString( key : "name" ) )
                self.trashRecord.setDeletedBy( deletedBy : deletedByUser )
            }
            else if( "display_name" == fieldAPIName )
            {
                self.trashRecord.setDisplayName( name : record.getString( key : fieldAPIName ) )
            }
            else if( "deleted_time" == fieldAPIName )
            {
                self.trashRecord.setDisplayName( name : record.getString( key : fieldAPIName ) )
            }
        }
    }
    
}

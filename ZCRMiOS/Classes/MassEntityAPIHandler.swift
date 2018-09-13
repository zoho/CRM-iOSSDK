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
    
    internal func createRecords(records: [ZCRMRecord]) throws -> BulkAPIResponse
    {
        if(records.count > 100)
        {
            throw ZCRMSDKError.MaxRecordCountExceeded("Cannot process more than 100 records at a time.")
        }
        var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
        var dataArray : [[String:Any]] = [[String:Any]]()
        for record in records
        {
            dataArray.append(EntityAPIHandler(record: record).getZCRMRecordAsJSON() as Any as! [String : Any])
        }
        reqBodyObj["data"] = dataArray
		
		setUrlPath(urlPath :  "/\(self.module.getAPIName())" )
		setRequestMethod(requestMethod : .POST )
		setRequestBody(requestBody : reqBodyObj )
		let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
        
        let response : BulkAPIResponse = try request.getBulkAPIResponse()
        let responses : [EntityResponse] = response.getEntityResponses()
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
        return response
		
    }
	
	internal func getRecords(cvId : Int64? ,fields : [String]? ,  sortByField : String? , sortOrder : SortOrder? , converted : Bool? , approved : Bool? , page : Int , per_page : Int , modifiedSince : String? ) throws -> BulkAPIResponse
	{
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
		addRequestParam(param: "page" , value: String(page) )
		addRequestParam(param: "per_page" , value: String(per_page) )
		let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
		let response = try request.getBulkAPIResponse()
        let responseJSON = response.getResponseJSON()
        if responseJSON.isEmpty == false
        {
            let recordsDetailsList:[[String:Any]] = responseJSON.getArrayOfDictionaries(key: "data")
            for recordDetails in recordsDetailsList
            {
                let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.getAPIName(), recordId: recordDetails.getInt64(key: "id"))
                EntityAPIHandler(record: record).setRecordProperties(recordDetails: recordDetails)
                records.append(record)
            }
            response.setData(data: records)
        }
		return response
		
	}
    
    internal func searchByText( searchText : String, page : Int, perPage : Int ) throws -> BulkAPIResponse
    {
        return try self.searchRecords( searchKey : "word", searchValue : searchText, page : page, per_page : perPage )
    }
    
    internal func searchByCriteria( searchCriteria : String, page : Int, perPage : Int ) throws -> BulkAPIResponse
    {
        return try self.searchRecords( searchKey : "criteria", searchValue : searchCriteria, page : page, per_page : perPage )
    }
    
    internal func searchByEmail( searchValue : String, page : Int, perPage : Int ) throws -> BulkAPIResponse
    {
        return try self.searchRecords( searchKey : "email", searchValue : searchValue, page : page, per_page : perPage )
    }
    
    internal func searchByPhone( searchValue : String, page : Int, perPage : Int ) throws -> BulkAPIResponse
    {
        return try self.searchRecords( searchKey : "phone", searchValue : searchValue, page : page, per_page : perPage )
    }
	
    internal func searchRecords( searchKey : String, searchValue : String, page : Int, per_page : Int) throws -> BulkAPIResponse
	{
		var records : [ZCRMRecord] = [ZCRMRecord]()
		setUrlPath(urlPath : "/\(self.module.getAPIName())/search" )
		setRequestMethod(requestMethod : .GET )
		addRequestParam(param:  searchKey , value: searchValue.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
		addRequestParam(param: "page" , value: String(page) )
		addRequestParam(param: "per_page" , value: String(per_page) )
		let request : APIRequest = APIRequest(handler: self )
		
        print( "Request : \( request.toString() )" )
		let response = try request.getBulkAPIResponse()
        let responseJSON = response.getResponseJSON()
        if responseJSON.isEmpty == false
        {
            let recordsList:[[String:Any]] = responseJSON.getArrayOfDictionaries(key: "data")
            for recordDetails in recordsList
            {
                let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.getAPIName(), recordId: recordDetails.getInt64(key: "id"))
                EntityAPIHandler(record: record).setRecordProperties(recordDetails: recordDetails)
                records.append(record)
            }
        }
		response.setData(data: records)
        return response
	}
	
	internal func updateRecords(ids: [Int64], fieldAPIName: String, value: Any?) throws -> BulkAPIResponse
	{
        if(ids.count > 100)
        {
            throw ZCRMSDKError.MaxRecordCountExceeded("Cannot process more than 100 records at a time.")
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
		reqBodyObj["data"] = dataArray

		setUrlPath(urlPath : "/\(self.module.getAPIName())")
		setRequestMethod(requestMethod : .PUT )
		setRequestBody(requestBody : reqBodyObj )
		let request : APIRequest = APIRequest(handler: self )
		
        print( "Request : \( request.toString() )" )
		
        let response : BulkAPIResponse = try request.getBulkAPIResponse()
        
        let responses : [EntityResponse] = response.getEntityResponses()
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
        return response
	}
    
    internal func upsertRecords( records : [ ZCRMRecord ] ) throws -> BulkAPIResponse
    {
        if ( records.count > 100 )
        {
            throw ZCRMSDKError.MaxRecordCountExceeded("Cannot process more than 100 records at a time.")
        }
        var reqBodyObj : [ String : [ [ String : Any ] ] ] = [ String : [ [ String : Any ] ] ]()
        var dataArray : [ [ String : Any ] ] = [ [ String : Any ] ]()
        for record in records
        {
            let recordJSON = EntityAPIHandler(record : record ).getZCRMRecordAsJSON() as Any as! [String : Any]
            dataArray.append( recordJSON as Any as! [String : Any] )
        }
        reqBodyObj["data"] = dataArray
		
		setUrlPath(urlPath:  "/\( self.module.getAPIName() )/upsert")
		setRequestMethod(requestMethod: .POST )
		setRequestBody(requestBody: reqBodyObj )
		let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
        
        let response : BulkAPIResponse = try request.getBulkAPIResponse()
        let responses : [ EntityResponse ] = response.getEntityResponses()
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
        return response
    }
    
    internal func deleteRecords(ids: [Int64] ) throws -> BulkAPIResponse
    {
        if(ids.count > 100)
        {
            throw ZCRMSDKError.MaxRecordCountExceeded("Cannot process more than 100 records at a time.")
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
        
        let response : BulkAPIResponse = try request.getBulkAPIResponse()
        
        let responses : [EntityResponse] = response.getEntityResponses()
        for entityResponse in responses
        {
            let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
            let recordJSON : [String:Any] = entResponseJSON.getDictionary(key: "details")
            let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.module.getAPIName(), recordId: recordJSON.getInt64( key : "id" ) )
            entityResponse.setData(data: record)
        }
        return response
    }
    
    internal func getAllDeletedRecords() throws -> BulkAPIResponse
    {
        return try self.getDeletedRecords( type : "all" )
    }
    
    internal func getRecycleBinRecords() throws -> BulkAPIResponse
    {
        return try self.getDeletedRecords( type : "recycle" )
    }
    
    internal func getPermanentlyDeletedRecords() throws -> BulkAPIResponse
    {
        return try self.getDeletedRecords( type : "permanent" )
    }
    
    internal func getDeletedRecords( type : String ) throws -> BulkAPIResponse
    {
		setUrlPath(urlPath : "/\( self.module.getAPIName() )/deleted")
		setRequestMethod(requestMethod : .GET )
		addRequestParam(param: "type" , value: type )
		let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
        
        let response : BulkAPIResponse = try request.getBulkAPIResponse()
        let responses : [ EntityResponse ] = response.getEntityResponses()
        var trashRecords : [ ZCRMTrashRecord ] = [ ZCRMTrashRecord ]()
        for entityResponse in responses
        {
            let trashRecordDetails : [ String : Any ] = entityResponse.getResponseJSON()
            self.trashRecord = ZCRMTrashRecord(type : trashRecordDetails.getString( key : "type" ), entityId : trashRecordDetails.getInt64( key : "id" ) )
            self.setTrashRecordProperties( record : trashRecordDetails )
            trashRecords.append( self.trashRecord )
        }
        response.setData( data : trashRecords )
        return response
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

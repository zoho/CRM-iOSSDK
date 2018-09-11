//
//  RelatedListAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 18/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class RelatedListAPIHandler : CommonAPIHandler
{
	private var parentRecord : ZCRMRecord
	private var relatedList : ZCRMModuleRelation
    private var junctionRecord : ZCRMJunctionRecord?
    
    private init( parentRecord : ZCRMRecord, relatedList : ZCRMModuleRelation, junctionRecord : ZCRMJunctionRecord? )
    {
        self.parentRecord = parentRecord
        self.relatedList = relatedList
        self.junctionRecord = junctionRecord
    }
	
	convenience init(parentRecord : ZCRMRecord, relatedList : ZCRMModuleRelation)
    {
        self.init(parentRecord: parentRecord, relatedList: relatedList, junctionRecord: nil)
	}
	
    convenience init( parentRecord : ZCRMRecord, junctionRecord : ZCRMJunctionRecord )
    {
        self.init(parentRecord: parentRecord, relatedList: ZCRMModuleRelation(parentRecord: parentRecord, junctionRecord: junctionRecord), junctionRecord: junctionRecord)
    }
    
    internal func getRecords(page : Int, per_page : Int, sortByField : String?, sortOrder : SortOrder?, modifiedSince : String? ) throws -> BulkAPIResponse
	{
		var records : [ZCRMRecord] = [ZCRMRecord]()
		setUrlPath(urlPath:  "/\(self.parentRecord.getModuleAPIName())/\(String(self.parentRecord.getId()))/\(self.relatedList.getAPIName())" )
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param:  "page" , value: String(page) )
		addRequestParam(param: "per_page", value: String(per_page) )
        if(sortByField.notNilandEmpty)
        {
			addRequestParam(param: "sort_by" , value: sortByField! )
        }
		if(sortOrder != nil )
		{
			addRequestParam(param: "sort_order" , value: sortOrder!.rawValue )
		}
        if ( modifiedSince.notNilandEmpty )
        {
			addRequestHeader(header: "If-Modified-Since" , value : modifiedSince! )
        }
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
		
        let response = try request.getBulkAPIResponse()

        let responseJSON = response.getResponseJSON()
        if responseJSON.isEmpty == false
        {
            let recordsList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : "data" )
            for recordDetails in recordsList
            {
                let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.parentRecord.getModuleAPIName(), recordId: recordDetails.optInt64(key: "id")!)
                EntityAPIHandler(record: record).setRecordProperties(recordDetails: recordDetails)
                records.append(record)
            }
            response.setData(data: records)
        }
        return response
	}
	
	internal func getNotes(page : Int, per_page : Int, sortByField : String?, sortOrder : SortOrder?, modifiedSince : String?) throws -> BulkAPIResponse
	{
		var notes : [ZCRMNote] = [ZCRMNote]()
		setUrlPath(urlPath:  "/\(self.parentRecord.getModuleAPIName())/\(String(self.parentRecord.getId()))/\(self.relatedList.getAPIName())" )
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param:  "page" , value: String(page) )
		addRequestParam(param: "per_page", value: String(per_page) )
        if(sortByField.notNilandEmpty)
        {
			addRequestParam(param: "sort_by" , value: sortByField! )
        }
		if(sortOrder != nil)
		{
			addRequestParam(param: "sort_order" , value: sortOrder!.rawValue )
		}
        if ( modifiedSince.notNilandEmpty)
        {
            addRequestHeader(header: "If-Modified-Since" , value : modifiedSince! )
        }
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
		
        let response = try request.getBulkAPIResponse()
		
        let responseJSON = response.getResponseJSON()
        if responseJSON.isEmpty == false
        {
            let notesList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : "data" )
            for noteDetails in notesList
            {
                notes.append( self.getZCRMNote( noteDetails : noteDetails, note : ZCRMNote( noteId : noteDetails.getInt64( key : "id" ) ) ) )
            }
            response.setData(data: notes)
        }
        return response
	}
	
	internal func getAllAttachmentsDetails(page : Int, per_page : Int, modifiedSince : String?) throws -> BulkAPIResponse
	{
		var attachments : [ZCRMAttachment] = [ZCRMAttachment]()
		setUrlPath(urlPath:  "/\(self.parentRecord.getModuleAPIName())/\(String(self.parentRecord.getId()))/\(self.relatedList.getAPIName())" )
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param:  "page" , value: String(page) )
		addRequestParam(param: "per_page", value: String(per_page) )
        if ( modifiedSince.notNilandEmpty)
        {
			addRequestHeader(header: "If-Modified-Since" , value : modifiedSince! )
        }
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
		
        let response = try request.getBulkAPIResponse()
		
        let responseJSON = response.getResponseJSON()
        if responseJSON.isEmpty == false
        {
            let attachmentsList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : "data" )
            for attachmentDetails in attachmentsList
            {
                attachments.append(self.getZCRMAttachment(attachmentDetails: attachmentDetails))
            }
            response.setData(data: attachments)
        }
        return response
	}
	
    internal func uploadAttachment( filePath : String ) throws -> APIResponse
    {
		
		setUrlPath(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String( self.parentRecord.getId()))/\(self.relatedList.getAPIName())" )
		setRequestMethod(requestMethod: .POST )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        let response = try request.uploadFile( filePath : filePath )
        
        let responseJSON = response.getResponseJSON()
        let respDataArr : [[String:Any?]] = responseJSON.getArrayOfDictionaries(key: "data")
        let respData : [String:Any?] = respDataArr[0]
        let recordDetails : [String:Any] = respData.getDictionary( key : "details" )
        response.setData(data: self.getZCRMAttachment(attachmentDetails: recordDetails))
        return response
    }
    
    internal func uploadLinkAsAttachment( attachmentURL : String ) throws -> APIResponse
    {
		setUrlPath(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String(self.parentRecord.getId()))/\(self.relatedList.getAPIName())" )
		addRequestParam(param:  "attachmentUrl" , value: attachmentURL )
		setRequestMethod(requestMethod: .POST )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        
        let response = try request.uploadLink()
        let responseJSONArray : [ [ String : Any ] ]  = response.getResponseJSON().getArrayOfDictionaries( key : "data" )
        let details = responseJSONArray[ 0 ].getDictionary( key : "details" )
        response.setData( data : self.getZCRMAttachment(attachmentDetails: details))
        return response
    }
    
	internal func downloadAttachment(attachmentId: Int64) throws -> FileAPIResponse
	{
		setUrlPath(urlPath:  "/\(self.parentRecord.getModuleAPIName())/\(String( self.parentRecord.getId()))/\(self.relatedList.getAPIName())/\(attachmentId)" )
		setRequestMethod(requestMethod: .GET )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
		return try request.downloadFile()
	}
    
    internal func deleteAttachment( attachmentId : Int64 ) throws -> APIResponse
    {
		setUrlPath(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String( self.parentRecord.getId()))/\(self.relatedList.getAPIName())/\(attachmentId)" )
		setRequestMethod(requestMethod: .DELETE )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        let response = try request.getAPIResponse()
        return response
    }
	
	internal func addNote(note : ZCRMNote) throws -> APIResponse
	{
		
		var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
		var dataArray : [[String:Any]] = [[String:Any]]()
		dataArray.append(self.getZCRMNoteAsJSON(note: note))
		reqBodyObj["data"] = dataArray
		setUrlPath(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String( self.parentRecord.getId()))/\(self.relatedList.getAPIName())" )
		setRequestMethod(requestMethod: .POST )
		setRequestBody(requestBody: reqBodyObj )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
		
		let response = try request.getAPIResponse()
		
        let responseJSON = response.getResponseJSON()
		let respDataArr : [[String:Any?]] = responseJSON.optArrayOfDictionaries(key: "data")!
		let respData : [String:Any?] = respDataArr[0]
		let recordDetails : [String:Any] = respData.getDictionary( key : "details" )
        response.setData(data: self.getZCRMNote(noteDetails: recordDetails, note: note))
        return response
	}
	
	internal func updateNote(note: ZCRMNote) throws -> APIResponse
	{
        if note.getId() == nil
        {
            throw ZCRMSDKError.ProcessingError("Note ID MUST NOT be nil")
        }
        let noteId : String = String( note.getId()! )
		var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
		var dataArray : [[String:Any]] = [[String:Any]]()
		dataArray.append(self.getZCRMNoteAsJSON(note: note))
		reqBodyObj["data"] = dataArray
		setUrlPath(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String(self.parentRecord.getId()))/\(self.relatedList.getAPIName())/\(noteId)")
		setRequestMethod(requestMethod: .PUT )
		setRequestBody(requestBody: reqBodyObj)
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
		
		let response = try request.getAPIResponse()
        
        let responseJSON = response.getResponseJSON()
        let respDataArr : [[String:Any?]] = responseJSON.optArrayOfDictionaries(key: "data")!
        let respData : [String:Any?] = respDataArr[0]
        let recordDetails : [String:Any] = respData.getDictionary(key: "details")
        response.setData(data: self.getZCRMNote(noteDetails: recordDetails, note: note))
        return response
	}
	
	internal func deleteNote(note: ZCRMNote) throws -> APIResponse
	{
        if note.getId() == nil
        {
            throw ZCRMSDKError.ProcessingError("Note ID MUST NOT be nil")
        }
        let noteId : String = String( note.getId()! )
		setUrlPath(urlPath:  "/\(self.parentRecord.getModuleAPIName())/\(String(self.parentRecord.getId()))/\(self.relatedList.getAPIName())/\( noteId )" )
		setRequestMethod(requestMethod: .DELETE )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
		return try request.getAPIResponse()
	}
	
	internal func getZCRMAttachment(attachmentDetails : [String:Any?]) -> ZCRMAttachment
	{
        var createdBy : ZCRMUser?
		let attachment : ZCRMAttachment = ZCRMAttachment(parentRecord: self.parentRecord, attachmentId: attachmentDetails.getInt64(key: "id"))
        if ( attachmentDetails.hasValue( forKey : "File_Name" ) )
        {
            let fileName : String = attachmentDetails.optString( key : "File_Name" )!
            attachment.setFileName( fileName : fileName )
            let fileType = fileName.pathExtension()
            attachment.setFileType(type: fileType)
        }
        if(attachmentDetails.hasValue(forKey: "Size"))
        {
            attachment.setFileSize(size: Int64(attachmentDetails.optInt64(key: "Size")!))
        }
        if ( attachmentDetails.hasValue( forKey : "Created_By" ) )
        {
            let createdByDetails : [String:Any] = attachmentDetails.getDictionary(key: "Created_By")
            createdBy = ZCRMUser(userId: createdByDetails.getInt64(key: "id"), userFullName: createdByDetails.getString(key: "name"))
            attachment.setCreatedByUser(createdByUser: createdBy)
            attachment.setCreatedTime(createdTime: attachmentDetails.getString(key: "Created_Time"))
        }
        if(attachmentDetails.hasValue(forKey: "Modified_By"))
        {
            let modifiedByDetails : [String:Any] = attachmentDetails.getDictionary(key: "Modified_By")
            let modifiedBy : ZCRMUser = ZCRMUser(userId: modifiedByDetails.getInt64(key: "id"), userFullName: modifiedByDetails.getString(key: "name"))
            attachment.setModifiedByUser(modifiedByUser: modifiedBy)
            attachment.setModifiedTime(modifiedTime: attachmentDetails.getString(key: "Modified_Time"))
        }
		if(attachmentDetails.hasValue(forKey: "Owner"))
		{
			let ownerDetails : [String:Any] = attachmentDetails.getDictionary(key: "Owner")
			let owner : ZCRMUser = ZCRMUser(userId: ownerDetails.getInt64(key: "id"), userFullName: ownerDetails.getString(key: "name"))
			attachment.setOwner(owner: owner)
		}
        else if( createdBy != nil )
        {
            attachment.setOwner( owner : createdBy! )
        }
		return attachment
	}
	
    internal func getZCRMNote(noteDetails : [String:Any?], note : ZCRMNote) -> ZCRMNote
	{
        var createdBy : ZCRMUser?
		note.setId( noteId : noteDetails.getInt64( key : "id" ) )
        if ( noteDetails.hasValue( forKey : "Note_Title" ) )
        {
            note.setTitle( title : noteDetails.getString( key : "Note_Title" ) )
        }
        if ( noteDetails.hasValue( forKey : "Note_Content" ) )
        {
            note.setContent( content : noteDetails.getString( key : "Note_Content" ) )
        }
        if ( noteDetails.hasValue( forKey : "Created_By" ) )
        {
            let createdByDetails : [String:Any] = noteDetails.getDictionary(key: "Created_By")
            createdBy = ZCRMUser(userId: createdByDetails.getInt64(key: "id"), userFullName: createdByDetails.getString(key: "name"))
            note.setCreatedByUser(createdByUser: createdBy)
            note.setCreatedTime(createdTime: noteDetails.getString(key: "Created_Time"))
        }
        if ( noteDetails.hasValue( forKey : "Modified_By" ) )
        {
            let modifiedByDetails : [String:Any] = noteDetails.getDictionary( key : "Modified_By" )
            let modifiedBy : ZCRMUser = ZCRMUser(userId: modifiedByDetails.getInt64(key: "id"), userFullName: modifiedByDetails.getString(key: "name"))
            note.setModifiedByUser(modifiedByUser: modifiedBy)
            note.setModifiedTime(modifiedTime: noteDetails.getString(key: "Modified_Time"))
        }
        if( noteDetails.hasValue( forKey: "Owner" ) )
        {
            let ownerDetails : [String:Any] = noteDetails.getDictionary(key: "Owner")
            let owner : ZCRMUser = ZCRMUser(userId: ownerDetails.getInt64(key: "id"), userFullName: ownerDetails.getString(key: "name"))
            note.setOwner(owner: owner)
        }
        else if( createdBy != nil )
        {
            note.setOwner( owner : createdBy! )
        }
        if(noteDetails.hasValue(forKey: "$attachments"))
        {
            let attachmentsList : [[String:Any?]] = noteDetails.getArrayOfDictionaries(key: "$attachments")
            for attachmentDetails in attachmentsList
            {
                note.addAttachment(attachment: self.getZCRMAttachment(attachmentDetails: attachmentDetails))
            }
        }
		return note
	}
	
	internal func getZCRMNoteAsJSON(note : ZCRMNote) -> [String:Any]
	{
		var noteJSON : [String:Any] = [String:Any]()
		noteJSON["Note_Title"] = note.getTitle()
		noteJSON["Note_Content"] = note.getContent()
		return noteJSON
	}
    
    internal func addRelation() throws -> APIResponse
    {
		
        var reqBodyObj : [ String : [ [ String : Any ] ] ] = [ String : [ [ String : Any ] ] ]()
        var dataArray : [ [ String : Any ] ] = [ [ String : Any ] ]()
        if( self.junctionRecord!.getRelatedDetails() != nil )
        {
             dataArray.append( self.getRelationDetailsAsJSON( releatedDetails : self.junctionRecord!.getRelatedDetails()! ) as Any as! [ String : Any ] )
        }
        else
        {
            dataArray.append( [ String : Any ]() )
        }
        reqBodyObj["data"] = dataArray
		setUrlPath(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(self.parentRecord.getId())/\(self.junctionRecord!.getApiName())/\(self.junctionRecord!.getId())" )
		setRequestMethod(requestMethod: .PUT )
		setRequestBody(requestBody: reqBodyObj )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        return try request.getAPIResponse()
    }
    
    private func getRelationDetailsAsJSON( releatedDetails : [ String : Any ] ) -> [ String : Any? ]
    {
        var relatedDetailsJSON : [ String : Any ] = [ String : Any ]()
        for key in releatedDetails.keys
        {
            let value = releatedDetails[ key ]
            relatedDetailsJSON[ key ] = value
        }
        return relatedDetailsJSON
    }
    
    internal func deleteRelation() throws -> APIResponse
    {
		setUrlPath(urlPath: "/\(self.parentRecord.getModuleAPIName())/\( String( self.parentRecord.getId() ) )/\(self.junctionRecord!.getApiName())/\(self.junctionRecord!.getId())" )
		setRequestMethod(requestMethod: .DELETE )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        return try request.getAPIResponse()
    }
    
}

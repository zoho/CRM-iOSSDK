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
    
    internal func getRecords(page : Int, per_page : Int, sortByField : String?, sortOrder : SortOrder?, modifiedSince : String?, completion : @escaping( BulkAPIResponse?, [ ZCRMRecord ]?, Error? ) -> () )
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
                    let recordsList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    for recordDetails in recordsList
                    {
                        let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.parentRecord.getModuleAPIName(), recordId: recordDetails.optInt64(key: "id")!)
                        EntityAPIHandler(record: record).setRecordProperties(recordDetails: recordDetails)
                        records.append(record)
                    }
                    bulkResponse.setData(data: records)
                }
                completion( bulkResponse, records, nil )
            }
        }
	}
	
    internal func getNotes( page : Int, per_page : Int, sortByField : String?, sortOrder : SortOrder?, modifiedSince : String?, completion : @escaping( BulkAPIResponse?, [ ZCRMNote ]?, Error? ) -> () )
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
                    let notesList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    for noteDetails in notesList
                    {
                        notes.append( self.getZCRMNote( noteDetails : noteDetails, note : ZCRMNote( noteId : noteDetails.getInt64( key : "id" ) ) ) )
                    }
                    bulkResponse.setData(data: notes)
                }
                completion( bulkResponse, notes, nil )
            }
        }
	}
	
    internal func getAllAttachmentsDetails( page : Int, per_page : Int, modifiedSince : String?, completion : @escaping( BulkAPIResponse?, [ ZCRMAttachment ]?, Error? ) -> () )
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
                    let attachmentsList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    for attachmentDetails in attachmentsList
                    {
                        attachments.append(self.getZCRMAttachment(attachmentDetails: attachmentDetails))
                    }
                    bulkResponse.setData(data: attachments)
                }
                completion( bulkResponse, attachments, nil )
            }
        }
	}
	
    internal func uploadAttachment( filePath : String, completion : @escaping( APIResponse?, ZCRMAttachment?, Error? ) -> () )
    {
		
		setUrlPath(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String( self.parentRecord.getId()))/\(self.relatedList.getAPIName())" )
		setRequestMethod(requestMethod: .POST )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.uploadFile( filePath : filePath, completion : { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let response = resp
            {
                let responseJSON = response.getResponseJSON()
                let respDataArr : [[String:Any?]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                let respData : [String:Any?] = respDataArr[0]
                let recordDetails : [String:Any] = respData.getDictionary( key : "details" )
                let attachment = self.getZCRMAttachment(attachmentDetails: recordDetails)
                response.setData(data: attachment)
                completion( response, attachment, nil )
            }
        })
    }
    
    internal func uploadLinkAsAttachment( attachmentURL : String, completion : @escaping( APIResponse?, ZCRMAttachment?, Error? ) -> () )
    {
		
		setUrlPath(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String(self.parentRecord.getId()))/\(self.relatedList.getAPIName())" )
		addRequestParam(param:  "attachmentUrl" , value: attachmentURL )
		setRequestMethod(requestMethod: .POST )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.uploadLink { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let response = resp
            {
                let responseJSONArray : [ [ String : Any ] ]  = response.getResponseJSON().getArrayOfDictionaries( key : self.getJSONRootKey() )
                let details = responseJSONArray[ 0 ].getDictionary( key : "details" )
                let attachment = self.getZCRMAttachment(attachmentDetails: details)
                response.setData( data : attachment )
                completion( response, attachment, nil )
            }
        }
    }
    
    internal func downloadAttachment( attachmentId : Int64, completion : @escaping( FileAPIResponse?, Error? ) -> () )
	{
		
		setUrlPath(urlPath:  "/\(self.parentRecord.getModuleAPIName())/\(String( self.parentRecord.getId()))/\(self.relatedList.getAPIName())/\(attachmentId)" )
		setRequestMethod(requestMethod: .GET )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.downloadFile { ( response, error ) in
            completion( response, error )
        }
	}
    
    internal func deleteAttachment( attachmentId : Int64, completion : @escaping( APIResponse?, Error? ) -> () )
    {
		setUrlPath(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String( self.parentRecord.getId()))/\(self.relatedList.getAPIName())/\(attachmentId)" )
		setRequestMethod(requestMethod: .DELETE )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( response, error ) in
            completion( response, error )
        }
    }
	
    internal func addNote( note : ZCRMNote, completion : @escaping( APIResponse?, ZCRMNote?, Error? ) -> () )
	{
		var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
		var dataArray : [[String:Any]] = [[String:Any]]()
        dataArray.append( self.getZCRMNoteAsJSON(note: note) )
		reqBodyObj[getJSONRootKey()] = dataArray

        setUrlPath(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String( self.parentRecord.getId()))/\(self.relatedList.getAPIName())" )
		setRequestMethod(requestMethod: .POST )
		setRequestBody(requestBody: reqBodyObj )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
		
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let response = resp
            {
                let responseJSON = response.getResponseJSON()
                let respDataArr : [[String:Any?]] = responseJSON.optArrayOfDictionaries(key: self.getJSONRootKey())!
                let respData : [String:Any?] = respDataArr[0]
                let recordDetails : [String:Any] = respData.getDictionary( key : "details" )
                let note = self.getZCRMNote(noteDetails: recordDetails, note: note)
                response.setData(data: note )
                completion( response, note, nil )
            }
        }
	}
	
    internal func updateNote( note : ZCRMNote, completion : @escaping( APIResponse?, ZCRMNote?, Error? ) -> () )
	{
        if note.getId() == nil
        {
            completion( nil, nil, ZCRMSDKError.ProcessingError( "Note ID MUST NOT be nil" ) )
        }
        let noteId : String = String( note.getId()! )
		var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
		var dataArray : [[String:Any]] = [[String:Any]]()
		dataArray.append(self.getZCRMNoteAsJSON(note: note))
		reqBodyObj[getJSONRootKey()] = dataArray
		
		setUrlPath(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String(self.parentRecord.getId()))/\(self.relatedList.getAPIName())/\(noteId)")
		setRequestMethod(requestMethod: .PUT )
		setRequestBody(requestBody: reqBodyObj)
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
		
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let response = resp
            {
                let responseJSON = response.getResponseJSON()
                let respDataArr : [[String:Any?]] = responseJSON.optArrayOfDictionaries(key: self.getJSONRootKey())!
                let respData : [String:Any?] = respDataArr[0]
                let recordDetails : [String:Any] = respData.getDictionary(key: "details")
                let updatedNote = self.getZCRMNote(noteDetails: recordDetails, note: note)
                response.setData(data: updatedNote )
                completion( response, updatedNote, nil )
            }
        }
	}
	
    internal func deleteNote( note : ZCRMNote, completion : @escaping( APIResponse?, Error? ) -> () )
	{
        if note.getId() == nil
        {
            completion( nil, ZCRMSDKError.ProcessingError( "Note ID MUST NOT be nil" ) )
        }
        let noteId : String = String( note.getId()! )
		setUrlPath(urlPath:  "/\(self.parentRecord.getModuleAPIName())/\(String(self.parentRecord.getId()))/\(self.relatedList.getAPIName())/\( noteId )" )
		setRequestMethod(requestMethod: .DELETE )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( response, error ) in
            completion( response, error )
        }
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
    
    internal func addRelation( completion : @escaping( APIResponse?, Error? ) -> () )
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
        reqBodyObj[getJSONRootKey()] = dataArray

		setUrlPath(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(self.parentRecord.getId())/\(self.junctionRecord!.getApiName())/\(self.junctionRecord!.getId())" )
		setRequestMethod(requestMethod: .PUT )
		setRequestBody(requestBody: reqBodyObj )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
		
        request.getAPIResponse { ( response, error ) in
            completion( response, error )
        }
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
    
    internal func deleteRelation( completion : @escaping( APIResponse?, Error? ) -> () )
    {

		setUrlPath(urlPath: "/\(self.parentRecord.getModuleAPIName())/\( String( self.parentRecord.getId() ) )/\(self.junctionRecord!.getApiName())/\(self.junctionRecord!.getId())" )
		setRequestMethod(requestMethod: .DELETE )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( response, error ) in
            completion( response, error )
        }
    }
    
    internal override func getJSONRootKey() -> String
    {
        return DATA
    }
    
}

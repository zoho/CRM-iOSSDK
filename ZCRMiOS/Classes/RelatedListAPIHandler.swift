//
//  RelatedListAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 18/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class RelatedListAPIHandler : CommonAPIHandler
{
	private var parentRecord : ZCRMRecordDelegate
	private var relatedList : ZCRMModuleRelation?
    private var junctionRecord : ZCRMJunctionRecord?
    
    private init( parentRecord : ZCRMRecordDelegate, relatedList : ZCRMModuleRelation?, junctionRecord : ZCRMJunctionRecord? )
    {
        self.parentRecord = parentRecord
        self.relatedList = relatedList
        self.junctionRecord = junctionRecord
    }
	
    convenience init(parentRecord : ZCRMRecordDelegate, relatedList : ZCRMModuleRelation)
    {
        self.init(parentRecord: parentRecord, relatedList: relatedList, junctionRecord: nil)
    }
    
    convenience init( parentRecord : ZCRMRecordDelegate, junctionRecord : ZCRMJunctionRecord )
    {
        self.init(parentRecord: parentRecord, relatedList: nil, junctionRecord: junctionRecord)
    }

    internal func getRecords(page : Int, per_page : Int, sortByField : String?, sortOrder : SortOrder?, modifiedSince : String?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
	{
		var records : [ZCRMRecord] = [ZCRMRecord]()
        if let relatedList = self.relatedList
        {
            setUrlPath(urlPath:  "/\(self.parentRecord.moduleAPIName)/\(String(self.parentRecord.recordId))/\(relatedList.apiName)" )
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
            
            request.getBulkAPIResponse { ( resultType ) in
                do{
                    let bulkResponse = try resultType.resolve()
                    let responseJSON = bulkResponse.getResponseJSON()
                    if responseJSON.isEmpty == false
                    {
                        let recordsList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                        for recordDetails in recordsList
                        {
//                            let record : ZCRMRecord = ZCRMRecord(moduleAPIName: relatedList.getAPIName(), recordId: recordDetails.optInt64(key: "id")!)
                            let record : ZCRMRecord = ZCRMRecord(moduleAPIName: relatedList.apiName)
                            EntityAPIHandler(record: record).setRecordProperties(recordDetails: recordDetails)
                            records.append(record)
                        }
                        bulkResponse.setData(data: records)
                        completion( .success( records, bulkResponse ) )
                    }
                    else
                    {
                        completion( .failure( ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message : ErrorMessage.RESPONSE_NIL_MSG ) ) )
                    }
                }
                catch{
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Related list MUST NOT be nil" ) ) )
        }
	}

    internal func getNotes( page : Int, per_page : Int, sortByField : String?, sortOrder : SortOrder?, modifiedSince : String?, completion : @escaping( Result.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> () )
	{
        if let relatedList = self.relatedList
        {
            var notes : [ZCRMNote] = [ZCRMNote]()
            setUrlPath(urlPath:  "/\(self.parentRecord.moduleAPIName)/\(String(self.parentRecord.recordId))/\(relatedList.apiName)" )
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
            
            request.getBulkAPIResponse { ( resultType ) in
                do{
                    let bulkResponse = try resultType.resolve()
                    let responseJSON = bulkResponse.getResponseJSON()
                    if responseJSON.isEmpty == false
                    {
                        let notesList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                        for noteDetails in notesList
                        {
                            notes.append( self.getZCRMNote(noteDetails: noteDetails))
                        }
                        bulkResponse.setData(data: notes)
                        completion( .success( notes, bulkResponse ) )
                    }
                    else
                    {
                        completion( .failure( ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message : ErrorMessage.RESPONSE_NIL_MSG ) ) )
                    }
                }
                catch{
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Related list MUST NOT be nil" ) ) )
        }
	}

    internal func getAllAttachmentsDetails( page : Int, per_page : Int, modifiedSince : String?, completion : @escaping( Result.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> () )
	{
        if let relatedList = self.relatedList
        {
            var attachments : [ZCRMAttachment] = [ZCRMAttachment]()
            setUrlPath(urlPath:  "/\(self.parentRecord.moduleAPIName)/\(String(self.parentRecord.recordId))/\(relatedList.apiName)" )
            setRequestMethod(requestMethod: .GET )
            addRequestParam(param:  "page" , value: String(page) )
            addRequestParam(param: "per_page", value: String(per_page) )
            if ( modifiedSince.notNilandEmpty)
            {
                addRequestHeader(header: "If-Modified-Since" , value : modifiedSince! )
            }
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \( request.toString() )" )
            
            request.getBulkAPIResponse { ( resultType ) in
                do{
                    let bulkResponse = try resultType.resolve()
                    let responseJSON = bulkResponse.getResponseJSON()
                    if responseJSON.isEmpty == false
                    {
                        let attachmentsList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                        for attachmentDetails in attachmentsList
                        {
                            attachments.append(self.getZCRMAttachment(attachmentDetails: attachmentDetails))
                        }
                        bulkResponse.setData(data: attachments)
                        completion( .success( attachments, bulkResponse ) )
                    }
                    else
                    {
                        completion( .failure( ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message : ErrorMessage.RESPONSE_NIL_MSG ) ) )
                    }
                }
                catch{
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Related list MUST NOT be nil" ) ) )
        }
	}
	
    internal func uploadAttachmentWithPath( filePath : String, completion : @escaping(Result.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        if let relatedList = self.relatedList
        {
            setUrlPath(urlPath: "/\(self.parentRecord.moduleAPIName)/\(String( self.parentRecord.recordId))/\(relatedList.apiName)" )
            setRequestMethod(requestMethod: .POST )
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \( request.toString() )" )
            
            request.uploadFile( filePath : filePath, completion: { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let responseJSON = response.getResponseJSON()
                    let respDataArr : [[String:Any?]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                    let respData : [String:Any?] = respDataArr[0]
                    let recordDetails : [String:Any] = respData.getDictionary( key : APIConstants.DETAILS )
                    let attachment = self.getZCRMAttachment(attachmentDetails: recordDetails)
                    response.setData(data: attachment)
                    completion( .success( attachment, response ) )
                }
                catch{
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            })
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Related list MUST NOT be nil" ) ) )
        }
    }
    
    internal func uploadAttachmentWithData( fileName : String, data : Data, completion : @escaping( Result.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        if let relatedList = self.relatedList
        {
            setUrlPath(urlPath: "/\(self.parentRecord.moduleAPIName)/\(String( self.parentRecord.recordId))/\(relatedList.apiName)" )
            setRequestMethod(requestMethod: .POST )
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \( request.toString() )" )
            request.uploadFileWithData(fileName: fileName, data: data, completion: { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let responseJSON = response.getResponseJSON()
                    let respDataArr : [[String:Any?]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                    let respData : [String:Any?] = respDataArr[0]
                    let recordDetails : [String:Any] = respData.getDictionary( key : APIConstants.DETAILS )
                    let attachment = self.getZCRMAttachment(attachmentDetails: recordDetails)
                    response.setData(data: attachment)
                    completion( .success( attachment, response ) )
                }
                catch{
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            })
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Related list MUST NOT be nil" ) ) )
        }
    }

    internal func uploadLinkAsAttachment( attachmentURL : String, completion : @escaping( Result.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        if let relatedList = self.relatedList
        {
            setUrlPath(urlPath: "/\(self.parentRecord.moduleAPIName)/\(String(self.parentRecord.recordId))/\(relatedList.apiName)" )
            addRequestParam(param:  "attachmentUrl" , value: attachmentURL )
            setRequestMethod(requestMethod: .POST )
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \( request.toString() )" )
            
            request.uploadLink { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let responseJSONArray : [ [ String : Any ] ]  = response.getResponseJSON().getArrayOfDictionaries( key : self.getJSONRootKey() )
                    let details = responseJSONArray[ 0 ].getDictionary( key : APIConstants.DETAILS )
                    let attachment = self.getZCRMAttachment(attachmentDetails: details)
                    response.setData( data : attachment )
                    completion( .success( attachment, response ) )
                }
                catch{
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Related list MUST NOT be nil" ) ) )
        }
    }

    internal func downloadAttachment( attachmentId : Int64, completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
	{
        if let relatedList = self.relatedList
        {
            setUrlPath(urlPath:  "/\(self.parentRecord.moduleAPIName)/\(String( self.parentRecord.recordId))/\(relatedList.apiName)/\(attachmentId)" )
            setRequestMethod(requestMethod: .GET )
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \( request.toString() )" )
            
            request.downloadFile { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    completion( .success( response ) )
                }
                catch{
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Related list MUST NOT be nil" ) ) )
        }
	}

    internal func deleteAttachment( attachmentId : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        if let relatedList = self.relatedList
        {
            setUrlPath(urlPath: "/\(self.parentRecord.moduleAPIName)/\(String( self.parentRecord.recordId))/\(relatedList.apiName)/\(attachmentId)" )
            setRequestMethod(requestMethod: .DELETE )
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
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Related list MUST NOT be nil" ) ) )
        }
    }

    internal func addNote( note : ZCRMNote, completion : @escaping( Result.DataResponse< ZCRMNote, APIResponse > ) -> () )
	{
        if let relatedList = self.relatedList
        {
            var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
            var dataArray : [[String:Any]] = [[String:Any]]()
            dataArray.append( self.getZCRMNoteAsJSON(note: note) )
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath(urlPath: "/\(self.parentRecord.moduleAPIName)/\(String( self.parentRecord.recordId))/\(relatedList.apiName)" )
            setRequestMethod(requestMethod: .POST )
            setRequestBody(requestBody: reqBodyObj )
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \( request.toString() )" )
            
            request.getAPIResponse { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let responseJSON = response.getResponseJSON()
                    let respDataArr : [[String:Any?]] = responseJSON.optArrayOfDictionaries(key: self.getJSONRootKey())!
                    let respData : [String:Any?] = respDataArr[0]
                    let recordDetails : [String:Any] = respData.getDictionary( key : APIConstants.DETAILS )
                    let note = self.getZCRMNote(noteDetails: recordDetails)
                    response.setData(data: note )
                    completion( .success( note, response ) )
                }
                catch{
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Related list MUST NOT be nil" ) ) )
        }
	}

    internal func updateNote( note : ZCRMNote, completion : @escaping( Result.DataResponse< ZCRMNote, APIResponse > ) -> () )
	{
        if let relatedList = self.relatedList
        {
            if note.noteId == APIConstants.INT64_MOCK
            {
                completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Note ID MUST NOT be nil" ) ) )
            }
            else
            {
                let noteId : String = String( note.noteId )
                var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
                var dataArray : [[String:Any]] = [[String:Any]]()
                dataArray.append(self.getZCRMNoteAsJSON(note: note))
                reqBodyObj[getJSONRootKey()] = dataArray
                
                setUrlPath(urlPath: "/\(self.parentRecord.moduleAPIName)/\(String(self.parentRecord.recordId))/\(relatedList.apiName)/\(noteId)")
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
                        let updatedNote = self.getZCRMNote(noteDetails: recordDetails)
                        response.setData(data: updatedNote )
                        completion( .success( updatedNote, response ) )
                    }
                    catch{
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Related list MUST NOT be nil" ) ) )
        }
	}

    internal func deleteNote( noteId : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
	{
        if let relatedList = self.relatedList
        {
            let noteIdString : String = String( noteId )
            setUrlPath(urlPath:  "/\(self.parentRecord.moduleAPIName)/\(String(self.parentRecord.recordId))/\(relatedList.apiName)/\( noteIdString )" )
            setRequestMethod(requestMethod: .DELETE )
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
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Related list MUST NOT be nil" ) ) )
        }
	}
	
	private func getZCRMAttachment(attachmentDetails : [String:Any?]) -> ZCRMAttachment
	{
        let fileName : String = attachmentDetails.optString( key : ResponseJSONKeys.fileName )!
        let attachment : ZCRMAttachment = ZCRMAttachment(parentRecord: self.parentRecord, fileName: fileName)
        let fileType = fileName.pathExtension()
        if(attachmentDetails.hasValue(forKey: ResponseJSONKeys.size))
        {
            attachment.fileSize = Int64(attachmentDetails.getInt64(key: ResponseJSONKeys.size))
        }
        if ( attachmentDetails.hasValue( forKey : ResponseJSONKeys.createdBy ) )
        {
            let createdByDetails : [String:Any] = attachmentDetails.getDictionary(key: ResponseJSONKeys.createdBy)
            attachment.createdBy = getUserDelegate(userJSON : createdByDetails)
            attachment.createdTime = attachmentDetails.getString(key: ResponseJSONKeys.createdTime)
        }
        if(attachmentDetails.hasValue(forKey: ResponseJSONKeys.modifiedBy))
        {
            let modifiedByDetails : [String:Any] = attachmentDetails.getDictionary(key: ResponseJSONKeys.modifiedBy)
            attachment.modifiedBy = getUserDelegate(userJSON : modifiedByDetails)
            attachment.modifiedTime = attachmentDetails.getString(key: ResponseJSONKeys.modifiedTime)
        }
		if(attachmentDetails.hasValue(forKey: ResponseJSONKeys.owner))
		{
			let ownerDetails : [String:Any] = attachmentDetails.getDictionary(key: ResponseJSONKeys.owner)
            attachment.owner = getUserDelegate(userJSON : ownerDetails)
		}
        else if( attachment.createdBy.id != APIConstants.INT64_MOCK )
        {
            attachment.owner = attachment.createdBy
        }
        if( attachmentDetails.hasValue(forKey: ResponseJSONKeys.editable))
        {
            attachment.isEditable = attachmentDetails.getBoolean( key : ResponseJSONKeys.editable )
        }
        if( attachmentDetails.hasValue(forKey: ResponseJSONKeys.type))
        {
            attachment.type = attachmentDetails.getString( key : ResponseJSONKeys.type )
        }
        if( attachmentDetails.hasValue(forKey: ResponseJSONKeys.linkURL) )
        {
            attachment.linkURL = attachmentDetails.getString( key : ResponseJSONKeys.linkURL )
        }
		return attachment
	}
	
    private func getZCRMNote(noteDetails : [String:Any?]) -> ZCRMNote
	{
        let note : ZCRMNote = ZCRMNote(content: noteDetails.getString( key : ResponseJSONKeys.noteContent ), parentRecord: self.parentRecord)
        note.title = noteDetails.optString( key : ResponseJSONKeys.noteTitle )
        if ( noteDetails.hasValue( forKey : ResponseJSONKeys.createdBy ) )
        {
            let createdByDetails : [String:Any] = noteDetails.getDictionary(key: ResponseJSONKeys.createdBy)
            note.createdBy = getUserDelegate(userJSON : createdByDetails)
            note.createdTime = noteDetails.getString(key: ResponseJSONKeys.createdTime)
        }
        if ( noteDetails.hasValue( forKey : ResponseJSONKeys.modifiedBy ) )
        {
            let modifiedByDetails : [String:Any] = noteDetails.getDictionary( key : ResponseJSONKeys.modifiedBy )
            note.modifiedBy = getUserDelegate(userJSON : modifiedByDetails)
            note.modifiedTime = noteDetails.getString(key: ResponseJSONKeys.modifiedTime)
        }
        if( noteDetails.hasValue( forKey: ResponseJSONKeys.owner ) )
        {
            let ownerDetails : [String:Any] = noteDetails.getDictionary(key: ResponseJSONKeys.owner)
            note.owner = getUserDelegate(userJSON : ownerDetails)
        }
        else if( note.createdBy.id != APIConstants.INT_MOCK )
        {
            note.owner = note.createdBy
        }
        if(noteDetails.hasValue(forKey: ResponseJSONKeys.attachments))
        {
            let attachmentsList : [[String:Any?]] = noteDetails.getArrayOfDictionaries(key: ResponseJSONKeys.attachments)
            for attachmentDetails in attachmentsList
            {
                note.addAttachment(attachment: self.getZCRMAttachment(attachmentDetails: attachmentDetails))
            }
        }
        if(noteDetails.hasValue(forKey: ResponseJSONKeys.parentId))
        {
            let parentRecordList : [ String : Any ] = noteDetails.getDictionary(key: ResponseJSONKeys.parentId)
            if( parentRecordList.optString(key: ResponseJSONKeys.name) != nil)
            {
                note.parentRecord = ZCRMRecordDelegate(recordId: self.parentRecord.recordId, moduleAPIName: noteDetails.getString(key: ResponseJSONKeys.seModule))
            }
            else
            {
                note.parentRecord = ZCRMRecordDelegate(recordId: self.parentRecord.recordId, moduleAPIName: self.parentRecord.moduleAPIName)
            }
        }
		return note
	}
	
	private func getZCRMNoteAsJSON(note : ZCRMNote) -> [String:Any]
	{
		var noteJSON : [String:Any] = [String:Any]()
		noteJSON[ResponseJSONKeys.noteTitle] = note.title
		noteJSON[ResponseJSONKeys.noteContent] = note.content
		return noteJSON
	}

    internal func addRelation( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
		if let junctionRecord = self.junctionRecord
        {
            var reqBodyObj : [ String : [ [ String : Any ] ] ] = [ String : [ [ String : Any ] ] ]()
            var dataArray : [ [ String : Any ] ] = [ [ String : Any ] ]()
            if( junctionRecord.relatedDetails.isEmpty == false )
            {
                dataArray.append( self.getRelationDetailsAsJSON( releatedDetails : junctionRecord.relatedDetails ) as Any as! [ String : Any ] )
            }
            else
            {
                dataArray.append( [ String : Any ]() )
            }
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath(urlPath: "/\(self.parentRecord.moduleAPIName)/\(self.parentRecord.recordId)/\(junctionRecord.apiName)/\(junctionRecord.id)" )
            setRequestMethod(requestMethod: .PUT )
            setRequestBody(requestBody: reqBodyObj )
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
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Juction Record MUST NOT be nil" ) ) )
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

    internal func deleteRelation( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        if let junctionRecord = self.junctionRecord
        {
            setUrlPath(urlPath: "/\(self.parentRecord.moduleAPIName)/\( String( self.parentRecord.recordId ) )/\(junctionRecord.apiName)/\(junctionRecord.id))" )
            setRequestMethod(requestMethod: .DELETE )
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
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Juction Record MUST NOT be nil" ) ) )
        }
    }
    
    internal override func getJSONRootKey() -> String
    {
        return JSONRootKey.DATA
    }
    
}

extension RelatedListAPIHandler
{
    internal struct ResponseJSONKeys
    {
        static let id = "id"
        static let name = "name"
        static let fileName = "File_Name"
        static let size = "Size"
        static let createdBy = "Created_By"
        static let createdTime = "Created_Time"
        static let modifiedBy = "Modified_By"
        static let modifiedTime = "Modified_Time"
        static let owner = "Owner"
        static let editable = "$editable"
        static let type = "$type"
        static let linkURL = "$link_url"
        
        static let noteTitle = "Note_Title"
        static let noteContent = "Note_Content"
        static let attachments = "$attachments"
        static let parentId = "Parent_Id"
        static let seModule = "$se_module"
    }
}

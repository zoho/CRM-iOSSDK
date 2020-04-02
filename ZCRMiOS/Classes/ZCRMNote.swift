//
//  ZCRMNote.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 15/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMNote : ZCRMEntity
{
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    internal var isCreate : Bool = APIConstants.BOOL_MOCK
    public var title : String?
    public var content : String?
    public var owner : ZCRMUserDelegate = USER_MOCK{
        didSet
        {
            self.isOwnerSet = true
        }
    }
    internal var isOwnerSet : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var createdBy : ZCRMUserDelegate = USER_MOCK
    public internal( set ) var createdTime : String = APIConstants.STRING_MOCK
    public internal( set ) var modifiedBy : ZCRMUserDelegate = USER_MOCK
    public internal( set ) var modifiedTime : String = APIConstants.STRING_MOCK
    public var attachments : [ZCRMAttachment]?
    public internal(set) var parentRecord : ZCRMRecordDelegate = RECORD_MOCK
    public var isVoiceNote : Bool = APIConstants.BOOL_MOCK
    public var size : Int64?
    public var isEditable : Bool = APIConstants.BOOL_MOCK
	
    /// Initialize the instance of ZCRMNote with the given content
    ///
    /// - Parameter content: note content
    init( content : String )
	{
        self.content = content
	}
    
    init( content : String?, title : String )
    {
        self.content = content
        self.title = title
    }
    
    fileprivate init()
    { }
    
    /// To add attachment to the note(Only for internal use).
    ///
    /// - Parameter attachment: add attachment to the note
    public func addAttachment( attachment : ZCRMAttachment )
    {
        if self.attachments == nil
        {
            self.attachments = [ ZCRMAttachment ]()
        }
        self.attachments?.append( attachment )
    }
    
    fileprivate func removeAttachment( attachmentId : Int64 )
    {
        if let attachementList = attachments, !attachementList.isEmpty
        {
            var index : Int = Int()
            for count in 0..<attachementList.count
            {
                if attachementList[count].id == attachmentId
                {
                    index = count
                    break
                }
            }
            attachments?.remove(at: index)
        }
    }
    
    public func getAttachments( withParams : GETEntityRequestParams, completion : @escaping( Result.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> () )
    {
        if self.isCreate
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : Note ID MUST NOT be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "Entity ID MUST NOT be nil.", details : nil ) ) )
        }
        RelatedListAPIHandler( parentRecord : ZCRMRecordDelegate( id : self.id, moduleAPIName : DefaultModuleAPINames.NOTES ), relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : DefaultModuleAPINames.ATTACHMENTS ) ).getAttachments( withParams : withParams ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method getAttachments( withParams : GETEntityRequestParams, completion : ) instead" )
    public func getAttachments( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> () )
    {
        if self.isCreate
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : Note ID MUST NOT be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "Entity ID MUST NOT be nil.", details : nil ) ) )
        }
        var params = ZCRMQuery.getEntityRequestParams
        params.page = page
        params.perPage = perPage
        RelatedListAPIHandler( parentRecord : ZCRMRecordDelegate( id : self.id, moduleAPIName : DefaultModuleAPINames.NOTES ), relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : DefaultModuleAPINames.ATTACHMENTS ) ).getAttachments( withParams : params ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method getAttachments( withParams : GETEntityRequestParams, completion : ) instead" )
    public func getAttachments( page : Int, perPage : Int, modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> () )
    {
        if self.isCreate
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : Note ID MUST NOT be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "Entity ID MUST NOT be nil.", details : nil ) ) )
        }
        var params = ZCRMQuery.getEntityRequestParams
        params.page = page
        params.perPage = perPage
        params.modifiedSince = modifiedSince
        RelatedListAPIHandler( parentRecord : ZCRMRecordDelegate( id : self.id, moduleAPIName : DefaultModuleAPINames.NOTES ), relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : DefaultModuleAPINames.ATTACHMENTS ) ).getAttachments( withParams : params ) { ( result ) in
            completion( result )
        }
    }
    
    /// To upload a Attachment to the note.
    ///
    /// - Parameter filePath: file path of the attachment
    /// - Returns: APIResponse of the attachment upload
    /// - Throws: ZCRMSDKError if failed to upload the attachment
    public func uploadAttachment( filePath : String, completion : @escaping( Result.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : ZCRMRecordDelegate( id : self.id, moduleAPIName : DefaultModuleAPINames.NOTES ), relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : DefaultModuleAPINames.NOTES ) ).uploadAttachment( filePath : filePath, fileName : nil, fileData : nil, note : self ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadAttachment( fileRefId : String, filePath : String, attachmentUploadDelegate : ZCRMAttachmentUploadDelegate )
    {
        RelatedListAPIHandler( parentRecord : ZCRMRecordDelegate( id : self.id, moduleAPIName : DefaultModuleAPINames.NOTES ), relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : DefaultModuleAPINames.ATTACHMENTS )).uploadAttachment( fileRefId : fileRefId, filePath : filePath, fileName : nil, fileData : nil, note : self , attachmentUploadDelegate : attachmentUploadDelegate )
    }
    
    public func uploadAttachment( fileName : String, fileData : Data, completion : @escaping( Result.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : ZCRMRecordDelegate( id : self.id, moduleAPIName : DefaultModuleAPINames.NOTES ), relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : DefaultModuleAPINames.NOTES ) ).uploadAttachment( filePath : nil, fileName : fileName, fileData : fileData, note : self ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadAttachment( fileRefId : String, fileName : String, fileData : Data, attachmentUploadDelegate : ZCRMAttachmentUploadDelegate )
    {
        RelatedListAPIHandler( parentRecord : ZCRMRecordDelegate( id : self.id, moduleAPIName : DefaultModuleAPINames.NOTES ), relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : DefaultModuleAPINames.NOTES )).uploadAttachment( fileRefId : fileRefId, filePath : nil, fileName : fileName, fileData : fileData, note : self, attachmentUploadDelegate : attachmentUploadDelegate  )
    }
    
    /// To download a Attachment from the note, it returns file as data, then it can be converted to a file.
    ///
    /// - Parameter id: Id of the attachment to be downloaded
    /// - Returns: FileAPIResponse containing the data of the file downloaded.
    /// - Throws: ZCRMSDKError if failed to download the attachment
    public func downloadAttachment(id : Int64, completion : @escaping( Result.Response< FileAPIResponse > ) -> ())
    {
        RelatedListAPIHandler( parentRecord : ZCRMRecordDelegate( id : self.id, moduleAPIName : DefaultModuleAPINames.NOTES ), relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : DefaultModuleAPINames.NOTES ) ).downloadAttachment( attachmentId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadAttachment(id : Int64, fileDownloadDelegate : ZCRMFileDownloadDelegate ) throws
    {
        try RelatedListAPIHandler( parentRecord : ZCRMRecordDelegate( id : self.id, moduleAPIName : DefaultModuleAPINames.NOTES ), relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : DefaultModuleAPINames.NOTES ) ).downloadAttachment( attachmentId : id, fileDownloadDelegate : fileDownloadDelegate )
    }
    
    /// To delete a Attachment from the note.
    ///
    /// - Parameter id: Id of the attachment to be deleted
    /// - Returns: APIResponse of the file deleted.
    /// - Throws: ZCRMSDKError if failed to delete the attachment
    public func deleteAttachment( id : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : ZCRMRecordDelegate( id : self.id, moduleAPIName : DefaultModuleAPINames.NOTES ), relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : DefaultModuleAPINames.NOTES ) ).deleteAttachment( attachmentId : id ) { ( result ) in
            do
            {
                let resp = try result.resolve()
                if resp.getStatus() == APIConstants.CODE_SUCCESS
                {
                    self.removeAttachment(attachmentId: id)
                }
                completion( result )
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
}

extension ZCRMNote : NSCopying, Equatable
{
    public func copy( with zone : NSZone? = nil ) -> Any
    {
        let copy : ZCRMNote = ZCRMNote()
        copy.id = self.id
        copy.title = self.title
        copy.content = self.content
        copy.owner = self.owner
        copy.createdBy = self.createdBy
        copy.createdTime = self.createdTime
        copy.modifiedBy = self.modifiedBy
        copy.modifiedTime = self.modifiedTime
        copy.attachments = self.attachments
        copy.parentRecord = self.parentRecord
        copy.isEditable = self.isEditable
        copy.isVoiceNote = self.isVoiceNote
        copy.size = self.size
        copy.isCreate = self.isCreate
        return copy
    }
    
    public static func == (lhs: ZCRMNote, rhs: ZCRMNote) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.content == rhs.content &&
            lhs.owner == rhs.owner &&
            lhs.createdBy == rhs.createdBy &&
            lhs.createdTime == rhs.createdTime &&
            lhs.modifiedBy == rhs.modifiedBy &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.attachments == rhs.attachments &&
            lhs.parentRecord == rhs.parentRecord &&
            lhs.isEditable == rhs.isEditable &&
            lhs.isVoiceNote == rhs.isVoiceNote &&
            lhs.size == rhs.size
        return equals
    }
}

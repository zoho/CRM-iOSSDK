//
//  ZCRMNoteDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 14/09/18.
//

open class ZCRMNoteDelegate : ZCRMEntity
{
    var noteId : Int64
    var parentRecord : ZCRMRecordDelegate
    
    init( noteId : Int64, parentRecord : ZCRMRecordDelegate )
    {
        self.noteId = noteId
        self.parentRecord = parentRecord
    }
    
    public func getAllAttachmentsDetails( page : Int, per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> () )
    {
        if( self.noteId != APIConstants.INT64_MOCK )
        {
            RelatedListAPIHandler(parentRecord: parentRecord, relatedList: ZCRMModuleRelation(relatedListAPIName: "Notes", parentModuleAPIName: "Attachments")).getAllAttachmentsDetails(page: page, per_page: per_page, modifiedSince: nil) { ( result ) in
                completion( result )
            }
        }
    }
    
    public func getAllAttachmentsDetails( page : Int, per_page : Int, modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> () )
    {
        if( self.noteId != APIConstants.INT64_MOCK )
        {
            RelatedListAPIHandler(parentRecord: parentRecord, relatedList: ZCRMModuleRelation(relatedListAPIName: "Notes", parentModuleAPIName: "Attachments")).getAllAttachmentsDetails(page: page, per_page: per_page, modifiedSince: modifiedSince) { ( result ) in
                completion( result )
            }
        }
    }
    
    /// To upload a Attachment to the note.
    ///
    /// - Parameter filePath: file path of the attachment
    /// - Returns: APIResponse of the attachment upload
    /// - Throws: ZCRMSDKError if failed to upload the attachment
    public func uploadAttachmentWithPath( filePath : String, completion : @escaping( Result.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: "Notes").uploadAttachmentWithPath(ofParentRecord: ZCRMRecordDelegate(recordId: self.noteId, moduleAPIName: "Notes"), filePath: filePath) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadAttachmentWithData( fileName : String, data : Data, completion : @escaping( Result.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: "Notes").uploadAttachmentWithData( ofParentRecord: ZCRMRecordDelegate(recordId: self.noteId, moduleAPIName: "Notes"), fileName : fileName, data : data ) { ( result ) in
            completion( result )
        }
    }
    
    /// To download a Attachment from the note, it returns file as data, then it can be converted to a file.
    ///
    /// - Parameter attachmentId: Id of the attachment to be downloaded
    /// - Returns: FileAPIResponse containing the data of the file downloaded.
    /// - Throws: ZCRMSDKError if failed to download the attachment
    public func downloadAttachment(attachmentId : Int64, completion : @escaping( Result.Response< FileAPIResponse > ) -> ())
    {
        ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: "Notes").downloadAttachment(ofParentRecord: ZCRMRecordDelegate(recordId: self.noteId, moduleAPIName: "Notes"), attachmentId: attachmentId) { ( result ) in
            completion( result )
        }
    }
    
    /// To delete a Attachment from the note.
    ///
    /// - Parameter attachmentId: Id of the attachment to be deleted
    /// - Returns: APIResponse of the file deleted.
    /// - Throws: ZCRMSDKError if failed to delete the attachment
    public func deleteAttachment( attachmentId : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        ZCRMModuleRelation( relatedListAPIName : "Attachments", parentModuleAPIName : "Notes" ).deleteAttachment( ofParentRecord : ZCRMRecordDelegate(recordId: self.noteId, moduleAPIName: "Notes"), attachmentId : attachmentId ) { ( result ) in
            completion( result )
        }
    }
}


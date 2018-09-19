//
//  ZCRMNote.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 15/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMNote : ZCRMEntity
{
    var id : Int64 = APIConstants.INT64_MOCK
    public var title : String?
    public var content : String?
    var owner : ZCRMUserDelegate = USER_MOCK
    var createdBy : ZCRMUserDelegate = USER_MOCK
    var createdTime : String = APIConstants.STRING_MOCK
    var modifiedBy : ZCRMUserDelegate = USER_MOCK
    var modifiedTime : String = APIConstants.STRING_MOCK
    public var attachments : [ZCRMAttachment]?
    public var parentRecord : ZCRMRecordDelegate?
	
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
    
    /// To add attachment to the note(Only for internal use).
    ///
    /// - Parameter attachment: add attachment to the note
    func addAttachment( attachment : ZCRMAttachment )
    {
        if self.attachments == nil
        {
            self.attachments = [ ZCRMAttachment ]()
        }
        self.attachments?.append( attachment )
    }
    
    public func getAllAttachmentsDetails( page : Int, per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> () )
    {
        do
        {
            try idMockValueCheck( id : self.id )
            RelatedListAPIHandler(parentRecord: ZCRMRecordDelegate( recordId : self.id, moduleAPIName : "Notes" ), relatedList: ZCRMModuleRelation(relatedListAPIName: "Notes", parentModuleAPIName: "Attachments")).getAllAttachmentsDetails(page: page, per_page: per_page, modifiedSince: nil) { ( result ) in
                completion( result )
            }
        }
        catch
        {
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    public func getAllAttachmentsDetails( page : Int, per_page : Int, modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> () )
    {
        do
        {
            try idMockValueCheck( id : self.id )
            RelatedListAPIHandler(parentRecord: ZCRMRecordDelegate( recordId : self.id, moduleAPIName : "Notes" ), relatedList: ZCRMModuleRelation(relatedListAPIName: "Notes", parentModuleAPIName: "Attachments")).getAllAttachmentsDetails(page: page, per_page: per_page, modifiedSince: modifiedSince) { ( result ) in
                completion( result )
            }
        }
        catch
        {
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    /// To upload a Attachment to the note.
    ///
    /// - Parameter filePath: file path of the attachment
    /// - Returns: APIResponse of the attachment upload
    /// - Throws: ZCRMSDKError if failed to upload the attachment
    public func uploadAttachmentWithPath( filePath : String, completion : @escaping( Result.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: "Notes").uploadAttachmentWithPath(ofParentRecord: ZCRMRecordDelegate(recordId: self.id, moduleAPIName: "Notes"), filePath: filePath) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadAttachmentWithData( fileName : String, data : Data, completion : @escaping( Result.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: "Notes").uploadAttachmentWithData( ofParentRecord: ZCRMRecordDelegate(recordId: self.id, moduleAPIName: "Notes"), fileName : fileName, data : data ) { ( result ) in
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
        ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: "Notes").downloadAttachment(ofParentRecord: ZCRMRecordDelegate(recordId: self.id, moduleAPIName: "Notes"), attachmentId: attachmentId) { ( result ) in
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
        ZCRMModuleRelation( relatedListAPIName : "Attachments", parentModuleAPIName : "Notes" ).deleteAttachment( ofParentRecord : ZCRMRecordDelegate(recordId: self.id, moduleAPIName: "Notes"), attachmentId : attachmentId ) { ( result ) in
            completion( result )
        }
    }
}

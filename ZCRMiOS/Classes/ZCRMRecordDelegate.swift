//
//  ZCRMRecordDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 13/09/18.
//

open class ZCRMRecordDelegate : ZCRMEntity
{
    public var recordId : Int64
    var moduleAPIName : String
    
    init ( recordId : Int64, moduleAPIName : String )
    {
        self.recordId = recordId
        self.moduleAPIName = moduleAPIName
    }
    
    public func newAttachment() -> ZCRMAttachment
    {
        return ZCRMAttachment(parentRecord: self)
    }
    
    public func newNote( content : String ) -> ZCRMNote
    {
        return ZCRMNote( content : content )
    }
    
    public func newNote( content : String?, title : String ) -> ZCRMNote
    {
        return ZCRMNote(content : content, title : title)
    }
    
    public func newTag( tagName : String ) -> ZCRMTag
    {
        return ZCRMTag(tagName: tagName)
    }
    
    public func getTagDelegate(tagId : Int64) -> ZCRMTagDelegate
    {
        return ZCRMTagDelegate(tagId: tagId, moduleAPIName: self.moduleAPIName)
    }
    
    public func getTagDelegate(tagId : Int64, tagName : String) -> ZCRMTagDelegate
    {
        return ZCRMTagDelegate(tagId: tagId, tagName: tagName, moduleAPIName: self.moduleAPIName)
    }
    
    /// Returns the API response of the ZCRMRecord delete.
    ///
    /// - Returns: API response of the ZCRMRecord delete
    /// - Throws: ZCRMSDKError if Entity ID of the record is nil
    public func delete( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        if(self.recordId == APIConstants.INT64_MOCK)
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Entity ID MUST NOT be null for delete operation." ) ) )
        }
        else
        {
            EntityAPIHandler(recordDelegate: self).deleteRecord { ( result ) in
                completion( result )
            }
        }
    }
    
    /// Convert the ZCRMRecord(Leads to Contacts) and Returns dictionary containing deal, contact and account vs its ID of the converted ZCRMecord.
    ///
    /// - Returns: dictionary containing deal, contact and account vs its ID of the converted ZCRMRecord
    /// - Throws: ZCRMSDKError if the ZCRMRecord is not convertible
    public func convert( completion : @escaping( Result.DataResponse< [ String : Int64 ], APIResponse > ) -> () )
    {
        if(self.moduleAPIName != "Leads")
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.INVALID_MODULE , message : "This module does not support convert operation" ) ) )
        }
        else
        {
            self.convert(newPotential: nil, assignTo: nil) { ( result ) in
                completion( result )
            }
        }
    }
    
    /// Convert the ZCRMRecord(Leads to Contacts and create new Potential) and Returns dictionary containing deal, contact and account vs its ID of the converted ZCRMRecord.
    ///
    /// - Parameter newPotential: New ZCRMRecord(Potential) to be created
    /// - Returns: dictionary containing deal, contact and account vs its ID of the converted ZCRMRecord
    /// - Throws: ZCRMSDKError if the ZCRMRecord is not convertible
    public func convert( newPotential : ZCRMRecord, completion :
        @escaping( Result.DataResponse< [ String : Int64 ], APIResponse > ) -> () )
    {
        if(self.moduleAPIName != "Leads")
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.INVALID_MODULE , message : "This module does not support convert operation" ) ) )
        }
        else
        {
            self.convert( newPotential: newPotential, assignTo: nil){
                ( result ) in
                completion( result )
            }
        }
    }
    
    /// Convert the ZCRMRecord(Leads to Contacts and create new Potential) with assignee and Returns map containing deal, contact and account vs its ID of the converted ZCRMRecord.
    ///
    /// - Parameters:
    ///   - newPotential: New ZCRMRecord(Potential) to be created
    ///   - assignTo: assignee for the converted ZCRMRecord
    /// - Returns: dictionary containing deal, contact and account vs its ID of the converted ZCRMRecord
    /// - Throws: ZCRMSDKError if the ZCRMRecord is not convertible
    public func convert(newPotential: ZCRMRecord?, assignTo: ZCRMUser?, completion :
        @escaping( Result.DataResponse< [ String : Int64 ], APIResponse > ) -> () )
    {
        if(self.moduleAPIName != "Leads")
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.INVALID_MODULE , message : "This module does not support convert operation" ) ) )
        }
        else
        {
            EntityAPIHandler(recordDelegate:self).convertRecord(newPotential: newPotential, assignTo: assignTo) {
                ( result ) in
                completion( result )
            }
        }
    }
    
    /// Return related list records of the ZCRMRecord(BulkAPIResponse).
    ///
    /// - Parameter relatedListAPIName: related list name to be returned
    /// - Returns: records of the related list of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get related list of the ZCRMRecord
    public func getRelatedListRecords(relatedListAPIName : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModuleRelation(relatedListAPIName: relatedListAPIName, parentModuleAPIName: self.moduleAPIName).getRelatedRecords( ofParentRecord : self, page : 1, per_page : 20 ) { ( result ) in
            completion( result )
        }
    }
    
    public func getRelatedListRecords(relatedListAPIName : String, modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModuleRelation(relatedListAPIName: relatedListAPIName, parentModuleAPIName: self.moduleAPIName).getRelatedRecords( ofParentRecord : self, modifiedSince: modifiedSince ) { ( result ) in
            completion( result )
        }
    }
    
    /// Return related list records of the ZCRMRecord of a requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - relatedListAPIName: related list name to be returned
    ///   - page: page number of the related list
    ///   - per_page: number of records to be given for a single page
    /// - Returns: related list records of the ZCRMRecord of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get related list of the ZCRMRecord
    public func getRelatedListRecords(relatedListAPIName : String, page : Int, per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        ZCRMModuleRelation(relatedListAPIName: relatedListAPIName, parentModuleAPIName: self.moduleAPIName).getRelatedRecords( ofParentRecord : self, page : page, per_page : per_page ) { ( result ) in
            completion( result )
        }
    }
    
    /// related list records of the ZCRMRecord, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - relatedListAPIName: related list name to be returned
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    /// - Returns: sorted list records of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get related list of the ZCRMRecord
    public func getRelatedListRecords( relatedListAPIName : String, sortByField : String, sortOrder : SortOrder, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModuleRelation(relatedListAPIName: relatedListAPIName, parentModuleAPIName: self.moduleAPIName).getRelatedRecords( ofParentRecord : self, sortByField : sortByField, sortOrder : sortOrder ) { ( result ) in
            completion( result )
        }
    }
    
    /// related list records of the ZCRMRecord of a requested page number with records of per_page count, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - relatedListAPIName: related list name to be returned
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - page: page number of the related list
    ///   - per_page: number of records to be given for a single page
    ///   - modifiedSince: modified time
    /// - Returns: sorted list of records of the ZCRMRecord of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get related list of the ZCRMRecord
    public func getRelatedListRecords( relatedListAPIName : String, sortByField : String, sortOrder : SortOrder, page : Int, per_page : Int, modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModuleRelation(relatedListAPIName: relatedListAPIName, parentModuleAPIName: self.moduleAPIName).getRelatedRecords( ofParentRecord : self, page : page, per_page : per_page, sortByField : sortByField, sortOrder : sortOrder, modifiedSince : modifiedSince ) { ( result ) in
            completion( result )
        }
    }
    
    /// To add a new Note to the ZCRMRecord
    ///
    /// - Parameter note: ZCRMNote to be added
    /// - Returns: APIResponse of the note addition
    /// - Throws: ZCRMSDKError if Note id is not nil
    public func addNote(note: ZCRMNote, completion : @escaping( Result.DataResponse< ZCRMNote, APIResponse > ) -> () )
    {
        if( note.id != APIConstants.INT64_MOCK )
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Note ID must be nil for create operation." ) ) )
        }
        else
        {
            ZCRMModuleRelation(relatedListAPIName: "Notes", parentModuleAPIName: self.moduleAPIName).addNote(note: note, toRecord: self) { ( result ) in
                completion( result )
            }
        }
    }
    
    /// To update a Note of the ZCRMRecord
    ///
    /// - Parameter note: ZCRMNote to be updated
    /// - Returns: APIResponse of the note update
    /// - Throws: ZCRMSDKError if Note id is nil
    public func updateNote(note: ZCRMNote, completion : @escaping( Result.DataResponse< ZCRMNote, APIResponse > ) -> ())
    {
        if( note.id == APIConstants.INT64_MOCK )
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Note ID must not be nil for update operation." ) ) )
        }
        else
        {
            ZCRMModuleRelation(relatedListAPIName: "Notes", parentModuleAPIName: self.moduleAPIName).updateNote(note: note, ofRecord: self) { ( result ) in
                completion( result )
            }
        }
    }
    
    /// To delete a Note of the ZCRMRecord
    ///
    /// - Parameter note: ZCRMNote to be deleted
    /// - Returns: APIResponse of the note deletion
    /// - Throws: ZCRMSDKError if Note id is nil
    public func deleteNote(noteId: Int64, completion : @escaping( Result.Response< APIResponse > ) -> ())
    {
        ZCRMModuleRelation(relatedListAPIName: "Notes", parentModuleAPIName: self.moduleAPIName).deleteNote(noteId: noteId, ofRecord: self) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of notes of the ZCRMRecord(BulkAPIResponse).
    ///
    /// - Returns: list of notes of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get notes of the ZCRMRecord
    public func getNotes( completion : @escaping( Result.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> () )
    {
        ZCRMModuleRelation(relatedListAPIName: "Notes", parentModuleAPIName: self.moduleAPIName).getNotes( ofParentRecord: self, page : 1, per_page : 20 ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of notes of the ZCRMRecord of a requested page number with notes of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - page: page number of the notes
    ///   - per_page: number of notes to be given for a single page
    /// - Returns: list of notes of the ZCRMRecord of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get notes of the ZCRMRecord
    public func getNotes( page : Int, per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> () )
    {
        ZCRMModuleRelation(relatedListAPIName: "Notes", parentModuleAPIName: self.moduleAPIName).getNotes( ofParentRecord: self, page : page, per_page : per_page, sortByField : nil, sortOrder : nil, modifiedSince : nil ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of notes of the ZCRMRecord, before returning the list of notes gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - sortByField: field by which the notes get sorted
    ///   - sortOrder: sort order (asc, desc)
    /// - Returns: sorted list of notes of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get notes of the ZCRMRecord
    public func getNotes( sortByField : String, sortOrder : SortOrder, completion : @escaping( Result.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> () )
    {
        ZCRMModuleRelation(relatedListAPIName: "Notes", parentModuleAPIName: self.moduleAPIName).getNotes( ofParentRecord: self, page : 0, per_page : 20, sortByField : sortByField, sortOrder : sortOrder, modifiedSince : nil ) { ( result ) in
            completion( result )
        }
    }
    
    /// Related list opf notes of the ZCRMRecord of a requested page number with notes of per_page count, before returning the list of notes gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - page: page number of the notes
    ///   - per_page: number of notes to be given for a single page
    ///   - sortByField: field by which the notes get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - modifiedSince: modified timesorted list of notes of the ZCRMRecord of a requested page number with records of per_page count
    /// - Returns: <#return value description#>
    /// - Throws: ZCRMSDKError if failed to get notes of the ZCRMRecord
    public func getNotes(page : Int, per_page : Int, sortByField : String?, sortOrder : SortOrder?, modifiedSince : String?, completion : @escaping( Result.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> () )
    {
        ZCRMModuleRelation(relatedListAPIName: "Notes", parentModuleAPIName: self.moduleAPIName).getNotes(ofParentRecord: self, page: page, per_page: per_page, sortByField: sortByField, sortOrder: sortOrder, modifiedSince: modifiedSince ) { ( result ) in
            completion( result )
        }
    }
    
    /// To get list of all attachments of the ZCRMRecord(BulkAPIResponse).
    ///
    /// - Returns: list of all attachments of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get the list of attachments
    public func getAttachments( completion : @escaping( Result.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> ())
    {
        ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: self.moduleAPIName).getAttachments(ofParentRecord: self, page: 1, per_page: 20, modifiedSince : nil) { ( result ) in
            completion( result )
        }
    }
    
    /// To get list of all attachments of the ZCRMRecord of a requested page number with attachments of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - page: page number of the attachments
    ///   - per_page: number of attachments to be given for a single page
    ///   - modifiedSince: modified time
    /// - Returns: list of all attachments of the ZCRMRecord of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the list of attachments
    public func getAttachments(page : Int, per_page : Int, modifiedSince : String?, completion : @escaping( Result.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> ())
    {
        ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: self.moduleAPIName).getAttachments(ofParentRecord: self, page: page, per_page: per_page, modifiedSince : modifiedSince) { ( result ) in
            completion( result )
        }
    }
    
    /// To download a Attachment from the ZCRMRecord, it returns file as data, then it can be converted to a file.
    ///
    /// - Parameter attachmentId: Id of the attachment to be downloaded
    /// - Returns: FileAPIResponse containing the data of the file downloaded.
    /// - Throws: ZCRMSDKError if failed to download the attachment
    public func downloadAttachment(attachmentId: Int64, completion : @escaping( Result.Response< FileAPIResponse > ) -> ())
    {
        ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: self.moduleAPIName).downloadAttachment(ofParentRecord: self, attachmentId: attachmentId) { ( result ) in
            completion( result )
        }
    }
    
    public func deleteAttachment( attachmentId : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        ZCRMModuleRelation( relatedListAPIName : "Attachments", parentModuleAPIName : self.moduleAPIName ).deleteAttachment( ofParentRecord : self, attachmentId :  attachmentId ) { ( result ) in
            completion( result )
        }
    }
    
    /// To upload a Attachment to the ZCRMRecord.
    ///
    /// - Parameter filePath: file path of the attachment
    /// - Returns: APIResponse of the attachment upload
    /// - Throws: ZCRMSDKError if failed to upload the attachment
    public func uploadAttachmentWithPath( filePath : String, completion : @escaping( Result.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        ZCRMModuleRelation( relatedListAPIName : "Attachments", parentModuleAPIName : self.moduleAPIName).uploadAttachmentWithPath( ofParentRecord : self, filePath : filePath ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadAttachmentWithData( fileName : String, data : Data, completion : @escaping( Result.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        ZCRMModuleRelation( relatedListAPIName : "Attachments", parentModuleAPIName : self.moduleAPIName).uploadAttachmentWithData( ofParentRecord : self, fileName : fileName, data : data) { ( result ) in
            completion( result )
        }
    }
    
    /// To upload a Attachment from attachmentUrl to the ZCRMRecord.
    ///
    /// - Parameter attachmentURL: URL of the attachment
    /// - Returns: APIResponse of the attachment upload
    /// - Throws: ZCRMSDKError if failed to upload the attachment
    public func uploadLinkAsAttachment( attachmentURL : String, completion : @escaping( Result.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        ZCRMModuleRelation( relatedListAPIName : "Attachments", parentModuleAPIName : self.moduleAPIName ).uploadLinkAsAttachment( ofParentRecord : self, attachmentURL : attachmentURL ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadPhotoWithPath( filePath : String, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).uploadPhotoWithPath( filePath : filePath) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadPhotoWithData( fileName : String, data : Data, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate: self ).uploadPhotoWithData( fileName : fileName, data : data) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadPhoto( completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).downloadPhoto { ( result ) in
            completion( result )
        }
    }
    
    public func deletePhoto( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).deletePhoto { ( result ) in
            completion( result )
        }
    }
    
    /// To add the association between ZCRMRecords.
    ///
    /// - Parameter junctionRecord: ZCRMJuctionRecord to assiciate with the ZCRMRecord
    /// - Returns: APIResponsed of added relation
    /// - Throws: ZCRMError if failed to add relation
    public func addRelation( junctionRecord : ZCRMJunctionRecord, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, junctionRecord : junctionRecord ).addRelation(completion: { ( result ) in
            completion( result )
        })
    }
    
    /// To delete the association between ZCRMRecords.
    ///
    /// - Parameter junctionRecord: ZCRMJunctionRecord to be delete.
    /// - Returns: APIResponse of the delete relation
    /// - Throws: ZCRMError if failed to delete the relation
    public func deleteRelation( junctionRecord : ZCRMJunctionRecord, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, junctionRecord : junctionRecord ).deleteRelation { ( result ) in
            completion( result )
        }
    }
    
    public func addTags( tags : [ZCRMTag], completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).addTags(tags: tags, overWrite: nil) { ( result ) in
            completion( result )
        }
    }
    
    public func addTags( tags : [ZCRMTag], overWrite : Bool?, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).addTags(tags: tags, overWrite: overWrite) { ( result ) in
            completion( result )
        }
    }
    
    public func removeTags( tags : [ZCRMTag], completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).removeTags(tags: tags) { ( result ) in
            completion( result )
        }
    }
    
    public func follow( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).follow() { ( result ) in
            completion( result )
        }
    }
    
    public func unfollow( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).unfollow() { ( result ) in
            completion( result )
        }
    }
    
    public func getTimelineEvents( completion : @escaping( Result.DataResponse< [ZCRMTimelineEvent], BulkAPIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).getTimelineEvents(page: 1, perPage: 20, filter: nil) { ( result ) in
            completion( result )
        }
    }
    
    public func getTimelineEvents( filter : String, completion : @escaping( Result.DataResponse< [ZCRMTimelineEvent], BulkAPIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).getTimelineEvents(page: 1, perPage: 20, filter: filter) { ( result ) in
            completion( result )
        }
    }
    
    public func getTimelineEvents( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ZCRMTimelineEvent], BulkAPIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).getTimelineEvents(page: page, perPage: perPage, filter: nil) { ( result ) in
            completion( result )
        }
    }
    
    public func getTimelineEvents( page : Int, perPage : Int, filter : String, completion : @escaping( Result.DataResponse< [ZCRMTimelineEvent], BulkAPIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).getTimelineEvents(page: page, perPage: perPage, filter: filter) { ( result ) in
            completion( result )
        }
    }
}

let RECORD_MOCK : ZCRMRecordDelegate = ZCRMRecordDelegate( recordId : APIConstants.INT64_MOCK, moduleAPIName : APIConstants.STRING_MOCK )

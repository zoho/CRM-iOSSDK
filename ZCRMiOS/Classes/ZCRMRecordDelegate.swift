//
//  ZCRMRecordDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 13/09/18.
//

open class ZCRMRecordDelegate : ZCRMEntity
{
    public internal(set) var id : Int64
    public internal(set) var moduleAPIName : String
    public var label : String?
    internal var data : [ String : Any? ] = [ String : Any? ]()
    public internal( set ) var properties : [ String : Any? ] = [ String : Any? ]()
    
    init ( id : Int64, moduleAPIName : String )
    {
        self.id = id
        self.moduleAPIName = moduleAPIName
    }
    
    /// Set the value of the ZCRMRecord's property.
    ///
    /// - Parameters:
    ///   - ofProperty: property whose value is to be change.
    ///   - value: value of the ZCRMRecord's property
    public func setValue( ofProperty : String, value : Any? )
    {
        self.properties.updateValue( value, forKey : ofProperty )
    }
    
    public func newNote( content : String ) -> ZCRMNote
    {
        let note = ZCRMNote( content : content )
        note.parentRecord = self
        note.isCreate = true
        return note
    }
    
    public func newNote( content : String?, title : String ) -> ZCRMNote
    {
        let note = ZCRMNote(content : content, title : title)
        note.parentRecord = self
        note.isCreate = true
        return note
    }
    
    public func newTag( name : String ) -> ZCRMTag
    {
        let tag = ZCRMTag( name : name, moduleAPIName : self.moduleAPIName )
        tag.isCreate = true
        return tag
    }
    
    public func newMail( from : ZCRMEmail.User, to : [ZCRMEmail.User] ) -> ZCRMEmail
    {
        let email = ZCRMEmail( record : self, from : from, to : to )
        email.didSend = false
        return email
    }
    
    /// Returns the API response of the ZCRMRecord delete.
    ///
    /// - Returns: API response of the ZCRMRecord delete
    /// - Throws: ZCRMSDKError if Entity ID of the record is nil
    public func delete( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).deleteRecord { ( result ) in
            completion( result )
        }
    }
    
    /// Convert the ZCRMRecord(Leads to Contacts) and Returns dictionary containing deal, contact and account vs its ID of the converted ZCRMecord.
    ///
    /// - Returns: dictionary containing deal, contact and account vs its ID of the converted ZCRMRecord
    /// - Throws: ZCRMSDKError if the ZCRMRecord is not convertible
    public func convert( completion : @escaping( Result.DataResponse< [ String : Int64 ], APIResponse > ) -> () )
    {
        if( self.moduleAPIName != DefaultModuleAPINames.LEADS )
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidModule) : This module does not support convert operation, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidModule , message : "This module does not support convert operation", details : nil ) ) )
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
    public func convert( newPotential : ZCRMRecord, completion : @escaping( Result.DataResponse< [ String : Int64 ], APIResponse > ) -> () )
    {
        if( self.moduleAPIName != DefaultModuleAPINames.LEADS )
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidModule) : This module does not support convert operation, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidModule , message : "This module does not support convert operation", details : nil ) ) )
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
    public func convert(newPotential: ZCRMRecord?, assignTo: ZCRMUser?, completion : @escaping( Result.DataResponse< [ String : Int64 ], APIResponse > ) -> () )
    {
        if( self.moduleAPIName != DefaultModuleAPINames.LEADS )
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidModule) : This module does not support convert operation, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidModule , message : "This module does not support convert operation", details : nil ) ) )
        }
        else
        {
            EntityAPIHandler(recordDelegate:self).convertRecord(newPotential: newPotential, assignTo: assignTo) {
                ( result ) in
                completion( result )
            }
        }
    }
    
    /// To add a new Note to the ZCRMRecord
    ///
    /// - Parameter note: ZCRMNote to be added
    /// - Returns: APIResponse of the note addition
    /// - Throws: ZCRMSDKError if Note id is not nil
    public func addNote(note: ZCRMNote, completion : @escaping( Result.DataResponse< ZCRMNote, APIResponse > ) -> () )
    { 
        if !note.isCreate
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : Note ID must be nil for create operation, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidData, message : "Note ID must be nil for create operation.", details : nil ) ) )
        }
        else
        {
            RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).addNote( note : note ) { ( result ) in
                note.isCreate = false
                completion( result )
            }
        }
    }
    
    public func addVoiceNote( filePath : String, note : ZCRMNote, completion : @escaping( Result.DataResponse< ZCRMNote, APIResponse > ) -> () )
    {
        if !note.isCreate
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : Note ID must be nil for create operation, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidData, message : "Note ID must be nil for create operation.", details : nil ) ) )
        }
        else
        {
            RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).addVoiceNote( filePath : filePath, fileName : nil, fileData : nil, note : note ) { ( result ) in
                note.isCreate = false
                completion( result )
            }
        }
    }
    
    public func addVoiceNote( fileRefId : String, filePath : String, note : ZCRMNote, voiceNoteUploadDelegate : ZCRMVoiceNoteUploadDelegate )
    {
        if !note.isCreate
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : Note ID must be nil for create operation, \( APIConstants.DETAILS ) : -")
            voiceNoteUploadDelegate.didFail( fileRefId : fileRefId, ZCRMError.processingError( code : ErrorCode.invalidData, message : "Note ID must be nil for create operation.", details : nil ) )
        }
        else
        {
            RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName )).addVoiceNote( fileRefId : fileRefId, filePath : filePath, fileName : nil, fileData : nil, note : note, voiceNoteUploadDelegate: voiceNoteUploadDelegate)
        }
    }
    
    public func addVoiceNote( fileName : String, fileData : Data, note : ZCRMNote, completion : @escaping( Result.DataResponse< ZCRMNote, APIResponse > ) -> () )
    {
        if !note.isCreate
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : Note ID must be nil for create operation, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidData, message : "Note ID must be nil for create operation.", details : nil ) ) ) 
        }
        else
        {
            RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).addVoiceNote( filePath : nil, fileName : fileName, fileData : fileData, note : note ) { ( result ) in
                completion( result )
            }
        }
    }
    
    public func addVoiceNote( fileRefId : String, fileName : String, fileData : Data, note : ZCRMNote, voiceNoteUploadDelegate : ZCRMVoiceNoteUploadDelegate )
    {
        if !note.isCreate
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : Note ID must be nil for create operation, \( APIConstants.DETAILS ) : -")
            voiceNoteUploadDelegate.didFail( fileRefId : fileRefId, ZCRMError.processingError( code : ErrorCode.invalidData, message : "Note ID must be nil for create operation.", details : nil ) )
        }
        else
        {
            RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName )).addVoiceNote( fileRefId : fileRefId, filePath : nil, fileName : fileName, fileData : fileData, note : note, voiceNoteUploadDelegate: voiceNoteUploadDelegate )
        }
    }
    
    public func addTags( tags : [ String ], completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).addTags( tags : tags, overWrite : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func addTags( tags : [ String ], overWrite : Bool?, completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).addTags( tags : tags, overWrite : overWrite ) { ( result ) in
            completion( result )
        }
    }
    
    public func removeTags( tags : [ String ], completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).removeTags( tags : tags ) { ( result ) in
            completion( result )
        }
    }
    
    /// To update a Note of the ZCRMRecord
    ///
    /// - Parameter note: ZCRMNote to be updated
    /// - Returns: APIResponse of the note update
    /// - Throws: ZCRMSDKError if Note id is nil
    public func updateNote(note: ZCRMNote, completion : @escaping( Result.DataResponse< ZCRMNote, APIResponse > ) -> ())
    {
        if note.isCreate
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : Note ID must not be nil for update operation, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "Note ID must not be nil for update operation.", details : nil ) ) )
        }
        else
        {
            RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).updateNote( note : note ) { ( result ) in
                completion( result )
            }
        }
    }
    
    public func downloadVoiceNote( id : Int64, completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).downloadVoiceNote( noteId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadVoiceNote( id : Int64, fileDownloadDelegate : ZCRMFileDownloadDelegate ) throws
    {
        try RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).downloadVoiceNote( noteId : id, fileDownloadDelegate : fileDownloadDelegate )
    }
    
    /// To delete a Note of the ZCRMRecord
    ///
    /// - Parameter id: Id of the ZCRMNote to be deleted
    /// - Returns: APIResponse of the note deletion
    /// - Throws: ZCRMSDKError if Note id is nil
    public func deleteNote( id : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).deleteNote( noteId : id ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of notes of the ZCRMRecord(BulkAPIResponse).
    ///
    /// - Returns: list of notes of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get notes of the ZCRMRecord
    public func getNotes( completion : @escaping( Result.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList :  ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).getNotes( page : nil, perPage : nil, sortByField : nil, sortOrder : nil, modifiedSince : nil ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of notes of the ZCRMRecord of a requested page number with notes of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - page: page number of the notes
    ///   - perPage: number of notes to be given for a single page
    /// - Returns: list of notes of the ZCRMRecord of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get notes of the ZCRMRecord
    public func getNotes( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> () )
    {
        self.getNotes(page: page, perPage: perPage, sortByField: nil, sortOrder: nil, modifiedSince: nil) { ( result ) in
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
        RelatedListAPIHandler( parentRecord : self, relatedList :  ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).getNotes( page : nil, perPage : nil, sortByField : sortByField, sortOrder : sortOrder, modifiedSince : nil ) { ( result ) in
            completion( result )
        }
    }
    
    /// Related list opf notes of the ZCRMRecord of a requested page number with notes of per_page count, before returning the list of notes gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - page: page number of the notes
    ///   - perPage: number of notes to be given for a single page
    ///   - sortByField: field by which the notes get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - modifiedSince: modified timesorted list of notes of the ZCRMRecord of a requested page number with records of per_page count
    /// - Returns: <#return value description#>
    /// - Throws: ZCRMSDKError if failed to get notes of the ZCRMRecord
    public func getNotes(page : Int, perPage : Int, sortByField : String?, sortOrder : SortOrder?, modifiedSince : String?, completion : @escaping( Result.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).getNotes( page : page, perPage : perPage, sortByField : sortByField, sortOrder : sortOrder, modifiedSince : modifiedSince ) { ( result ) in
            completion( result )
        }
    }
    
    public func getNote( id : Int64, completion : @escaping( Result.DataResponse< ZCRMNote, APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).getNote( noteId : id ) { ( result ) in
            completion( result )
        }
    }
    
    /// To get list of all attachments of the ZCRMRecord(BulkAPIResponse).
    ///
    /// - Returns: list of all attachments of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get the list of attachments
    public func getAttachments( completion : @escaping( Result.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> ())
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).getAttachments( page : nil, perPage : nil, modifiedSince : nil ) { ( result ) in
            completion( result )
        }
    }
    
    /// To get list of all attachments of the ZCRMRecord of a requested page number with attachments of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - page: page number of the attachments
    ///   - perPage: number of attachments to be given for a single page
    ///   - modifiedSince: modified time
    /// - Returns: list of all attachments of the ZCRMRecord of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the list of attachments
    public func getAttachments( page : Int, perPage : Int, modifiedSince : String?, completion : @escaping( Result.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).getAttachments( page : page, perPage : perPage, modifiedSince : modifiedSince ) { ( result ) in
            completion( result )
        }
    }
    
    /// To download a Attachment from the ZCRMRecord, it returns file as data, then it can be converted to a file.
    ///
    /// - Parameter id: Id of the attachment to be downloaded
    /// - Returns: FileAPIResponse containing the data of the file downloaded.
    /// - Throws: ZCRMSDKError if failed to download the attachment
    public func downloadAttachment(id: Int64, completion : @escaping( Result.Response< FileAPIResponse > ) -> ())
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).downloadAttachment( attachmentId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadAttachment( id : Int64, fileDownloadDelegate : ZCRMFileDownloadDelegate ) throws
    {
        try RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).downloadAttachment( attachmentId : id, fileDownloadDelegate : fileDownloadDelegate )
    }
    
    public func deleteAttachment( id : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).deleteAttachment( attachmentId : id ) { ( result ) in
            completion( result )
        }
    }
    
    /// To upload a Attachment to the ZCRMRecord.
    ///
    /// - Parameter filePath: file path of the attachment
    /// - Returns: APIResponse of the attachment upload
    /// - Throws: ZCRMSDKError if failed to upload the attachment
    public func uploadAttachment( filePath : String, completion : @escaping( Result.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName) ).uploadAttachment( filePath : filePath, fileName : nil, fileData : nil, note : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadAttachment( fileRefId : String, filePath : String, attachmentUploadDelegate : ZCRMAttachmentUploadDelegate )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName)).uploadAttachment( fileRefId : fileRefId, filePath : filePath, fileName : nil, fileData : nil, note : nil , attachmentUploadDelegate: attachmentUploadDelegate)
    }
    
    public func uploadAttachment( fileName : String, fileData : Data, completion : @escaping( Result.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).uploadAttachment( filePath : nil, fileName : fileName, fileData : fileData, note : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadAttachment( fileRefId : String, fileName : String, fileData : Data, attachmentUploadDelegate : ZCRMAttachmentUploadDelegate )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName)).uploadAttachment( fileRefId : fileRefId, filePath : nil, fileName : fileName, fileData : fileData, note : nil , attachmentUploadDelegate: attachmentUploadDelegate)
    }
    
    /// To upload a Attachment from attachmentUrl to the ZCRMRecord.
    ///
    /// - Parameter URL: URL of the attachment
    /// - Returns: APIResponse of the attachment upload
    /// - Throws: ZCRMSDKError if failed to upload the attachment
    public func uploadLinkAsAttachment( URL : String, completion : @escaping( Result.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).uploadLinkAsAttachment( attachmentURL : URL ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadPhoto( filePath : String, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).uploadPhoto(filePath: filePath, fileName: nil, fileData: nil) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadPhoto( fileRefId : String, filePath : String, fileUploadDelegate : ZCRMFileUploadDelegate )
    {
        EntityAPIHandler( recordDelegate : self ).uploadPhoto( fileRefId : fileRefId, filePath : filePath, fileName : nil, fileData : nil, fileUploadDelegate : fileUploadDelegate )
    }
    
    public func uploadPhoto( fileName : String, fileData : Data, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).uploadPhoto( filePath : nil, fileName : fileName, fileData : fileData ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadPhoto( fileRefId : String, fileName : String, fileData : Data, fileUploadDelegate : ZCRMFileUploadDelegate )
    {
        EntityAPIHandler( recordDelegate : self ).uploadPhoto( fileRefId : fileRefId, filePath : nil, fileName : fileName, fileData : fileData, fileUploadDelegate : fileUploadDelegate )
    }
    
    public func downloadPhoto( completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).downloadPhoto { ( result ) in
            completion( result )
        }
    }
    
    public func downloadPhoto( fileDownloadDelegate : ZCRMFileDownloadDelegate )
    {
        EntityAPIHandler(recordDelegate: self).downloadPhoto(fileDownloadDelegate: fileDownloadDelegate)
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
    
    public func addRelations( junctionRecords : [ ZCRMJunctionRecord ], completion : @escaping( Result.Response< BulkAPIResponse > ) -> () )
    {
        let apiName = junctionRecords[0].apiName
        for junctionRecord in junctionRecords
        {
            if junctionRecord.apiName != apiName
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidOperation) : All relation must be of the same module, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidOperation , message : "All relation must be of the same module", details : nil ) ) )
            }
        }
        RelatedListAPIHandler( parentRecord : self ).addRelations( junctionRecords : junctionRecords ) { ( result ) in
            completion( result )
        }
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
    
    public func deleteRelations( junctionRecords : [ ZCRMJunctionRecord ], completion : @escaping( Result.Response< BulkAPIResponse > ) -> () )
    {
        let apiName = junctionRecords[0].apiName
        for junctionRecord in junctionRecords
        {
            if junctionRecord.apiName != apiName
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidOperation) : All relation must be of the same module, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidOperation , message : "All relation must be of the same module", details : nil ) ) )
            }
        }
        RelatedListAPIHandler( parentRecord : self ).deleteRelations( junctionRecords : junctionRecords) { ( result ) in
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
        EntityAPIHandler( recordDelegate : self ).getTimelineEvents( page : nil, perPage : nil, filter : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getTimelineEvents( filter : String, completion : @escaping( Result.DataResponse< [ZCRMTimelineEvent], BulkAPIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).getTimelineEvents( page : nil, perPage : nil, filter : filter ) { ( result ) in
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
    
    public func getMail( userId : Int64, messageId : String, completion : @escaping( Result.DataResponse< ZCRMEmail, APIResponse > ) -> () )
    {
        EmailAPIHandler().viewMail(record: self, userId: userId, messageId: messageId) { ( result ) in
            completion( result )
        }
    }
}

extension ZCRMRecordDelegate : Equatable
{
    public static func == (lhs: ZCRMRecordDelegate, rhs: ZCRMRecordDelegate) -> Bool {
        return lhs.id == rhs.id &&
            lhs.moduleAPIName == rhs.moduleAPIName &&
            lhs.label == rhs.label
    }
}

let RECORD_MOCK : ZCRMRecordDelegate = ZCRMRecordDelegate( id : APIConstants.INT64_MOCK, moduleAPIName : APIConstants.STRING_MOCK )

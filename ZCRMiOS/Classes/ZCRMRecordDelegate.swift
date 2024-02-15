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
    
    func copy() -> ZCRMRecordDelegate
    {
        let copyObj = ZCRMRecordDelegate(id: id, moduleAPIName: moduleAPIName)
        copyObj.label = label
        copyObj.data = data.copy()
        copyObj.properties = properties.copy()
        return copyObj
    }
    
    init ( id : Int64, moduleAPIName : String )
    {
        self.id = id
        self.moduleAPIName = moduleAPIName
    }
    
    /**
      Returns the ZCRMRecordDelegate's fieldAPIName vs field value dictionary
     
     - Returns: ZCRMRecordDelegate's fieldAPIName vs field value dictionary
     */
    public func getData() -> [ String : Any? ]
    {
        return self.data
    }
    
    /**
      Returns the value of the property name given
     
     - Parameter ofProperty : Name of the property
     - Returns: The value of the property
     */
    public func getValue( ofProperty : String ) -> Any?
    {
        return self.properties.optValue( key : ofProperty )
    }
    
    /**
      Returns the field value to which the specified field name is mapped
     
     - Parameter ofFieldAPIName: Field name whose associated value is to be returned
     - Returns: The value to which specified field name is mapped
     - Throws: The ZCRMSDKError if the given field is not present in the ZCRMRecord
     */
    public func getValue( ofFieldAPIName : String ) throws -> Any?
    {
        if self.data.hasKey( forKey : ofFieldAPIName )
        {
            return self.data.optValue( key : ofFieldAPIName )
        }
        else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.fieldNotFound) : The given field is not present in the record. Field Name -> \( ofFieldAPIName )")
            throw ZCRMError.processingError( code : ZCRMErrorCode.fieldNotFound, message : "The given field is not present in the record. Field Name -> \( ofFieldAPIName )", details : nil )
        }
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
        let tag = ZCRMTag(name: name, moduleAPIName: moduleAPIName)
        tag.isCreate = true
        return tag
    }
    
    /// Returns the API response of the ZCRMRecord delete.
    ///
    /// - Returns: API response of the ZCRMRecord delete
    /// - Throws: ZCRMSDKError if Entity ID of the record is nil
    public func delete( completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).deleteRecord { ( result ) in
            completion( result )
        }
    }
    
    /// Convert the ZCRMRecord(Leads to Contacts) and Returns dictionary containing deal, contact and account vs its ID of the converted ZCRMecord.
    ///
    /// - Returns: dictionary containing deal, contact and account vs its ID of the converted ZCRMRecord
    /// - Throws: ZCRMSDKError if the ZCRMRecord is not convertible
    public func convert( completion : @escaping( ZCRMResult.DataResponse< [ String : Int64 ], APIResponse > ) -> () )
    {
        if( self.moduleAPIName != ZCRMDefaultModuleAPINames.LEADS )
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidModule) : This module does not support convert operation, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.invalidModule , message : "This module does not support convert operation", details : nil ) ) )
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
    public func convert( newPotential : ZCRMRecord, completion : @escaping( ZCRMResult.DataResponse< [ String : Int64 ], APIResponse > ) -> () )
    {
        if( self.moduleAPIName != ZCRMDefaultModuleAPINames.LEADS )
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidModule) : This module does not support convert operation, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.invalidModule , message : "This module does not support convert operation", details : nil ) ) )
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
    public func convert(newPotential: ZCRMRecord?, assignTo: ZCRMUser?, completion : @escaping( ZCRMResult.DataResponse< [ String : Int64 ], APIResponse > ) -> () )
    {
        if( self.moduleAPIName != ZCRMDefaultModuleAPINames.LEADS )
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidModule) : This module does not support convert operation, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.invalidModule , message : "This module does not support convert operation", details : nil ) ) )
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
    public func addNote(note: ZCRMNote, completion : @escaping( ZCRMResult.DataResponse< ZCRMNote, APIResponse > ) -> () )
    { 
        if !note.isCreate
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidData) : Note ID must be nil for create operation, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.invalidData, message : "Note ID must be nil for create operation.", details : nil ) ) )
        }
        else
        {
            RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).addNote( note : note ) { ( result ) in
                completion( result )
            }
        }
    }
    
    @available( *, deprecated, message: "Use addTags with tagDelegate param instead" )
    public func addTags( tags : [ String ], completion : @escaping( ZCRMResult.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).addTags( tags : tags, overWrite : nil ) { ( result ) in
            completion( result )
        }
    }
    
    @available( *, deprecated, message: "Use addTags with tagDelegate and overWrite params instead" )
    public func addTags( tags : [ String ], overWrite : Bool?, completion : @escaping( ZCRMResult.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).addTags( tags : tags, overWrite : overWrite ) { ( result ) in
            completion( result )
        }
    }
    
    /// To update a Note of the ZCRMRecord
    ///
    /// - Parameter note: ZCRMNote to be updated
    /// - Returns: APIResponse of the note update
    /// - Throws: ZCRMSDKError if Note id is nil
    public func updateNote(note: ZCRMNote, completion : @escaping( ZCRMResult.DataResponse< ZCRMNote, APIResponse > ) -> ())
    {
        if note.isCreate
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.mandatoryNotFound) : Note ID must not be nil for update operation, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.mandatoryNotFound, message : "Note ID must not be nil for update operation.", details : nil ) ) )
        }
        else
        {
            RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).updateNote( note : note ) { ( result ) in
                completion( result )
            }
        }
    }
    
    /// To delete a Note of the ZCRMRecord
    ///
    /// - Parameter id: Id of the ZCRMNote to be deleted
    /// - Returns: APIResponse of the note deletion
    /// - Throws: ZCRMSDKError if Note id is nil
    public func deleteNote( id : Int64, completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).deleteNote( noteId : id ) { ( result ) in
            completion( result )
        }
    }
    
    /**
       To delete a Note of the ZCRMRecord
     
     - Parameters:
         - id: Id of the ZCRMNote to be deleted
         - requestHeaders : Headers that needs to be included in the request
         - completion :
            - Success : Returns an APIResponse of the delete operation
            - Failure : ZCRMError
     */
    public func deleteNote( id : Int64, requestHeaders : [ String : String ], completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).deleteNote( noteId : id, requestHeaders: requestHeaders ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of notes of the ZCRMRecord(BulkAPIResponse).
    ///
    /// - Returns: list of notes of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get notes of the ZCRMRecord
    public func getNotes( completion : @escaping( ZCRMResult.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList :  ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).getNotes( withParams : ZCRMQuery.getEntityRequestParams ) { ( result ) in
            completion( result )
        }
    }
    
    /**
     Returns list of notes of the ZCRMRecord of a requested params.
     
     - Parameters:
        - withParams : GetFieldParams Which defines the params required to get the records.
        - completion : Returns an array of ZCRMNotes and a BulkAPIResponse
     */
    public func getNotes( withParams : GETEntityRequestParams, completion : @escaping ( ZCRMResult.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> Void )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).getNotes( withParams : withParams ) { ( result ) in
            completion( result )
        }
    }
    
    public func getNote( id : Int64, completion : @escaping( ZCRMResult.DataResponse< ZCRMNote, APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).getNote( noteId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getMails( params : ZCRMQuery.GetEmailParams? = nil, completion : @escaping ( ZCRMResult.DataResponse< [ ZCRMEmail ], BulkAPIResponse >) -> ())
    {
        EmailAPIHandler().viewMails(record: self, params: params ?? ZCRMQuery.GetEmailParams()) { result in
            completion( result )
        }
    }
    
    /// To get list of all attachments of the ZCRMRecord(BulkAPIResponse).
    ///
    /// - Returns: list of all attachments of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get the list of attachments
    public func getAttachments( completion : @escaping( ZCRMResult.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> ())
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).getAttachments( withParams : ZCRMQuery.getEntityRequestParams ) { ( result ) in
            completion( result )
        }
    }
    
    /**
     To get list of all attachments of the ZCRMRecord of a requested params.
     
     - Parameters:
        - withParams : GetFieldParams Which defines the params required to get the records.
        - completion : Returns an array of ZCRMAttachment and a BulkAPIResponse
     */
    public func getAttachments( withParams : GETEntityRequestParams, completion : @escaping ( ZCRMResult.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> Void )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).getAttachments( withParams : withParams ) { ( result ) in
            completion( result )
        }
    }
    
    /// To download a Attachment from the ZCRMRecord, it returns file as data, then it can be converted to a file.
    ///
    /// - Parameter id: Id of the attachment to be downloaded
    /// - Returns: FileAPIResponse containing the data of the file downloaded.
    /// - Throws: ZCRMSDKError if failed to download the attachment
    public func downloadAttachment(id: Int64, completion : @escaping( ZCRMResult.Response< FileAPIResponse > ) -> ())
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).downloadAttachment( attachmentId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadAttachment( id : Int64, fileDownloadDelegate : ZCRMFileDownloadDelegate ) throws
    {
        try RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).downloadAttachment( attachmentId : id, fileDownloadDelegate : fileDownloadDelegate )
    }
    
    public func deleteAttachment( id : Int64, completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).deleteAttachment( attachmentId : id ) { ( result ) in
            completion( result )
        }
    }
    
    /// To upload a Attachment to the ZCRMRecord.
    ///
    /// - Parameter filePath: file path of the attachment
    /// - Returns: APIResponse of the attachment upload
    /// - Throws: ZCRMSDKError if failed to upload the attachment
    public func uploadAttachment( filePath : String, completion : @escaping( ZCRMResult.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName) ).uploadAttachment( filePath : filePath, fileName : nil, fileData : nil, note : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadAttachment( fileRefId : String, filePath : String, attachmentUploadDelegate : ZCRMAttachmentUploadDelegate )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName)).uploadAttachment( fileRefId : fileRefId, filePath : filePath, fileName : nil, fileData : nil, note : nil , attachmentUploadDelegate: attachmentUploadDelegate)
    }
    
    public func uploadAttachment( fileName : String, fileData : Data, completion : @escaping( ZCRMResult.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).uploadAttachment( filePath : nil, fileName : fileName, fileData : fileData, note : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadAttachment( fileRefId : String, fileName : String, fileData : Data, attachmentUploadDelegate : ZCRMAttachmentUploadDelegate )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName)).uploadAttachment( fileRefId : fileRefId, filePath : nil, fileName : fileName, fileData : fileData, note : nil , attachmentUploadDelegate: attachmentUploadDelegate)
    }
    
    /**
      To upload a link as an attachment to a ZCRMRecord
     
     ~~~
     Title is supported from v2.1 version
     ~~~
     
     - Parameters:
         - URL : URL of the link attachment
         - title : Name of the link attachment
         - completion :
             - success : Returns a ZCRMAttachment object and an APIResponse
             - failure : ZCRMError
     */
    public func uploadLinkAsAttachment( URL : String, title : String? = nil, completion : @escaping( ZCRMResult.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        if title != nil && ZCRMSDKClient.shared.apiVersion < "v2.1"
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.notSupported) : Title is not supported in this version - \( ZCRMSDKClient.shared.apiVersion ), \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.notSupported, message : "Title is not supported in this version - \( ZCRMSDKClient.shared.apiVersion )", details : nil ) ) )
            return
        }
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : ZCRMDefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).uploadLinkAsAttachment( attachmentURL : URL, title: title, completion: completion )
    }
    
    public func uploadPhoto( filePath : String, completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).uploadPhoto(filePath: filePath, fileName: nil, fileData: nil) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadPhoto( fileRefId : String, filePath : String, fileUploadDelegate : ZCRMFileUploadDelegate )
    {
        EntityAPIHandler( recordDelegate : self ).uploadPhoto( fileRefId : fileRefId, filePath : filePath, fileName : nil, fileData : nil, fileUploadDelegate : fileUploadDelegate )
    }
    
    public func uploadPhoto( fileName : String, fileData : Data, completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).uploadPhoto( filePath : nil, fileName : fileName, fileData : fileData ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadPhoto( fileRefId : String, fileName : String, fileData : Data, fileUploadDelegate : ZCRMFileUploadDelegate )
    {
        EntityAPIHandler( recordDelegate : self ).uploadPhoto( fileRefId : fileRefId, filePath : nil, fileName : fileName, fileData : fileData, fileUploadDelegate : fileUploadDelegate )
    }
    
    public func downloadPhoto( completion : @escaping( ZCRMResult.Response< FileAPIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).downloadPhoto { ( result ) in
            completion( result )
        }
    }
    
    public func downloadPhoto( fileDownloadDelegate : ZCRMFileDownloadDelegate )
    {
        EntityAPIHandler(recordDelegate: self).downloadPhoto(fileDownloadDelegate: fileDownloadDelegate)
    }
    
    public func deletePhoto( completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
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
    public func addRelation( junctionRecord : ZCRMJunctionRecord, completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, junctionRecord : junctionRecord ).addRelation(completion: { ( result ) in
            completion( result )
        })
    }
    
    public func addRelations( junctionRecords : [ ZCRMJunctionRecord ], completion : @escaping( ZCRMResult.Response< BulkAPIResponse > ) -> () )
    {
        guard let apiName = junctionRecords.first?.apiName else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidOperation) : Junction Records cannot be empty, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.inValidError( code : ZCRMErrorCode.invalidData , message : "Junction Records cannot be empty", details : nil ) ) )
            return
        }
        for junctionRecord in junctionRecords
        {
            if junctionRecord.apiName != apiName
            {
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidOperation) : All relation must be of the same module, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.invalidOperation , message : "All relation must be of the same module", details : nil ) ) )
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
    public func deleteRelation( junctionRecord : ZCRMJunctionRecord, completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, junctionRecord : junctionRecord ).deleteRelation { ( result ) in
            completion( result )
        }
    }
    
    public func deleteRelations( junctionRecords : [ ZCRMJunctionRecord ], completion : @escaping( ZCRMResult.Response< BulkAPIResponse > ) -> () )
    {
        guard let apiName = junctionRecords.first?.apiName else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidOperation) : Junction Records cannot be empty, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.inValidError( code : ZCRMErrorCode.invalidData , message : "Junction Records cannot be empty", details : nil ) ) )
            return
        }
        for junctionRecord in junctionRecords
        {
            if junctionRecord.apiName != apiName
            {
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidOperation) : All relation must be of the same module, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.invalidOperation , message : "All relation must be of the same module", details : nil ) ) )
            }
        }
        RelatedListAPIHandler( parentRecord : self ).deleteRelations( junctionRecords : junctionRecords) { ( result ) in
            completion( result )
        }
    }
}

extension ZCRMRecordDelegate : Hashable
{
    public static func == (lhs: ZCRMRecordDelegate, rhs: ZCRMRecordDelegate) -> Bool {
        return lhs.id == rhs.id &&
            lhs.moduleAPIName == rhs.moduleAPIName &&
            lhs.label == rhs.label
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

let RECORD_DELEGATE_MOCK : ZCRMRecordDelegate = ZCRMRecordDelegate( id : APIConstants.INT64_MOCK, moduleAPIName : APIConstants.STRING_MOCK )
let RECORD_MOCK : ZCRMRecord = ZCRMRecord(moduleAPIName: APIConstants.STRING_MOCK)

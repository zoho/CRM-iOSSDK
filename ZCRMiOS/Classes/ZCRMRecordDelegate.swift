//
//  ZCRMRecordDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 13/09/18.
//
import ZCacheiOS

open class ZCRMRecordDelegate : ZCRMEntity, ZCacheRecord
{
    public var id : String
    public var moduleName : String
    public var layoutId : String?
    public var offlineOwner: ZCacheUser?
    public var offlineCreatedTime: String?
    public var offlineCreatedBy: ZCacheUser?
    public var offlineModifiedTime: String?
    public var offlineModifiedBy: ZCacheUser?
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case moduleName
        case layoutId
        case moduleAPIName
        case label
    }
    
    private struct CustomCodingKeys: CodingKey
    {
        var stringValue: String
        init?(stringValue: String)
        {
            self.stringValue = stringValue
        }
        var intValue: Int?
        init?(intValue: Int)
        {
            return nil
        }
    }
    
    required public init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        moduleName = try values.decode(String.self, forKey: .moduleName)
        layoutId = try values.decodeIfPresent(String.self, forKey: .layoutId)
        moduleAPIName = try values.decode(String.self, forKey: .moduleAPIName)
        label = try values.decodeIfPresent(String.self, forKey: .label)

        let dynamicValues = try! decoder.container(keyedBy: CustomCodingKeys.self)
        for key in dynamicValues.allKeys
        {
            if key.stringValue != "data" && key.stringValue != "upsertJSON"
            {
                if let customKey = key.intValue
                {
                    data[String(customKey)] = try! dynamicValues.decodeIfPresent(JSONValue.self, forKey: key)
                }
                else
                {
                    data[key.stringValue] = try! dynamicValues.decodeIfPresent(JSONValue.self, forKey: key)
                }
            }
        }
    }
    
    open func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        try container.encode( self.id, forKey : .id )
        try container.encode( self.moduleName, forKey : .moduleName )
        try container.encode( self.moduleAPIName, forKey : .moduleAPIName )
        try container.encodeIfPresent( self.label, forKey : .label )
        try container.encodeIfPresent( self.layoutId, forKey : .layoutId )
        
        var customContainer = encoder.container(keyedBy: CustomCodingKeys.self)
        for (key, value) in data
        {
            if let customKey = CustomCodingKeys(stringValue: key)
            {
                try customContainer.encodeIfPresent( value, forKey : customKey )
            }
        }
        for (key, value) in properties
        {
            if let customKey = CustomCodingKeys(stringValue: key)
            {
                try customContainer.encodeIfPresent( value, forKey : customKey )
            }
        }
    }
    
    public func create< T >(completion: @escaping (ResultType.DataResponse<ZCacheResponse, T>) -> Void)
    {
        
    }
    
    public func update< T >(completion: @escaping (ResultType.DataResponse<ZCacheResponse, T>) -> Void)
    {
        
    }
    
    public func delete(completion: @escaping (ResultType.DataResponse<ZCacheResponse, String>) -> Void)
    {
        
    }
    
    public func reset< T >(completion: @escaping (ResultType.DataResponse<ZCacheResponse, T>) -> Void)
    {
        
    }

    public internal(set) var moduleAPIName : String
    public var label : String?
    internal var data : [ String : JSONValue? ] = [ String : JSONValue? ]()
    public internal( set ) var properties : [ String : JSONValue? ] = [ String : JSONValue? ]()
    
    init ( id : String, moduleAPIName : String )
    {
        self.id = id
        self.moduleAPIName = moduleAPIName
        self.moduleName = moduleAPIName
    }
    
    /**
      Returns the ZCRMRecordDelegate's fieldAPIName vs field value dictionary
     
     - Returns: ZCRMRecordDelegate's fieldAPIName vs field value dictionary
     */
    public func getData() -> [ String : JSONValue? ]
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
        let value = self.properties.optValue( key : ofProperty )
        return JSONValue(value: value)
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
            let value = self.data.optValue( key : ofFieldAPIName )
            return JSONValue(value: value)
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.fieldNotFound) : The given field is not present in the record. Field Name -> \( ofFieldAPIName )")
            throw ZCRMError.processingError( code : ErrorCode.fieldNotFound, message : "The given field is not present in the record. Field Name -> \( ofFieldAPIName )", details : nil )
        }
    }
    
    /// Set the value of the ZCRMRecord's property.
    ///
    /// - Parameters:
    ///   - ofProperty: property whose value is to be change.
    ///   - value: value of the ZCRMRecord's property
    public func setValue( ofProperty : String, value : Any? )
    {
        self.properties.updateValue( JSONValue(value: value), forKey : ofProperty )
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
    
    /// Returns the API response of the ZCRMRecord delete.
    ///
    /// - Returns: API response of the ZCRMRecord delete
    /// - Throws: ZCRMSDKError if Entity ID of the record is nil
    public func delete( completion : @escaping( CRMResultType.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).deleteRecord { ( result ) in
            completion( result )
        }
    }
    
    /// Convert the ZCRMRecord(Leads to Contacts) and Returns dictionary containing deal, contact and account vs its ID of the converted ZCRMecord.
    ///
    /// - Returns: dictionary containing deal, contact and account vs its ID of the converted ZCRMRecord
    /// - Throws: ZCRMSDKError if the ZCRMRecord is not convertible
    public func convert( completion : @escaping( CRMResultType.DataResponse< [ String : Int64 ], APIResponse > ) -> () )
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
    public func convert( newPotential : ZCRMRecord, completion : @escaping( CRMResultType.DataResponse< [ String : Int64 ], APIResponse > ) -> () )
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
    public func convert(newPotential: ZCRMRecord?, assignTo: ZCRMUser?, completion : @escaping( CRMResultType.DataResponse< [ String : Int64 ], APIResponse > ) -> () )
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
    public func addNote(note: ZCRMNote, completion : @escaping( CRMResultType.DataResponse< ZCRMNote, APIResponse > ) -> () )
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
    
    public func addTags( tags : [ String ], completion : @escaping( CRMResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).addTags( tags : tags, overWrite : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func addTags( tags : [ String ], overWrite : Bool?, completion : @escaping( CRMResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).addTags( tags : tags, overWrite : overWrite ) { ( result ) in
            completion( result )
        }
    }
    
    public func removeTags( tags : [ String ], completion : @escaping( CRMResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
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
    public func updateNote(note: ZCRMNote, completion : @escaping( CRMResultType.DataResponse< ZCRMNote, APIResponse > ) -> ())
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
    
    /// To delete a Note of the ZCRMRecord
    ///
    /// - Parameter id: Id of the ZCRMNote to be deleted
    /// - Returns: APIResponse of the note deletion
    /// - Throws: ZCRMSDKError if Note id is nil
    public func deleteNote( id : Int64, completion : @escaping( CRMResultType.Response< APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).deleteNote( noteId : id ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of notes of the ZCRMRecord(BulkAPIResponse).
    ///
    /// - Returns: list of notes of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get notes of the ZCRMRecord
    public func getNotes( completion : @escaping( CRMResultType.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList :  ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).getNotes( withParams : ZCRMQuery.getEntityRequestParams ) { ( result ) in
            completion( result )
        }
    }
    
    /**
     Returns list of notes of the ZCRMRecord of a requested params.
     
     - Parameters:
        - withParams : GetFieldParams Which defines the params required to get the records.
        - completion : Returns an array of ZCRMNotes and a BulkAPIResponse
     */
    public func getNotes( withParams : GETEntityRequestParams, completion : @escaping ( CRMResultType.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> Void )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).getNotes( withParams : withParams ) { ( result ) in
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
    @available(*, deprecated, message: "Use the method getNotes( withParams : GETEntityRequestParams, completion : ) instead" )
    public func getNotes( page : Int, perPage : Int, completion : @escaping( CRMResultType.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> () )
    {
        var params = ZCRMQuery.getEntityRequestParams
        params.page = page
        params.perPage = perPage
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).getNotes( withParams : params ) { ( result ) in
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
    @available(*, deprecated, message: "Use the method getNotes( withParams : GETEntityRequestParams, completion : ) instead" )
    public func getNotes( sortByField : String, sortOrder : SortOrder, completion : @escaping( CRMResultType.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> () )
    {
        var params = ZCRMQuery.getEntityRequestParams
        params.sortBy = sortByField
        params.sortOrder = sortOrder
        RelatedListAPIHandler( parentRecord : self, relatedList :  ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).getNotes( withParams : params ) { ( result ) in
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
    @available(*, deprecated, message: "Use the method getNotes( withParams : GETEntityRequestParams, completion : ) instead" )
    public func getNotes(page : Int, perPage : Int, sortByField : String?, sortOrder : SortOrder?, modifiedSince : String?, completion : @escaping( CRMResultType.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> () )
    {
        var params = ZCRMQuery.getEntityRequestParams
        params.page = page
        params.perPage = perPage
        params.sortBy = sortByField
        params.sortOrder = sortOrder
        params.modifiedSince = modifiedSince
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).getNotes( withParams : params ) { ( result ) in
            completion( result )
        }
    }
    
    public func getNote( id : Int64, completion : @escaping( CRMResultType.DataResponse< ZCRMNote, APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.NOTES, parentModuleAPIName : self.moduleAPIName ) ).getNote( noteId : id ) { ( result ) in
            completion( result )
        }
    }
    
    /// To get list of all attachments of the ZCRMRecord(BulkAPIResponse).
    ///
    /// - Returns: list of all attachments of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get the list of attachments
    public func getAttachments( completion : @escaping( CRMResultType.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> ())
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).getAttachments( withParams : ZCRMQuery.getEntityRequestParams ) { ( result ) in
            completion( result )
        }
    }
    
    /**
     To get list of all attachments of the ZCRMRecord of a requested params.
     
     - Parameters:
        - withParams : GetFieldParams Which defines the params required to get the records.
        - completion : Returns an array of ZCRMAttachment and a BulkAPIResponse
     */
    public func getAttachments( withParams : GETEntityRequestParams, completion : @escaping ( CRMResultType.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> Void )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).getAttachments( withParams : withParams ) { ( result ) in
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
    @available(*, deprecated, message: "Use the method getAttachments( withParams : GETEntityRequestParams, completion : ) instead" )
    public func getAttachments( page : Int, perPage : Int, modifiedSince : String?, completion : @escaping( CRMResultType.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> () )
    {
        var params = ZCRMQuery.getEntityRequestParams
        params.page = page
        params.perPage = perPage
        params.modifiedSince = modifiedSince
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).getAttachments( withParams : params ) { ( result ) in
            completion( result )
        }
    }
    
    /// To download a Attachment from the ZCRMRecord, it returns file as data, then it can be converted to a file.
    ///
    /// - Parameter id: Id of the attachment to be downloaded
    /// - Returns: FileAPIResponse containing the data of the file downloaded.
    /// - Throws: ZCRMSDKError if failed to download the attachment
    public func downloadAttachment(id: Int64, completion : @escaping( CRMResultType.Response< FileAPIResponse > ) -> ())
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).downloadAttachment( attachmentId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadAttachment( id : Int64, fileDownloadDelegate : ZCRMFileDownloadDelegate ) throws
    {
        try RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).downloadAttachment( attachmentId : id, fileDownloadDelegate : fileDownloadDelegate )
    }
    
    public func deleteAttachment( id : Int64, completion : @escaping( CRMResultType.Response< APIResponse > ) -> () )
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
    public func uploadAttachment( filePath : String, completion : @escaping( CRMResultType.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName) ).uploadAttachment( filePath : filePath, fileName : nil, fileData : nil, note : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadAttachment( fileRefId : String, filePath : String, attachmentUploadDelegate : ZCRMAttachmentUploadDelegate )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName)).uploadAttachment( fileRefId : fileRefId, filePath : filePath, fileName : nil, fileData : nil, note : nil , attachmentUploadDelegate: attachmentUploadDelegate)
    }
    
    public func uploadAttachment( fileName : String, fileData : Data, completion : @escaping( CRMResultType.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
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
    public func uploadLinkAsAttachment( URL : String, completion : @escaping( CRMResultType.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.moduleAPIName ) ).uploadLinkAsAttachment( attachmentURL : URL ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadPhoto( filePath : String, completion : @escaping( CRMResultType.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).uploadPhoto(filePath: filePath, fileName: nil, fileData: nil) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadPhoto( fileRefId : String, filePath : String, fileUploadDelegate : ZCRMFileUploadDelegate )
    {
        EntityAPIHandler( recordDelegate : self ).uploadPhoto( fileRefId : fileRefId, filePath : filePath, fileName : nil, fileData : nil, fileUploadDelegate : fileUploadDelegate )
    }
    
    public func uploadPhoto( fileName : String, fileData : Data, completion : @escaping( CRMResultType.Response< APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : self ).uploadPhoto( filePath : nil, fileName : fileName, fileData : fileData ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadPhoto( fileRefId : String, fileName : String, fileData : Data, fileUploadDelegate : ZCRMFileUploadDelegate )
    {
        EntityAPIHandler( recordDelegate : self ).uploadPhoto( fileRefId : fileRefId, filePath : nil, fileName : fileName, fileData : fileData, fileUploadDelegate : fileUploadDelegate )
    }
    
    public func downloadPhoto( completion : @escaping( CRMResultType.Response< FileAPIResponse > ) -> () )
    {
        EntityAPIHandler(recordDelegate: self).downloadPhoto { ( result ) in
            completion( result )
        }
    }
    
    public func downloadPhoto( fileDownloadDelegate : ZCRMFileDownloadDelegate )
    {
        EntityAPIHandler(recordDelegate: self).downloadPhoto(fileDownloadDelegate: fileDownloadDelegate)
    }
    
    public func deletePhoto( completion : @escaping( CRMResultType.Response< APIResponse > ) -> () )
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
    public func addRelation( junctionRecord : ZCRMJunctionRecord, completion : @escaping( CRMResultType.Response< APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, junctionRecord : junctionRecord ).addRelation(completion: { ( result ) in
            completion( result )
        })
    }
    
    public func addRelations( junctionRecords : [ ZCRMJunctionRecord ], completion : @escaping( CRMResultType.Response< BulkAPIResponse > ) -> () )
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
    public func deleteRelation( junctionRecord : ZCRMJunctionRecord, completion : @escaping( CRMResultType.Response< APIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self, junctionRecord : junctionRecord ).deleteRelation { ( result ) in
            completion( result )
        }
    }
    
    public func deleteRelations( junctionRecords : [ ZCRMJunctionRecord ], completion : @escaping( CRMResultType.Response< BulkAPIResponse > ) -> () )
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

let RECORD_MOCK : ZCRMRecordDelegate = ZCRMRecordDelegate( id : APIConstants.STRING_MOCK, moduleAPIName : APIConstants.STRING_MOCK )

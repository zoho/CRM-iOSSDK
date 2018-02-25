//
//  ZCRMModuleRelation.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMModuleRelation
{
	private var apiName : String?
	private var parentModuleAPIName : String?
	private var childModuleAPIName : String?
	private var label : String?
	private var id : Int64?
	private var visible : Bool?
	private var isDefault : Bool?
    
    private var parentRecord : ZCRMRecord?
    private var junctionRecord : ZCRMJunctionRecord?
    
    /// Initialize the instance of a ZCRMModuleRelation with the given module and related list
    ///
    /// - Parameters:
    ///   - relatedListAPIName: relatedListAPIName whose instance to be initialized
    ///   - parentModuleAPIName: parentModuleAPIName to get that module's relation
    public init( relatedListAPIName : String, parentModuleAPIName : String )
    {
        self.apiName = relatedListAPIName
        self.parentModuleAPIName = parentModuleAPIName
    }
    
    /// Initialize the instance of a ZCRMModuleRelation with the given record and related list.
    ///
    /// - Parameters:
    ///   - parentRecord: parentRecord to get that record's related list
    ///   - junctionRecord: junction record
    public init( parentRecord : ZCRMRecord, junctionRecord : ZCRMJunctionRecord )
    {
        self.parentRecord = parentRecord
        self.junctionRecord = junctionRecord
    }
	
    /// Returns related list apiname
    ///
    /// - Returns: related list apiname
	public func getAPIName() -> String
	{
		return self.apiName!
	}
	
    /// Returns module apiname.
    ///
    /// - Returns: module apiname
	public func getParentModuleAPIName() -> String
	{
		return self.parentModuleAPIName!
	}
	
    /// Set the child module apiname
    ///
    /// - Parameter childModuleAPIName: child module apiname
	internal func setChildModuleAPIName(childModuleAPIName : String?)
	{
		self.childModuleAPIName = childModuleAPIName
	}
	
    /// Returns the child module api name.
    ///
    /// - Returns: child module api name
	public func getChildModuleAPIName() -> String?
	{
		return self.childModuleAPIName
	}
	
    /// Set related list label.
    ///
    /// - Parameter label: related list label
	internal func setLabel(label : String?)
	{
		self.label = label
	}
	
    /// Returns the related list label
    ///
    /// - Returns: related list label
	public func getDisplayLabel() -> String?
	{
		return self.label
	}
	
    /// Set the related list id
    ///
    /// - Parameter relatedListId: related list id
	internal func setId(relatedListId : Int64?)
	{
		self.id = relatedListId
	}
	
    /// Returns the related list id
    ///
    /// - Returns: related list id
	public func getId() -> Int64?
	{
		return self.id
	}
	
    /// Set true if related list is visible.
    ///
    /// - Parameter isVisible: true if related list is visible
	internal func setVisibility(isVisible : Bool?)
	{
		self.visible = isVisible
	}
	
    /// Return true if related list is visible.
    ///
    /// - Returns: true if related list is visible
	public func isVisible() -> Bool?
	{
		return self.visible
	}
	
    /// Set true if related list is defult.
    ///
    /// - Parameter isDefault: true if related list is defult
	internal func setIsDefaultRelatedList(isDefault : Bool?)
	{
		self.isDefault = isDefault
	}
	
    /// Returns true if related list is defult
    ///
    /// - Returns: true if related list is defult
	public func isDefaultRelatedList() -> Bool?
	{
		return self.isDefault
	}
	
    /// Return list of related records of the module(BulkAPIResponse).
    ///
    /// - Parameter ofParentRecord: list of records of the module
    /// - Returns: list of related records of the module
    /// - Throws: ZCRMSDKError if falied to get related records
	public func getRelatedRecords(ofParentRecord: ZCRMRecord) throws -> BulkAPIResponse
	{
		return try self.getRelatedRecords(ofParentRecord: ofParentRecord, page: 1, per_page: 20, sortByField: nil, sortOrder: nil, modifiedSince: nil)
	}
	
    /// Returns list of all records of the module of a requested page number with records of per_page count, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - ofParentRecord: list of records of the module
    ///   - page: page number of the module
    ///   - per_page: number of records to be given for a single page.
    ///   - sortByField: field by which the module get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - modifiedSince: modified time
    /// - Returns: sorted list of module of the ZCRMRecord of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if falied to get related records
	public func getRelatedRecords(ofParentRecord: ZCRMRecord, page: Int, per_page: Int, sortByField: String?, sortOrder: SortOrder?, modifiedSince: String?) throws -> BulkAPIResponse
	{
		return try RelatedListAPIHandler(parentRecord: ofParentRecord, relatedList: self).getRecords(page: page, per_page: per_page, sortByField: sortByField, sortOrder: sortOrder, modifiedSince: modifiedSince)
	}
	
    /// To add a new Note to the Record
    ///
    /// - Parameters:
    ///   - note: ZCRMNote to be added
    ///   - toRecord: note to be added in the ZCRMRecord
    /// - Returns: APIResponse of the note addition
    /// - Throws: ZCRMSDKError if failed to add note
	public func addNote(note: ZCRMNote, toRecord: ZCRMRecord) throws -> APIResponse
	{
		return try RelatedListAPIHandler(parentRecord: toRecord, relatedList: self).addNote(note: note)
	}
	
    /// To update a Note of the Record
    ///
    /// - Parameters:
    ///   - note: ZCRMNote to be updated
    ///   - ofRecord: note to be updated in the ZCRMRecord
    /// - Returns: APIResponse of the note update
    /// - Throws: ZCRMSDKError if failed to update note
	public func updateNote(note: ZCRMNote, ofRecord: ZCRMRecord) throws -> APIResponse
	{
		return try RelatedListAPIHandler(parentRecord: ofRecord, relatedList: self).updateNote(note: note)
	}
	
    /// To delete a Note of the Record
    ///
    /// - Parameters:
    ///   - note: ZCRMNote to be deleted
    ///   - ofRecord: note to be deleted in the ZCRMRecord
    /// - Returns: APIResponse of the note deletion
    /// - Throws: ZCRMSDKError if failed to delete note
	public func deleteNote(note: ZCRMNote, ofRecord: ZCRMRecord) throws -> APIResponse
	{
		return try RelatedListAPIHandler(parentRecord: ofRecord, relatedList: self).deleteNote(note: note)
	}
	
    /// Returns list of notes of the ZCRMRecord(BulkAPIResponse).
    ///
    /// - Parameter ofParentRecord: ZCRMRecord which return all notes
    /// - Returns: list of notes of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get notes of the ZCRMRecord
	public func getNotes(ofParentRecord : ZCRMRecord) throws -> BulkAPIResponse
	{
		return try self.getNotes(ofParentRecord: ofParentRecord, page: 1, per_page: 20, sortByField: nil, sortOrder: nil, modifiedSince: nil)
	}
	
    /// Returns list of all notes of the ZCRMRecord of a requested page number with notes of per_page count, before returning the list of notes gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - ofParentRecord: ZCRMRecord which return all notes
    ///   - page: page number of the notes
    ///   - per_page: number of notes to be given for a single page.
    ///   - sortByField: field by which the notes get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - modifiedSince: modified time
    /// - Returns: list of all notes of the ZCRMRecord of a requested page number with notes of per_page count, before returning the list of notes gets sorted with the given field and sort order
    /// - Throws: ZCRMSDKError if failed to get notes of the ZCRMRecord
    public func getNotes(ofParentRecord : ZCRMRecord, page : Int, per_page : Int, sortByField : String?, sortOrder : SortOrder?, modifiedSince : String? ) throws -> BulkAPIResponse
	{
        return try RelatedListAPIHandler( parentRecord : ofParentRecord, relatedList : self ).getNotes(page: page, per_page: per_page, sortByField: sortByField, sortOrder: sortOrder, modifiedSince: modifiedSince)
	}
	
    /// To get list of all attachments of the ZCRMRecord(BulkAPIResponse).
    ///
    /// - Parameter ofParentRecord: ZCRMRecord to which retuns all the attachments
    /// - Returns: list of all attachments of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get attachments of the ZCRMRecord
	public func getAttachments(ofParentRecord : ZCRMRecord) throws -> BulkAPIResponse
	{
        return try self.getAttachments(ofParentRecord: ofParentRecord, page: 1, per_page: 20, modifiedSince : nil )
	}
	
    /// Returns list of all attachments of the ZCRMRecord of a requested page number with attachments of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - ofParentRecord: ZCRMRecord to which retuns all the attachments
    ///   - page: page number of the attachments
    ///   - per_page: number of attachments to be given for a single page.
    ///   - modifiedSince: modified time
    /// - Returns: list of all attachments of the ZCRMRecord of a requested page number with attachments of per_page count(BulkAPIResponse).
    /// - Throws: ZCRMSDKError if failed to get attachments of the ZCRMRecord
    public func getAttachments(ofParentRecord : ZCRMRecord, page : Int, per_page : Int, modifiedSince : String?) throws -> BulkAPIResponse
	{
		return try RelatedListAPIHandler(parentRecord: ofParentRecord, relatedList: self).getAllAttachmentsDetails(page: page, per_page: per_page, modifiedSince: modifiedSince)
	}
	
    /// To download a Attachment from the ZCRMRecord, it returns file as data, then it can be converted to a file.
    ///
    /// - Parameters:
    ///   - ofParentRecord: ZCRMRecord which has the attachment
    ///   - attachmentId: Id of the attachment to be downloaded
    /// - Returns: FileAPIResponse containing the data of the file downloaded.
    /// - Throws: ZCRMSDKError if failed to download the attachment
	public func downloadAttachment(ofParentRecord: ZCRMRecord, attachmentId: Int64) throws -> FileAPIResponse
	{
		return try RelatedListAPIHandler(parentRecord: ofParentRecord, relatedList: self).downloadAttachment(attachmentId: attachmentId)
	}
    
    /// To delete a Attachment from the ZCRMRecord.
    ///
    /// - Parameters:
    ///   - ofParentRecord: ZCRMRecord which has the attachment
    ///   - attachmentId: Id of the attachment to be deleted
    /// - Returns: APIResponse of the file deleted
    /// - Throws: ZCRMSDKError if failed to delete the attachment
    public func deleteAttachment( ofParentRecord : ZCRMRecord, attachmentId : Int64 ) throws -> APIResponse
    {
        return try RelatedListAPIHandler( parentRecord : ofParentRecord, relatedList : self ).deleteAttachment( attachmentId : attachmentId )
    }
    
    /// To upload a Attachment to the ZCRMRecord.
    ///
    /// - Parameters:
    ///   - ofParentRecord: ZCRMRecord which has the attachment
    ///   - filePath: file path of the attachment
    /// - Returns: APIResponse of the attachment upload
    /// - Throws: ZCRMSDKError if failed to upload the attachment
    public func uploadAttachment( ofParentRecord : ZCRMRecord, filePath : String ) throws -> APIResponse
    {
        try fileDetailCheck( filePath : filePath )
        return try RelatedListAPIHandler( parentRecord : ofParentRecord, relatedList : self ).uploadAttachment( filePath : filePath )
    }
    
    /// To upload a Attachment from attachmentUrl to the ZCRMRecord.
    ///
    /// - Parameters:
    ///   - ofParentRecord: ZCRMRecord which has the attachment
    ///   - attachmentURL: URL of the attachment
    /// - Returns: APIResponse of the attachment upload
    /// - Throws: ZCRMSDKError if failed to upload the attachment
    public func uploadLinkAsAttachment( ofParentRecord : ZCRMRecord, attachmentURL : String ) throws -> APIResponse
    {
        return try RelatedListAPIHandler( parentRecord : ofParentRecord, relatedList : self ).uploadLinkAsAttachment( attachmentURL : attachmentURL )
    }
    
    /// To add the association between Records.
    ///
    /// - Returns: APIResponse of the added relation.
    /// - Throws: ZCRMSDKError if failed to add the relation
    public func addRelation() throws -> APIResponse
    {
        return try RelatedListAPIHandler( parentRecord : parentRecord!, junctionRecord : junctionRecord! ).addRelation()
    }
    
    /// To delete the association between Records.
    ///
    /// - Returns: APIResponse of the delete relation.
    /// - Throws: ZCRMSDKError if failed to delete the relation
    public func deleteRelation() throws -> APIResponse
    {
        return try RelatedListAPIHandler( parentRecord : parentRecord!, junctionRecord : junctionRecord! ).deleteRelation()
    }
}

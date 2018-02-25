//
//  ZCRMNote.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 15/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMNote : ZCRMEntity
{
	private var id : Int64?
	private var title : String?
	private var content : String?
	private var owner : ZCRMUser?
	private var createdBy : ZCRMUser?
	private var createdTime : String?
	private var modifiedBy : ZCRMUser?
	private var modifiedTime : String?
    private var attachments : [ZCRMAttachment]?
    private var parentRecord : ZCRMRecord?
	
    /// Initialize the instance of ZCRMNote with the given content
    ///
    /// - Parameter content: note content
	public init(content : String)
	{
		self.content = content
	}
	
    /// Initialize the instance of ZCRMNote with the given note id and given content.
    ///
    /// - Parameters:
    ///   - noteId: id to get that note's instance
    ///   - newContent: note content
	public init(noteId: Int64, newContent: String)
	{
		self.id = noteId
		self.content = newContent
	}
	
    /// Initialize the instance of ZCRMNote with the given note id
    ///
    /// - Parameter noteId: id to get that note's instance
	public init(noteId: Int64)
	{
		self.id = noteId
	}
    
    /// Initialize the instance of ZCRMNote with the given ZCRMRecord and given note id
    ///
    /// - Parameters:
    ///   - parentRecord: ZCRMRecord for which ZCRMNote instance initialized
    ///   - noteId: id to get that note's instance
    public init( parentRecord : ZCRMRecord, noteId : Int64 )
    {
        self.parentRecord = parentRecord
        self.id = noteId
    }
    
    /// Initialize the instance of ZCRMNote with the given ZCRMRecord
    ///
    /// - Parameter record: ZCRMRecord for which ZCRMNote instance initialized
    public init( record : ZCRMRecord )
    {
        self.parentRecord = record
    }
    
    /// Returns note's ZCRMRecord
    ///
    /// - Returns: <#return value description#>
    public func getParentRecord() -> ZCRMRecord
    {
        return self.parentRecord!
    }
    
    /// Add a note content
    ///
    /// - Parameter content: note content
    internal func setContent( content : String? )
    {
        self.content = content
    }
	
    /// Returns the note's content
    ///
    /// - Returns: note's content
	public func getContent() -> String
	{
		return self.content!
	}
	
    /// Set the id of the note
    ///
    /// - Parameter noteId: id of the note
	internal func setId(noteId : Int64?)
	{
		self.id = noteId
	}
	
    /// Returns the id of the note
    ///
    /// - Returns: id of the note
	public func getId() -> Int64?
	{
		return self.id
	}
	
    /// Set the title of the note
    ///
    /// - Parameter title: note's title
	public func setTitle(title : String?)
	{
		self.title = title
	}
	
    /// Returns the title of the note
    ///
    /// - Returns: note's title
	public func getTitle() -> String?
	{
		return self.title
	}
	
    /// Set the ZCRMUser who adds the note.
    ///
    /// - Parameter owner: ZCRMUser who adds the note
	internal func setOwner(owner : ZCRMUser?)
	{
		self.owner = owner
	}
	
    /// Returns ZCRMUser who added the note.
    ///
    /// - Returns: ZCRMUser who added the note
	public func getOwner() -> ZCRMUser?
	{
		return self.owner
	}
	
    /// Set ZCRMUser who created the note.
    ///
    /// - Parameter createdByUser: ZCRMUser who created the note
	internal func setCreatedByUser(createdByUser : ZCRMUser?)
	{
		self.createdBy = createdByUser
	}
	
    /// Returns ZCRMUser who created the note or nil if the note is not yet created.
    ///
    /// - Returns: ZCRMUser who created the note or nil if the note is not yet created
	public func getCreatedByUser() -> ZCRMUser?
	{
		return self.createdBy
	}
	
    /// Set created time of the note.
    ///
    /// - Parameter createdTime: the time at which the note is created
	internal func setCreatedTime(createdTime : String?)
	{
		self.createdTime = createdTime
	}
	
    /// Returns created time of the note.
    ///
    /// - Returns: the time at which the note is created
	public func getCreatedTime() -> String?
	{
		return self.createdTime
	}
	
    /// Set ZCRMUser who recently modified the note(last modification of the note) or nil if the note is not yet created/modified.
    ///
    /// - Parameter modifiedByUser: ZCRMUser who modified the note
	internal func setModifiedByUser(modifiedByUser : ZCRMUser?)
	{
		self.modifiedBy = modifiedByUser
	}
	
    ///  Returns ZCRMUser who recently modified the note(last modification of the note) or nil if the note is not yet created/modified.
    ///
    /// - Returns: ZCRMUser who recently modified the note or nil if the note is not yet created/modifie
	public func getModifiedByUser() -> ZCRMUser?
	{
		return self.modifiedBy
	}
	
    /// Set modified time of the note(last modification of the note).
    ///
    /// - Parameter modifiedTime: the time at which the note is modified
	internal func setModifiedTime(modifiedTime : String?)
	{
		self.modifiedTime = modifiedTime
	}
	
    /// Returns modified time of the note(last modification of the note) or nil if the note is not yet created.
    ///
    /// - Returns: the time at which the note is modified or nil if the note is not yet created
	public func getModifiedTime() -> String?
	{
		return self.modifiedTime
	}
    
    /// To add attachment to the note(Only for internal use).
    ///
    /// - Parameter attachment: add attachment to the note
    internal func addAttachment(attachment : ZCRMAttachment)
    {
        if( self.attachments != nil )
        {
            self.attachments?.append(attachment)
        }
        else
        {
            self.attachments = [ attachment ]
        }
    }
    
    /// To get list of all attachments of the note.
    ///
    /// - Returns: list of all attachments of the note
    public func getAttachments() -> [ZCRMAttachment]?
    {
        return self.attachments
    }
    
    /// To upload a Attachment to the note.
    ///
    /// - Parameter filePath: file path of the attachment
    /// - Returns: APIResponse of the attachment upload
    /// - Throws: ZCRMSDKError if failed to upload the attachment
    public func uploadAttachment(filePath : String) throws -> APIResponse
    {
        return try ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: "Notes").uploadAttachment(ofParentRecord: ZCRMRecord(moduleAPIName: "Notes", recordId: self.getId()!), filePath: filePath)
    }
    
    /// To download a Attachment from the note, it returns file as data, then it can be converted to a file.
    ///
    /// - Parameter attachmentId: Id of the attachment to be downloaded
    /// - Returns: FileAPIResponse containing the data of the file downloaded.
    /// - Throws: ZCRMSDKError if failed to download the attachment
    public func downloadAttachment(attachmentId : Int64) throws -> FileAPIResponse
    {
        return try ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: "Notes").downloadAttachment(ofParentRecord: ZCRMRecord(moduleAPIName: "Notes", recordId: self.getId()!), attachmentId: attachmentId)
    }
    
    /// To delete a Attachment from the note.
    ///
    /// - Parameter attachmentId: Id of the attachment to be deleted
    /// - Returns: APIResponse of the file deleted.
    /// - Throws: ZCRMSDKError if failed to delete the attachment
    public func deleteAttachment( attachmentId : Int64 ) throws -> APIResponse
    {
        return try ZCRMModuleRelation( relatedListAPIName : "Attachments", parentModuleAPIName : "Notes" ).deleteAttachment( ofParentRecord : ZCRMRecord( moduleAPIName : "Notes", recordId : self.getId()! ), attachmentId : attachmentId )
    }
}

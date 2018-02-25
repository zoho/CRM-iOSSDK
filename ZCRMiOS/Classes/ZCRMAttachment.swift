//
//  ZCRMAttachment.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 15/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMAttachment : ZCRMEntity
{
	private var id : Int64
	private var fileName : String?
	private var fileType : String?
	private var fileSize : Int64?
	private var owner : ZCRMUser?
	private var createdBy : ZCRMUser?
	private var createdTime : String?
	private var modifiedBy : ZCRMUser?
	private var modifiedTime : String?
	
	private var parentRecord: ZCRMRecord
	
    /// Initialise the instance of a attachment for the given record with given note attachment Id
    ///
    /// - Parameters:
    ///   - parentRecord: A record for which attachment instance is to be initialized
    ///   - attachmentId: id to get that attachment detail
	internal init(parentRecord: ZCRMRecord, attachmentId : Int64)
	{
		self.id = attachmentId
		self.parentRecord = parentRecord
	}
    
    /// Returns attachment record
    ///
    /// - Returns: attachment record
    public func getParentRecord() -> ZCRMRecord
    {
        return self.parentRecord
    }
	
    ///  Returns Id of the attachment.
    ///
    /// - Returns: Id of the attachment
	public func getId() -> Int64
	{
		return self.id
	}
	
    /// Set name of the attachment.
    ///
    /// - Parameter fileName: name of the attachment
	internal func setFileName(fileName : String?)
	{
		self.fileName = fileName
	}
	
    /// Returns name of the attachment.
    ///
    /// - Returns: name of the attachmen
	public func getFileName() -> String?
	{
		return self.fileName
	}
	
    /// Set the file type of the attachment.
    ///
    /// - Parameter type: file type of the attachment
	internal func setFileType(type : String?)
	{
		self.fileType = type
	}
	
    /// Returns file type of the attachment.
    ///
    /// - Returns: file type of the attachment
	public func getFileType() -> String?
	{
		return self.fileType
	}
	
    /// Set the size of the attachment.
    ///
    /// - Parameter size: size of the attachment
	internal func setFileSize(size : Int64?)
	{
		self.fileSize = size
	}
	
    /// Returns size of the attachment
    ///
    /// - Returns: size of the attachment
	public func getFileSize() -> Int64?
	{
		return self.fileSize
	}
	
    /// Set the ZCRMUser who adds the attachment.
    ///
    /// - Parameter owner: ZCRMUser who adds the attachment
	internal func setOwner(owner : ZCRMUser?)
	{
		self.owner = owner
	}
	
    /// Returns ZCRMUser who added the attachment.
    ///
    /// - Returns: ZCRMUser who added the attachment
	public func getOwner() -> ZCRMUser?
	{
		return self.owner
	}
	
    /// Set ZCRMUser who created the attachment.
    ///
    /// - Parameter createdByUser: ZCRMUser who created the attachment
	internal func setCreatedByUser(createdByUser : ZCRMUser?)
	{
		self.createdBy = createdByUser
	}
	
    ///  Returns ZCRMUser who created the attachment or nil if the attachment is not yet created.
    ///
    /// - Returns: ZCRMUser who created the attachment or nil if the attachment is not yet created
	public func getCreatedByUser() -> ZCRMUser?
	{
		return self.createdBy
	}
	
    /// Set created time of the attachment.
    ///
    /// - Parameter createdTime: the time at which the attachment is created
	internal func setCreatedTime(createdTime : String?)
	{
		self.createdTime = createdTime
	}
	
    /// Returns created time of the attachment.
    ///
    /// - Returns: the time at which the attachment is created
	public func getCreatedTime() -> String?
	{
		return self.createdTime
	}
	
    /// Set ZCRMUser who recently modified the attachment(last modification of the attachment) or nil if the attachment is not yet modified.
    ///
    /// - Parameter modifiedByUser: ZCRMUser who modified the attachment
	internal func setModifiedByUser(modifiedByUser : ZCRMUser?)
	{
		self.modifiedBy = modifiedByUser
	}
	
    ///  Returns ZCRMUser who recently modified the attachment(last modification of the attachment) or nil if the attachment is not yet modified.
    ///
    /// - Returns: ZCRMUser who recently modified the attachment or nil if the attachment is not yet modified
	public func getModifiedByUser() -> ZCRMUser?
	{
		return self.modifiedBy
	}
	
    /// Set modified time of the attachment(last modification of the attachment).
    ///
    /// - Parameter modifiedTime: the time at which the attachment is modified
	internal func setModifiedTime(modifiedTime : String?)
	{
		self.modifiedTime = modifiedTime
	}
	
    /// Returns modified time of the attachment(last modification of the attachment) or nil if the attachment is not yet modified.
    ///
    /// - Returns: the time at which the attachment is modified or nil if the attachment is not yet modified
	public func getModifiedTime() -> String?
	{
		return self.modifiedTime
	}
	
    /// To download Attachment, it returns file as data, then it can be converted to a file.
    ///
    /// - Returns: FileAPIResponse containing the data of the file downloaded.
    /// - Throws: ZCRMSDkError if failed to download the attachment
	public func downloadFile() throws -> FileAPIResponse
	{
		return try ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: self.parentRecord.getModuleAPIName()).downloadAttachment(ofParentRecord: self.parentRecord, attachmentId: self.getId())
	}
    
}

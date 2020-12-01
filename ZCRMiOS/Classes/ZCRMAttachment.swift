//
//  ZCRMAttachment.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 15/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMAttachment : ZCRMEntity
{
    public internal( set ) var parentRecord : ZCRMRecordDelegate
    public internal( set ) var fileExtension : String?
    public internal( set ) var fileSize : Int64?
    public internal( set ) var owner : ZCRMUserDelegate = USER_MOCK
    public internal( set ) var createdBy : ZCRMUserDelegate = USER_MOCK
    public internal( set ) var createdTime : String = APIConstants.STRING_MOCK
    public internal( set ) var modifiedBy : ZCRMUserDelegate = USER_MOCK
    public internal( set ) var modifiedTime : String  = APIConstants.STRING_MOCK
    public internal( set ) var type : String?
    
    public internal( set ) var isEditable : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var linkURL : String?
    public internal( set ) var fileName : String?
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    
    /// Initialise the instance of a attachment for the given record with given note attachment Id
    ///
    /// - Parameters:
    ///   - parentRecord: A record for which attachment instance is to be initialized
    ///   - fileName: name to get that attachment detail
    init( parentRecord : ZCRMRecordDelegate )
    {
        self.parentRecord = parentRecord
    }
    
    /// To download Attachment, it returns file as data, then it can be converted to a file.
    ///
    /// - Returns: FileAPIResponse containing the data of the file downloaded.
    /// - Throws: ZCRMSDkError if failed to download the attachment
    public func downloadFile( completion : @escaping( ResultType.Response< FileAPIResponse > ) -> () )
    {
        RelatedListAPIHandler( parentRecord : self.parentRecord, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames.ATTACHMENTS, parentModuleAPIName : self.parentRecord.moduleAPIName ) ).downloadAttachment( attachmentId : self.id ) { ( result ) in
            completion( result )
        }
    }
    
    /// To download attachment, it returns file as data, then it can be converted to a file.
    ///
    /// - Parameters:
    ///   - fileDownloadDelegate: The object that confirmed to the file download delegate
    /// - Returns: The progress of the file being downloaded and the FileAPIResponse containing the data of the file downloaded.
    /// - Throws: ZCRMSDKError if failed to download the attachment
    public func downloadFile( fileDownloadDelegate : ZCRMFileDownloadDelegate ) throws
    {
        try RelatedListAPIHandler( parentRecord : self.parentRecord, relatedList : ZCRMModuleRelation( relatedListAPIName : DefaultModuleAPINames
            .ATTACHMENTS, parentModuleAPIName : self.parentRecord.moduleAPIName ) ).downloadAttachment( attachmentId : self.id, fileDownloadDelegate : fileDownloadDelegate )
    }
}

extension ZCRMAttachment : Hashable
{
    public static func == (lhs: ZCRMAttachment, rhs: ZCRMAttachment) -> Bool
    {
        let equals : Bool = lhs.parentRecord == rhs.parentRecord &&
            lhs.fileExtension == rhs.fileExtension &&
            lhs.fileSize == rhs.fileSize &&
            lhs.owner == rhs.owner &&
            lhs.createdBy == rhs.createdBy &&
            lhs.createdTime == rhs.createdTime &&
            lhs.modifiedBy == rhs.modifiedBy &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.type == rhs.type &&
            lhs.isEditable == rhs.isEditable &&
            lhs.linkURL == rhs.linkURL &&
            lhs.fileName == rhs.fileName &&
            lhs.id == rhs.id
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

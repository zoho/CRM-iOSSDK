//
//  ZCRMAttachmentDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 12/09/18.
//

open class ZCRMAttachmentDelegate : ZCRMEntity
{
    var attachmentId : Int64
    var parentRecord : ZCRMRecordDelegate
    
    init( attachmentId : Int64, parentRecord : ZCRMRecordDelegate )
    {
        self.attachmentId = attachmentId
        self.parentRecord = parentRecord
    }
    
    /// To download Attachment, it returns file as data, then it can be converted to a file.
    ///
    /// - Returns: FileAPIResponse containing the data of the file downloaded.
    /// - Throws: ZCRMSDkError if failed to download the attachment
    public func downloadFile( completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: self.parentRecord.moduleAPIName).downloadAttachment(ofParentRecord: self.parentRecord, attachmentId: self.attachmentId) { ( result ) in
            completion( result )
        }
    }
}

let ATTACHMENT_MOCK : ZCRMAttachmentDelegate = ZCRMAttachmentDelegate( attachmentId : APIConstants.INT64_MOCK, parentRecord : RECORD_MOCK )

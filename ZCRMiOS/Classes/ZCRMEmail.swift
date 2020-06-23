//
//  ZCRMEmail.swift
//  ZCRMiOS
//
//  Created by Umashri R on 12/11/18.
//

open class ZCRMEmail : ZCRMEntity
{
    var userId : Int64 = APIConstants.INT64_MOCK
    var isUserIdSet : Bool = APIConstants.BOOL_MOCK
    var record : ZCRMRecordDelegate
    public var from : User
    public var to : [ User ] = [ User ]()
    public var cc : [ User ]?
    public var bcc : [ User ]?
    public var replyTo : User?
    public var subject : String?
    public var mailFormat : MailFormat = MailFormat.html
    public var content : String?
    public var attachments : [ Attachment ]?
    public var isOrgEmail : Bool?
    public var isConsentEmail : Bool?
    public var inReplyTo : String?
    public var layoutId : Int64?
    public var paperType : PaperType?
    public var viewType : ViewType?
    public var layoutName : String?
    public var templateId : Int64?
    public var scheduledTime : String?
    public var messageId : String = APIConstants.STRING_MOCK
    public var sentimentDetails : SentimentDetails?
    public var isEditable : Bool = APIConstants.BOOL_MOCK
    public var sentTime : String = APIConstants.STRING_MOCK
    public var inlineImageIds : [String]?
    internal var didSend : Bool = APIConstants.BOOL_MOCK
    
    init( record : ZCRMRecordDelegate, from : User, to : [User] )
    {
        self.record = record
        self.from = from
        self.to = to
        self.didSend = false
    }
    
    public struct User : Equatable
    {
        var name : String?
        var email : String = APIConstants.STRING_MOCK
        
        internal init()
        { }
        
        public init( email : String )
        {
            self.email = email
        }
        
        public static func == (lhs: ZCRMEmail.User, rhs: ZCRMEmail.User) -> Bool {
            let equals : Bool = lhs.name == rhs.name &&
                lhs.email == rhs.email
            return equals
        }
    }
    
    public struct Attachment : Equatable
    {
        var id : String = APIConstants.STRING_MOCK
        var fileName : String?
        var serviceName : ServiceName?
        
        public init( id : String )
        {
            self.id = id
        }
        
        public static func == (lhs: ZCRMEmail.Attachment, rhs: ZCRMEmail.Attachment) -> Bool {
            let equals : Bool = lhs.id == rhs.id &&
                lhs.fileName == rhs.fileName &&
                lhs.serviceName == rhs.serviceName
            return equals
        }
    }
    
    public enum MailFormat : String
    {
        case html = "html"
        case text = "text"
    }
    
    public enum ServiceName : String
    {
        case zohoDocs = "zohodocs"
        case googleDrive = "google_drive"
        case documents = "documents"
    }
    
    public enum SentimentDetails : String
    {
        case positive = "Positive"
        case negative = "Negative"
    }
    
    public enum PaperType : String
    {
        case usLetter = "USLetter"
        case defaultType = "default"
        case a4 = "A4"
    }
    
    public enum ViewType : String
    {
        case landscape = "landscape"
        case portrait = "portrait"
    }
    
    public func send( completion : @escaping( Result.DataResponse< ZCRMEmail, APIResponse > ) -> () )
    {
        EmailAPIHandler(email: self).sendMail { ( result ) in
            self.didSend = true
            completion( result )
        }
    }
    
    public func delete( completion : @escaping ( Result.Response< APIResponse > ) -> () )
    {
        if !didSend
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidOperation) : Mail MUST be sent before performing delete operation.")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidOperation, message : "Mail MUST be sent before performing delete operation.", details : nil  ) ) )
        }
        else
        {
            EmailAPIHandler(email: self).deleteMail(record: record, messageId: messageId) { result in
                completion( result )
            }
        }
    }
    
    public func uploadAttachment( filePath : String, completion : @escaping( Result.DataResponse< String, APIResponse > ) -> () )
    {
        EmailAPIHandler().uploadAttachment( filePath : filePath, fileName : nil, fileData : nil, inline : false, sendMail : false ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadAttachment( fileRefId : String, filePath : String, emailAttachmentUploadDelegate : ZCRMEmailAttachmentUploadDelegate )
    {
        EmailAPIHandler().uploadAttachment( fileRefId : fileRefId, filePath : filePath, fileName : nil, fileData : nil, inline : false, sendMail : false, emailAttachmentUploadDelegate: emailAttachmentUploadDelegate )
    }
    
    public func uploadAttachment( fileName : String, fileData : Data, completion : @escaping( Result.DataResponse< String, APIResponse > ) -> () )
    {
        EmailAPIHandler().uploadAttachment( filePath : nil, fileName : fileName, fileData : fileData, inline : false, sendMail : false ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadAttachment( fileRefId : String, fileName : String, fileData : Data, emailAttachmentUploadDelegate : ZCRMEmailAttachmentUploadDelegate )
    {
        EmailAPIHandler().uploadAttachment( fileRefId : fileRefId, filePath : nil, fileName : fileName, fileData : fileData, inline : false, sendMail : false, emailAttachmentUploadDelegate: emailAttachmentUploadDelegate )
    }
    
    public func uploadInlineAttachment( filePath : String, completion : @escaping( Result.DataResponse< String, APIResponse > ) -> () )
    {
        EmailAPIHandler().uploadAttachment( filePath : filePath, fileName : nil, fileData : nil, inline : true, sendMail : true ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadInlineAttachment( fileRefId : String, filePath : String, emailAttachmentUploadDelegate : ZCRMEmailAttachmentUploadDelegate )
    {
        EmailAPIHandler().uploadAttachment( fileRefId : fileRefId, filePath : filePath, fileName : nil, fileData : nil, inline : true, sendMail : true, emailAttachmentUploadDelegate: emailAttachmentUploadDelegate )
    }
    
    public func uploadInlineAttachment( fileName : String, fileData : Data, completion : @escaping( Result.DataResponse< String, APIResponse > ) -> () )
    {
        EmailAPIHandler().uploadAttachment( filePath : nil, fileName : fileName, fileData : fileData, inline : true, sendMail : true ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadInlineAttachment( fileRefId : String, fileName : String, fileData : Data, emailAttachmentUploadDelegate : ZCRMEmailAttachmentUploadDelegate )
    {
        EmailAPIHandler().uploadAttachment( fileRefId : fileRefId, filePath : nil, fileName : fileName, fileData : fileData, inline : true, sendMail : true, emailAttachmentUploadDelegate: emailAttachmentUploadDelegate )
    }
    
    public func downloadAttachment( attachmentId : String, fileName : String, completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        EmailAPIHandler(email: self).downloadAttachment(attachmentId: attachmentId, fileName: fileName) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadAttachment( attachmentId : String, fileName : String, fileDownloadDelegate : ZCRMFileDownloadDelegate ) throws
    {
        try EmailAPIHandler(email: self).downloadAttachment(attachmentId: attachmentId, fileName: fileName, fileDownloadDelegate: fileDownloadDelegate)
    }
    
    public func downloadAllAttachments( completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        EmailAPIHandler(email: self).downloadAttachment(attachmentId: nil, fileName: nil) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadAllAttachments( fileDownloadDelegate : ZCRMFileDownloadDelegate ) throws
    {
        try EmailAPIHandler(email: self).downloadAttachment(attachmentId: nil, fileName: nil, fileDownloadDelegate: fileDownloadDelegate)
    }
    
    public func downloadInlineImage( imageId : String, completion : @escaping (Result.Response< FileAPIResponse >) -> () )
    {
        EmailAPIHandler(email: self).downloadInlineImage(imageId: imageId) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadInlineImage( imageId : String, fileDownloadDelegate : ZCRMFileDownloadDelegate ) throws
    {
        try EmailAPIHandler(email : self).downloadInlineImage(imageId: imageId, fileDownloadDelegate: fileDownloadDelegate)
    }
}

extension ZCRMEmail : Equatable
{
    public static func == (lhs: ZCRMEmail, rhs: ZCRMEmail) -> Bool {
        let equals : Bool = lhs.userId == rhs.userId &&
            lhs.record == rhs.record &&
            lhs.from == rhs.from &&
            lhs.to == rhs.to &&
            lhs.cc == rhs.cc &&
            lhs.bcc == rhs.bcc &&
            lhs.replyTo == rhs.replyTo &&
            lhs.subject == rhs.subject &&
            lhs.mailFormat == rhs.mailFormat &&
            lhs.content == rhs.content &&
            lhs.attachments == rhs.attachments &&
            lhs.isOrgEmail == rhs.isOrgEmail &&
            lhs.isConsentEmail == rhs.isConsentEmail &&
            lhs.inReplyTo == rhs.inReplyTo &&
            lhs.layoutId == rhs.layoutId &&
            lhs.paperType == rhs.paperType &&
            lhs.viewType == rhs.viewType &&
            lhs.layoutName == rhs.layoutName &&
            lhs.templateId == rhs.templateId &&
            lhs.scheduledTime == rhs.scheduledTime &&
            lhs.messageId == rhs.messageId &&
            lhs.sentimentDetails == rhs.sentimentDetails &&
            lhs.isEditable == rhs.isEditable &&
            lhs.sentTime == rhs.sentTime
        return equals
    }
}

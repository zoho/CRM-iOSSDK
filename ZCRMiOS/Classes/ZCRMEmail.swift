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
    public var mailFormat : MailFormat = MailFormat.HTML
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
    internal var isSend : Bool = APIConstants.BOOL_MOCK
    
    init( record : ZCRMRecordDelegate, from : User, to : [User] )
    {
        self.record = record
        self.from = from
        self.to = to
        self.isSend = true
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
        case HTML = "html"
        case TEXT = "text"
    }
    
    public enum ServiceName : String
    {
        case ZOHODOCS = "zohodocs"
        case GOOGLE_DRIVE = "google_drive"
        case DOCUMENTS = "documents"
    }
    
    public enum SentimentDetails : String
    {
        case POSITIVE = "Positive"
        case NEGATIVE = "Negative"
    }
    
    public enum PaperType : String
    {
        case USLETTER = "USLetter"
        case DEFAULT = "default"
        case A4 = "A4"
    }
    
    public enum ViewType : String
    {
        case LANDSCAPE = "landscape"
        case PORTRAIT = "portrait"
    }
    
    public func send( completion : @escaping( Result.DataResponse< ZCRMEmail, APIResponse > ) -> () )
    {
        EmailAPIHandler(email: self).sendMail { ( result ) in
            self.isSend = false
            completion( result )
        }
    }
    
    public func uploadAttachment( filePath : String, completion : @escaping( Result.DataResponse< String, APIResponse > ) -> () )
    {
        EmailAPIHandler().uploadAttachment( filePath : filePath, fileName : nil, fileData : nil, inline : false, sendMail : false ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadAttachment( filePath : String, emailAttachmentUploadDelegate : EmailAttachmentUploadDelegate )
    {
        EmailAPIHandler( emailAttachmentUploadDelegate : emailAttachmentUploadDelegate ).uploadAttachment( filePath : filePath, fileName : nil, fileData : nil, inline : false, sendMail : false )
    }
    
    public func uploadAttachment( fileName : String, fileData : Data, completion : @escaping( Result.DataResponse< String, APIResponse > ) -> () )
    {
        EmailAPIHandler().uploadAttachment( filePath : nil, fileName : fileName, fileData : fileData, inline : false, sendMail : false ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadAttachment( fileName : String, fileData : Data, emailAttachmentUploadDelegate : EmailAttachmentUploadDelegate )
    {
        EmailAPIHandler( emailAttachmentUploadDelegate : emailAttachmentUploadDelegate ).uploadAttachment( filePath : nil, fileName : fileName, fileData : fileData, inline : false, sendMail : false )
    }
    
    public func uploadInlineAttachment( filePath : String, completion : @escaping( Result.DataResponse< String, APIResponse > ) -> () )
    {
        EmailAPIHandler().uploadAttachment( filePath : filePath, fileName : nil, fileData : nil, inline : true, sendMail : true ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadInlineAttachment( filePath : String, emailAttachmentUploadDelegate : EmailAttachmentUploadDelegate )
    {
        EmailAPIHandler( emailAttachmentUploadDelegate : emailAttachmentUploadDelegate ).uploadAttachment( filePath : filePath, fileName : nil, fileData : nil, inline : true, sendMail : true )
    }
    
    public func uploadInlineAttachment( fileName : String, fileData : Data, completion : @escaping( Result.DataResponse< String, APIResponse > ) -> () )
    {
        EmailAPIHandler().uploadAttachment( filePath : nil, fileName : fileName, fileData : fileData, inline : true, sendMail : true ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadInlineAttachment( fileName : String, fileData : Data, emailAttachmentUploadDelegate : EmailAttachmentUploadDelegate )
    {
        EmailAPIHandler( emailAttachmentUploadDelegate : emailAttachmentUploadDelegate ).uploadAttachment( filePath : nil, fileName : fileName, fileData : fileData, inline : true, sendMail : true )
    }
    
    public func downloadAttachment( attachmentId : String, fileName : String, completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        EmailAPIHandler(email: self).downloadAttachment(attachmentId: attachmentId, fileName: fileName) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadAttachment( attachmentId : String, fileName : String, fileDownloadDelegate : FileDownloadDelegate ) throws
    {
        try EmailAPIHandler(email: self).downloadAttachment(attachmentId: attachmentId, fileName: fileName, fileDownloadDelegate: fileDownloadDelegate)
    }
    
    public func downloadAllAttachments( completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        EmailAPIHandler(email: self).downloadAttachment(attachmentId: nil, fileName: nil) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadAllAttachments( fileDownloadDelegate : FileDownloadDelegate ) throws
    {
        try EmailAPIHandler(email: self).downloadAttachment(attachmentId: nil, fileName: nil, fileDownloadDelegate: fileDownloadDelegate)
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

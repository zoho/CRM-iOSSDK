//
//  ZCRMEmail.swift
//  ZCRMiOS
//
//  Created by test on 15/02/24.
//

import Foundation

open class ZCRMEmail : ZCRMEntity
{
    public internal( set ) var ownerId : Int64 = APIConstants.INT64_MOCK
    public internal( set ) var ownerName : String?
    var isUserIdSet : Bool = APIConstants.BOOL_MOCK
    public var record : ZCRMRecordDelegate
    public var from : User
    public var to : [ User ] = [ User ]()
    public var cc : [ User ] = []
    public var bcc : [ User ] = []
    public var replyTo : User?
    public var subject : String = APIConstants.STRING_MOCK
    public var mailFormat : MailFormat?
    public var content : String?
    public var attachments : [ Attachment ]?
    public var isOrgEmail : Bool?
    public var isConsentEmail : Bool?
    public var inReplyTo : String?
    public var templateId : Int64?
    public var scheduledTime : String?
    public internal( set ) var messageId : String = APIConstants.STRING_MOCK
    public internal( set ) var sentimentDetails : SentimentDetails?
    public var isEditable : Bool?
    public internal( set ) var sentTime : String = APIConstants.STRING_MOCK
    public internal( set ) var isRead : Bool?
    public internal( set ) var source : Source?
    public internal( set ) var category : Category?
    public internal( set ) var isConversation : Bool?
    public internal( set ) var inlineImageIds : [String]?
    public internal( set ) var associatedContact : ZCRMRecordDelegate?
    public internal( set ) var mailIndex : String?
    internal var didSend : Bool = APIConstants.BOOL_MOCK
    public var inventoryTemplateDetails : InventoryTemplateDetails?
    public internal( set ) var status : [ Status ]?
    
    init( record : ZCRMRecordDelegate, from : User )
    {
        self.record = record
        self.from = from
        self.didSend = false
    }
    
    public struct InventoryTemplateDetails : Equatable
    {
        public let templateId : Int64
        public var name : String?
        public var paperType : PaperType?
        public var viewType : ViewType?
        
        public init( templateId : Int64 )
        {
            self.templateId = templateId
        }
        
        public static func == (lhs: ZCRMEmail.InventoryTemplateDetails, rhs: ZCRMEmail.InventoryTemplateDetails) -> Bool {
            return lhs.templateId == rhs.templateId &&
                lhs.name == rhs.name &&
                lhs.paperType == rhs.paperType &&
                lhs.viewType == rhs.viewType
        }
    }
    
    public struct User : Equatable
    {
        public var name : String?
        public internal( set ) var email : String = APIConstants.STRING_MOCK
        
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
        public internal( set ) var id : String = APIConstants.STRING_MOCK
        public var fileName : String?
        public internal( set ) var size : Int64?
        public var serviceName : ServiceName?
        
        public init( id : String )
        {
            self.id = id
        }
        
        public static func == (lhs: ZCRMEmail.Attachment, rhs: ZCRMEmail.Attachment) -> Bool {
            let equals : Bool = lhs.id == rhs.id &&
                lhs.fileName == rhs.fileName &&
                lhs.size == rhs.size &&
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
    
    public enum MailType
    {
        case emailSentFromCRM
        case otherUsers
        case allIMAPSharedUsers
        case allContactsEmails
        case allEmails
        case scheduled_in_crm
        case drafts
        case user_emails
        case all_contacts_scheduled_crm_emails
        case all_contacts_draft_crm_emails
        
        internal var rawValue : String
        {
            if ZCRMSDKClient.shared.apiVersion < APIConstants.API_VERSION_V4
            {
                switch self
                {
                case .emailSentFromCRM:
                    return "1"
                case .otherUsers:
                    return "2"
                case .allIMAPSharedUsers:
                    return "3"
                case .allContactsEmails:
                    return "4"
                case .allEmails:
                    return "5"
                case .scheduled_in_crm:
                    return ""
                case .drafts:
                    return ""
                case .user_emails:
                    return ""
                case .all_contacts_scheduled_crm_emails:
                    return ""
                case .all_contacts_draft_crm_emails:
                    return ""
                }
            }
            else
            {
                switch self
                {
                case .emailSentFromCRM:
                    return "sent_from_crm"
                case .otherUsers:
                    return ""
                case .allIMAPSharedUsers:
                    return ""
                case .allContactsEmails:
                    return ""
                case .allEmails:
                    return ""
                case .scheduled_in_crm:
                    return "scheduled_in_crm"
                case .drafts:
                    return "drafts"
                case .user_emails:
                    return "user_emails"
                case .all_contacts_scheduled_crm_emails:
                    return "all_contacts_scheduled_crm_emails"
                case .all_contacts_draft_crm_emails:
                    return "all_contacts_draft_crm_emails"
                }
            }
        }
    }

    public enum Source : String
    {
        case individual = "individual"
        case workflow = "workflow"
        case bccDropbox = "bcc_dropbox"
        case imap = "imap"
        case consentMail = "consent_mail"
        case outlook = "outlook"
        case manualMassMail = "manual_massmail"
        case massEmailFollowUp = "mass_email_follow_up"
        case autoResponder = "auto_responder"
        case autoResponderFollowUp = "auto_responder_follow_up"
        case event = "event"
        case mailMerge = "mail_merge"
        case webForm = "webForm"
        case unHandled
        
        static func getSource( _ source : String ) -> Source
        {
            if let source = Source( rawValue: source.lowercased() )
            {
                return source
            }
            else
            {
                ZCRMLogger.logInfo(message: "UNHANDLED -> Mail Source : \( source )")
                return .unHandled
            }
        }
    }
    
    public enum Category
    {
        case sent
        case received
    }
    
    public func send( completion : @escaping( ZCRMResult.DataResponse< ZCRMEmail, APIResponse > ) -> () )
    {
        EmailAPIHandler(email: self).sendMail { ( result ) in
            completion( result )
        }
    }
    
    public func delete( completion : @escaping ( ZCRMResult.Response< APIResponse > ) -> () )
    {
        if !didSend
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidOperation) : Mail MUST be sent before performing delete operation.")
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.invalidOperation, message : "Mail MUST be sent before performing delete operation.", details : nil  ) ) )
        }
        else
        {
            EmailAPIHandler(email: self).deleteMail(record: record, messageId: messageId) { result in
                completion( result )
            }
        }
    }
}

extension ZCRMEmail : Equatable
{
    public static func == (lhs: ZCRMEmail, rhs: ZCRMEmail) -> Bool {
        let equals : Bool = lhs.ownerId == rhs.ownerId &&
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
            lhs.inventoryTemplateDetails == rhs.inventoryTemplateDetails &&
            lhs.templateId == rhs.templateId &&
            lhs.scheduledTime == rhs.scheduledTime &&
            lhs.messageId == rhs.messageId &&
            lhs.sentimentDetails == rhs.sentimentDetails &&
            lhs.isEditable == rhs.isEditable &&
            lhs.sentTime == rhs.sentTime &&
            lhs.associatedContact == rhs.associatedContact
        return equals
    }
    
    public class FromAddress : ZCRMEntity
    {
        public internal( set ) var email : String
        public internal( set ) var type : MailAddressType
        public internal( set ) var isDefault : Bool = APIConstants.BOOL_MOCK
        public internal( set ) var userName : String?
        
        init( _ email : String, type : MailAddressType )
        {
            self.email = email
            self.type = type
        }
        
        public enum MailAddressType : String
        {
            case primary
            case imap
            case pop
            case api
            case orgEmail = "org_email"
            case unhandled
            
            static func getType( rawValue : String ) -> MailAddressType
            {
                if let type = MailAddressType(rawValue: rawValue)
                {
                    return type
                }
                ZCRMLogger.logDebug(message: "UNHANDLED -> MailType : \( rawValue )")
                return .unhandled
            }
        }
    }
    
    public enum Status
    {
        case sent
        case received
        case delivered
        case opened( OpenedDetails )
        case clicked( ClickedDetails )
        case bounced( BouncedDetails )
        case scheduled
        case failed
        case unhandled
        
        public struct OpenedDetails
        {
            public internal( set ) var firstOpen : String
            public internal( set ) var lastOpen : String
            public internal( set ) var count : Int64
        }
        
        public struct ClickedDetails
        {
            public internal( set ) var firstClick : String
            public internal( set ) var lastClick : String
            public internal( set ) var count : Int64
        }
        
        public struct BouncedDetails
        {
            public internal( set ) var time : String
            public internal( set ) var reason : String?
        }
        
        public var rawValue : String
        {
            switch self
            {
            case .sent:
                return "sent"
            case .received:
                return "received"
            case .delivered:
                return "delivered"
            case .opened:
                return "opened"
            case .clicked:
                return "clicked"
            case .bounced:
                return "bounced"
            case .scheduled:
                return "scheduled"
            case .failed:
                return "failed"
            case .unhandled:
                return "unhandled"
            }
        }
        
        static func getStatus( _ status : [ String : Any ] ) throws -> Status
        {
            let type = try status.getString(key: ResponseJSONKeys.type)
            switch type
            {
            case "sent" :
                return .sent
            case "received" :
                return .received
            case "delivered" :
                return .delivered
            case "opened" :
                let firstOpen = try status.getString(key: ResponseJSONKeys.firstOpen)
                let lastOpen = try status.getString(key: ResponseJSONKeys.lastOpen)
                let count = try status.getInt64(key: ResponseJSONKeys.count)
                return .opened( OpenedDetails(firstOpen: firstOpen, lastOpen: lastOpen, count: count) )
            case "clicked" :
                let firstClick = try status.getString(key: ResponseJSONKeys.firstClick)
                let lastClick = try status.getString(key: ResponseJSONKeys.lastClick)
                let count = try status.getInt64(key: ResponseJSONKeys.count)
                return .clicked( ClickedDetails(firstClick: firstClick, lastClick: lastClick, count: count) )
            case "bounced" :
                let time = try status.getString(key: ResponseJSONKeys.bouncedTime)
                let reason = status.optString(key: ResponseJSONKeys.bouncedReason)
                return .bounced( BouncedDetails(time: time, reason: reason) )
            case "scheduled" :
                return .scheduled
            case "failed" :
                return .failed
            default:
                return .unhandled
            }
        }
        
        struct ResponseJSONKeys
        {
            static let type = "type"
            static let firstOpen = "first_open"
            static let lastOpen = "last_open"
            static let count = "count"
            static let firstClick = "first_click"
            static let lastClick = "last_click"
            static let bouncedTime = "bounced_time"
            static let bouncedReason = "bounced_reason"
        }
    }
}

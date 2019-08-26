//
//  EmailAPIHandler.swift
//  ZCRMiOS
//
//  Created by Umashri R on 05/10/18.
//

internal class EmailAPIHandler : CommonAPIHandler
{
    private var email : ZCRMEmail?
    private var emailAttachmentUploadDelegate : EmailAttachmentUploadDelegate?
    
    init( email : ZCRMEmail ) {
        self.email = email
    }
    
    init( emailAttachmentUploadDelegate : EmailAttachmentUploadDelegate )
    {
        self.emailAttachmentUploadDelegate = emailAttachmentUploadDelegate
    }
    
    override init()
    { }
    
    internal func sendMail( completion : @escaping( Result.DataResponse< ZCRMEmail, APIResponse > ) -> () )
    {
        if let email = self.email
        {
            setJSONRootKey(key: JSONRootKey.DATA)
            var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
            var dataArray : [[String:Any]] = [[String:Any]]()
            dataArray.append(self.getZCRMEmailAsJSON(email: email))
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath( urlPath : "\( email.record.moduleAPIName )/\( email.record.id )/actions/send_mail" )
            setRequestMethod(requestMethod: .POST)
            setRequestBody(requestBody: reqBodyObj)
            let request : APIRequest = APIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.getAPIResponse { ( resultType ) in
                do
                {
                    let response = try resultType.resolve()
                    let responseJSON = response.getResponseJSON()
                    let responseJSONArray  = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    let responseJSONData = responseJSONArray[ 0 ]
                    let responseDetails : [ String : Any ] = try responseJSONData.getDictionary( key : APIConstants.DETAILS )
                    if responseDetails.hasValue(forKey: ResponseJSONKeys.messageId) == false
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.VALUE_NIL) : \(ResponseJSONKeys.messageId) must not be nil")
                        throw ZCRMError.InValidError(code: ErrorCode.VALUE_NIL, message: "\(ResponseJSONKeys.messageId) must not be nil", details : nil)
                    }
                    email.messageId = try responseDetails.getString( key : ResponseJSONKeys.messageId )
                    response.setData( data : email )
                    completion( .success( email, response ) )
                }
                catch
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : EMAIL must not be nil")
            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "EMAIL must not be nil", details : nil ) ) )
        }
    }
    
    internal func viewMail( record : ZCRMRecordDelegate, userId : Int64, messageId : String, completion : @escaping( Result.DataResponse< ZCRMEmail, APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.EMAIL_RELATED_LIST)
        setUrlPath( urlPath : "\( record.moduleAPIName )/\( record.id )/Emails" )
        addRequestParam(param: RequestParamKeys.userId, value: String(userId))
        addRequestParam(param: RequestParamKeys.messageId, value: messageId)
        setRequestMethod(requestMethod: .GET)
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do
            {
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let responseJSONArray  = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let responseJSONData = responseJSONArray[ 0 ]
                let email = try self.getZCRMEmail(record: record, emailDetails: responseJSONData)
                email.userId = userId
                email.messageId = messageId
                response.setData( data : email )
                completion( .success( email, response ) )
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func downloadAttachment( attachmentId : String?, fileName : String?, completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        if let email = self.email
        {
            setJSONRootKey( key : JSONRootKey.NIL )
            self.setIsEmail( true )
            let urlString = "\( email.record.moduleAPIName )/\( email.record.id )/Emails/attachments"
            guard !email.isSend else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : USER ID and MESSAGE ID must not be nil")
                completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "USER ID and MESSAGE ID must not be nil", details : nil ) ) )
                return
            }
            addRequestParam(param: RequestParamKeys.messageId, value: email.messageId)
            addRequestParam( param : RequestParamKeys.userId, value : String( email.userId ) )
            if let attachmentId = attachmentId
            {
                addRequestParam(param: RequestParamKeys.id, value: attachmentId)
            }
            if let fileName = fileName
            {
                addRequestParam( param : RequestParamKeys.name, value : fileName )
            }
            setUrlPath(urlPath: urlString)
            
            setRequestMethod(requestMethod: .GET )
            let request : FileAPIRequest = FileAPIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.downloadFile { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    completion( .success( response ) )
                }
                catch{
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : EMAIL must not be nil")
            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: " EMAIL must not be nil", details : nil ) ) )
        }
    }
    
    internal func downloadAttachment( attachmentId : String?, fileName : String?, fileDownloadDelegate : FileDownloadDelegate ) throws
    {
        if let email = self.email
        {
            setJSONRootKey( key : JSONRootKey.NIL )
            self.setIsEmail( true )
            let urlString = "\( email.record.moduleAPIName )/\( email.record.id )/Emails/attachments"
            guard !email.isSend else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : USER ID and MESSAGE ID must not be nil")
                throw ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "USER ID and MESSAGE ID must not be nil", details : nil )
            }
            addRequestParam(param: RequestParamKeys.messageId, value: email.messageId)
            addRequestParam( param : RequestParamKeys.userId, value : String( email.userId ) )
            if let attachmentId = attachmentId
            {
                addRequestParam(param: RequestParamKeys.id, value: attachmentId)
            }
            if let fileName = fileName
            {
                addRequestParam( param : RequestParamKeys.name, value : fileName )
            }
            setUrlPath(urlPath: urlString)
            
            setRequestMethod(requestMethod: .GET )
            let request : FileAPIRequest = FileAPIRequest(handler: self, fileDownloadDelegate: fileDownloadDelegate)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.downloadFile()
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.MANDATORY_NOT_FOUND) : EMAIL must not be nil")
            throw ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: " EMAIL must not be nil", details : nil )
        }
    }
    
    internal func delete( id : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.ORG_EMAILS)
        setUrlPath(urlPath: "\(APIConstants.SETTINGS)/\(APIConstants.EMAILS)/\(APIConstants.ORG_EMAILS)/\(String(id))" )
        setRequestMethod(requestMethod: .DELETE )
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                completion( .success( response ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    private func getZCRMEmail( record : ZCRMRecordDelegate, emailDetails : [String : Any] ) throws -> ZCRMEmail
    {
        var from = ZCRMEmail.User()
        var to = [ZCRMEmail.User]()
        if emailDetails.hasValue(forKey: ResponseJSONKeys.from)
        {
            let fromDetails = try emailDetails.getDictionary( key : ResponseJSONKeys.from )
            from = try self.getUser(userJSON: fromDetails)
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.to)
        {
            let toDetails = try emailDetails.getArrayOfDictionaries( key : ResponseJSONKeys.to )
            to = try self.getArrayOfUser(usersJSON: toDetails)
        }
        let email : ZCRMEmail = ZCRMEmail(record: record, from: from, to: to)
        if emailDetails.hasValue(forKey: ResponseJSONKeys.messageId)
        {
            email.messageId = try emailDetails.getString( key : ResponseJSONKeys.messageId )
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.cc)
        {
            let ccDetails = try emailDetails.getArrayOfDictionaries( key : ResponseJSONKeys.cc )
            email.cc = try self.getArrayOfUser(usersJSON: ccDetails)
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.bcc)
        {
            let bccDetails = try emailDetails.getArrayOfDictionaries( key : ResponseJSONKeys.bcc )
            email.bcc = try self.getArrayOfUser(usersJSON: bccDetails)
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.replyTo)
        {
            let replyToDetails = try emailDetails.getDictionary( key : ResponseJSONKeys.replyTo )
            email.replyTo = try self.getUser(userJSON: replyToDetails)
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.subject)
        {
            email.subject = try emailDetails.getString( key : ResponseJSONKeys.subject )
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.content)
        {
            email.content = try emailDetails.getString( key : ResponseJSONKeys.content )
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.attachments)
        {
            email.attachments = [ZCRMEmail.Attachment]()
            let attachments = try emailDetails.getArrayOfDictionaries( key : ResponseJSONKeys.attachments )
            for attachment in attachments
            {
                let attachmentId = try attachment.getString( key : ResponseJSONKeys.id )
                var attach = ZCRMEmail.Attachment( id : attachmentId )
                attach.fileName = try attachment.getString(key: ResponseJSONKeys.name)
                email.attachments?.append(attach)
            }
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.sentimentDetails)
        {
            let sentimentDet = try emailDetails.getString( key : ResponseJSONKeys.sentimentDetails )
            guard let sentiment = ZCRMEmail.SentimentDetails(rawValue: sentimentDet) else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.INVALID_DATA) : \(ResponseJSONKeys.sentimentDetails) has invalid value")
                throw ZCRMError.InValidError( code : ErrorCode.INVALID_DATA, message : "\(ResponseJSONKeys.sentimentDetails) has invalid value", details : nil )
            }
            email.sentimentDetails = sentiment
        }
        let mailFormat = try emailDetails.getString( key : ResponseJSONKeys.mailFormat )
        guard let format = ZCRMEmail.MailFormat(rawValue: mailFormat) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.INVALID_DATA) : \(ResponseJSONKeys.mailFormat) has invalid value")
            throw ZCRMError.InValidError( code : ErrorCode.INVALID_DATA, message : "\(ResponseJSONKeys.mailFormat) has invalid value", details : nil )
        }
        email.mailFormat = format
        if emailDetails.hasValue(forKey: ResponseJSONKeys.editable)
        {
            email.isEditable = try emailDetails.getBoolean( key : ResponseJSONKeys.editable )
        }
        email.sentTime = try emailDetails.getString( key : ResponseJSONKeys.sentTime )
        if emailDetails.hasValue(forKey: ResponseJSONKeys.orgEmail)
        {
            email.isOrgEmail = try emailDetails.getBoolean( key : ResponseJSONKeys.orgEmail )
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.consentEmail)
        {
            email.isConsentEmail = try emailDetails.getBoolean( key : ResponseJSONKeys.consentEmail )
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.inReplyTo)
        {
            email.inReplyTo = try emailDetails.getString( key : ResponseJSONKeys.inReplyTo )
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.layoutId)
        {
            email.layoutId = try emailDetails.getInt64( key : ResponseJSONKeys.layoutId )
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.paperType)
        {
            let paperType = try emailDetails.getString( key : ResponseJSONKeys.paperType )
            guard let paperTypeEnum = ZCRMEmail.PaperType(rawValue: paperType) else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.INVALID_DATA) : \(ResponseJSONKeys.paperType) has invalid value")
                throw ZCRMError.InValidError( code : ErrorCode.INVALID_DATA, message : "\(ResponseJSONKeys.paperType) has invalid value", details : nil )
            }
            email.paperType = paperTypeEnum
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.viewType)
        {
            let viewType = try emailDetails.getString( key : ResponseJSONKeys.viewType )
            guard let viewTypeEnum = ZCRMEmail.ViewType(rawValue: viewType) else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.INVALID_DATA) : \(ResponseJSONKeys.viewType) has invalid value")
                throw ZCRMError.InValidError( code : ErrorCode.INVALID_DATA, message : "\(ResponseJSONKeys.viewType) has invalid value", details : nil )
            }
            email.viewType = viewTypeEnum
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.layoutName)
        {
            email.layoutName = try emailDetails.getString( key : ResponseJSONKeys.layoutName )
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.templateId)
        {
            email.templateId = try emailDetails.getInt64( key : ResponseJSONKeys.templateId )
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.scheduledTime)
        {
            email.scheduledTime = try emailDetails.getString( key : ResponseJSONKeys.scheduledTime )
        }
        email.isSend = false
        return email
    }
    
    private func getArrayOfUser( usersJSON : [[String:Any]] ) throws -> [ZCRMEmail.User]
    {
        var users : [ZCRMEmail.User] = [ZCRMEmail.User]()
        for userJSON in usersJSON
        {
            users.append( try getUser( userJSON: userJSON ) )
        }
        return users
    }
    
    private func getUser( userJSON : [String:Any] ) throws -> ZCRMEmail.User
    {
        var user : ZCRMEmail.User = ZCRMEmail.User()
        user.email = try userJSON.getString( key : ResponseJSONKeys.email )
        if userJSON.hasValue(forKey: ResponseJSONKeys.userName)
        {
            user.name = try userJSON.getString(key: ResponseJSONKeys.userName)
        }
        return user
    }
    
    private func getZCRMEmailAsJSON( email : ZCRMEmail ) -> [String:Any]
    {
        var emailDetails : [String:Any] = [String:Any]()
        emailDetails.updateValue( self.getUserAsJSON( user : email.from ), forKey : ResponseJSONKeys.from )
        emailDetails.updateValue( self.getArrayOfUserJSON( users : email.to ), forKey : ResponseJSONKeys.to )
        if let cc = email.cc
        {
            emailDetails.updateValue( self.getArrayOfUserJSON( users : cc ), forKey : ResponseJSONKeys.cc )
        }
        if let bcc = email.bcc
        {
            emailDetails.updateValue( self.getArrayOfUserJSON( users : bcc ), forKey : ResponseJSONKeys.bcc )
        }
        if let replyTo = email.replyTo
        {
            emailDetails.updateValue( self.getUserAsJSON( user : replyTo ), forKey : ResponseJSONKeys.replyTo )
        }
        if let subject = email.subject
        {
            emailDetails.updateValue( subject, forKey : ResponseJSONKeys.subject )
        }
        if let content = email.content
        {
            emailDetails.updateValue( content, forKey : ResponseJSONKeys.content )
        }
        emailDetails.updateValue( email.mailFormat.rawValue, forKey : ResponseJSONKeys.mailFormat )
        if let scheduledTime = email.scheduledTime
        {
            emailDetails.updateValue( scheduledTime, forKey : ResponseJSONKeys.scheduledTime )
        }
        if let templateId = email.templateId
        {
            emailDetails.updateValue( templateId, forKey : ResponseJSONKeys.templateId )
        }
        if let attachments = email.attachments
        {
            emailDetails.updateValue( self.getArrayOfAttachmentJSON( attachments : attachments ), forKey : ResponseJSONKeys.attachments )
        }
        if let isOrgEmail = email.isOrgEmail
        {
            emailDetails.updateValue( isOrgEmail, forKey : ResponseJSONKeys.orgEmail )
        }
        if let isConsentEmail = email.isConsentEmail
        {
            emailDetails.updateValue( isConsentEmail, forKey : ResponseJSONKeys.consentEmail )
        }
        if let inReplyTo = email.inReplyTo
        {
            emailDetails.updateValue( inReplyTo, forKey : ResponseJSONKeys.inReplyTo )
        }
        if let layoutId = email.layoutId
        {
            emailDetails.updateValue( layoutId, forKey : ResponseJSONKeys.layoutId )
        }
        if let paperType = email.paperType
        {
            emailDetails.updateValue( paperType.rawValue, forKey : ResponseJSONKeys.paperType )
        }
        if let viewType = email.viewType
        {
            emailDetails.updateValue( viewType.rawValue, forKey : ResponseJSONKeys.viewType )
        }
        if let layoutName = email.layoutName
        {
            emailDetails.updateValue( layoutName, forKey : ResponseJSONKeys.layoutName )
        }
        return emailDetails
    }
    
    private func getArrayOfUserJSON( users : [ ZCRMEmail.User ] ) -> [[String:Any]]
    {
        var usersDetails : [[String:Any]] = [[String:Any]]()
        for user in users
        {
            let userDetails = self.getUserAsJSON(user: user)
            usersDetails.append(userDetails)
        }
        return usersDetails
    }
    
    private func getUserAsJSON( user : ZCRMEmail.User ) -> [String:Any]
    {
        var userDetails : [String:Any] = [String:Any]()
        if let userName = user.name
        {
            userDetails.updateValue( userName, forKey : ResponseJSONKeys.userName )
        }
        userDetails.updateValue( user.email, forKey : ResponseJSONKeys.email )
        return userDetails
    }
    
    private func getArrayOfAttachmentJSON( attachments : [ZCRMEmail.Attachment] ) -> [[String:Any]]
    {
        var attachmentsJSON : [[String:Any]] = [[String:Any]]()
        for attachment in attachments
        {
            var attachmentJSON : [String:Any] = [String:Any]()
            attachmentJSON[ ResponseJSONKeys.id ] = attachment.id
            if let fileName = attachment.fileName
            {
                attachmentJSON.updateValue( fileName, forKey : ResponseJSONKeys.name )
            }
            if let serviceName = attachment.serviceName
            {
                attachmentJSON.updateValue( serviceName.rawValue, forKey : ResponseJSONKeys.serviceName )
            }
            attachmentsJSON.append(attachmentJSON)
        }
        return attachmentsJSON
    }
}

extension EmailAPIHandler : FileUploadDelegate
{
    internal func uploadAttachment( filePath : String?, fileName : String?, fileData : Data?, inline : Bool, sendMail : Bool, completion : @escaping( Result.DataResponse< String, APIResponse > ) -> () )
    {
        do
        {
            try fileDetailCheck( filePath : filePath, fileData : fileData )
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            completion( .failure( typeCastToZCRMError( error ) ) )
            return
        }
        setJSONRootKey(key: JSONRootKey.NIL)
        setUrlPath(urlPath: "emails/attachments/upload" )
        setRequestMethod(requestMethod: .POST )
        if inline && sendMail
        {
            addRequestParam( param : RequestParamKeys.inline, value : String( inline ) )
            addRequestParam( param : RequestParamKeys.sendMail, value : String( sendMail ) )
        }
        let request : FileAPIRequest = FileAPIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        if let filePath = filePath
        {
            request.uploadFile( filePath : filePath, entity : nil, completion: { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let attachmentId = try self.getAttachmentIdFrom( response : response )
                    completion( .success( attachmentId, response ) )
                }
                catch{
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            })
        }
        else  if let fileName = fileName, let fileData = fileData
        {
            request.uploadFile( fileName : fileName, entity : nil, fileData : fileData ) { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let attachmentId = try self.getAttachmentIdFrom( response : response )
                    completion( .success( attachmentId, response ) )
                }
                catch{
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
    }
    
    internal func uploadAttachment( filePath : String?, fileName : String?, fileData : Data?, inline : Bool, sendMail : Bool )
    {
        do
        {
            try fileDetailCheck( filePath : filePath, fileData : fileData )
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            self.emailAttachmentUploadDelegate?.didFail( typeCastToZCRMError( error ) )
            return
        }
        setJSONRootKey(key: JSONRootKey.NIL)
        setUrlPath(urlPath: "emails/attachments/upload" )
        setRequestMethod(requestMethod: .POST )
        if inline && sendMail
        {
            addRequestParam( param : RequestParamKeys.inline, value : String( inline ) )
            addRequestParam( param : RequestParamKeys.sendMail, value : String( sendMail ) )
        }
        let request : FileAPIRequest = FileAPIRequest( handler : self, fileUploadDelegate : self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        if let filePath = filePath
        {
            request.uploadFile( filePath : filePath, entity : nil )
        }
        else if let fileName = fileName, let fileData = fileData
        {
            request.uploadFile( fileName : fileName, entity : nil, fileData : fileData )
        }
    }
    
    func progress( session : URLSession, sessionTask : URLSessionTask, progressPercentage : Double, totalBytesSent : Int64, totalBytesExpectedToSend : Int64 )
    {
        emailAttachmentUploadDelegate?.progress(session: session, sessionTask: sessionTask, progressPercentage: progressPercentage, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }
    
    func didFinish( _ apiResponse : APIResponse )
    {
        do
        {
            let attachmentId = try self.getAttachmentIdFrom( response : apiResponse )
            emailAttachmentUploadDelegate?.didFinish( apiResponse )
            emailAttachmentUploadDelegate?.getAttachmentId( id : attachmentId )
        }
        catch
        {
            emailAttachmentUploadDelegate?.didFail( typeCastToZCRMError( error ) )
        }
    }
    
    private func getAttachmentIdFrom( response : APIResponse ) throws -> String
    {
        let responseJSON = response.getResponseJSON()
        let attachmentId = try responseJSON.getString( key : JSONRootKey.DATA )
        return attachmentId
    }
    
    func didFail( _ withError : ZCRMError? )
    {
        emailAttachmentUploadDelegate?.didFail( withError )
    }
}

extension EmailAPIHandler
{
    struct ResponseJSONKeys
    {
        static let id = "id"
        static let displayName = "display_name"
        static let email = "email"
        static let profiles = "profiles"
        static let name = "name"
        static let confirm = "confirm"
        
        static let messageId = "message_id"
        static let from = "from"
        static let to = "to"
        static let cc = "cc"
        static let bcc = "bcc"
        static let userName = "user_name"
        static let replyTo = "reply_to"
        static let subject = "subject"
        static let mailFormat = "mail_format"
        static let content = "content"
        static let attachments = "attachments"
        static let fileName = "file_name"
        static let serviceName = "service_name"
        static let scheduledTime = "scheduled_time"
        static let templateId = "template_id"
        static let orgEmail = "org_email"
        static let consentEmail = "consent_email"
        static let inReplyTo = "in_reply_to"
        static let layoutId = "layout_id"
        static let paperType = "paper_type"
        static let viewType = "view_type"
        static let layoutName = "layout_name"
        static let sentimentDetails = "sentiment_details"
        static let editable = "editable"
        static let sentTime = "sent_time"
    }
}

public protocol EmailAttachmentUploadDelegate : FileUploadDelegate
{
    func getAttachmentId( id : String )
}

extension RequestParamKeys
{
    static let code = "code"
    static let inline = "inline"
    static let sendMail = "sendMail"
    static let name = "name"
    static let userId = "user_id"
    static let messageId = "message_id"
}

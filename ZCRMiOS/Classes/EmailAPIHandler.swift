//
//  EmailAPIHandler.swift
//  ZCRMiOS
//
//  Created by Umashri R on 05/10/18.
//

internal class EmailAPIHandler : CommonAPIHandler
{
    private var email : ZCRMEmail?
    private var orgEmail : ZCRMOrgEmail?
    
    init( email : ZCRMEmail ) {
        self.email = email
    }
    
    init( orgEmail : ZCRMOrgEmail )
    {
        self.orgEmail = orgEmail
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
            
            setUrlPath( urlPath : "\( email.record.moduleAPIName )/\( email.record.id )/\( URLPathConstants.actions )/\( URLPathConstants.sendMail )" )
            setRequestMethod(requestMethod: .post)
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
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.valueNil) : \(ResponseJSONKeys.messageId) must not be nil, \( APIConstants.DETAILS ) : -")
                        throw ZCRMError.inValidError(code: ErrorCode.valueNil, message: "\(ResponseJSONKeys.messageId) must not be nil", details : nil)
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
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : EMAIL must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code: ErrorCode.mandatoryNotFound, message: "EMAIL must not be nil", details : nil ) ) )
        }
    }
    
    internal func viewMail( record : ZCRMRecordDelegate, userId : Int64, messageId : String, completion : @escaping( Result.DataResponse< ZCRMEmail, APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.EMAIL_RELATED_LIST)
        setUrlPath( urlPath : "\( record.moduleAPIName )/\( record.id )/\( URLPathConstants.Emails )" )
        addRequestParam(param: RequestParamKeys.userId, value: String(userId))
        addRequestParam(param: RequestParamKeys.messageId, value: messageId)
        setRequestMethod(requestMethod: .get)
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
    
    
    internal func buildDownloadInlineImageRequest(imageId : String) throws {
        guard let email = self.email else
        {
            throw ZCRMError.processingError( code: ErrorCode.mandatoryNotFound, message: " EMAIL must not be nil", details : nil )
        }
        if !email.didSend {
            throw ZCRMError.processingError( code: ErrorCode.processingError, message: "Only sent messages can be used to perform download operations", details : nil )
        }
        setJSONRootKey(key: JSONRootKey.NIL)
        self.setIsEmail( true )
        let urlString = "\( email.record.moduleAPIName )/\( email.record.id )/\( URLPathConstants.Emails )/\( URLPathConstants.inlineImages )"
        addRequestParam(param: RequestParamKeys.userId, value: String( email.userId ))
        addRequestParam(param: RequestParamKeys.messageId, value: email.messageId)
        addRequestParam(param: RequestParamKeys.id, value: imageId)
        setUrlPath(urlPath: urlString)
        setRequestMethod(requestMethod: .get)
    }
    
    internal func downloadInlineImage( imageId : String, completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        do {
            try buildDownloadInlineImageRequest(imageId: imageId)
            let request : FileAPIRequest = FileAPIRequest(handler : self)
            ZCRMLogger.logDebug(message: "Request : \( request.toString() )")
            
            request.downloadFile { ( resultType ) in
                do
                {
                    switch resultType
                    {
                    case .success(let response) :
                        completion( .success( response ) )
                    case .failure(let error) :
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }
            }
        } catch {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( error )")
            completion( .failure( typeCastToZCRMError( error )))
        }
    }
    
    internal func downloadInlineImage( imageId : String, fileDownloadDelegate : ZCRMFileDownloadDelegate ) throws
    {
        do {
            try buildDownloadInlineImageRequest(imageId: imageId)
            let request : FileAPIRequest = FileAPIRequest(handler: self, fileDownloadDelegate: fileDownloadDelegate, imageId )
            ZCRMLogger.logDebug(message: "Request : \( request.toString() )")
            
            request.downloadFile()
        } catch {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( error )")
            throw typeCastToZCRMError( error )
        }
    }
    
    func buildDownloadAttachmentRequest( email : ZCRMEmail, attachmentId : String?, fileName : String? ) throws
    {
        setJSONRootKey( key : JSONRootKey.NIL )
        self.setIsEmail( true )
        let urlString = "\( email.record.moduleAPIName )/\( email.record.id )/\( URLPathConstants.Emails )/\( URLPathConstants.attachments )"
        guard email.didSend else
        {
            throw ZCRMError.processingError( code: ErrorCode.processingError, message: "Only sent messages can be used to perform download operations", details : nil )
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
        
        setRequestMethod(requestMethod: .get )
    }
    
    internal func downloadAttachment( attachmentId : String?, fileName : String?, completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        do
        {
            guard let email = self.email else
            {
                throw ZCRMError.processingError( code: ErrorCode.mandatoryNotFound, message: " EMAIL must not be nil", details : nil )
            }
            try buildDownloadAttachmentRequest( email : email, attachmentId: attachmentId, fileName: fileName )
            let request : FileAPIRequest = FileAPIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.downloadFile { ( resultType ) in
                switch resultType
                {
                case .success(let fileResponse) :
                    completion( .success( fileResponse ) )
                case .failure(let error) :
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        catch
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( error )")
            completion( .failure( typeCastToZCRMError( error )))
        }
    }
    
    internal func downloadAttachment( attachmentId : String?, fileName : String?, fileDownloadDelegate : ZCRMFileDownloadDelegate ) throws
    {
        do
        {
            guard let email = self.email else
            {
                throw ZCRMError.processingError( code: ErrorCode.mandatoryNotFound, message: " EMAIL must not be nil", details : nil )
            }
            try buildDownloadAttachmentRequest( email : email, attachmentId: attachmentId, fileName: fileName )
            let request : FileAPIRequest = FileAPIRequest(handler: self, fileDownloadDelegate: fileDownloadDelegate, attachmentId ?? fileName ?? email.messageId )
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.downloadFile()
        }
        catch
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( error )")
            throw typeCastToZCRMError( error )
        }
    }
    
    internal func createOrgEmail( completion : @escaping( Result.DataResponse< ZCRMOrgEmail, APIResponse > ) -> () )
    {
        if let orgEmail = self.orgEmail
        {
            setJSONRootKey(key: JSONRootKey.ORG_EMAILS)
            var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
            var dataArray : [[String:Any]] = [[String:Any]]()
            do
            {
                dataArray.append(try self.getZCRMOrgEmailAsJSON(orgEmail: orgEmail))
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath(urlPath: "\(URLPathConstants.settings)/\(URLPathConstants.emails)/\(URLPathConstants.orgEmails)")
            setRequestMethod(requestMethod: .post)
            setRequestBody(requestBody: reqBodyObj)
            
            let request : APIRequest = APIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.getAPIResponse { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let responseJSON = response.getResponseJSON()
                    let responseJSONArray  = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    let responseJSONData = responseJSONArray[ 0 ]
                    let responseDetails : [ String : Any ] = try responseJSONData.getDictionary( key : APIConstants.DETAILS )
                    let createdMail = try self.getZCRMOrgEmail(orgEmail: orgEmail, orgEmailDetails: responseDetails)
                    response.setData( data : createdMail )
                    completion( .success( createdMail, response ) )
                }
                catch{
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : ORG EMAIL must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code: ErrorCode.mandatoryNotFound, message: "ORG EMAIL must not be nil", details : nil ) ) )
        }
    }
    
    //MARK:- To confirm the email id given
    internal func confirmation( withCode : String, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        if let orgEmail = self.orgEmail
        {
            if !orgEmail.isCreate
            {
                setJSONRootKey(key: JSONRootKey.ORG_EMAILS)
                setUrlPath(urlPath: "\(URLPathConstants.settings)/\(URLPathConstants.emails)/\(URLPathConstants.orgEmails)/\(String(orgEmail.id))/\( URLPathConstants.actions )/\( URLPathConstants.confirm )")
                addRequestParam(param: RequestParamKeys.code, value: withCode)
                setRequestMethod(requestMethod: .post)
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
            else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : ORG EMAIL ID must not be nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code: ErrorCode.mandatoryNotFound, message: "ORG EMAIL ID must not be nil", details : nil ) ) )
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : ORG EMAIL must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code: ErrorCode.mandatoryNotFound, message: "ORG EMAIL must not be nil", details : nil ) ) )
        }
    }
    
    internal func resendConfirmationCode( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        if let orgEmail = self.orgEmail
        {
            if !orgEmail.isCreate
            {
                setJSONRootKey(key: JSONRootKey.ORG_EMAILS)
                setUrlPath(urlPath: "\(URLPathConstants.settings)/\(URLPathConstants.emails)/\(URLPathConstants.orgEmails)/\(String(orgEmail.id))/\( URLPathConstants.actions )/\( URLPathConstants.resendConfirmEmail )")
                setRequestMethod(requestMethod: .post)
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
            else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : ORG EMAIL ID must not be nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code: ErrorCode.mandatoryNotFound, message: "ORG EMAIL ID must not be nil", details : nil ) ) )
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : ORG EMAIL must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code: ErrorCode.mandatoryNotFound, message: "ORG EMAIL must not be nil", details : nil ) ) )
        }
    }
    
    internal func getOrgEmail( id : Int64, completion : @escaping( Result.DataResponse< ZCRMOrgEmail, APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.ORG_EMAILS)
        setUrlPath(urlPath: "\(URLPathConstants.settings)/\(URLPathConstants.emails)/\(URLPathConstants.orgEmails)/\(String(id))")
        setRequestMethod(requestMethod: .get)
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do
            {
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let orgEmailList:[ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                var orgEmail : ZCRMOrgEmail = ZCRMOrgEmail( id : try orgEmailList[ 0 ].getInt64( key : ResponseJSONKeys.id ) )
                orgEmail = try self.getZCRMOrgEmail(orgEmail: orgEmail, orgEmailDetails: orgEmailList[0])
                response.setData(data: orgEmail )
                completion( .success( orgEmail, response ) )
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getOrgEmails( completion : @escaping( Result.DataResponse< [ ZCRMOrgEmail ], BulkAPIResponse > ) -> () )
    {
        var orgEmails : [ZCRMOrgEmail] = [ZCRMOrgEmail]()
        setJSONRootKey(key: JSONRootKey.ORG_EMAILS)
        setUrlPath(urlPath: "\(URLPathConstants.settings)/\(URLPathConstants.emails)/\(URLPathConstants.orgEmails)")
        setRequestMethod(requestMethod: .get)
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let orgEmailsList:[ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    if orgEmailsList.isEmpty == true
                    {
                        completion( .failure( ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    for orgEmailList in orgEmailsList
                    {
                        let orgEmail = ZCRMOrgEmail( id : try orgEmailList.getInt64( key : ResponseJSONKeys.id ) )
                        orgEmails.append( try self.getZCRMOrgEmail(orgEmail: orgEmail, orgEmailDetails: orgEmailList))
                    }
                }
                bulkResponse.setData(data: orgEmails)
                completion( .success( orgEmails, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func delete( id : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.ORG_EMAILS)
        setUrlPath(urlPath: "\(URLPathConstants.settings)/\(URLPathConstants.emails)/\(URLPathConstants.orgEmails)/\(String(id))" )
        setRequestMethod(requestMethod: .delete )
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
            
            if let content = email.content {
                let inlineImageIds = getIdsFromEmail( content )
                if !inlineImageIds.isEmpty {
                    email.inlineImageIds = inlineImageIds
                }
            }
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
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : \(ResponseJSONKeys.sentimentDetails) has invalid value, \( APIConstants.DETAILS ) : -")
                throw ZCRMError.inValidError( code : ErrorCode.invalidData, message : "\(ResponseJSONKeys.sentimentDetails) has invalid value", details : nil )
            }
            email.sentimentDetails = sentiment
        }
        let mailFormat = try emailDetails.getString( key : ResponseJSONKeys.mailFormat )
        guard let format = ZCRMEmail.MailFormat(rawValue: mailFormat) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : \(ResponseJSONKeys.mailFormat) has invalid value, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ErrorCode.invalidData, message : "\(ResponseJSONKeys.mailFormat) has invalid value", details : nil )
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
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : \(ResponseJSONKeys.paperType) has invalid value, \( APIConstants.DETAILS ) : -")
                throw ZCRMError.inValidError( code : ErrorCode.invalidData, message : "\(ResponseJSONKeys.paperType) has invalid value", details : nil )
            }
            email.paperType = paperTypeEnum
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.viewType)
        {
            let viewType = try emailDetails.getString( key : ResponseJSONKeys.viewType )
            guard let viewTypeEnum = ZCRMEmail.ViewType(rawValue: viewType) else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : \(ResponseJSONKeys.viewType) has invalid value, \( APIConstants.DETAILS ) : -")
                throw ZCRMError.inValidError( code : ErrorCode.invalidData, message : "\(ResponseJSONKeys.viewType) has invalid value", details : nil )
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
        email.didSend = true
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
    
    private func getZCRMOrgEmail(orgEmail : ZCRMOrgEmail, orgEmailDetails : [String : Any]) throws -> ZCRMOrgEmail
    {
        orgEmail.id = try orgEmailDetails.getInt64( key : ResponseJSONKeys.id )
        if orgEmailDetails.hasValue(forKey: ResponseJSONKeys.confirm)
        {
            orgEmail.isConfirmed = try orgEmailDetails.getBoolean(key: ResponseJSONKeys.confirm)
        }
        orgEmail.name = try orgEmailDetails.getString( key : ResponseJSONKeys.displayName )
        if orgEmailDetails.hasValue(forKey: ResponseJSONKeys.email)
        {
            orgEmail.email = try orgEmailDetails.getString( key : ResponseJSONKeys.email )
        }
        let profilesDet : [ [ String : Any ] ] = try orgEmailDetails.getArrayOfDictionaries( key : ResponseJSONKeys.profiles )
        for profileDet in profilesDet
        {
            var profile : ZCRMProfileDelegate
            profile = ZCRMProfileDelegate( id : try profileDet.getInt64( key : ResponseJSONKeys.id ), name : try profileDet.getString( key : ResponseJSONKeys.name ) )
            orgEmail.addAccessibleProfile(profile: profile)
        }
        return orgEmail
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
    
    private func getZCRMOrgEmailAsJSON( orgEmail : ZCRMOrgEmail ) throws -> [String:Any]
    {
        var orgEmailDetails : [String:Any] = [String:Any]()
        var profilesDetails : [[String:Any]] = [[String:Any]]()
        orgEmailDetails.updateValue( orgEmail.name, forKey : ResponseJSONKeys.displayName )
        orgEmailDetails.updateValue( orgEmail.email, forKey : ResponseJSONKeys.email )
        if orgEmail.accessibleProfiles.isEmpty == true
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.valueNil) : \(ResponseJSONKeys.profiles) must not be nil, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ErrorCode.valueNil, message : "\( ResponseJSONKeys.profiles ) must not be nil", details : nil )
        }
        for profile in orgEmail.accessibleProfiles
        {
            var profileDetails : [String:Any] = [String:Any]()
            profileDetails.updateValue( profile.id, forKey : ResponseJSONKeys.id )
            profilesDetails.append(profileDetails)
        }
        orgEmailDetails.updateValue( profilesDetails, forKey : ResponseJSONKeys.profiles )
        return orgEmailDetails
    }
}

extension EmailAPIHandler
{
    internal func uploadAttachment( filePath : String?, fileName : String?, fileData : Data?, inline : Bool, sendMail : Bool, completion : @escaping( Result.DataResponse< String, APIResponse > ) -> () )
    {
        do
        {
            try fileDetailCheck( filePath : filePath, fileData : fileData, maxFileSize: MaxFileSize.emailAttachment )
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            completion( .failure( typeCastToZCRMError( error ) ) )
            return
        }
        setJSONRootKey(key: JSONRootKey.NIL)
        setUrlPath(urlPath: "\( URLPathConstants.emails )/\( URLPathConstants.attachments )/\( URLPathConstants.upload )" )
        setRequestMethod(requestMethod: .post )
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
    
    internal func uploadAttachment( fileRefId : String, filePath : String?, fileName : String?, fileData : Data?, inline : Bool, sendMail : Bool, emailAttachmentUploadDelegate : ZCRMEmailAttachmentUploadDelegate )
    {
        do
        {
            try fileDetailCheck( filePath : filePath, fileData : fileData, maxFileSize: MaxFileSize.emailAttachment )
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            emailAttachmentUploadDelegate.didFail( fileRefId : fileRefId, typeCastToZCRMError( error ) )
            return
        }
        setJSONRootKey(key: JSONRootKey.NIL)
        setUrlPath(urlPath: "\( URLPathConstants.emails )/\( URLPathConstants.attachments )/\( URLPathConstants.upload )" )
        setRequestMethod(requestMethod: .post )
        if inline && sendMail
        {
            addRequestParam( param : RequestParamKeys.inline, value : String( inline ) )
            addRequestParam( param : RequestParamKeys.sendMail, value : String( sendMail ) )
        }
        let request : FileAPIRequest = FileAPIRequest( handler : self, fileUploadDelegate : emailAttachmentUploadDelegate, fileRefId: fileRefId )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        var emailAPIHandler : EmailAPIHandler? = self
        request.uploadFile(fileRefId: fileRefId, filePath: filePath, fileName: fileName, fileData: fileData, entity: nil) { result, response in
            if result
            {
                guard let response = response else {
                    emailAPIHandler = nil
                    return
                }
                do
                {
                    guard let attachmentId = try emailAPIHandler?.getAttachmentIdFrom( response : response ) else { return }
                    emailAttachmentUploadDelegate.getAttachmentId( attachmentId, fileRefId: fileRefId )
                }
                catch
                {
                    emailAttachmentUploadDelegate.didFail( fileRefId : fileRefId, typeCastToZCRMError( error ) )
                }
            }
            emailAPIHandler = nil
        }
    }
    
    private func getAttachmentIdFrom( response : APIResponse ) throws -> String
    {
        let responseJSON = response.getResponseJSON()
        let attachmentId = try responseJSON.getString( key : JSONRootKey.DATA )
        return attachmentId
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
    
    struct URLPathConstants {
        static let actions = "actions"
        static let sendMail = "send_mail"
        static let Emails = "Emails"
        static let inlineImages = "inline_images"
        static let attachments = "attachments"
        static let resendConfirmEmail = "resend_confirm_email"
        static let upload = "upload"
        static let emails = "emails"
        static let confirm = "confirm"
        static let orgEmails = "org_emails"
        static let settings = "settings"
    }
}

public protocol ZCRMEmailAttachmentUploadDelegate : ZCRMFileUploadDelegate
{
    func getAttachmentId( _ id : String, fileRefId : String )
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

/**
 To seperate the inline image ids from the content of the email.
 
 - parameters:
    - content : Content of the email
 
 - returns: An array of string containing the ids of the inline images
 */
internal func getIdsFromEmail(_ content : String) -> [String] {
    let pattern = "(?<=(img_id:))[a-zA-Z0-9]+(?=(\"))"
    let matched = findMatch(for: pattern, in: content)
    var imageIds : [String] = [String]()
    for match in matched {
        imageIds.append(match)
    }
    return imageIds
}

/**
 To find the matching pattern in the content of the email to get the array of inline image ids
 
 - parameters:
    - regex : The regex that needs to be matched
    - text : The text from which the ids needs to be seperated
 
 - returns: An array of string containing the inline image ids
 */
func findMatch(for regex: String, in text: String) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text, range: NSRange(location: 0, length: text.utf8.count))
        var inlineAttachmentIds : [String] = [String]()
        _ = results.map {
            guard let range = Range($0.range, in: text) else {
                return
            }
            inlineAttachmentIds.append(String(text[range]))
        }
        return inlineAttachmentIds
    } catch {
        ZCRMLogger.logDebug(message: "ZCRM SDK - Invalid RegEx \(error)")
        return []
    }
}
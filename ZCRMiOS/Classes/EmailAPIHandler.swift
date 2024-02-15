//
//  EmailAPIHandler.swift
//  ZCRMiOS
//
//  Created by test on 15/02/24.
//

import Foundation

class EmailAPIHandler : CommonAPIHandler {
    
    internal var email : ZCRMEmail?
    
    init( email : ZCRMEmail ) {
        self.email = email
    }
    
    override init()
    { }
    
    internal func sendMail( completion : @escaping( ZCRMResult.DataResponse< ZCRMEmail, APIResponse > ) -> () )
    {
        if let email = self.email
        {
            setJSONRootKey(key: JSONRootKey.DATA)
            var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
            var dataArray : [[String:Any]] = [[String:Any]]()
            do
            {
                dataArray.append( try self.getZCRMEmailAsJSON(email: email))
            }
            catch
            {
                completion( .failure( typeCastToZCRMError( error ) ) )
                return
            }
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
                        ZCRMLogger.logError(message: "\(ZCRMErrorCode.valueNil) : \(ResponseJSONKeys.messageId) must not be nil, \( APIConstants.DETAILS ) : -")
                        throw ZCRMError.inValidError(code: ZCRMErrorCode.valueNil, message: "\(ResponseJSONKeys.messageId) must not be nil", details : nil)
                    }
                    email.messageId = try responseDetails.getString( key : ResponseJSONKeys.messageId )
                    email.didSend = true
                    response.setData( data : email )
                    completion( .success( email, response ) )
                }
                catch
                {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.mandatoryNotFound) : EMAIL must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code: ZCRMErrorCode.mandatoryNotFound, message: "EMAIL must not be nil", details : nil ) ) )
        }
    }
    
    internal func viewMail( record : ZCRMRecordDelegate, userId : Int64, messageId : String, completion : @escaping( ZCRMResult.DataResponse< ZCRMEmail, APIResponse > ) -> () )
    {
        if ZCRMSDKClient.shared.apiVersion < APIConstants.API_VERSION_V4
        {
            setJSONRootKey(key: JSONRootKey.EMAIL_RELATED_LIST)
        }
        else
        {
            setJSONRootKey(key: JSONRootKey.EMAILS)
        }
        setUrlPath( urlPath : "\( record.moduleAPIName )/\( record.id )/\( URLPathConstants.Emails )" )
        addRequestParam(param: RequestParamKeys.userId, value: String( userId ) )
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
                email.ownerId = userId
                email.messageId = messageId
                response.setData( data : email )
                completion( .success( email, response ) )
            }
            catch
            {
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func viewMails( record : ZCRMRecordDelegate, params : ZCRMQuery.GetEmailParams, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMEmail ], BulkAPIResponse > ) -> () )
    {
        var emails : [ ZCRMEmail ] = [ ZCRMEmail ]()
        if ZCRMSDKClient.shared.apiVersion < APIConstants.API_VERSION_V4
        {
            setJSONRootKey(key: JSONRootKey.EMAIL_RELATED_LIST)
        }
        else
        {
            setJSONRootKey(key: JSONRootKey.EMAILS)
        }
        setUrlPath( urlPath : "\( record.moduleAPIName )/\( record.id )/\( URLPathConstants.Emails )" )
        setRequestMethod(requestMethod: .get)
        
        if let ownerId = params.ownerId
        {
            addRequestParam(param: RequestParamKeys.userId, value: "\( ownerId )")
        }
        if let type = params.type
        {
            if (type.rawValue == "")
            {
                ZCRMLogger.logError(message: "\( ZCRMErrorCode.notSupported ) : Given mail type is not supported in this api version - \(type.rawValue), \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code: ZCRMErrorCode.notSupported, message: "Given mail type is not supported in this api version - \(type.rawValue)", details : nil ) ) )
                return
            }
            else
            {
                addRequestParam(param: RequestParamKeys.type, value: "\( type.rawValue )")
            }
        }
        if let lastMailIndex = params.lastMailIndex
        {
            addRequestParam(param: RequestParamKeys.lastMailIndex, value: "\( lastMailIndex )")
        }
        if let startIndex = params.startIndex
        {
            addRequestParam(param: RequestParamKeys.startIndex, value: "\( startIndex )")
        }
        if let page = params.page
        {
            addRequestParam(param: RequestParamKeys.page, value: "\( page )")
        }
        if let dealsMail = params.dealsMail
        {
            addRequestParam(param: RequestParamKeys.dealsMail, value: "\( dealsMail )")
        }
        
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { result in
            do
            {
                switch result
                {
                case .success(let bulkResponse) :
                    let responseJSON = bulkResponse.getResponseJSON()
                    if !responseJSON.isEmpty
                    {
                        let emailList : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                        for emailJSON in emailList
                        {
                            let email = try self.getZCRMEmail(record: record, emailDetails: emailJSON)
                            emails.append( email )
                        }
                    }
                    bulkResponse.setData(data: emails)
                    completion( .success(emails, bulkResponse) )
                case .failure(let error) :
                    ZCRMLogger.logError(message: "\( error )")
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
            catch
            {
                ZCRMLogger.logError(message: "\( error )")
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getInventoryTemplates( params : ZCRMQuery.GetTemplateParams, completion : @escaping ( ZCRMResult.DataResponse< [ ZCRMInventoryTemplate ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.INVENTORY_TEMPLATES)
        setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.inventoryTemplates )")
        
        if let category = params.category
        {
            if category == .associated
            {
                ZCRMLogger.logError(message: "\( ZCRMErrorCode.invalidData ) : Category - associated is not applicable for Inventory template type, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.sdkError( code : ZCRMErrorCode.invalidData, message : "Category - associated is not applicable for Inventory template type", details : nil ) ) )
                return
            }
            addRequestParam(param: RequestParamKeys.category, value: category.rawValue)
        }
        if let module = params.module
        {
            addRequestParam(param: RequestParamKeys.module, value: module)
        }
        if let sortBy = params.sortBy
        {
            addRequestParam(param: RequestParamKeys.sortBy, value: sortBy)
        }
        if let sortOrder = params.sortOrder
        {
            addRequestParam(param: RequestParamKeys.sortOrder, value: sortOrder.rawValue)
        }
        if let filterQuery = params.filter?.filterQuery
        {
            addRequestParam(param: RequestParamKeys.filters, value: filterQuery)
        }
        setRequestMethod(requestMethod: .get)
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( result ) in
            switch result
            {
            case .success(let bulkResponse) :
                do
                {
                    var inventoryTemplates : [ ZCRMInventoryTemplate ] = [ ZCRMInventoryTemplate ]()
                    let responseJSON = bulkResponse.getResponseJSON()
                    if responseJSON.isEmpty == false
                    {
                        let inventoryTemplatesList : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                        if inventoryTemplatesList.isEmpty == true
                        {
                            ZCRMLogger.logError(message: "\( ZCRMErrorCode.responseNil ) : \( ZCRMErrorMessage.responseJSONNilMsg ), \( APIConstants.DETAILS ) : -")
                            completion( .failure( ZCRMError.sdkError( code : ZCRMErrorCode.responseNil, message : ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                            return
                        }
                        for inventoryTemplateList in inventoryTemplatesList
                        {
                            inventoryTemplates.append( try self.getZCRMInventoryTemplate(inventoryTemplateDetails: inventoryTemplateList) )
                        }
                    }
                    bulkResponse.setData(data: inventoryTemplates)
                    completion( .success( inventoryTemplates, bulkResponse ) )
                }
                catch
                {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getInventoryTemplate(byId id : Int64, completion : @escaping ( ZCRMResult.DataResponse< ZCRMInventoryTemplate, APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.INVENTORY_TEMPLATES)
        setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.inventoryTemplates )/\( id )")
        setRequestMethod(requestMethod: .get)
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( result ) in
            switch result
            {
            case .success(let response) :
                do
                {
                    let responseJSON = response.getResponseJSON()
                    let inventoryTemplateArray = try responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey() )
                    guard !inventoryTemplateArray.isEmpty else
                    {
                        ZCRMLogger.logError(message: "\( ZCRMErrorCode.responseNil ) : \( ZCRMErrorMessage.responseJSONNilMsg ), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ZCRMErrorCode.responseNil, message : ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    let inventoryTemplate = try self.getZCRMInventoryTemplate(inventoryTemplateDetails: inventoryTemplateArray[0] )
                    response.setData(data: inventoryTemplate)
                    completion( .success( inventoryTemplate, response ) )
                }
                catch
                {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getEmailTemplates( params : ZCRMQuery.GetTemplateParams, completion : @escaping ( ZCRMResult.DataResponse< [ ZCRMEmailTemplate ], BulkAPIResponse > ) -> ())
    {
        setRequestMethod(requestMethod: .get)
        if ZCRMSDKClient.shared.appType == .bigin
        {
            if let pipelineId = params.pipelineId
            {
                if (params.module != ZCRMDefaultModuleAPINames.DEALS)
                {
                    ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidModule) : \( ZCRMErrorMessage.invalidDealsModule)")
                    
                    completion( .failure( ZCRMError.inValidError(code: ZCRMErrorCode.invalidModule, message: ZCRMErrorMessage.invalidDealsModule, details: nil)))
                    return
                }
                else
                {
                    self.addRequestParam(param: RequestParamKeys.pipelineId, value: "\(pipelineId)")
                }
            }
            setJSONRootKey(key: JSONRootKey.TEMPLATES)
            setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.templates )")
            self.addRequestParam(param: RequestParamKeys.type, value: ResponseJSONKeys.email)
        }
        else
        {
            setJSONRootKey(key: JSONRootKey.EMAIL_TEMPLATES)
            setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.emailTemplates )")
        }
        if let module = params.module
        {
            addRequestParam(param: RequestParamKeys.module, value: module)
        }
        if let category = params.category
        {
            let categoryStr: String = ZCRMTemplateCategory.getString(for: category, isBigin: ZCRMSDKClient.shared.appType == .bigin)
            if categoryStr == ""
            {
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidData) : \( ZCRMErrorMessage.invalidTemplateCategory)")
                
                completion( .failure( ZCRMError.inValidError(code: ZCRMErrorCode.invalidData, message: ZCRMErrorMessage.invalidTemplateCategory, details: nil)))
                return
            }
            addRequestParam(param: RequestParamKeys.category, value: categoryStr)
        }
        if let sortBy = params.sortBy
        {
            addRequestParam(param: RequestParamKeys.sortBy, value: sortBy)
        }
        if let sortOrder = params.sortOrder
        {
            addRequestParam(param: RequestParamKeys.sortOrder, value: sortOrder.rawValue)
        }
        if let filterQuery = params.filter?.filterQuery
        {
            addRequestParam(param: RequestParamKeys.filters, value: filterQuery)
        }
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( result ) in
            switch result
            {
            case .success(let bulkResponse) :
                do
                {
                    var emailTemplates : [ ZCRMEmailTemplate ] = [ ZCRMEmailTemplate ]()
                    let responseJSON = bulkResponse.getResponseJSON()
                    if responseJSON.isEmpty == false
                    {
                        let emailTemplatesList : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                        if emailTemplatesList.isEmpty == true
                        {
                            ZCRMLogger.logError(message: "\( ZCRMErrorCode.responseNil ) : \( ZCRMErrorMessage.responseJSONNilMsg ), \( APIConstants.DETAILS ) : -")
                            completion( .failure( ZCRMError.sdkError( code : ZCRMErrorCode.responseNil, message : ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                            return
                        }
                        for emailTemplateList in emailTemplatesList
                        {
                            emailTemplates.append( try self.getZCRMEmailTemplate(emailTemplateDetails: emailTemplateList) )
                        }
                    }
                    bulkResponse.setData(data: emailTemplates)
                    completion( .success( emailTemplates, bulkResponse ) )
                }
                catch
                {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getEmailTemplate( byId id : Int64, completion : @escaping ( ZCRMResult.DataResponse< ZCRMEmailTemplate, APIResponse > ) -> ())
    {
        setJSONRootKey(key: JSONRootKey.EMAIL_TEMPLATES)
        setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.emailTemplates )/\( id )")
        setRequestMethod(requestMethod: .get)
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( result ) in
            switch result
            {
            case .success(let response) :
                do
                {
                    let responseJSON = response.getResponseJSON()
                    let emailTemplateArray = try responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                    guard !emailTemplateArray.isEmpty else
                    {
                        ZCRMLogger.logError(message: "\( ZCRMErrorCode.responseNil ) : \( ZCRMErrorMessage.responseJSONNilMsg ), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ZCRMErrorCode.responseNil, message : ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    let emailTemplate = try self.getZCRMEmailTemplate(emailTemplateDetails: emailTemplateArray[0])
                    response.setData(data: emailTemplate)
                    completion( .success( emailTemplate, response ) )
                }
                catch
                {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    private func getTemplateAttachments( attachment : [ String : Any ], isPreviewAPI : Bool ) throws -> ZCRMEmailTemplate.Attachment
    {
        let size = try attachment.getInt64(key: ResponseJSONKeys.size )
        var fileName : String
        if isPreviewAPI
        {
            fileName = try attachment.getString(key: ResponseJSONKeys.name )
        }
        else
        {
            fileName = try attachment.getString(key: ResponseJSONKeys.fileName )
        }
        let fileId = try attachment.getString(key: ResponseJSONKeys.fileId )
        let id = try attachment.getInt64(key: ResponseJSONKeys.id )
        
        return ZCRMEmailTemplate.Attachment( size: size, file_name: fileName, fileId: fileId, id: id )
    }
    
    private func getZCRMEmailTemplate( emailTemplateDetails : [ String : Any ] ) throws -> ZCRMEmailTemplate
    {
        let id = try emailTemplateDetails.getInt64(key: ResponseJSONKeys.id )
        let name = try emailTemplateDetails.getString(key: ResponseJSONKeys.name )
        let folderDetails = try emailTemplateDetails.getDictionary(key: ResponseJSONKeys.folder )
        let folder = try ZCRMEmailTemplate.Folder(name: folderDetails.getString(key: ResponseJSONKeys.name), id: folderDetails.getInt64(key: ResponseJSONKeys.id))
        let moduleAPIName =  try emailTemplateDetails.optDictionary(key: ResponseJSONKeys.module)?.getString(key: ResponseJSONKeys.apiName) ?? emailTemplateDetails.getString(key: ResponseJSONKeys.module)
        let module = ZCRMModuleDelegate(apiName: moduleAPIName)
        let emailTemplate = ZCRMEmailTemplate(id : id, name : name, folder: folder, module: module )
        
        emailTemplate.isConsentLinked = try emailTemplateDetails.getBoolean(key: ResponseJSONKeys.consentLinked)
        emailTemplate.subject = try emailTemplateDetails.getString(key: ResponseJSONKeys.subject)

        emailTemplate.modifiedTime = emailTemplateDetails.optString(key: ResponseJSONKeys.modifiedTime )
        emailTemplate.editorMode = ZCRMTemplateEditorMode.getType(rawValue: try emailTemplateDetails.getString(key: ResponseJSONKeys.editorMode))
        
        emailTemplate.isFavorite = try emailTemplateDetails.optBoolean(key: ResponseJSONKeys.favorite) ?? emailTemplateDetails.getBoolean(key: ResponseJSONKeys.favourite)
        
        emailTemplate.content = emailTemplateDetails.optString(key: ResponseJSONKeys.content )
        
        if let modifiedUserDetails = emailTemplateDetails.optDictionary(key: ResponseJSONKeys.modifiedBy )
        {
            emailTemplate.modifiedBy = try getUserDelegate(userJSON: modifiedUserDetails)
        }
        if let associated = emailTemplateDetails.optBoolean(key: ResponseJSONKeys.associated)
        {
            emailTemplate.isAssociated = associated
        }
        
        emailTemplate.createdTime = emailTemplateDetails.optString(key: ResponseJSONKeys.createdTime )
        emailTemplate.lastUsageTime = emailTemplateDetails.optString(key: ResponseJSONKeys.lastUsageTime )
        if emailTemplateDetails.hasValue(forKey: ResponseJSONKeys.attachments)
        {
            let attachments = try emailTemplateDetails.getArrayOfDictionaries(key: ResponseJSONKeys.attachments )
            emailTemplate.attachments = [ ZCRMEmailTemplate.Attachment ]()
            for attachment in attachments
            {
                emailTemplate.attachments?.append( try self.getTemplateAttachments( attachment : attachment, isPreviewAPI: false ) )
            }
        }
        if let templateType = emailTemplateDetails.optString(key: ResponseJSONKeys.type)
        {
            emailTemplate.type = ZCRMTemplateType(rawValue: templateType)
        }
        
        if let createdUserDetails = emailTemplateDetails.optDictionary(key: ResponseJSONKeys.createdBy)
        {
            emailTemplate.createdBy = try getUserDelegate(userJSON: createdUserDetails)
        }
        
        if let lastVersionStatistics = emailTemplateDetails.optDictionary(key: "last_version_statistics")
        {
            emailTemplate.lastVersionStatistics = ZCRMEmailTemplate.LastVersionStatistics(tracked: try lastVersionStatistics.getInt(key: "tracked"), delivered: try lastVersionStatistics.getInt(key: "delivered"), opened: try lastVersionStatistics.getInt(key: "opened"), bounced: try lastVersionStatistics.getInt(key: "bounced"), sent: try lastVersionStatistics.getInt(key: "sent"), clicked: try lastVersionStatistics.getInt(key: "clicked"))
        }
        
        
        return emailTemplate
    }
    
    private func getZCRMInventoryTemplate( inventoryTemplateDetails : [ String : Any ] ) throws -> ZCRMInventoryTemplate
    {
        let id = try inventoryTemplateDetails.getInt64(key: ResponseJSONKeys.id )
        let name = try inventoryTemplateDetails.getString(key: ResponseJSONKeys.name )
        let folderDetails = try inventoryTemplateDetails.getDictionary(key: ResponseJSONKeys.folder )
        let folder = try ZCRMInventoryTemplate.Folder(name: folderDetails.getString(key: ResponseJSONKeys.name), id: folderDetails.getInt64(key: ResponseJSONKeys.id))
        let moduleDetails = try inventoryTemplateDetails.getDictionary(key: ResponseJSONKeys.module )
        let module = try ZCRMModuleDelegate(apiName: moduleDetails.getString(key: ResponseJSONKeys.apiName ))
        let inventoryTemplate = ZCRMInventoryTemplate( id : id, name : name, folder: folder, module: module )
        
        if let type = ZCRMTemplateType.getType(rawValue: inventoryTemplateDetails.optString(key: ResponseJSONKeys.type))
        {
            inventoryTemplate.type = type
        }
            
        inventoryTemplate.isFavorite = try inventoryTemplateDetails.getBoolean(key: ResponseJSONKeys.favorite )
        
        inventoryTemplate.createdTime = inventoryTemplateDetails.optString(key: ResponseJSONKeys.createdTime )
        if let createdUserDetails = inventoryTemplateDetails.optDictionary(key: ResponseJSONKeys.createdBy)
        {
            inventoryTemplate.createdBy = try getUserDelegate(userJSON: createdUserDetails)
        }
        inventoryTemplate.modifiedTime = inventoryTemplateDetails.optString(key: ResponseJSONKeys.modifiedTime )
        if let modifiedUserDetails = inventoryTemplateDetails.optDictionary(key: ResponseJSONKeys.modifiedBy )
        {
            inventoryTemplate.modifiedBy = try getUserDelegate(userJSON: modifiedUserDetails)
        }
        inventoryTemplate.content = inventoryTemplateDetails.optString(key: ResponseJSONKeys.content )
        inventoryTemplate.lastUsageTime = inventoryTemplateDetails.optString(key: ResponseJSONKeys.lastUsageTime )
        inventoryTemplate.editorMode = ZCRMTemplateEditorMode.getType(rawValue: try inventoryTemplateDetails.getString(key: ResponseJSONKeys.editorMode))
        
        return inventoryTemplate
    }
    
    private func getZCRMEmailAsJSON( email : ZCRMEmail ) throws -> [String:Any]
    {
        var emailDetails : [String:Any] = [String:Any]()
        emailDetails.updateValue( self.getUserAsJSON( user : email.from ), forKey : ResponseJSONKeys.from )
        emailDetails.updateValue( self.getArrayOfUserJSON( users : email.to ), forKey : ResponseJSONKeys.to )
        if !email.cc.isEmpty
        {
            emailDetails.updateValue( self.getArrayOfUserJSON( users : email.cc ), forKey : ResponseJSONKeys.cc )
        }
        if !email.bcc.isEmpty
        {
            emailDetails.updateValue( self.getArrayOfUserJSON( users : email.bcc ), forKey : ResponseJSONKeys.bcc )
        }
        if let replyTo = email.replyTo
        {
            emailDetails.updateValue( self.getUserAsJSON( user : replyTo ), forKey : ResponseJSONKeys.replyTo )
        }
        if email.subject != APIConstants.STRING_MOCK
        {
            emailDetails.updateValue( email.subject, forKey : ResponseJSONKeys.subject )
        }
        if let content = email.content
        {
            emailDetails.updateValue( content, forKey : ResponseJSONKeys.content )
        }
        if let mailFormat = email.mailFormat
        {
            emailDetails.updateValue( mailFormat.rawValue, forKey : ResponseJSONKeys.mailFormat )
        }
        if let scheduledTime = email.scheduledTime
        {
            emailDetails.updateValue( scheduledTime, forKey : ResponseJSONKeys.scheduledTime )
        }
        if let id = email.templateId
        {
            let template : [ String : Int64 ] = [ ResponseJSONKeys.id : id ]
            emailDetails.updateValue( template, forKey : ResponseJSONKeys.template )
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
        if let inventoryDetails = email.inventoryTemplateDetails
        {
            let moduleAPIName = email.record.moduleAPIName
            guard moduleAPIName == ZCRMDefaultModuleAPINames.QUOTES || moduleAPIName == ZCRMDefaultModuleAPINames.SALES_ORDERS || moduleAPIName == ZCRMDefaultModuleAPINames.PURCHASE_ORDERS || moduleAPIName == ZCRMDefaultModuleAPINames.INVOICES else
            {
                ZCRMLogger.logError(message: "Inventory templates are not allowed for this module - \( moduleAPIName )")
                throw ZCRMError.inValidError(code: ZCRMErrorCode.invalidModule, message: "Inventory templates are not allowed for this module - \( moduleAPIName )", details: nil)
            }
            emailDetails[ ResponseJSONKeys.inventoryDetails ] = getInventoryTemplateDetailsASJSON( inventoryDetails )
        }
        return emailDetails
    }
    
    private func getZCRMEmail( record : ZCRMRecordDelegate, emailDetails : [String : Any] ) throws -> ZCRMEmail
    {
        var from = ZCRMEmail.User()
        if emailDetails.hasValue(forKey: ResponseJSONKeys.from)
        {
            let fromDetails = try emailDetails.getDictionary( key : ResponseJSONKeys.from )
            from = try self.getUser(userJSON: fromDetails)
        }
        
        let email : ZCRMEmail = ZCRMEmail(record: record, from: from)
        if emailDetails.hasValue(forKey: ResponseJSONKeys.to)
        {
            let toDetails = try emailDetails.getArrayOfDictionaries( key : ResponseJSONKeys.to )
            email.to = try self.getArrayOfUser(usersJSON: toDetails)
        }
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
        email.subject = try emailDetails.getString( key : ResponseJSONKeys.subject )
        if emailDetails.hasValue(forKey: ResponseJSONKeys.read)
        {
            email.isRead = try emailDetails.getBoolean(key: ResponseJSONKeys.read )
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.source)
        {
            email.source = try ZCRMEmail.Source.getSource( emailDetails.getString(key: ResponseJSONKeys.source) )
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.sent)
        {
            if try emailDetails.getBoolean(key: ResponseJSONKeys.sent)
            {
                email.category = .sent
            }
            else
            {
                email.category = .received
            }
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.conversation)
        {
            email.isConversation = try emailDetails.getBoolean(key: ResponseJSONKeys.conversation)
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.mailIndex)
        {
            email.mailIndex = try emailDetails.getString(key: ResponseJSONKeys.mailIndex)
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.owner)
        {
            let owner = try emailDetails.getDictionary(key: ResponseJSONKeys.owner)
            email.ownerId = try owner.getInt64(key: ResponseJSONKeys.id)
            email.ownerName = try owner.getString(key: ResponseJSONKeys.name)
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
        if emailDetails.hasValue(forKey: ResponseJSONKeys.contactId)
        {
            email.associatedContact = try ZCRMRecordDelegate(id: emailDetails.getInt64(key: ResponseJSONKeys.contactId), moduleAPIName: ZCRMDefaultModuleAPINames.CONTACTS)
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
                attach.size = attachment.optInt64(key: ResponseJSONKeys.size)
                email.attachments?.append(attach)
            }
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.sentimentDetails)
        {
            let sentimentDet = try emailDetails.getString( key : ResponseJSONKeys.sentimentDetails )
            guard let sentiment = ZCRMEmail.SentimentDetails(rawValue: sentimentDet) else
            {
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidData) : \(ResponseJSONKeys.sentimentDetails) has invalid value, \( APIConstants.DETAILS ) : -")
                throw ZCRMError.inValidError( code : ZCRMErrorCode.invalidData, message : "\(ResponseJSONKeys.sentimentDetails) has invalid value", details : nil )
            }
            email.sentimentDetails = sentiment
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.mailFormat)
        {
            let mailFormat = try emailDetails.getString( key : ResponseJSONKeys.mailFormat )
            guard let format = ZCRMEmail.MailFormat(rawValue: mailFormat) else
            {
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidData) : \(ResponseJSONKeys.mailFormat) has invalid value, \( APIConstants.DETAILS ) : -")
                throw ZCRMError.inValidError( code : ZCRMErrorCode.invalidData, message : "\(ResponseJSONKeys.mailFormat) has invalid value", details : nil )
            }
            email.mailFormat = format
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.editable)
        {
            email.isEditable = try emailDetails.getBoolean( key : ResponseJSONKeys.editable )
        }
        if let time = emailDetails.optString( key : ResponseJSONKeys.sentTime )
        {
            email.sentTime = time
        }
        else if let time = emailDetails.optString( key : ResponseJSONKeys.time )
        {
            email.sentTime = time
        }
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
        if emailDetails.hasValue(forKey: ResponseJSONKeys.scheduledTime)
        {
            email.scheduledTime = try emailDetails.getString( key : ResponseJSONKeys.scheduledTime )
        }
        if emailDetails.hasValue(forKey: ResponseJSONKeys.status)
        {
            let status = try emailDetails.getArrayOfDictionaries(key: ResponseJSONKeys.status)
            email.status = []
            for status in status
            {
                email.status?.append( try ZCRMEmail.Status.getStatus( status ) )
            }
        }
        email.didSend = true
        return email
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
    
    private func getInventoryTemplateDetailsASJSON( _ inventoryTemplateDetails : ZCRMEmail.InventoryTemplateDetails ) -> [ String : Any ]
    {
        var inventoryTemplate : [ String : Any ] = [ String : Any ]()
        var layoutDetails : [ String : String ] = [ ResponseJSONKeys.id : "\( inventoryTemplateDetails.templateId )" ]
        if let layoutName = inventoryTemplateDetails.name
        {
            layoutDetails[ ResponseJSONKeys.name ] = layoutName
        }
        inventoryTemplate[ ResponseJSONKeys.inventoryTemplate ] = layoutDetails
        if let paperType = inventoryTemplateDetails.paperType
        {
            inventoryTemplate[ ResponseJSONKeys.paperType ] = paperType.rawValue
        }
        if let viewType = inventoryTemplateDetails.viewType
        {
            inventoryTemplate[ ResponseJSONKeys.viewType ] = viewType.rawValue
        }
        return inventoryTemplate
    }
    
    private func getEmailFromAddresses( fromresponseJSON responseJSON : [[ String : Any ]] ) throws -> [ ZCRMEmail.FromAddress ]
    {
        var emailAddresses : [ ZCRMEmail.FromAddress ] = []
        for emailDetails in responseJSON
        {
            let type = try ZCRMEmail.FromAddress.MailAddressType.getType(rawValue: emailDetails.getString(key: ResponseJSONKeys.type))
            let emailAddress = try ZCRMEmail.FromAddress( emailDetails.getString(key: ResponseJSONKeys.email), type: type)
            emailAddress.userName = emailDetails.optString(key: ResponseJSONKeys.userName)
            if let isDefault = emailDetails.optBoolean(key: ResponseJSONKeys.default)
            {
                emailAddress.isDefault = isDefault
            }
            
            emailAddresses.append( emailAddress )
        }
        return emailAddresses
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
        static let fileId = "file_id"
        static let serviceName = "service_name"
        static let scheduledTime = "scheduled_time"
        static let status = "status"
        static let template = "template"
        static let orgEmail = "org_email"
        static let consentEmail = "consent_email"
        static let inReplyTo = "in_reply_to"
        static let inventoryDetails = "inventory_details"
        static let inventoryTemplate = "inventory_template"
        static let paperType = "paper_type"
        static let viewType = "view_type"
        static let folder = "folder"
        static let apiName = "api_name"
        static let favorite = "favorite"
        static let favourite = "favourite"
        static let type = "type"
        static let lastUsageTime = "last_usage_time"
        static let associated = "associated"
        static let consentLinked = "consent_linked"
        static let editorMode = "editor_mode"
        static let size = "size"
        static let module = "module"
        static let createdTime = "created_time"
        static let modifiedTime = "modified_time"
        static let createdBy = "created_by"
        static let modifiedBy = "modified_by"
        static let sentimentDetails = "sentiment_details"
        static let editable = "editable"
        static let sentTime = "sent_time"
        static let time = "time"
        static let read = "read"
        static let source = "source"
        static let sent = "sent"
        static let conversation = "conversation"
        static let mailIndex = "mail_index"
        static let owner = "owner"
        
        static let active = "active"
        static let body = "body"
        static let usLetter = "us_letter"
        static let `default` = "default"
        static let contactId = "contact_id"
    }
    
    struct URLPathConstants {
        static let actions = "actions"
        static let sendMail = "send_mail"
        static let Emails = "Emails"
        static let emails = "emails"
        static let settings = "settings"
        static let fromAddresses = "from_addresses"
        static let templates = "templates"
        static let emailTemplates = "email_templates"
        static let inventoryTemplates = "inventory_templates"
    }
}

extension RequestParamKeys
{
    static let code = "code"
    static let sendMail = "sendMail"
    static let name = "name"
    static let userId = "user_id"
    static let messageId = "message_id"
    static let printType = "print_type"
    static let viewType = "view_type"
    static let paperType = "paper_type"
}

/**
 To seperate the inline image ids from the content of the email.
 
 - parameters:
    - content : Content of the email
 
 - returns: An array of string containing the ids of the inline images
 */
internal func getIdsFromEmail(_ content : String) -> [String] {
    let pattern = "(?<=img_id:)[a-zA-Z0-9]+(?=\")"
    return findMatch(for: pattern, in: content)
}

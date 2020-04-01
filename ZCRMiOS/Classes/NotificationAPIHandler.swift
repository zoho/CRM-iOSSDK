//
//  NotificationAPIHandler.swift
//  ZCRMiOS
//
//  Created by Umashri R on 01/11/18.
//

internal class NotificationAPIHandler : CommonAPIHandler
{
    
    internal override init() {
    }
    
    internal func getNotifications( page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMNotification ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.NOTIFICATIONS)
        setUrlPath(urlPath: "\( URLPathConstants.signals )/\( URLPathConstants.notifications )")
        setRequestMethod(requestMethod: .get)
        if let page = page
        {
            addRequestParam( param : RequestParamKeys.page, value : String( page ) )
        }
        if let perPage = perPage
        {
            addRequestParam( param : RequestParamKeys.perPage, value : String( perPage ) )
        }
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do
            {
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                var notifications : [ ZCRMNotification ] = [ ZCRMNotification ]()
                if responseJSON.isEmpty == false
                {
                    let notificationsList : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    if notificationsList.isEmpty == true
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code: ErrorCode.responseNil, message: ErrorMessage.responseJSONNilMsg , details : nil) ) )
                        return
                    }
                    for notificationList in notificationsList
                    {
                        notifications.append(try self.getZCRMNotification(notificationDetails: notificationList))
                    }
                }
                bulkResponse.setData(data: notifications)
                completion( .success( notifications, bulkResponse ) )
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getNotificationsCount( completion : @escaping( Result.DataResponse< [ String : Any ], APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.NIL)
        setUrlPath(urlPath: "\( URLPathConstants.signals )/\( URLPathConstants.notifications )/\( URLPathConstants.actions )/\( URLPathConstants.count )")
        setRequestMethod(requestMethod: .get)
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do
            {
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let notificationCount = try responseJSON.getDictionary( key : JSONRootKey.NOTIFICATIONS )
                completion( .success( notificationCount, response ) )
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func markNotificationsAsRead(recordId : Int64?, notificationIds : [Int64]?, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        var urlPath = "\( URLPathConstants.signals )/\( URLPathConstants.notifications )/\( URLPathConstants.actions )/\( URLPathConstants.read )"
        setJSONRootKey(key: JSONRootKey.NOTIFICATIONS)
        
        if let recordId = recordId
        {
            addRequestParam(param: RequestParamKeys.recordId, value: String(recordId))
        }
        else if let notificationIds = notificationIds, notificationIds.isEmpty == false
        {
            if notificationIds.count == 1
            {
                urlPath = urlPath + "/\(String(notificationIds[0]))"
            }
            else
            {
                var idString : String = String()
                for index in 0..<notificationIds.count
                {
                    idString.append(String(notificationIds[index]))
                    if ( index != ( notificationIds.count - 1 ) )
                    {
                        idString.append(",")
                    }
                }
                addRequestParam(param: RequestParamKeys.ids, value: idString)
            }
        }
        
        setUrlPath(urlPath: urlPath)
        setRequestMethod(requestMethod: .put)
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
    
    private func getZCRMNotification( notificationDetails : [ String : Any ] ) throws -> ZCRMNotification
    {
        let notification : ZCRMNotification = ZCRMNotification( id : try notificationDetails.getInt64( key : ResponseJSONKeys.id ) )
        let date = try notificationDetails.getDictionary(key: ResponseJSONKeys.date)
        notification.dateDisplay = try date.getString(key: ResponseJSONKeys.display)
        notification.dateTooltip = try date.getString(key: ResponseJSONKeys.tooltip)
        if notificationDetails.hasValue(forKey: ResponseJSONKeys.metadata)
        {
            let metadata = try notificationDetails.getDictionary(key: ResponseJSONKeys.metadata)
            notification.mailMeta = ZCRMNotification.ZCRMMailMetadata()
            notification.mailMeta?.messageId = try metadata.getString(key: ResponseJSONKeys.mId)
            if metadata.hasValue(forKey: ResponseJSONKeys.AUDITED_TIME)
            {
                notification.mailMeta?.auditedTime = try metadata.getString( key : ResponseJSONKeys.AUDITED_TIME )
            }
            if metadata.hasValue(forKey: ResponseJSONKeys.mailType)
            {
                notification.mailMeta?.mailType = try metadata.getString( key : ResponseJSONKeys.mailType )
            }
            if metadata.hasValue(forKey: ResponseJSONKeys.subject)
            {
                notification.mailMeta?.subject = try metadata.getString( key : ResponseJSONKeys.subject )
            }
        }
        notification.read = try notificationDetails.getBoolean(key: ResponseJSONKeys.read)
        let record = try notificationDetails.getDictionary(key: ResponseJSONKeys.record)
        let module = try notificationDetails.getDictionary(key: ResponseJSONKeys.module)
        notification.record = ZCRMRecordDelegate( id : try record.getInt64( key : ResponseJSONKeys.id ), moduleAPIName : try module.getString( key : ResponseJSONKeys.apiName ) )
        if record.hasValue(forKey: ResponseJSONKeys.phoneNum)
        {
            notification.record.data.updateValue(try record.getString( key : ResponseJSONKeys.phoneNum ), forKey: ResponseJSONKeys.phoneNum)
        }
        if record.hasValue(forKey: ResponseJSONKeys.email)
        {
            notification.record.data.updateValue(try record.getString( key : ResponseJSONKeys.email ), forKey: ResponseJSONKeys.email)
        }
        if record.hasValue(forKey: ResponseJSONKeys.account)
        {
            let accountJSON = try record.getDictionary(key: ResponseJSONKeys.account)
            let account = ZCRMRecordDelegate( id : try accountJSON.getInt64( key : ResponseJSONKeys.id ), moduleAPIName : try module.getString( key : ResponseJSONKeys.apiName ) )
            account.label = try accountJSON.getString(key: ResponseJSONKeys.name)
            notification.record.data.updateValue( account, forKey: ResponseJSONKeys.account)
        }
        if record.hasValue(forKey: ResponseJSONKeys.photoField)
        {
            notification.record.data.updateValue( try record.getString( key : ResponseJSONKeys.photoField ), forKey: ResponseJSONKeys.photoField)
        }
        notification.moduleAPIName = try module.getString( key : ResponseJSONKeys.apiName )
        notification.auditedTime = try notificationDetails.getString( key : ResponseJSONKeys.auditedTime )
        let signal = try notificationDetails.getDictionary( key : ResponseJSONKeys.signal )
        if signal.hasValue(forKey: ResponseJSONKeys.id) && signal.hasValue(forKey: ResponseJSONKeys.namespace) && signal.hasValue(forKey: ResponseJSONKeys.type)
        {
            notification.signal = ZCRMSignalDelegate( id : try signal.getInt64( key : ResponseJSONKeys.id ) )
            notification.signal.type = try signal.getInt( key : ResponseJSONKeys.type )
            notification.signal.namespace = try signal.getString( key : ResponseJSONKeys.namespace )
            notification.signal.displayLabel = signal.optString(key: ResponseJSONKeys.displayLabel)
            if signal.hasValue(forKey: ResponseJSONKeys.icon)
            {
                let icon = try signal.getDictionary( key : ResponseJSONKeys.icon )
                notification.signal.fileId = try icon.getString( key : ResponseJSONKeys.id )
                notification.signal.sandBoxZgId = try icon.getString( key : ResponseJSONKeys.sandBoxZgId )
            }
        }
        return notification
    }
}

internal extension NotificationAPIHandler
{
    struct ResponseJSONKeys
    {
        static let id = "id"
        static let date = "date"
        static let display = "display"
        static let name = "name"
        static let tooltip = "tooltip"
        static let metadata = "metadata"
        static let AUDITED_TIME = "AUDITEDTIME"
        static let mailType = "mailType"
        static let mId = "MID"
        static let subject = "SUBJECT"
        static let read = "read"
        static let record = "record"
        static let module = "module"
        static let auditedTime = "audited_time"
        static let signal = "signal"
        static let phoneNum = "phoneNum"
        static let apiName = "api_name"
        static let email = "email"
        static let account = "account"
        static let namespace = "namespace"
        static let type = "type"
        static let displayLabel = "display_label"
        static let configured = "configured"
        static let signals = "signals"
        static let featureAvailability = "feature_availability"
        static let scoring = "scoring"
        static let notifyVia = "notify_via"
        static let negativeSignal = "negative_signal"
        static let crm = "crm"
        static let cliq = "cliq"
        static let slack = "slack"
        static let enable = "enable"
        static let photoField = "photoFileId"
        static let icon = "icon"
        static let sandBoxZgId = "sand_box_zgid"
        static let title = "title"
        static let summary = "summary"
        static let anamoly = "anamoly"
        static let details = "details"
        static let original = "original"
        static let anomaly = "anomaly"
        static let normal = "normal"
        
        static let ios = "IOS"
    }
    
    struct URLPathConstants
    {
        static let notifications = "notifications"
        static let zia = "zia"
        static let signals = "signals"
        static let actions = "actions"
        static let count = "count"
        static let read = "read"
        static let __internal = "__internal"
        static let ins = "ins"
        static let uns = "uns"
    }
}

extension RequestParamKeys
{
    static let recordId = "record_id"
    static let namespaces = "namespaces"
    static let extensionType = "extension_type"
    static let nfChannel = "nfchannel"
    static let OSCode = "oscode"
    static let appId = "appid"
    static let dInfo = "dinfo"
    static let sInfo = "sinfo"
    static let insId = "insid"
    static let serviceName = "servicename"
    static let apnsMode = "apnsmode"
    static let mobileVersion = "mobileversion"
    static let nfId = "nfid"
    static let displayLabel = "display_label"
}

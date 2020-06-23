//
//  ZCRMNotification.swift
//  ZCRMiOS
//
//  Created by Umashri R on 01/11/18.
//

open class ZCRMNotification : ZCRMEntity
{
    public internal(set) var dateDisplay : String = APIConstants.STRING_MOCK
    public internal(set) var dateTooltip : String = APIConstants.STRING_MOCK
    public internal(set) var mailMeta : ZCRMMailMetadata?
    public internal(set) var read : Bool = APIConstants.BOOL_MOCK
    public internal(set) var record : ZCRMRecordDelegate = RECORD_MOCK
    public internal(set) var moduleAPIName : String = APIConstants.STRING_MOCK
    public internal(set) var auditedTime : String = APIConstants.STRING_MOCK
    public internal(set) var id : Int64 = APIConstants.INT64_MOCK
    public internal(set) var signal : ZCRMSignalDelegate = SIGNAL_MOCK
    
    init( id : Int64 )
    {
        self.id = id
    }
    
    public struct ZCRMMailMetadata : ZCRMEntity
    {
        public internal(set) var auditedTime : String = APIConstants.STRING_MOCK
        public internal(set) var mailType : String = APIConstants.STRING_MOCK
        public internal(set) var messageId : String = APIConstants.STRING_MOCK
        public internal(set) var subject : String = APIConstants.STRING_MOCK
        public internal(set) var dateTime : String?
        public internal(set) var massMailId : String?
    }
    
    public func markAsRead( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        let notificationIds : [Int64] = [self.id]
        NotificationAPIHandler().markNotificationsAsRead(recordId: nil, notificationIds: notificationIds) { ( result ) in
            completion( result )
        }
    }
}

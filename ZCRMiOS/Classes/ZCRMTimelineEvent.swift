//
//  ZCRMTimeline.swift
//  ZCRMiOS
//
//  Created by Umashri R on 26/09/18.
//

open class ZCRMTimeline : ZCRMEntity
{
    var automationType : String?
    var automationRule : String?
    var sourceName : String = APIConstants.STRING_MOCK
    var action : String
    var auditedTime : String = APIConstants.STRING_MOCK
    var doneBy : ZCRMUserDelegate = USER_MOCK
    var record : ZCRMRecordDelegate = RECORD_MOCK
    var relatedRecord : ZCRMRecordDelegate?
    var fieldHistory : [fieldHistory]?
    
    struct fieldHistory
    {
        var fieldLabel : String
        var id : Int64
        var oldValue : Any
        var newValue : Any
    }
    
    init( action : String, record : ZCRMRecordDelegate )
    {
        self.action = action
        self.record = record
    }
}

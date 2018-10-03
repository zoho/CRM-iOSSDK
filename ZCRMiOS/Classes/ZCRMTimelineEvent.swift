//
//  ZCRMTimelineEvent.swift
//  ZCRMiOS
//
//  Created by Umashri R on 03/10/18.
//

open class ZCRMTimelineEvent : ZCRMEntity
{
    var automationType : String?
    var automationRule : String?
    var sourceName : String = APIConstants.STRING_MOCK
    var action : String
    var auditedTime : String = APIConstants.STRING_MOCK
    var doneBy : ZCRMUserDelegate = USER_MOCK
    var record : ZCRMRecordDelegate = RECORD_MOCK
    var fieldHistory : [FieldHistory]?
    
    struct FieldHistory
    {
        var fieldLabel : String
        var id : Int64
        var oldValue : String?
        var newValue : String?
    }
    
    init( action : String, record : ZCRMRecordDelegate )
    {
        self.action = action
        self.record = record
    }
    
    func initFieldHistory( fieldLabel : String, id : Int64, old : String?, new : String? ) -> FieldHistory
    {
        let fieldHistory = FieldHistory(fieldLabel : fieldLabel, id : id, oldValue : old, newValue : new)
        return fieldHistory
    }
    
    func addFieldHistory( fieldLabel : String, id : Int64, old : String?, new : String? )
    {
        if self.fieldHistory != nil
        {
            self.fieldHistory = [FieldHistory]()
        }
        let fieldHistory = FieldHistory(fieldLabel : fieldLabel, id : id, oldValue : old, newValue : new)
        self.fieldHistory?.append(fieldHistory)
    }
}

//
//  ZCRMTimelineEvent.swift
//  ZCRMiOS
//
//  Created by Umashri R on 03/10/18.
//

open class ZCRMTimelineEvent : ZCRMEntity
{
    public internal( set ) var automationType : String?
    public internal( set ) var automationRule : String?
    public internal( set ) var source : String = APIConstants.STRING_MOCK
    public internal( set ) var action : String
    public internal( set ) var auditedTime : String = APIConstants.STRING_MOCK
    public internal( set ) var doneBy : ZCRMUserDelegate = USER_MOCK
    public internal( set ) var record : ZCRMRecordDelegate = RECORD_MOCK
    public internal( set ) var fieldHistory : [FieldHistory]?
    
    public struct FieldHistory : Equatable
    {
        public var fieldLabel : String
        public var id : Int64
        public var oldValue : String?
        public var newValue : String?
        
        public static func == (lhs: ZCRMTimelineEvent.FieldHistory, rhs: ZCRMTimelineEvent.FieldHistory) -> Bool {
            let equals : Bool = lhs.fieldLabel == rhs.fieldLabel &&
                lhs.id == rhs.id &&
                lhs.oldValue == rhs.oldValue &&
                lhs.newValue == rhs.newValue
            return equals
        }
    }
    
    internal init( action : String, record : ZCRMRecordDelegate )
    {
        self.action = action
        self.record = record
    }
    
    internal func addFieldHistory( fieldLabel : String, id : Int64, old : String?, new : String? )
    {
        if self.fieldHistory == nil
        {
            self.fieldHistory = [FieldHistory]()
        }
        let fieldHistory = FieldHistory(fieldLabel : fieldLabel, id : id, oldValue : old, newValue : new)
        self.fieldHistory?.append(fieldHistory)
    }
}

extension ZCRMTimelineEvent : Equatable
{
    public static func == (lhs: ZCRMTimelineEvent, rhs: ZCRMTimelineEvent) -> Bool {
        let equals : Bool = lhs.automationType == rhs.automationType &&
            lhs.automationRule == rhs.automationRule &&
            lhs.source == rhs.source &&
            lhs.action == rhs.action &&
            lhs.auditedTime == rhs.auditedTime &&
            lhs.doneBy == rhs.doneBy &&
            lhs.record == rhs.record &&
            lhs.fieldHistory == rhs.fieldHistory
        return equals
    }
}

//
//  ZCRMSignalDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 01/11/18.
//
open class ZCRMSignalDelegate : ZCRMEntity
{
    public internal(set) var id : Int64 = APIConstants.INT64_MOCK
    public internal(set) var type : Int = APIConstants.INT_MOCK
    public internal(set) var namespace : String = APIConstants.STRING_MOCK
    public internal(set) var displayLabel : String?
    public internal(set) var fileId: String?
    public internal(set) var sandBoxZgId: String?
    
    internal init( id : Int64 )
    {
        self.id = id
    }
}

extension ZCRMSignalDelegate : Equatable
{
    public static func == (lhs: ZCRMSignalDelegate, rhs: ZCRMSignalDelegate) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.type == rhs.type &&
            lhs.namespace == rhs.namespace &&
            lhs.fileId == rhs.fileId &&
            lhs.sandBoxZgId == rhs.sandBoxZgId
        return equals
    }
}

var SIGNAL_MOCK : ZCRMSignalDelegate = ZCRMSignalDelegate(id: APIConstants.INT64_MOCK)

//
//  ZCRMSignal.swift
//  ZCRMiOS
//
//  Created by Umashri R on 01/11/18.
//
open class ZCRMSignal : ZCRMEntity
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

var SIGNAL_MOCK : ZCRMSignal = ZCRMSignal(id: APIConstants.INT64_MOCK)

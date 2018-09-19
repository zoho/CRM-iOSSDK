//
//  ZCRMDataProcessBasicDetails.swift
//  Pods-ZCRMiOS_Tests
//
//  Created by Boopathy P on 04/06/18.
//

import Foundation

open class ZCRMDataProcessBasicDetails
{
    public var consentProcessThroughList : [ String ]
    public var owner : ZCRMUserDelegate = USER_MOCK
    public var modifiedTime : String = APIConstants.STRING_MOCK
    public var modifiedBy : ZCRMUserDelegate = USER_MOCK
    public var createdTime : String = APIConstants.STRING_MOCK
    public var createdBy : ZCRMUserDelegate = USER_MOCK
    public var mailSentTime : String?
    public var dataProcessingBasis : String // Consent - obtained use enum for consent type
    public var id : Int64 = APIConstants.INT64_MOCK
    
    public var lawfulReason : String?
    public var consentDate : String?
    public var consentRemarks : String?
    public var consentEndsOn : String?
    public var consentThrough : String?
    
    public init( dataProcessingBasis : String, consentThrough : String, consentDate : String, consentProcessThroughList : [ String ] ) {
        self.dataProcessingBasis = dataProcessingBasis
        self.consentThrough = consentThrough
        self.consentDate = consentDate
        self.consentProcessThroughList = consentProcessThroughList
    }
    
    internal init( id : Int64, dataProcessingBasis : String, consentThrough : String, consentDate : String, consentProcessThroughList : [ String ] )
    {
        self.id = id
        self.dataProcessingBasis = dataProcessingBasis
        self.consentThrough = consentThrough
        self.consentDate = consentDate
        self.consentProcessThroughList = consentProcessThroughList
    }
}

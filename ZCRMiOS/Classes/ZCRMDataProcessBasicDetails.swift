//
//  ZCRMDataProcessBasicDetails.swift
//  Pods-ZCRMiOS_Tests
//
//  Created by Boopathy P on 04/06/18.
//

import Foundation

open class ZCRMDataProcessBasicDetails
{
    var consentProcessThroughList : [ String ]
    var owner : ZCRMUserDelegate = USER_MOCK
    var modifiedTime : String = APIConstants.STRING_MOCK
    var modifiedBy : ZCRMUserDelegate = USER_MOCK
    var createdTime : String = APIConstants.STRING_MOCK
    var createdBy : ZCRMUserDelegate = USER_MOCK
    var lawfulReason : String?
    var mailSentTime : String?
    var consentDate : String
    var id : Int64 = APIConstants.INT64_MOCK
    var consentRemarks : String?
    var consentEndsOn : String?
    var consentThrough : String
    var dataProcessingBasis : String // Consent - obtained use enum for consent type
    
    init( dataProcessingBasis : String, consentThrough : String, consentDate : String, consentProcessThroughList : [ String ] ) {
        self.dataProcessingBasis = dataProcessingBasis
        self.consentThrough = consentThrough
        self.consentDate = consentDate
        self.consentProcessThroughList = consentProcessThroughList
    }
    
    public init( id : Int64, dataProcessingBasis : String, consentThrough : String, consentDate : String, consentProcessThroughList : [ String ] )
    {
        self.id = id
        self.dataProcessingBasis = dataProcessingBasis
        self.consentThrough = consentThrough
        self.consentDate = consentDate
        self.consentProcessThroughList = consentProcessThroughList
    }
}

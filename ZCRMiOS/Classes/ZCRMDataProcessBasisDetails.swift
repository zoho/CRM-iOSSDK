//
//  ZCRMDataProcessBasisDetails.swift
//  Pods-ZCRMiOS_Tests
//
//  Created by Boopathy P on 04/06/18.
//

import Foundation

open class ZCRMDataProcessBasisDetails
{
    public var consentProcessThrough : [ String ]
    public var owner : ZCRMUserDelegate = USER_MOCK
    public internal( set ) var modifiedTime : String = APIConstants.STRING_MOCK
    public internal( set ) var modifiedBy : ZCRMUserDelegate = USER_MOCK
    public internal( set ) var createdTime : String = APIConstants.STRING_MOCK
    public internal( set ) var createdBy : ZCRMUserDelegate = USER_MOCK
    public var mailSentTime : String?
    public var dataProcessingBasis : String // Consent - obtained use enum for consent type
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    
    public var lawfulReason : String?
    public var consentDate : String?
    public var consentRemarks : String?
    public var consentEndsOn : String?
    public var consentThrough : String?
    
    public init( dataProcessingBasis : String, consentProcessThrough : [ String ] ) {
        self.dataProcessingBasis = dataProcessingBasis
        self.consentProcessThrough = consentProcessThrough
    }
    
    internal init( id : Int64, dataProcessingBasis : String, consentProcessThrough : [ String ] )
    {
        self.id = id
        self.dataProcessingBasis = dataProcessingBasis
        self.consentProcessThrough = consentProcessThrough
    }
}

extension ZCRMDataProcessBasisDetails : Equatable
{
    public static func == (lhs: ZCRMDataProcessBasisDetails, rhs: ZCRMDataProcessBasisDetails) -> Bool {
        let equals : Bool = lhs.consentProcessThrough == rhs.consentProcessThrough &&
            lhs.owner == rhs.owner &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.modifiedBy == rhs.modifiedBy &&
            lhs.createdTime == rhs.createdTime &&
            lhs.createdBy == rhs.createdBy &&
            lhs.mailSentTime == rhs.mailSentTime &&
            lhs.dataProcessingBasis == rhs.dataProcessingBasis &&
            lhs.id == rhs.id &&
            lhs.lawfulReason == rhs.lawfulReason &&
            lhs.consentDate == rhs.consentDate &&
            lhs.consentRemarks == rhs.consentRemarks &&
            lhs.consentEndsOn == rhs.consentEndsOn &&
            lhs.consentThrough == rhs.consentThrough
        return equals
    }
}

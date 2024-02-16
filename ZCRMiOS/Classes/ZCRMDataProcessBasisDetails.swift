//
//  ZCRMDataProcessBasisDetails.swift
//  Pods-ZCRMiOS_Tests
//
//  Created by Boopathy P on 04/06/18.
//

import Foundation

open class ZCRMDataProcessBasisDetails : ZCRMEntity
{
    public var communicationPreferences : [ ZCRMCommunicationPreferences ]?
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
    
    func copy() -> ZCRMDataProcessBasisDetails
    {
        let copyObj = ZCRMDataProcessBasisDetails(id: id, dataProcessingBasis: dataProcessingBasis, communicationPreferences: communicationPreferences)
        copyObj.owner = owner.copy()
        copyObj.modifiedTime = modifiedTime
        copyObj.modifiedBy = modifiedBy
        copyObj.createdTime = createdTime
        copyObj.createdBy = createdBy
        copyObj.mailSentTime = mailSentTime
        copyObj.lawfulReason = lawfulReason
        copyObj.consentDate = consentDate
        copyObj.consentRemarks = consentRemarks
        copyObj.consentEndsOn = consentEndsOn
        copyObj.consentThrough = consentThrough
        return copyObj
    }
    
    public init( dataProcessingBasis : String) {
        self.dataProcessingBasis = dataProcessingBasis
    }
    
    internal init( id : Int64, dataProcessingBasis : String, communicationPreferences : [ ZCRMCommunicationPreferences ]? )
    {
        self.id = id
        self.dataProcessingBasis = dataProcessingBasis
        self.communicationPreferences = communicationPreferences
    }
}

extension ZCRMDataProcessBasisDetails : Hashable
{
    public static func == (lhs: ZCRMDataProcessBasisDetails, rhs: ZCRMDataProcessBasisDetails) -> Bool {
        let equals : Bool = lhs.communicationPreferences == rhs.communicationPreferences &&
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
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

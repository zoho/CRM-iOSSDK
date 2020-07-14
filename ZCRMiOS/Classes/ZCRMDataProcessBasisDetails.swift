//
//  ZCRMDataProcessBasisDetails.swift
//  Pods-ZCRMiOS_Tests
//
//  Created by Boopathy P on 04/06/18.
//

import Foundation

open class ZCRMDataProcessBasisDetails : ZCRMEntity
{
    public var communicationPreferences : [ CommunicationPreferences ]?
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
    public internal( set ) var consentThrough : ConsentThrough.Readable?
    
    public init( dataProcessingBasis : String) {
        self.dataProcessingBasis = dataProcessingBasis
    }
    
    internal init( id : Int64, dataProcessingBasis : String, communicationPreferences : [ CommunicationPreferences ]? )
    {
        self.id = id
        self.dataProcessingBasis = dataProcessingBasis
        self.communicationPreferences = communicationPreferences
    }
    
    public func setConsentThrough(_ consentThrough : ConsentThrough.Writable)
    {
        self.consentThrough = consentThrough.toReadable()
    }
    
    internal func parseConsentFromAPI(consentAPIString : String) throws -> ConsentThrough.Readable?
    {
        guard let consent = ConsentThrough.Readable(rawValue: consentAPIString) else {
            ZCRMLogger.logError(message: "New consent type encountered in API - \( consentAPIString )")
            throw ZCRMError.sdkError(code: ErrorCode.unhandled, message: "New consent type encountered in API - \( consentAPIString )", details: nil)
        }
        return consent
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

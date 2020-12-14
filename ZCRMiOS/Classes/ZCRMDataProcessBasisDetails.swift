//
//  ZCRMDataProcessBasisDetails.swift
//  Pods-ZCRMiOS_Tests
//
//  Created by Boopathy P on 04/06/18.
//

import Foundation

open class ZCRMDataProcessBasisDetails : ZCRMEntity, Codable
{
    enum CodingKeys: String, CodingKey
    {
        case communicationPreferences
        case owner
        case modifiedTime
        case modifiedBy
        case createdTime
        case createdBy
        case mailSentTime
        case dataProcessingBasis
        case id
        case lawfulReason
        case consentDate
        case consentRemarks
        case consentEndsOn
        case consentThrough
    }
    required public init(from decoder: Decoder) throws {
        
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        
        communicationPreferences = try! values.decode([ CommunicationPreferences ].self, forKey: .communicationPreferences)
        owner = try! values.decode(ZCRMUserDelegate.self, forKey: .owner)
        modifiedTime = try! values.decode(String.self, forKey: .modifiedTime)
        modifiedBy = try! values.decode(ZCRMUserDelegate.self, forKey: .modifiedBy)
        createdTime = try! values.decode(String.self, forKey: .createdTime)
        createdBy = try! values.decode(ZCRMUserDelegate.self, forKey: .createdBy)
        mailSentTime = try! values.decodeIfPresent(String.self, forKey: .mailSentTime)
        dataProcessingBasis = try! values.decode(String.self, forKey: .dataProcessingBasis)
        id = try! values.decode(Int64.self, forKey: .id)
        lawfulReason = try! values.decodeIfPresent(String.self, forKey: .lawfulReason)
        consentDate = try! values.decodeIfPresent(String.self, forKey: .consentDate)
        consentRemarks = try! values.decodeIfPresent(String.self, forKey: .consentRemarks)
        consentEndsOn = try! values.decodeIfPresent(String.self, forKey: .consentEndsOn)
        consentThrough = try! values.decodeIfPresent(ConsentThrough.Readable.self, forKey: .consentThrough)
    }
    open func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        
        try container.encode( self.communicationPreferences, forKey : CodingKeys.communicationPreferences )
        try container.encode( self.owner, forKey : CodingKeys.owner )
        try container.encode( self.modifiedTime, forKey : CodingKeys.modifiedTime )
        try container.encode( self.modifiedBy, forKey : CodingKeys.modifiedBy )
        try container.encode( self.createdTime, forKey : CodingKeys.createdTime )
        try container.encode( self.createdBy, forKey : CodingKeys.createdBy )
        try container.encodeIfPresent( self.mailSentTime, forKey : CodingKeys.mailSentTime )
        try container.encode( self.dataProcessingBasis, forKey : CodingKeys.dataProcessingBasis )
        try container.encode( self.id, forKey : CodingKeys.id )
        try container.encodeIfPresent( self.lawfulReason, forKey : CodingKeys.lawfulReason )
        try container.encodeIfPresent( self.consentDate, forKey : CodingKeys.consentDate )
        try container.encodeIfPresent( self.consentRemarks, forKey : CodingKeys.consentRemarks )
        try container.encodeIfPresent( self.consentEndsOn, forKey : CodingKeys.consentEndsOn )
        try container.encodeIfPresent( self.consentThrough, forKey : CodingKeys.consentThrough )
    }
    
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

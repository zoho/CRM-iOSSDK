//
//  ZCRMDataProcessBasicDetails.swift
//  Pods-ZCRMiOS_Tests
//
//  Created by Boopathy P on 04/06/18.
//

import Foundation

public class ZCRMDataProcessBasicDetails
{
    private var consentProcessThroughList : [ String ]?
    private var owner : ZCRMUser?
    private var modifiedTime : String?
    private var modifiedBy : ZCRMUser?
    private var createdTime : String?
    private var createdBy : ZCRMUser?
    private var lawfulReason : String?
    private var mailSentTime : String?
    private var consentDate : String?
    private var id : Int64?
    private var consentRemarks : String?
    private var consentEndsOn : String?
    private var consentThrough : String?
    private var dataProcessingBasis : String? // Consent - obtained use enum for consent type
    
    public init() {}
    
    public init( id : Int64 )
    {
        self.id = id
    }
    
    internal func setId( id : Int64 )
    {
        self.id = id
    }
    
    public func getId() -> Int64?
    {
        return self.id
    }
    
    internal func setOwner( owner : ZCRMUser )
    {
        self.owner = owner
    }
    
    public func getOwner() -> ZCRMUser
    {
        return self.owner!
    }
    
    internal func setDataProcessingBasis( dataProcessingBasis : String )
    {
        self.dataProcessingBasis = dataProcessingBasis
    }
    
    public func getDataProcessingBasis() -> String?
    {
        return self.dataProcessingBasis
    }
    
    public func addConsentProcessThrough( consentProcessThrough : ConsentProcessThrough )
    {
        if( self.consentProcessThroughList?.isEmpty == true )
        {
            self.consentProcessThroughList = [ String ]()
        }
        self.consentProcessThroughList?.append( consentProcessThrough.rawValue )
    }
    
    public func setConsentProcessThroughList( list : [ String ] )
    {
        self.consentProcessThroughList = list
    }
    
    public func getConsentProcessThroughList() -> [ String ]?
    {
        return self.consentProcessThroughList
    }
    
    internal func setConsentThrough( consentThrough : String? )
    {
        self.consentThrough = consentThrough
    }
    
    public func getConsentThrough() -> String?
    {
        return self.consentThrough
    }
    
    internal func setConsentEndsOn( endsOn : String? )
    {
        self.consentEndsOn = endsOn
    }
    
    public func getConsentEndsOn() -> String?
    {
        return self.consentEndsOn
    }
    
    internal func setConsentDate( date : String? )
    {
        self.consentDate = date
    }
    
    public func getConsentDate() -> String?
    {
        return self.consentDate
    }
    
    internal func setConsentRemarks( remarks : String? )
    {
        self.consentRemarks = remarks
    }
    
    public func getConsentRemarks() -> String?
    {
        return self.consentThrough
    }
    
    internal func setLawfulReason( lawfulReason : String? )
    {
        self.lawfulReason = lawfulReason
    }
    
    public func getLawfulReason() -> String?
    {
        return self.lawfulReason
    }
    
    internal func setMailSentTime( mailSentTime : String? )
    {
        self.mailSentTime = mailSentTime
    }
    
    public func getMailSentTime() -> String?
    {
        return self.mailSentTime
    }
    
    internal func setCreatedBy( createdBy : ZCRMUser )
    {
        self.createdBy = createdBy
    }
    
    public func getCreatedBy() -> ZCRMUser?
    {
        return self.createdBy
    }
    
    internal func setCreatedTime( createdTime : String )
    {
        self.createdTime = createdTime
    }
    
    public func getCreatedTime() -> String?
    {
        return self.createdTime
    }
    
    internal func setModifiedBy( modifiedBy : ZCRMUser )
    {
        self.modifiedBy = modifiedBy
    }
    
    public func getModifiedBy() -> ZCRMUser?
    {
        return self.modifiedBy
    }
    
    internal func setModifiedTime( modifiedTime : String )
    {
        self.modifiedTime = modifiedTime
    }
    
    public func getModifiedTime() -> String?
    {
        return self.modifiedTime
    }
    
}

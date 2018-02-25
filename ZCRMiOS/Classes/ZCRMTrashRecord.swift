//
//  ZCRMTrashRecord.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 20/06/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class ZCRMTrashRecord : ZCRMEntity
{
    private var entityId : Int64?
    private var type : String
    private var displayName : String?
    private var deletedTime : String?
    private var deletedBy : ZCRMUser?
    private var createdBy : ZCRMUser?
    
    public init( type : String )
    {
        self.type = type
    }
    
    public init( type : String, entityId : Int64 )
    {
        self.entityId = entityId
        self.type = type
    }
    
    
    /// returns the type of the deleted record
    ///
    /// - Returns: type of the deleted record
    public func getType() -> String
    {
        return self.type
    }
    
    /// set the Entity Id of the trash record
    ///
    /// - Parameter id: Entity Id of the trash record
    internal func setEntityId( id : Int64? )
    {
        self.entityId = id
    }
    
    
    /// returns the Entity Id of the trash record
    ///
    /// - Returns: Entity Id of the trash record
    public func getEntityId() -> Int64
    {
        return self.entityId!
    }
    
    
    /// set the display name of the trash record
    ///
    /// - Parameter name: display name
    internal func setDisplayName( name : String? )
    {
        self.displayName = name
    }
    
    
    /// returns the display name of the trash record
    ///
    /// - Returns: display name
    public func getDisplayName() -> String
    {
        return self.displayName!
    }
    
    
    /// set the deleted time of the trash record
    ///
    /// - Parameter time: deleted time
    internal func setDeletedTime( time : String? )
    {
        self.deletedTime = time
    }
    
    
    /// returns the deleted time of the trash record
    ///
    /// - Returns: deleted time
    public func getDeletedTime() -> String
    {
        return self.deletedTime!
    }
    
    
    /// set ZCRMUser who created the record
    ///
    /// - Parameter createdBy: ZCRMUser who created the record
    internal func setCreatedBy( createdBy : ZCRMUser? )
    {
        self.createdBy = createdBy
    }
    
    
    /// returns ZCRMUser who created the record
    ///
    /// - Returns: ZCRMUser who created the record
    public func getCreatedBy() -> ZCRMUser
    {
        return self.createdBy!
    }
    
    /// set ZCRMUser who deleted the record
    ///
    /// - Parameter createdBy: ZCRMUser who deleted the record
    internal func setDeletedBy( deletedBy : ZCRMUser? )
    {
        self.deletedBy = deletedBy
    }
    
    /// returns ZCRMUser who deleted the record
    ///
    /// - Returns: ZCRMUser who deleted the record
    public func getdeletedBy() -> ZCRMUser
    {
        return self.deletedBy!
    }
}

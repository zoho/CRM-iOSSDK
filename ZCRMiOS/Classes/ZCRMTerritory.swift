//
//  ZCRMTerritory.swift
//  ZCRMiOS
//
//  Created by gowtham-pt2177 on 30/06/20.
//

import Foundation

open class ZCRMTerritory : ZCRMEntity
{
    public var id : Int64 = APIConstants.INT64_MOCK
    public var name : String
    public internal( set ) var createdTime : String = APIConstants.STRING_MOCK
    public internal( set ) var modifiedTime : String = APIConstants.STRING_MOCK
    public internal( set ) var manager : ZCRMUserDelegate?
    public internal( set ) var parentId : Int64?
    public internal( set ) var criteria : ZCRMQuery.ZCRMCriteria?
    public var modifiedBy : ZCRMUserDelegate = USER_MOCK
    public var createdBy : ZCRMUserDelegate = USER_MOCK
    public internal( set ) var description : String?
    public internal( set ) var permissionType : AccessPermission.Readable?
    
    internal init( _ name : String )
    {
        self.name = name
    }
}

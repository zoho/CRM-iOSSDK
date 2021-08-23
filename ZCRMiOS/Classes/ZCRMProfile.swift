//
//  ZCRMProfile.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMProfile : ZCRMProfileDelegate
{
    public internal( set ) var category : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var description : String?
    public internal( set ) var modifiedBy : ZCRMUserDelegate?
    public internal( set ) var createdBy : ZCRMUserDelegate?
    public internal( set ) var modifiedTime : String?
    public internal( set ) var createdTime : String?
    public internal( set ) var displayName : String = APIConstants.STRING_MOCK
    public internal( set ) var permissionSections : [ PermissionSection ]?
    
    internal init( name : String )
    {
        super.init( id : APIConstants.INT64_MOCK, name : name )
    }
    
    public struct Permission : Equatable
    {
        public internal( set ) var displayName : String
        public internal( set ) var name : String
        public internal( set ) var isEnabled : Bool
        public internal( set ) var id : Int64?
        public internal( set ) var moduleAPIName : String?
    }
    
    public struct PermissionSection : Equatable
    {
        public internal( set ) var name : String
        public internal( set ) var categories : [ Category ]
        
        public struct Category : Equatable
        {
            public internal( set ) var displayName : String
            public internal( set ) var permissions : [ Permission ]
            public internal( set ) var name : String
            public internal( set ) var moduleAPIName : String?
        }
    }
    
    public func getPermissionCategory( name : String ) -> ZCRMProfile.PermissionSection.Category?
    {
        if let sections = self.permissionSections
        {
            for section in sections
            {
                for category in section.categories
                {
                    if category.name == name
                    {
                        return category
                    }
                }
            }
        }
        return nil
    }
    
    public func getPermission( name : String ) -> ZCRMProfile.Permission?
    {
        if let sections = self.permissionSections
        {
            for section in sections
            {
                for category in section.categories
                {
                    for permissionDetail in category.permissions
                    {
                        if permissionDetail.name == name
                        {
                            return permissionDetail
                        }
                    }
                }
            }
        }
        return nil
    }
    
    public func isPermissionEnabled( name : String ) throws -> Bool
    {
        guard let permission = getPermission(name: name) else
        {
            ZCRMLogger.logError(message: "Failed to get the permission detail by it's name")
            throw ZCRMError.processingError( code : ErrorCode.invalidData, message : "Failed to get the permission detail by it's name", details : nil )
        }
        return permission.isEnabled
    }
}

extension ZCRMProfile
{
    public static func == (lhs: ZCRMProfile, rhs: ZCRMProfile) -> Bool {
        let equals : Bool = lhs.category == rhs.category &&
            lhs.description == rhs.description &&
            lhs.modifiedBy == rhs.modifiedBy &&
            lhs.createdBy == rhs.createdBy &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.createdTime == rhs.createdTime &&
            lhs.displayName == rhs.displayName &&
            lhs.permissionSections == rhs.permissionSections
        return equals
    }
}

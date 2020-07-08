//
//  ZCRMLayout.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMLayout : ZCRMLayoutDelegate
{
    public internal( set ) var createdBy : ZCRMUserDelegate?
    public internal( set ) var createdTime : String?
    public internal( set ) var modifiedBy : ZCRMUserDelegate?
    public internal( set ) var modifiedTime : String?
    public internal( set ) var isVisible : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var status : Int = APIConstants.INT_MOCK
    public internal( set ) var sections : [ ZCRMSection ] = [ ZCRMSection ]()
    public internal( set ) var accessibleProfiles : [ ZCRMProfileDelegate ] = [ ZCRMProfileDelegate ]()
    
    init( name : String )
    {
        super.init( id : APIConstants.INT64_MOCK, name : name )
    }
    
    /// Add ZCRMSection to the ZCRMLayout.
    ///
    /// - Parameter section: ZCRMSection to be added
    internal func addSection(section : ZCRMSection)
    {
        self.sections.append(section)
    }
}

extension ZCRMLayout
{
    public static func == (lhs: ZCRMLayout, rhs: ZCRMLayout) -> Bool {
        let equals : Bool = lhs.createdBy == rhs.createdBy &&
            lhs.createdTime == rhs.createdTime &&
            lhs.modifiedBy == rhs.modifiedBy &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.isVisible == rhs.isVisible &&
            lhs.status == rhs.status &&
            lhs.sections == rhs.sections &&
            lhs.accessibleProfiles == rhs.accessibleProfiles
        return equals
    }
}

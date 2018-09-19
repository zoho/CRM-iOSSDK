//
//  ZCRMLayout.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMLayout : ZCRMLayoutDelegate
{
    public var name : String
    public var createdBy : ZCRMUserDelegate = USER_MOCK
    public var createdTime : String = APIConstants.STRING_MOCK
    public var modifiedBy : ZCRMUserDelegate = USER_MOCK
    public var modifiedTime : String = APIConstants.STRING_MOCK
    public var visible : Bool = APIConstants.BOOL_MOCK
    public var status : Int = APIConstants.INT_MOCK
    public var sections : [ZCRMSection]?
    public var accessibleProfiles : [ZCRMProfileDelegate]?
	
    init( name : String )
    {
        self.name = name
        super.init( layoutId : APIConstants.INT64_MOCK, layoutName : self.name )
    }
	
    /// Add ZCRMSection to the ZCRMLayout.
    ///
    /// - Parameter section: ZCRMSection to be added
	internal func addSection(section : ZCRMSection)
	{
        if self.sections == nil
        {
            self.sections = [ ZCRMSection ]()
        }
        self.sections?.append(section)
	}
	
    /// Set list ZCRMSections of the ZCRMLayout
    ///
    /// - Parameter allSections: list of ZCRMSection
	internal func setSections(allSections : [ZCRMSection])
	{
		self.sections = allSections
	}
	
    /// Add ZCRMProfile access to the ZCRMLayout
    ///
    /// - Parameter profile: ZCRMProfile to be added
	internal func addAccessibleProfile(profile : ZCRMProfileDelegate)
	{
        if self.accessibleProfiles == nil
        {
            self.accessibleProfiles = [ ZCRMProfileDelegate ]()
        }
        self.accessibleProfiles?.append(profile)
	}
}

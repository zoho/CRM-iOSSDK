//
//  ZCRMLayout.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMLayout : ZCRMLayoutDelegate
{
    var createdBy : ZCRMUserDelegate = USER_NIL
    var createdTime : String = STRING_NIL
    var modifiedBy : ZCRMUserDelegate = USER_NIL
    var modifiedTime : String = STRING_NIL
    var visible : Bool = BOOL_NIL
    var status : Int = INT_NIL
    var sections : [ZCRMSection] = [ZCRMSection]()
    var accessibleProfiles : [ZCRMProfileDelegate] = [ZCRMProfileDelegate]()
	
    /// Initialise the instance of ZCRMLayout with the given layout Id.
    ///
    /// - Parameter layoutId: layout Id whose associated layout is to be initialised
//    init(layoutId : Int64) {
//        self.id = layoutId
//    }
    
    init( layoutName : String )
    {
        super.init(layoutId: INT64_NIL, layoutName: layoutName)
    }
	
    /// Add ZCRMSection to the ZCRMLayout.
    ///
    /// - Parameter section: ZCRMSection to be added
	internal func addSection(section : ZCRMSection)
	{
        if( self.sections != nil )
        {
            self.sections.append(section)
        }
        else
        {
            self.sections = [ section ]
        }
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
        if self.accessibleProfiles != nil
        {
            self.accessibleProfiles.append(profile)
        }
        else
        {
            self.accessibleProfiles = [ profile ]
        }
	}
}

//
//  ZCRMLayout.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMLayout : ZCRMEntity
{
	private var id : Int64
	private var name : String?
	private var createdBy : ZCRMUser?
	private var createdTime : String?
	private var modifiedBy : ZCRMUser?
	private var modifiedTime : String?
	private var visible : Bool?
	private var status : Int?
	private var sections : [ZCRMSection]?
	private var accessibleProfiles : [ZCRMProfile]?
	
    /// Initialise the instance of ZCRMLayout with the given layout Id.
    ///
    /// - Parameter layoutId: layout Id whose associated layout is to be initialised
	init(layoutId : Int64) {
		self.id = layoutId
	}
	
    /// Returns the layout Id.
    ///
    /// - Returns: the layout Id.
	public func getId() -> Int64
	{
		return self.id
	}
	
    /// Set the name of the ZCRMLayout
    ///
    /// - Parameter name: ZCRMLayout's name
	internal func setName(name : String?)
	{
		self.name = name
	}
	
    /// Returns ZCRMLayout's name
    ///
    /// - Returns: ZCRMLayout's name
	public func getName() -> String?
	{
		return self.name
	}
	
    /// Set the ZCRMUser who created the ZCRMLayout
    ///
    /// - Parameter createdByUser: ZCRMUser who created the ZCRMLayout
	internal func setCreatedBy(createdByUser : ZCRMUser?)
	{
		self.createdBy = createdByUser
	}
	
    /// Returns the ZCRMUser who created the ZCRMLayout
    ///
    /// - Returns: ZCRMUser who created the ZCRMLayout
	public func getCreatedBy() -> ZCRMUser?
	{
		return self.createdBy
	}
	
    /// Set created time of the ZCRMLayout
    ///
    /// - Parameter createdTime: the time at which the layout is created
	internal func setCreatedTime(createdTime : String?)
	{
		self.createdTime = createdTime
	}
	
    /// Returns the created time of the ZCRMLayout
    ///
    /// - Returns: the time at which the ZCRMLayout is created
	public func getCreatedTime() -> String?
	{
		return self.createdTime
	}
	
    /// Set the ZCRMUser who recently modified the ZCRMLayout(last modification of the ZCRMLayout)
    ///
    /// - Parameter modifiedByUser: ZCRMUser who modified the ZCRMLayout
	internal func setModifiedBy(modifiedByUser : ZCRMUser?)
	{
		self.modifiedBy = modifiedByUser
	}
	
    /// Returns the ZCRMUser who recently modified the ZCRMLayout(last modification of the ZCRMLayout)
    ///
    /// - Returns: ZCRMUser who modified the ZCRMLayout
	public func getModifiedBy() -> ZCRMUser?
	{
		return self.modifiedBy
	}
	
    /// Set modified time of the ZCRMLayout(last modification of the ZCRMLayout).
    ///
    /// - Parameter modifiedTime: the time at which the layout is modified
	internal func setModifiedTime(modifiedTime : String?)
	{
		self.modifiedTime = modifiedTime
	}
	
    /// Returns the modified time of the ZCRMLayout(last modification of the ZCRMLayout).
    ///
    /// - Returns: the time at which the layout is modified
	public func getModifiedTime() -> String?
	{
		return self.modifiedTime
	}
	
    /// Set true if the ZCRMLayout is visible.
    ///
    /// - Parameter isVisible: true if the ZCRMLayout is visible
	internal func setVisibility(isVisible : Bool?)
	{
		self.visible = isVisible
	}
	
    /// Returns true if the ZCRMLayout is visible
    ///
    /// - Returns: true if the ZCRMLayout is visible
	public func isVisible() -> Bool?
	{
		return self.visible
	}
	
    /// Set the status of the ZCRMLayout, It can be 1 if it is customized ZCRMLayout or else 0.
    ///
    /// - Parameter status: ZCRMLayout's status
	internal func setStatus(status : Int?)
	{
		self.status = status
	}
	
    /// Returns the status of the ZCRMLayout, It can be 1 if it is customized ZCRMLayout or else 0.
    ///
    /// - Returns: ZCRMLayout's status
	public func getStatus() -> Int?
	{
		return self.status
	}
	
    /// Add ZCRMSection to the ZCRMLayout.
    ///
    /// - Parameter section: ZCRMSection to be added
	internal func addSection(section : ZCRMSection)
	{
        if( self.sections != nil )
        {
            self.sections?.append(section)
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
	
    /// Returns all the ZCRMSections of the ZCRMLayout
    ///
    /// - Returns: all the ZCRMSections of the ZCRMLayout
	public func getAllSections() -> [ZCRMSection]?
	{
		return self.sections
	}
	
    /// Add ZCRMProfile access to the ZCRMLayout
    ///
    /// - Parameter profile: ZCRMProfile to be added
	internal func addAccessibleProfile(profile : ZCRMProfile)
	{
        if self.accessibleProfiles != nil
        {
            self.accessibleProfiles?.append(profile)
        }
        else
        {
            self.accessibleProfiles = [ profile ]
        }
	}
	
    /// Returns all ZCRMProfiles who are all having access to the ZCRMLayout
    ///
    /// - Returns: all accessible ZCRMProfile of the ZCRMLayout
	public func getAccessibleProfiles() -> [ZCRMProfile]?
	{
		return self.accessibleProfiles
	}

	
}

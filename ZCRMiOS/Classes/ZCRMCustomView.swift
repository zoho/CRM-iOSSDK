//
//  ZCRMCustomView.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 17/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMCustomView : ZCRMCustomViewDelegate
{
    public var sysName : String = APIConstants.STRING_MOCK
    public var cvName : String
    public var displayName : String = APIConstants.STRING_MOCK
	public var isDefault : Bool = APIConstants.BOOL_MOCK
    public var fields : [String] = [String]()
    public var favouriteSequence : Int = APIConstants.INT_MOCK
    public var sortByCol : String?
    public var sortOrder : SortOrder?
    public var category : String = APIConstants.STRING_MOCK
    
    public var isOffline : Bool = APIConstants.BOOL_MOCK
    public var isSystemDefined : Bool = APIConstants.BOOL_MOCK
	
    /// Initialise the instance of a custom view with the given custom view Id.
    ///
    /// - Parameters:
    ///   - cvName: custom view Name whose associated custom view is to be initialised
    ///   - moduleAPIName: module API name of a custom view is to be initialised
    init ( cvName : String, moduleAPIName : String )
    {
        self.cvName = cvName
        super.init( cvId : APIConstants.INT64_MOCK, moduleAPIName : moduleAPIName )
    }
}

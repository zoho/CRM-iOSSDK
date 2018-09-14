//
//  ZCRMCustomView.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 17/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMCustomView : ZCRMCustomViewDelegate
{
    var sysName : String = STRING_NIL
    var cvName : String
    var displayName : String = STRING_NIL
	var isDefault : Bool = BOOL_NIL
    var fields : [String] = [String]()
    var favouriteSequence : Int = INT_NIL
    var sortByCol : String?
    var sortOrder : SortOrder?
    var category : String = STRING_NIL
    
    var isOffline : Bool = BOOL_NIL
    var isSystemDefined : Bool = BOOL_NIL
	
    /// Initialise the instance of a custom view with the given custom view Id.
    ///
    /// - Parameters:
    ///   - cvName: custom view Name whose associated custom view is to be initialised
    ///   - moduleAPIName: module API name of a custom view is to be initialised
    init ( cvName : String, moduleAPIName : String )
    {
        super.init(cvId: INT64_NIL, moduleAPIName: moduleAPIName)
        self.cvName = cvName
    }
}

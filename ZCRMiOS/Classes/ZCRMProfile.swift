//
//  ZCRMProfile.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMProfile : ZCRMProfileDelegate
{
    var category : Bool = BOOL_NIL
    var description : String = STRING_NIL
    var modifiedBy : ZCRMUserDelegate = USER_NIL
    var createdBy : ZCRMUserDelegate = USER_NIL
    var modifiedTime : String = STRING_NIL
    var createdTime : String = STRING_NIL
	
	init(profileName : String)
	{
		super.init(profileId: INT64_NIL, profileName: profileName)
	}
}

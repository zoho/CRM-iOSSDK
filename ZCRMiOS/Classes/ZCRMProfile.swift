//
//  ZCRMProfile.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMProfile : ZCRMProfileDelegate
{
    var name : String
    public var category : Bool = APIConstants.BOOL_MOCK
    public var description : String  = APIConstants.STRING_MOCK
    public var modifiedBy : ZCRMUserDelegate = USER_MOCK
    public var createdBy : ZCRMUserDelegate = USER_MOCK
    public var modifiedTime : String  = APIConstants.STRING_MOCK
    public var createdTime : String  = APIConstants.STRING_MOCK
	
	init( name : String )
	{
        self.name = name
		super.init( profileId : APIConstants.INT64_MOCK, profileName : self.name )
	}
}

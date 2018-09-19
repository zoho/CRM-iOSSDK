//
//  ZCRMProfile.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMProfile : ZCRMProfileDelegate
{
    public var category : Bool = APIConstants.BOOL_MOCK
    public var description : String?
    public var modifiedBy : ZCRMUserDelegate?
    public var createdBy : ZCRMUserDelegate?
    public var modifiedTime : String?
    public var createdTime : String?
	
	internal init( name : String )
	{
		super.init( profileId : APIConstants.INT64_MOCK, profileName : name )
	}
}
